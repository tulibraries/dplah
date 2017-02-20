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

	desc "Harvest records from an OAI seed and ingest into repository"
	task :harvest_ingest, [:seed] => :environment do |t, args|
		args.download(:seed => nil)
		if args[:seed]
		  oai_seed = Provider.find(args[:seed])
		  HarvestUtils.create_log_file(oai_seed.name)
		  rec_count = HarvestUtils.harvest_action(oai_seed)
		  message = "#{rec_count} records ingested.  Enjoy!"
		else
		  message = "No valid OAI Seed model ID entered. To ingest, run rake oai:harvest_ingest[seed id]."
		end
		puts message
	end

	desc "Harvest one OAI seed by OAI Seed model ID (found in interface)"
	task :harvest, [:seed] => :environment do |t, args|
		args.download(:seed => nil)
		if args[:seed]
		  oai_seed = Provider.find(args[:seed])
		  HarvestUtils.create_log_file(oai_seed.name)
		  HarvestUtils.harvest(oai_seed)
		  message = "Single OAI seed harvested.  Enjoy!"
		else
		  message = "No valid OAI Seed model ID entered. To harvest all, run rake oai:harvest_all."
		end
		puts message
	end

	desc "Convert all XML harvests currently in the harvested directory to FOXML"
	task :convert_all => :environment do
		Provider.all.select { |x| Time.now > x.next_harvest_at }.each do |provider|
			HarvestUtils.create_log_file(provider.name)
			HarvestUtils.convert(provider)
		end
	end

	desc "Delete all OAI objects from the repository"
	task :delete_all => :environment do
		HarvestUtils.delete_all
	end
end

