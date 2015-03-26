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
    rec_count
  end
  module_function :harvest_action

  def harvest(provider)
    File.open(@log_file, "a+") do |f|
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.log_begin') << I18n.t('oai_seed_logs.current_time') << Time.current.utc.iso8601 << I18n.t('oai_seed_logs.harvest_begin') << provider.name << I18n.t('oai_seed_logs.text_buffer')
    end
    num_files = 0
    transient_records = 0
    client = OAI::Client.new provider.endpoint_url
    response = client.list_records
    set = provider.set if provider.set
    response = client.list_records :set => set if set
    full_records = ''
    response.each do |record|
        num_files += 1
        full_records, transient_records = process_record_token(record, full_records,transient_records)
        File.open(@log_file, "a+") do |f|
          f << "#{num_files} " << I18n.t('oai_seed_logs.records_count')
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
        num_files += 1
        full_records, transient_records = process_record_token(record, full_records,transient_records)
        File.open(@log_file, "a+") do |f|
          f << "#{num_files} " << I18n.t('oai_seed_logs.records_count')
        end
      end
      create_harvest_file(provider, full_records, num_files)
      `rake tmp:cache:clear`
      sleep(5)
    end
    File.open(@log_file, "a+") do |f|
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.harvest_end') << "#{provider.name}" << I18n.t('oai_seed_logs.text_buffer') << "#{num_files} " << I18n.t('oai_seed_logs.records_count') << "#{transient_records} " << I18n.t('oai_seed_logs.transient_records_detected') << I18n.t('oai_seed_logs.text_buffer')
    end
  end
  module_function :harvest 

  def convert(provider)
      File.open(@log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.convert_begin') << I18n.t('oai_seed_logs.text_buffer')
      end
      xslt_path = Rails.root.join("lib", "tasks", "oai_to_foxml.xsl")
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

    # little fix for weird nested OAI identifiers in Bepress -- earmarking for potential custom module
    file_prefix.slice!("publication_") if provider.common_repository_type == "Bepress"
    
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

      File.open(new_file, 'w') do |f|  
          f.print(doc.to_xml)
          File.rename(new_file, xml_file)
          f.close
      end
    end
    File.open(@log_file, "a+") do |f|
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
    ActiveFedora::Base.find_each({},batch_size: 2000) do |o|
      delete_from_aggregator(o)
      records_num += 1
      File.open(@log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.text_buffer') << "#{records_num} " << I18n.t('oai_seed_logs.delete_count') << I18n.t('oai_seed_logs.text_buffer')
      end
    end
    File.open(@log_file, "a+") do |f|
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.delete_all_end') << I18n.t('oai_seed_logs.text_buffer')
    end
  end
  module_function :delete_all

  def self.delete_from_aggregator(o)
    o.delete if o.pid.starts_with?(@pid_prefix + ':')
  end

  def self.create_log_file(log_name)
    @log_file = "#{@human_log_path}/#{log_name}.#{Time.now.to_i}.txt"
    FileUtils.touch(@log_file)
  end

  def self.add_xml_formatting(xml_file, options = {})
      contributing_institution = options[:contributing_institution] || ''
      intermediate_provider = options[:intermediate_provider] || ''
      set_spec = options[:set_spec] || ''
      collection_name = options[:collection_name] || ''
      provider_id_prefix = options[:provider_id_prefix] || ''
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
        xml_manifest = get_xml_manifest(:contributing_institution => contributing_institution, :intermediate_provider => intermediate_provider, :set_spec => set_spec, :collection_name => collection_name, :provider_id_prefix => provider_id_prefix, :common_repository_type => common_repository_type, :endpoint_url => endpoint_url, :pid_prefix => pid_prefix)
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

    def self.process_record_token(record, full_records, transient_records)
      puts record.metadata
      identifier_reformed = reform_oai_id(record.header.identifier.to_s)
      record_header = "<record><header><identifier>#{identifier_reformed}</identifier><datestamp>#{record.header.datestamp.to_s}</datestamp></header>#{record.metadata.to_s}</record>"
      full_records += record_header + record.metadata.to_s unless record.header.status.to_s == "deleted"
      File.open(@log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.single_transient_record_detected') if record.header.status.to_s == "deleted"
        transient_records += 1 if record.header.status.to_s == "deleted"
      end
      return full_records, transient_records
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
      common_repository_type = options[:common_repository_type] || ''
      endpoint_url = options[:endpoint_url] || ''
      pid_prefix = options[:pid_prefix] || ''

      xml_manifest = "<manifest><partner>#{partner_s}</partner><contributing_institution>#{contributing_institution}</contributing_institution><intermediate_provider>#{intermediate_provider}</intermediate_provider><set_spec>#{set_spec}</set_spec><collection_name>#{collection_name}</collection_name><common_repository_type>#{common_repository_type}</common_repository_type><endpoint_url>#{endpoint_url}</endpoint_url><provider_id_prefix>#{provider_id_prefix}</provider_id_prefix><pid_prefix>#{pid_prefix}</pid_prefix><harvest_data_directory>#{harvest_s}</harvest_data_directory><converted_foxml_directory>#{converted_s}</converted_foxml_directory></manifest>"
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
      rec_count
    end

    def self.create_harvest_file(provider, full_records, num_files)
      f_name = provider.provider_id_prefix.gsub(/\s+/, "") +  (provider.set ? provider.set : "") + "_" + "#{num_files}" + "_" + Time.current.utc.iso8601.to_i.to_s + ".xml"
      f_name_full = Rails.root + @harvest_path + f_name
      FileUtils::mkdir_p @harvest_path
      File.open(f_name_full, "w") { |file| file.puts full_records }
      add_xml_formatting(f_name_full, :contributing_institution => provider.contributing_institution, :intermediate_provider => provider.intermediate_provider, :set_spec => provider.set, :collection_name => provider.collection_name, :provider_id_prefix => provider.provider_id_prefix, :common_repository_type => provider.common_repository_type, :endpoint_url => provider.endpoint_url, :pid_prefix => @pid_prefix)
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

    ###
    # special case customizations -- hopefully can be eliminated later
    ###
    def self.custom_file_prefixing(file_prefix, provider)
      # little fix for weird nested OAI identifiers in Bepress
      file_prefix.slice!("publication_") if provider.common_repository_type == "Bepress"
      # little fix for Villanova's DPLA set
      file_prefix.slice!("dpla") if provider.contributing_institution == "Villanova University" && provider.common_repository_type == "VuDL"
    end
end
