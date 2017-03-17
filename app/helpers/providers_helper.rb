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

	def render_harvest_all_intermediate_provider(provider)
		if provider.intermediate_provider.present?
			button = link_to 'Harvest all OAI Seeds from this Institution\'s Intermediate Provider', harvest_all_selective_intermediate_provider_provider_path(provider), method: :post, class: :triggerWaiting, data: { confirm: 'This may take a while for intermediate providers with institutions and associated OAI seeds. Are you sure?' }
		else
			button = content_tag(:span, "Harvest all OAI Seeds from this Institution's Intermediate Provider (not available)", class: "disabled-harvest-all-intermediate-provider")
		end
    return button
	end

	def oai_action_disabled_class(attribute_check)
		return attribute_check.present? ? "oai-actions btn-provider" : "oai-actions"
	end

	def selected_filter(params)
		params.fetch('contributing_institution', '')
	end
end
