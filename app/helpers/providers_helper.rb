module ProvidersHelper
	def human_logs_url
      config = YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__))
      human_log_url = config['human_log_url']
      human_log_url
	end
end
