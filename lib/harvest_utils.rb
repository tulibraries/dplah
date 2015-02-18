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

    #make sure there are no excess harvest or conversion fixture files before restarting the tasks
    FileUtils.rm_rf(Dir.glob('#{@harvest_path}/*'))
    FileUtils.rm_rf(Dir.glob('#{@converted_path}/*'))

    create_log_file(provider.name)

    harvest(provider)
    convert(provider)
    cleanup()
    rec_count = ingest(provider)
    File.open(@log_file, "a+") do |f|
        f << "================
HARVEST AND INGEST COMPLETE FOR #{provider.name} OAI SEED at #{Time.now}.
#{rec_count} OAI records were processed
================
         
"
      end
    rec_count
  end
  module_function :harvest_action

  def harvest(provider)
    File.open(@log_file, "a+") do |f|
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.log_begin') << I18n.t('oai_seed_logs.harvest_begin') << provider.name << I18n.t('oai_seed_logs.current_time') << Time.now << I18n.t('oai_seed_logs.text_buffer')
    end
    num_files = 1
    transient_records = 0
    full_records = ''
    client = OAI::Client.new provider.endpoint_url
    response = client.list_records
    set = provider.set if provider.set
    response = client.list_records :set => set if set
    response.each do |record|
        full_records, transient_records, num_files = process_record_token(record, full_records, @log_file,transient_records, num_files)
    end

    while(response.resumption_token and not response.resumption_token.empty?)
      File.open(@log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.resumption_token_detected') << I18n.t('oai_seed_logs.current_time') << Time.now << I18n.t('oai_seed_logs.text_buffer')
      end
      token = response.resumption_token
      response = client.list_records :resumption_token => token if token
      response.each do |record|
        full_records, transient_records, num_files = process_record_token(record, full_records, @log_file,transient_records, num_files)
      end
    end
    f_name = provider.name.gsub(/\s+/, "") +  (set ? set : "") + "_" + Time.now.to_i.to_s + ".xml"
    f_name_full = Rails.root + @harvest_path + f_name
    FileUtils::mkdir_p @harvest_path
    File.open(f_name_full, "w") { |file| file.puts full_records }
    add_xml_formatting(f_name_full, :contributing_institution => provider.contributing_institution, :set_spec => provider.set, :collection_name => provider.collection_name)
      File.open(@log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.harvest_end') << provider.name << I18n.t('oai_seed_logs.current_time') << Time.now << num_files << I18n.t('oai_seed_logs.records_count') << "#{transient_records} " << I18n.t('oai_seed_logs.transient_records_detected') << I18n.t('oai_seed_logs.text_buffer')
      end
    end
  module_function :harvest 

  def convert(provider)
      File.open(@log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.convert_begin') << I18n.t('oai_seed_logs.current_time') << Time.now << I18n.t('oai_seed_logs.text_buffer')
      end
      xslt_path = Rails.root.join("lib", "tasks", "oai_to_foxml.xsl")
      u_files = Dir.glob("#{@harvest_path}/*").select { |fn| File.file?(fn) }
      File.open(@log_file, "a+") do |f|

        f << "#{u_files.length} "<< I18n.t('oai_seed_logs.convert_count')
      end
      u_files.length.times do |i|
        puts "Contents of #{u_files[i]} transformed"
        `xsltproc #{Rails.root}/lib/tasks/oai_to_foxml.xsl #{u_files[i]}`
        File.delete(u_files[i])
      end
  end
  module_function :convert

  def cleanup()
    File.open(@log_file, "a+") do |f|
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.normalize_begin') << I18n.t('oai_seed_logs.current_time') << Time.now << I18n.t('oai_seed_logs.text_buffer')
      end
    new_file = "/tmp/xml_hold_file.xml"
    xml_files = @converted_path ? Dir.glob(File.join(@converted_path, "*.xml")) : Dir.glob("spec/fixtures/fedora/*.xml")
    xml_files.each do |xml_file|

      xml_content = File.read(xml_file)
      doc = Nokogiri::XML(xml_content)
      node_update = doc.search("//subject")
      node_update.each do |node_value|
        #do all metadata normalizing for subjects here
        node_value.inner_html = node_value.inner_html.gsub(/[\,;.]$/, '')
      end

      node_update = doc.search("//type")
      node_update.each do |node_value|
        #do all metadata normalizing for types here
        node_value.inner_html = node_value.inner_html.gsub(/[\,;.]$/, '')
      end

      File.open(new_file, 'w') do |f|  
          f.print(doc.to_xml)
          File.rename(new_file, xml_file)
          f.close
      end
    end
    File.open(@log_file, "a+") do |f|
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.normalize_end') << I18n.t('oai_seed_logs.current_time') << Time.now << I18n.t('oai_seed_logs.text_buffer')
    end
  end
  module_function :cleanup

  def ingest(provider)
    File.open(@log_file, "a+") do |f|
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.ingest_begin') << I18n.t('oai_seed_logs.current_time') << Time.now << I18n.t('oai_seed_logs.text_buffer')
      end
    num_files = 1
    contents = @converted_path ? Dir.glob(File.join(@converted_path, "*.xml")) : Dir.glob("spec/fixtures/fedora/*.xml")
    contents.each do |file|
      pid = ActiveFedora::FixtureLoader.import_to_fedora(file)
      ActiveFedora::FixtureLoader.index(pid)
      obj = OaiRec.find(pid)
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
    create_log_file("delete_#{reindex_by}_")
    rec_count = 0
    File.open(@log_file, "a+") do |f|
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.delete_begin') << I18n.t('oai_seed_logs.current_time') << Time.now << I18n.t('oai_seed_logs.text_buffer')
    end
    if reindex_by == "institution"
      ActiveFedora::Base.find_each({'contributing_institution_si'=>provider.contributing_institution}, batch_size: 2000) do |o|
        delete_from_aggregator(o)
        File.open(@log_file, "a+") do |f|
          f << I18n.t('oai_seed_logs.text_buffer') << "#{rec_count} " << I18n.t('oai_seed_logs.delete_count') << I18n.t('oai_seed_logs.text_buffer')
          rec_count += 1
        end
      end
      File.open(@log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.text_buffer') << "#{provider.contributing_institution} " << I18n.t('oai_seed_logs.delete_end') << I18n.t('oai_seed_logs.current_time') << Time.now << I18n.t('oai_seed_logs.text_buffer')
      end
    elsif reindex_by == "set"
      ActiveFedora::Base.find_each({'set_spec_si'=>provider.set}, batch_size: 2000) do |o|
        delete_from_aggregator(o)
        File.open(@log_file, "a+") do |f|
          f << I18n.t('oai_seed_logs.text_buffer') << "#{rec_count} " << I18n.t('oai_seed_logs.delete_count') << I18n.t('oai_seed_logs.text_buffer')
          rec_count += 1
        end
      end
      File.open(@log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.text_buffer') << "#{provider.set} " << I18n.t('oai_seed_logs.delete_end') << I18n.t('oai_seed_logs.current_time') << Time.now << I18n.t('oai_seed_logs.text_buffer')
      end
    else
      File.open(@log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.reindexing_error')
      end
    end
    rec_count
  end
  module_function :cleanout_and_reindex

  def delete_all
    create_log_file("delete_all")
    File.open(@log_file, "a+") do |f|
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.delete_all_begin') << I18n.t('oai_seed_logs.current_time') << Time.now << I18n.t('oai_seed_logs.text_buffer')
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
      f << I18n.t('oai_seed_logs.text_buffer') << I18n.t('oai_seed_logs.delete_all_end') << I18n.t('oai_seed_logs.current_time') << Time.now << I18n.t('oai_seed_logs.text_buffer')
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
      set_spec = options[:set_spec] || ''
      collection_name = options[:collection_name] || ''
      new_file = "/tmp/xml_hold_file.xml"
      xml_heading = '<?xml version="1.0" encoding="UTF-8"?>'
      unless File.open(xml_file).each_line.any?{|line| line.include?(xml_heading)}
        fopen = File.open(xml_file)
        xml_file_contents = fopen.read
        xml_open = "<records>"
        xml_close = "</records>"
        xml_manifest = get_xml_manifest(contributing_institution, set_spec, collection_name)
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

    def self.process_record_token(record, full_records, log_file, transient_records, num_files)
      puts record.metadata
      identifier_reformed = reform_oai_id(record.header.identifier.to_s)
      record_header = "<record><header><identifier>#{identifier_reformed}</identifier><datestamp>#{record.header.datestamp.to_s}</datestamp></header>#{record.metadata.to_s}</record>"
      full_records += record_header + record.metadata.to_s unless record.header.status.to_s == "deleted"
      File.open(log_file, "a+") do |f|
        f << I18n.t('oai_seed_logs.single_transient_record_detected') if record.header.status.to_s == "deleted"
        transient_records += 1 if record.header.status.to_s == "deleted"
        f << "#{num_files} " << I18n.t('oai_seed_logs.records_count')
      end
      num_files += 1
      return full_records, transient_records, num_files
    end

    def self.get_xml_manifest(contributing_institution, set_spec, collection_name)
      harvest_s = @harvest_path.to_s
      converted_s = @converted_path.to_s
      partner_s = @partner.to_s
      xml_manifest = "<manifest><partner>#{partner_s}</partner><contributing_institution>#{contributing_institution}</contributing_institution><set_spec>#{set_spec}</set_spec><collection_name>#{collection_name}</collection_name><harvest_data_directory>#{harvest_s}</harvest_data_directory><converted_foxml_directory>#{converted_s}</converted_foxml_directory></manifest>"
      return xml_manifest
    end

    def self.reform_oai_id(id_string)
      id_string.slice! "oai:"
      id_string = id_string.gsub(/([\/:.-])/,"_")
      id_string = id_string.gsub(/\s+/, "")
    end
end



