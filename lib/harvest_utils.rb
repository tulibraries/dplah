require "active-fedora"
require "open-uri"
require "fileutils"
require "oai"

module HarvestUtils
  extend ActionView::Helpers::TranslationHelper
  private

  config = YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__))
  @harvest_path = config['harvest_data_directory']
  @converted_path = config['converted_foxml_directory']
  @pid_prefix = config['pid_prefix']
  @partner = config['partner']
  @human_log_path = config['human_log_path']
  @noharvest_stopword = config['noharvest_stopword']
  @passthrough_url = config['passthrough_url']

  def harvest_action(provider)
    create_log_file(provider.name)
    harvest(provider)
    sleep(5)
    convert(provider)
    cleanup(provider)
    sleep(5)
    rec_count = ingest(provider)
    File.open(@log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.log_end') << "#{provider.name} " << I18n.t('oai_seed_logs.log_end_processed') << " #{rec_count}" << I18n.t('oai_seed_logs.text_buffer')
      end
    HarvestMailer.harvest_complete_email(provider, HarvestUtils.get_log_file).deliver
    rec_count
  end
  module_function :harvest_action

  def harvest_action_all(provider)
    seeds = Provider.where(:contributing_institution => "#{provider.contributing_institution}")
    seeds.each do |ci|
      harvest_action(ci)
    end
  end
  module_function :harvest_action_all

  def harvest_all()
    Provider.find_each(batch_size: 5) do |provider|
      harvest_action(provider)
    end
  end
  module_function :harvest_all


  def harvest(provider)
    File.open(@log_file, "a+") do |f|
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.log_begin') << I18n.t('oai_seed_logs.current_time') << Time.current.utc.iso8601 << I18n.t('oai_seed_logs.harvest_begin') << provider.name << I18n.t('oai_seed_logs.text_buffer')
    end
    num_files = 0
    transient_records = 0
    noharvest_records = 0
    client = OAI::Client.new provider.endpoint_url
    response = client.list_records
    set = provider.set ? provider.set : ""
    metadata_prefix = provider.metadata_prefix ? provider.metadata_prefix : "oai_dc"
    response = provider.set ? client.list_records(:metadata_prefix => metadata_prefix, :set => set) : client.list_records(:metadata_prefix => metadata_prefix)
    full_records = ''
    response.each do |record|
      unless record.header.identifier.include?("fedora-system")
        num_files += 1
        full_records, transient_records, noharvest_records = process_record_token(record, full_records,transient_records,noharvest_records)
        File.open(@log_file, "a+") do |f|
          f << "#{num_files} " << I18n.t('oai_seed_logs.records_count')
        end
      end
    end
    create_harvest_file(provider, full_records, num_files)
    `rake tmp:cache:clear`
    sleep(5)


    while(response.resumption_token and not response.resumption_token.empty?)
      full_records = ''
      File.open(@log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.resumption_token_detected') << I18n.t('oai_seed_logs.text_buffer')
      end
      token = response.resumption_token
      response = client.list_records :resumption_token => token if token
      response.each do |record|
        unless record.header.identifier.include?("fedora-system")
          num_files += 1
          full_records, transient_records, noharvest_records = process_record_token(record, full_records,transient_records,noharvest_records)
          File.open(@log_file, "a+") do |f|
            f << "#{num_files} " << I18n.t('oai_seed_logs.records_count')
          end
        end
      end
      create_harvest_file(provider, full_records, num_files)
      `rake tmp:cache:clear`
      sleep(5)
    end
    File.open(@log_file, "a+") do |f|
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.harvest_end') << "#{provider.name}" << I18n.t('oai_seed_logs.text_buffer') << "#{num_files} " << I18n.t('oai_seed_logs.records_count') << "#{transient_records} " << I18n.t('oai_seed_logs.transient_records_detected')  << "#{noharvest_records} " << I18n.t('oai_seed_logs.noharvest_records_detected') << I18n.t('oai_seed_logs.text_buffer')
    end
  end
  module_function :harvest

  def convert(provider)

      File.open(@log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.convert_begin') << I18n.t('oai_seed_logs.text_buffer')
      end

      xslt_file = provider.metadata_prefix == "oai_qdc" ? "oaiqdc_to_foxml" : "oai_to_foxml"

      xslt_path = Rails.root.join("lib", "tasks", "#{xslt_file}.xsl")
      u_files = Dir.glob("#{@harvest_path}/*").select { |fn| File.file?(fn) }
      File.open(@log_file, "a+") do |f|

        f << "#{u_files.length} "<< I18n.t('oai_seed_logs.convert_count')
      end
      u_files.length.times do |i|
        puts "Contents of #{u_files[i]} transformed"
        `xsltproc #{xslt_path} #{u_files[i]}`
        File.delete(u_files[i])
      end
  end
  module_function :convert

  def cleanup(provider)

    File.open(@log_file, "a+") do |f|
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.normalize_begin') << I18n.t('oai_seed_logs.text_buffer')
      end
    new_file = "#{Rails.root.join('tmp')}/xml_hold_file.xml"

    file_prefix = (provider.set) ? "#{provider.provider_id_prefix}_#{provider.set}" : "#{provider.provider_id_prefix}"
    file_prefix = file_prefix.gsub(/([\/:.-])/,"_").gsub(/\s+/, "")
    custom_file_prefixing(file_prefix, provider)

    xml_files = @converted_path ? Dir.glob(File.join(@converted_path, "file_#{file_prefix}*.xml")) : Dir.glob("spec/fixtures/fedora/file_#{file_prefix}*.xml")

    xml_files.each do |xml_file|

      xml_content = File.read(xml_file)
      doc = Nokogiri::XML(xml_content)

      normalize_global(doc, "//title")
      normalize_global(doc, "//creator")
      normalize_global(doc, "//subject")
      normalize_global(doc, "//description")
      normalize_global(doc, "//publisher")
      normalize_global(doc, "//contributor")
      normalize_global(doc, "//date")
      normalize_global(doc, "//type")
      normalize_global(doc, "//format")
      normalize_global(doc, "//source")
      normalize_global(doc, "//language")
      normalize_global(doc, "//relation")
      normalize_global(doc, "//coverage")
      normalize_global(doc, "//rights")

      normalize_facets(doc, "//subject")
      normalize_facets(doc, "//type")
      normalize_facets(doc, "//language")
      normalize_facets(doc, "//publisher")

      standardize_formats(doc, "//format")
      normalize_dates(doc, "//date")
      normalize_language(doc, "//language")
      dcmi_types(doc, "//type", provider)
      remove_fake_identifiers(doc, "//identifier")

      File.open(new_file, 'w') do |f|
          f.print(doc.to_xml)
          File.rename(new_file, xml_file)
          f.close
      end

      if provider.common_repository_type == "Passthrough Workflow"
        old_pid, new_pid = construct_si_pid(doc, "//identifier", @pid_prefix, provider.provider_id_prefix)
        replace_pid(xml_file, old_pid, new_pid)
      end

    end
    File.open(@log_file, "a+") do |f|
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.normalize_global')
      f << I18n.t('oai_seed_logs.normalize_facets')
      f << I18n.t('oai_seed_logs.standardize_formats')
      f << I18n.t('oai_seed_logs.normalize_dates')
      f << I18n.t('oai_seed_logs.normalize_language')
      f << I18n.t('oai_seed_logs.dcmi_types') if provider.dcmi_mappings
      f << I18n.t('oai_seed_logs.passthrough_workflow') if provider.common_repository_type == "Passthrough Workflow"
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.normalize_end') << I18n.t('oai_seed_logs.text_buffer')
    end
  end
  module_function :cleanup

  def ingest(provider)

    File.open(@log_file, "a+") do |f|
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.ingest_begin') << I18n.t('oai_seed_logs.text_buffer')
      end
    num_files = 1
    file_prefix = (provider.set) ? "#{provider.provider_id_prefix}_#{provider.set}" : "#{provider.provider_id_prefix}"
    file_prefix = file_prefix.gsub(/([\/:.-])/,"_").gsub(/\s+/, "")
    custom_file_prefixing(file_prefix, provider)

    contents = @converted_path ? Dir.glob(File.join(@converted_path, "file_#{file_prefix}*.xml")) : Dir.glob("spec/fixtures/fedora/file_#{file_prefix}*.xml")

    contents.each do |file|
      check_if_exists(file)
      pid = ActiveFedora::FixtureLoader.import_to_fedora(file)
      ActiveFedora::FixtureLoader.index(pid)
      obj = OaiRec.find(pid)
      thumbnail = ThumbnailUtils.define_thumbnail(obj, provider)
      obj.thumbnail = thumbnail
      obj.assign_rights
      obj.assign_contributing_institution
      build_identifier(obj, provider) unless provider.identifier_pattern.blank? || provider.identifier_pattern.empty?
      obj.reorg_identifiers
      obj.save
      obj.to_solr
      obj.update_index
      File.delete(file)
      File.open(@log_file, "a+") do |f|
        f << "#{num_files} " << I18n.t('oai_seed_logs.ingest_count')
      end
      num_files += 1
    end
    contents.size
  end
  module_function :ingest

  def cleanout_and_reindex(provider, options = {})
    reindex_by = options[:reindex_by] || ''
    rec_count = remove_selective(provider, options[:reindex_by] || '')
  end
  module_function :cleanout_and_reindex

  def delete_all
    create_log_file("delete_all")
    File.open(@log_file, "a+") do |f|
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.delete_all_begin') << I18n.t('oai_seed_logs.text_buffer')
    end
    records_num = 0
    ActiveFedora::Base.all.each do |o|
      delete_from_aggregator(o)
      records_num += 1
      File.open(@log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.text_buffer') << "#{records_num} " << I18n.t('oai_seed_logs.delete_count') << I18n.t('oai_seed_logs.text_buffer')
      end
    end
    File.open(@log_file, "a+") do |f|
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.delete_all_end') << I18n.t('oai_seed_logs.text_buffer')
    end
    HarvestMailer.dumped_whole_index_email(@log_file).deliver
  end
  module_function :delete_all

  def self.delete_from_aggregator(o)
    o.delete if o.pid.starts_with?(@pid_prefix + ':')
  end

  def self.create_log_file(log_name)
    @log_file = "#{@human_log_path}/#{log_name}.#{Time.now.to_i}.txt"
    FileUtils.touch(@log_file)
  end

  def self.get_log_file
    @log_file
  end

  def self.add_xml_formatting(xml_file, options = {})
      contributing_institution = options[:contributing_institution] || ''
      intermediate_provider = options[:intermediate_provider] || ''
      set_spec = options[:set_spec] || ''
      collection_name = options[:collection_name] || ''
      provider_id_prefix = options[:provider_id_prefix] || ''
      rights_statement = options[:rights_statement] || ''
      common_repository_type = options[:common_repository_type] || ''
      endpoint_url = options[:endpoint_url] || ''
      pid_prefix = options[:pid_prefix] || ''

      new_file = "#{Rails.root.join('tmp')}/xml_hold_file.xml"
      xml_heading = '<?xml version="1.0" encoding="UTF-8"?>'
      unless File.open(xml_file).each_line.any?{|line| line.include?(xml_heading)}
        fopen = File.open(xml_file)
        xml_file_contents = fopen.read
        xml_open = "<records>"
        xml_close = "</records>"
        xml_manifest = get_xml_manifest(:contributing_institution => contributing_institution, :intermediate_provider => intermediate_provider, :set_spec => set_spec, :collection_name => collection_name, :provider_id_prefix => provider_id_prefix, :rights_statement => rights_statement, :common_repository_type => common_repository_type, :endpoint_url => endpoint_url, :pid_prefix => pid_prefix)
        fopen.close
        File.open(new_file, 'w') do |f|
          f.puts xml_heading
          f.puts xml_open
          f.puts xml_manifest
          f.puts xml_file_contents
          f.puts xml_close
          File.rename(new_file, xml_file)
          f.close
        end
      end

    end

    def self.remove_bad_namespaces(xml_file)
      bad_namespace = "xmlns:oai_qdc='http://worldcat.org/xmlschemas/qdc-1.0/'"
      good_namespace = "xmlns:oai_qdc='http://oclc.org/appqualifieddc/'"
      new_file = "#{Rails.root.join('tmp')}/xml_hold_file.xml"
      fopen = File.open(xml_file)
      file_contents = fopen.read
      fopen.close
      File.open(new_file, 'w') do |f|
        fc = file_contents.gsub(bad_namespace, good_namespace)
        f.puts fc
        File.rename(new_file, xml_file)
        f.close
      end
    end

    def self.normalize_global(doc, string_to_search)
      node_update = doc.search(string_to_search)
      node_update.each do |node_value|
        node_value.inner_html = node_value.inner_html.sub(/^./) { |m| m.upcase }
        node_value.inner_html = node_value.inner_html.gsub(/[\,;]$/, '')
        node_value.inner_html = node_value.inner_html.gsub(/^\s+/, "")
        node_value.inner_html = node_value.inner_html.gsub(/\s+$/, "")
      end
    end

    def self.normalize_facets(doc, string_to_search)
      node_update = doc.search(string_to_search)
      node_update.each do |node_value|
        node_value.inner_html = node_value.inner_html.gsub(/[\.]$/, '')
      end
    end

    def self.strip_brackets(value)
      value = value.gsub(/[\[\]']+/,'')
    end


    def self.normalize_dates(doc, string_to_search)
      node_update = doc.search(string_to_search)
      node_update.each do |node_value|
        node_value.inner_html = node_value.inner_html.gsub(/[^0-9]/,"").strip
      end
    end

    def self.standardize_formats(doc, string_to_search)
      node_update = doc.search(string_to_search)
      node_update.each do |node_value|
        node_value.inner_html = node_value.inner_html.downcase
        case node_value.inner_html
          when /\bjpg\b/, /\bjpeg\b/
            node_value.inner_html = "image/jpeg"
          when /\bjp2\b/, /\bjpg2\b/, /\bjpeg2\b/, /\bjpeg2000\b/, /\bjp2000\b/
            node_value.inner_html = "image/jp2"
          when /\btif\b/, /\btiff\b/
            node_value.inner_html = "image/tiff"
          when /\bpdf\b/
            node_value.inner_html = "application/pdf"
          when /\bmpeg4\b/
            node_value.inner_html = "video/mpeg"
          when /\bmp4\b/
            node_value.inner_html = "video/mp4"
          when /\bmpeg\b/
            node_value.inner_html = "video/mpeg"
          when /\bmpeg3\b/
            node_value.inner_html = "audio/mpeg"
          when /\bmp3\b/
            node_value.inner_html = "audio/mp3"
          else
            node_value.inner_html = node_value.inner_html
          end
        normalize_first_case(node_value.inner_html)
      end
    end

    def self.normalize_language(doc, string_to_search)
      node_update = doc.search(string_to_search)
      node_update.each do |node_value|
        node_value.inner_html = strip_brackets(node_value.inner_html)
        normalize_first_case(node_value.inner_html)
        node_value.inner_html = Encodings::Constants::LANG_ABBR.include?(node_value.inner_html) ? Encodings::Constants::LANG_ABBR[node_value.inner_html] : node_value.inner_html
      end
    end

    def self.normalize_first_case(value)
      value.downcase
      value.sub(/^./) { |m| m.upcase }
    end


    def self.remove_fake_identifiers(doc, string_to_search)
      node_update = doc.search(string_to_search)
      node_update.each do |node_value|
        node_value.inner_html = node_value.inner_html.include?(@passthrough_url) ? "" : node_value.inner_html
      end
    end

    def self.construct_si_pid(doc, string_to_search, pid_prefix, provider_id_prefix)
      node_update = doc.search(string_to_search)
      new_pid = ""
      node_update.each do |node_value|
        new_pid = "#{pid_prefix}:#{provider_id_prefix}_#{node_value.inner_html}" if node_value.inner_html.exclude?("http") unless node_value.inner_html.blank?
      end
      elems = doc.xpath("//*[@PID]")
      old_pid = elems[0].attr('PID')
      return old_pid, new_pid
    end

    def self.replace_pid(xml_file, old_pid, new_pid)
      new_file = "#{Rails.root.join('tmp')}/xml_hold_file.xml"
      fopen = File.open(xml_file)
      file_contents = fopen.read
      fopen.close
      File.open(new_file, 'w') do |f|
        fc = file_contents.gsub(old_pid, new_pid)
        f.puts fc
        File.rename(new_file, xml_file)
        f.close
      end

    end

    def self.dcmi_types(doc, string_to_search, provider)

      types_ongoing ||= []

      node_update = doc.search(string_to_search)
      node_update.each do |node_value|
        if provider.type_sound.present?
          new_val = sort_types("Sound", provider.type_sound, node_value.inner_html)
          unless types_ongoing.include?(new_val)
            node_value.inner_html = new_val
            types_ongoing.push(new_val)
          end

        end

        if provider.type_text.present?
          new_val = sort_types("Text", provider.type_text, node_value.inner_html)
          unless types_ongoing.include?(new_val)
            node_value.inner_html = new_val
            types_ongoing.push(new_val)
          end
        end

        if provider.type_image.present?
          new_val = sort_types("Image", provider.type_image, node_value.inner_html)
          unless types_ongoing.include?(new_val)
            node_value.inner_html = new_val
            types_ongoing.push(new_val)
          end

        end

        if provider.type_moving_image.present?
          new_val = sort_types("Moving image", provider.type_moving_image, node_value.inner_html)
          unless types_ongoing.include?(new_val)
            node_value.inner_html = new_val
            types_ongoing.push(new_val)
          end
        end

        if provider.type_physical_object.present?
          new_val = sort_types("Physical object", provider.type_physical_object, node_value.inner_html)
          unless types_ongoing.include?(new_val)
            node_value.inner_html = new_val
            types_ongoing.push(new_val)
          end
        end

      end
    end

    def self.sort_types(dcmi_type, type_array, value)
      t_arr = type_array.split(";")
      t_arr.each do |a|
        value = dcmi_type if value == a.to_s
      end
      normalize_first_case(value)
    end

    def self.process_record_token(record, full_records, transient_records, noharvest_records)
        puts record.metadata
        identifier_reformed = reform_oai_id(record.header.identifier.to_s)
        record_header = "<record><header><identifier>#{identifier_reformed}</identifier><datestamp>#{record.header.datestamp.to_s}</datestamp></header>#{record.metadata.to_s}</record>"
        full_records += record_header + record.metadata.to_s unless record.header.status.to_s == "deleted" || check_if_noharvest(record)
        File.open(@log_file, "a+") do |f|
          f << I18n.t('oai_seed_logs.single_transient_record_detected') if record.header.status.to_s == "deleted"
          f << I18n.t('oai_seed_logs.noharvest_detected') if check_if_noharvest(record)
          transient_records += 1 if record.header.status.to_s == "deleted"
          noharvest_records += 1 if check_if_noharvest(record)
        end
        return full_records, transient_records, noharvest_records
    end

    def self.get_xml_manifest(options = {})
      harvest_s = @harvest_path.to_s
      converted_s = @converted_path.to_s
      partner_s = @partner.to_s

      contributing_institution = options[:contributing_institution] || ''
      intermediate_provider = options[:intermediate_provider] || ''
      set_spec = options[:set_spec] || ''
      collection_name = options[:collection_name] || ''
      provider_id_prefix = options[:provider_id_prefix] || ''
      rights_statement = options[:rights_statement] || ''
      common_repository_type = options[:common_repository_type] || ''
      endpoint_url = options[:endpoint_url] || ''
      pid_prefix = options[:pid_prefix] || ''

      xml_manifest = "<manifest><partner>#{partner_s}</partner><contributing_institution>#{contributing_institution}</contributing_institution><intermediate_provider>#{intermediate_provider}</intermediate_provider><set_spec>#{set_spec}</set_spec><collection_name>#{collection_name}</collection_name><common_repository_type>#{common_repository_type}</common_repository_type><endpoint_url>#{endpoint_url}</endpoint_url><provider_id_prefix>#{provider_id_prefix}</provider_id_prefix><rights_statement>#{rights_statement}</rights_statement><pid_prefix>#{pid_prefix}</pid_prefix><harvest_data_directory>#{harvest_s}</harvest_data_directory><converted_foxml_directory>#{converted_s}</converted_foxml_directory></manifest>"
      return xml_manifest
    end

    def self.reform_oai_id(id_string)
      local_id = id_string.split(":").last
      local_id = local_id.gsub(/([\/:.-])/,"_").gsub(/\s+/, "")
    end

    def self.remove_selective(provider, reindex_by)
      rec_count = 0
      case reindex_by
      when "set"

        solr_term = (provider.set) ? 'set_spec_si' : 'provider_id_prefix_si'
        model_term = (provider.set) ? provider.set : provider.provider_id_prefix

        create_log_file("delete_#{reindex_by}_#{provider.set}")
      when "institution"
        solr_term = 'contributing_institution_si'
        model_term = provider.contributing_institution
        create_log_file("delete_#{reindex_by}_#{provider.contributing_institution}")
      else
        File.open(@log_file, "a+") do |f|
          f << I18n.t('oai_seed_logs.reindexing_error')
        end
        abort I18n.t('oai_seed_logs.reindexing_error')
      end

      File.open(@log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.delete_begin') << I18n.t('oai_seed_logs.delete_remove_by') << "#{reindex_by}" << I18n.t('oai_seed_logs.delete_seed_derived') << "#{model_term}" << I18n.t('oai_seed_logs.text_buffer')
      end

      ActiveFedora::Base.find_each({solr_term=>model_term}, batch_size: 2000) do |o|
        delete_from_aggregator(o)
        File.open(@log_file, "a+") do |f|
          rec_count += 1
          f << I18n.t('oai_seed_logs.text_buffer') << "#{rec_count} " << I18n.t('oai_seed_logs.delete_count') << I18n.t('oai_seed_logs.text_buffer')
        end
      end
      File.open(@log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.text_buffer') << "#{model_term} " << I18n.t('oai_seed_logs.delete_end') << I18n.t('oai_seed_logs.text_buffer')
      end
      case reindex_by
      when "set"
        HarvestMailer.dump_and_reindex_by_collection_email(provider, @log_file).deliver
      when "institution"
        HarvestMailer.dump_and_reindex_by_institution_email(provider, @log_file).deliver
      end
      rec_count
    end

    def self.create_harvest_file(provider, full_records, num_files)
      f_name = provider.provider_id_prefix.gsub(/\s+/, "") +  (provider.set ? provider.set : "") + "_" + "#{num_files}" + "_" + Time.current.utc.iso8601.to_i.to_s + ".xml"
      f_name_full = Rails.root + @harvest_path + f_name
      FileUtils::mkdir_p @harvest_path
      File.open(f_name_full, "w") { |file| file.puts full_records }
      add_xml_formatting(f_name_full, :contributing_institution => provider.contributing_institution, :intermediate_provider => provider.intermediate_provider, :set_spec => provider.set, :collection_name => provider.collection_name, :provider_id_prefix => provider.provider_id_prefix, :rights_statement => provider.rights_statement, :common_repository_type => provider.common_repository_type, :endpoint_url => provider.endpoint_url, :pid_prefix => @pid_prefix)
      remove_bad_namespaces(f_name_full)
    end

    def self.check_if_exists(file)
      fopen = File.open(file)
      xml_contents = fopen.read
      doc = Nokogiri::XML(xml_contents)
      pid_check = doc.child.attribute('PID').value
      o = OaiRec.find(pid_check) if ActiveFedora::Base.exists?(pid_check)
      o.delete if o
      File.open(@log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.duplicate_record_detected') << " #{pid_check}" << I18n.t('oai_seed_logs.text_buffer') if o
      end
    end

    def self.check_if_noharvest(record)
      viable = record.metadata.to_s.include?(@noharvest_stopword)
      viable
    end

    def self.build_identifier(obj, provider)
      token = obj.send(provider.identifier_token).find {|i| i.exclude?("http")}
      assembled_identifier = provider.identifier_pattern.gsub("$1", token)
      obj.add_identifier(assembled_identifier)
    end

    ###
    # special case customizations -- hopefully can be eliminated later
    ###
    def self.custom_file_prefixing(file_prefix, provider)
      # little fix for weird nested OAI identifiers in Bepress
      file_prefix.slice!("publication_") if provider.common_repository_type == "Bepress"

      # little fix for Villanova's DPLA set
      file_prefix.slice!("dpla") if provider.contributing_institution == "Villanova University" && provider.common_repository_type == "VuDL"

      file_prefix.slice!("_#{provider.set}") if provider.common_repository_type == "Passthrough Workflow"

    end

end
