namespace :oai do
		config = YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__))
        @harvest_path = config['harvest_data_directory'] 
        @converted_path = config['converted_foxml_directory']
        @pid_prefix = config['pid_prefix'] 
        @partner = config['partner'] 
        
        desc "Harvest records from all OAI providers in repository"
        task :harvest => :environment do
                require 'oai'

                Provider.all.select { |x| Time.now > x.next_harvest_at }.each do |provider|
                        full_records = ''
                        client = OAI::Client.new provider.endpoint_url
                        response = client.list_records
                        set = provider.set if provider.set
                        response = client.list_records :set => set if set
                        response.each do |record|
                                puts record.metadata
                                full_records += record.metadata.to_s
                        end

                        while(response.resumption_token and not response.resumption_token.empty?)
	                        token = response.resumption_token
	                        response = client.list_records :resumption_token => token if token
	                        response.each do |record|
	                          puts record.metadata
	                          full_records += record.metadata.to_s
	                        end
	                    end
                        f_name = provider.name.gsub(/\s+/, "") +  (set ? set : "") + "_" + Time.now.to_i.to_s + ".xml"
			            f_name_full = Rails.root + @harvest_path + f_name
                        FileUtils::mkdir_p @harvest_path
			            File.open(f_name_full, "w") { |file| file.puts full_records }
			            add_xml_formatting(f_name_full, provider.contributing_institution)
                end
        end

	desc "Convert OAI-PMH metadata to MODS-friendly DC metadata"
	task :convert => :environment do
		xslt_path = Rails.root.join("lib", "tasks", "oai_to_foxml.xsl")
		u_files = Dir.glob("#{@harvest_path}/*").select { |fn| File.file?(fn) }
		puts "#{u_files.length} #{"provider".pluralize(u_files.length)} detected"

		u_files.length.times do |i|
			puts "Contents of #{u_files[i]} transformed"
			`xsltproc #{Rails.root}/lib/tasks/oai_to_foxml.xsl #{u_files[i]}`
			File.delete(u_files[i])
		end
	end

	desc "Load fixtures from spec/fixtures/fedora, use DIR=path/to/directory to specify other location"
	task :ingest => :environment do
		contents = ENV['DIR'] ? Dir.glob(File.join(ENV['DIR'], "*.xml")) : Dir.glob("spec/fixtures/fedora/*.xml")
		contents.each do |file|
			puts file
			print "Loading #{File.basename(file)} ... "
			pid = ActiveFedora::FixtureLoader.import_to_fedora(file)
			puts "PID: "
			puts pid
			ActiveFedora::FixtureLoader.index(pid)
			obj = OaiRec.find(pid)
			obj.to_solr
			obj.update_index
			puts "done."
			File.delete(file)
		end
	end

	desc 'Index all DPLA objects in Fedora repo.'
	task :index => :environment do
		ActiveFedora::Base.connection_for_pid('changeme:1') #Fake obj for Rubydora
		ActiveFedora::Base.fedora_connection[0].connection.search(nil) do |object|
			if object.pid.starts_with?('#{@pid_prefix}:')
				obj = OaiRec.find(object.pid)
				obj.to_solr
				obj.update_index
				puts "#{obj} indexed."
			end
		end
	end


	def add_xml_formatting(xml_file, contributing_institution)
		new_file = "/tmp/xml_hold_file.xml"
		xml_heading = '<?xml version="1.0" encoding="UTF-8"?>'
		unless File.open(xml_file).each_line.any?{|line| line.include?(xml_heading)}
			fopen = File.open(xml_file)
			xml_file_contents = fopen.read
			xml_open = "<records>"
			xml_close = "</records>"
			xml_manifest = get_xml_manifest(contributing_institution)
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

	def get_xml_manifest(contributing_institution)
		harvest_s = @harvest_path.to_s
		converted_s = @converted_path.to_s
		partner_s = @partner.to_s
		xml_manifest = "<manifest><partner>#{partner_s}</partner><contributing_institution>#{contributing_institution}</contributing_institution><harvest_data_directory>#{harvest_s}</harvest_data_directory><converted_foxml_directory>#{converted_s}</converted_foxml_directory></manifest>"
		return xml_manifest
	end
end

