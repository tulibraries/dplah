namespace :oai do
	config = YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__))
	@harvest_path = config['harvest_data_directory'] 
	@converted_path = config['converted_foxml_directory']
	@pid_prefix = config['pid_prefix'] 
	@partner = config['partner'] 

	desc "Harvest records from all OAI providers and ingest into in repository"
	task :harvest_ingest_all => :environment do
		Provider.all.select { |x| Time.now > x.next_harvest_at }.each do |provider|
			rec_count = HarvestUtils.harvest_action(provider)
			puts "#{rec_count} records harvested and ingested"
		end
	end

	desc "Harvest records from all OAI providers and ingest into in repository"
	task :harvest_all => :environment do
		Provider.all.select { |x| Time.now > x.next_harvest_at }.each do |provider|
		    HarvestUtils.create_log_file(provider.name)
			HarvestUtils.harvest(provider)
		end
	end

	desc "Harvest records from all OAI providers and ingest into in repository"
	task :convert_all => :environment do
		  HarvestUtils.convert
	end



	desc "Delete all OAI objects from the repository"
	task :delete_all => :environment do
		HarvestUtils.delete_all
	end
end

