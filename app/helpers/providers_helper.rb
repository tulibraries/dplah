module ProvidersHelper
	def human_logs_url
      config = YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__))
      human_log_url = config['human_log_url']
      human_log_url
	end

	def human_readable_time(time_value)
		rendered_time = time_value.present? ? time_value.to_time.strftime('%B %d, %Y at %H:%M:%S %Z') : "N/A"
		return rendered_time
	end
end
