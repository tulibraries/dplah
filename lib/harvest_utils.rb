require "active-fedora"
require "open-uri"
require "fileutils"
require "oai"

module HarvestUtils

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
        f << "================
BEGINNING HARVEST FOR #{provider.name} OAI SEED at #{Time.now} 
This log will update throughout this process.
================
        
"
      end
    num_files = 1
    transient_records = 1
    full_records = ''
    client = OAI::Client.new provider.endpoint_url
    response = client.list_records
    set = provider.set if provider.set
    response = client.list_records :set => set if set
    response.each do |record|
      puts record.metadata
      full_records += record.metadata.to_s
      File.open(@log_file, "a+") do |f|
        f << "Transient record detected -- " if record.header.status.to_s == "deleted"
        transient_records += 1 if record.header.status.to_s == "deleted"
        f << "#{num_files} #{"OAI record".pluralize(num_files)} detected from seed
        "

      end
      num_files += 1
    end
    while(response.resumption_token and not response.resumption_token.empty?)
      File.open(@log_file, "a+") do |f|
        f << "

==============
Resumption token detected at #{Time.now} 
==============

"
      end
      token = response.resumption_token
      response = client.list_records :resumption_token => token if token
      response.each do |record|
        puts record.metadata
        full_records += record.metadata.to_s
        num_files += 1
        File.open(@log_file, "a+") do |f|
          f << "Transient record detected -- " if record.header.status.to_s == "deleted"
          transient_records += 1 if record.header.status.to_s == "deleted"
          f << "#{num_files} #{"OAI record".pluralize(num_files)} detected from seed
          "

        end
      end
    end
    f_name = provider.name.gsub(/\s+/, "") +  (set ? set : "") + "_" + Time.now.to_i.to_s + ".xml"
    f_name_full = Rails.root + @harvest_path + f_name
    FileUtils::mkdir_p @harvest_path
    File.open(f_name_full, "w") { |file| file.puts full_records }
    add_xml_formatting(f_name_full, :contributing_institution => provider.contributing_institution, :set_spec => provider.set, :collection_name => provider.collection_name)
      File.open(@log_file, "a+") do |f|
        f << "================
HARVEST COMPLETE FOR #{provider.name} OAI SEED at #{Time.now}.
#{num_files} OAI records were detected, #{transient_records} of which were transient
================
            
"
      end
    end
  module_function :harvest 

  def convert(provider)
      File.open(@log_file, "a+") do |f|
        f << "================
ALL OAI RECORDS HARVESTED, BEGINNING CONVERSION at #{Time.now}
================
        
"
      end
      xslt_path = Rails.root.join("lib", "tasks", "oai_to_foxml.xsl")
      u_files = Dir.glob("#{@harvest_path}/*").select { |fn| File.file?(fn) }
      File.open(@log_file, "a+") do |f|
        f << "#{u_files.length} #{"OAI seed".pluralize(u_files.length)} detected
        "
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
              f << "================
ALL OAI RECORDS HARVESTED AND CONVERTED, BEGINNING NORMALIZING at #{Time.now} 
================

"
      end
    new_file = "/tmp/xml_hold_file.xml"
    xml_files = @converted_path ? Dir.glob(File.join(@converted_path, "*.xml")) : Dir.glob("spec/fixtures/fedora/*.xml")
    xml_files.each do |xml_file|
      # xml = Nokogiri::XML(open(xml_file))
      # values = xml.xpath("/records/metadata//dc/text()")
      # values = xml.at('subject').text
      # values.gsub(/[\,;.]$/, '')
      #text()")
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

  end
  module_function :cleanup

  def ingest(provider)
    File.open(@log_file, "a+") do |f|
        f << "================
ALL OAI RECORDS HARVESTED, CONVERTED, AND NORMALIZED, BEGINNING INGEST at #{Time.now} 
================

"
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
        f << "#{num_files} #{"OAI record".pluralize(num_files)} ingested
        "
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
    f << "================
    INITIATING DELETE OF RECORDS BY #{reindex_by} FROM AGGREGATOR at #{Time.now} 
    ================

    "
    end
    if reindex_by == "institution"
      ActiveFedora::Base.find_each({'contributing_institution_si'=>provider.contributing_institution}, batch_size: 2000) do |o|
        delete_from_aggregator(o)
        File.open(@log_file, "a+") do |f|
            f << "================
            #{rec_count} #{"record".pluralize(rec_count)} deleted from aggregator
            ================

            "
            rec_count += 1
        end
      end
      File.open(@log_file, "a+") do |f|
        f << "================
        #{rec_count} RECORDS CONTRIBUTED BY #{provider.contributing_institution} DELETED FROM AGGREGATOR at #{Time.now} 
        ================

        "
      end
    elsif reindex_by == "set"
      ActiveFedora::Base.find_each({'set_spec_si'=>provider.set}, batch_size: 2000) do |o|
        delete_from_aggregator(o)
        File.open(@log_file, "a+") do |f|
          f << "================
          #{rec_count} #{"record".pluralize(rec_count)} deleted from aggregator
          ================

          "
          rec_count += 1
        end
      end
      File.open(@log_file, "a+") do |f|
        f << "================
        #{rec_count} RECORDS CONTRIBUTED BY #{provider.set} DELETED FROM AGGREGATOR at #{Time.now} 
        ================

        "
      end
    else
      File.open(@log_file, "a+") do |f|
        f << "ERROR: No reindexing option specified."
      end
    end
    rec_count
  end
  module_function :cleanout_and_reindex

  def delete_all
    create_log_file("delete_all")
    File.open(@log_file, "a+") do |f|
      f << "================
      INITIATING DELETE OF ALL RECORDS FROM AGGREGATOR at #{Time.now} 
      ================

      "
    end
    records_num = 0
    ActiveFedora::Base.find_each({},batch_size: 2000) do |o|
      delete_from_aggregator(o)
      records_num += 1
      File.open(@log_file, "a+") do |f|
        f << "================
        #{records_num} #{"record".pluralize(records_num)} deleted from aggregator
        ================

        "
      end
    end
    File.open(@log_file, "a+") do |f|
      f << "================
      ALL OAI RECORDS DELETED FROM AGGREGATOR at #{Time.now} 
      ================

      "
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

    def self.get_xml_manifest(contributing_institution, set_spec, collection_name)
      harvest_s = @harvest_path.to_s
      converted_s = @converted_path.to_s
      partner_s = @partner.to_s
      xml_manifest = "<manifest><partner>#{partner_s}</partner><contributing_institution>#{contributing_institution}</contributing_institution><set_spec>#{set_spec}</set_spec><collection_name>#{collection_name}</collection_name><harvest_data_directory>#{harvest_s}</harvest_data_directory><converted_foxml_directory>#{converted_s}</converted_foxml_directory></manifest>"
      return xml_manifest
    end
end



