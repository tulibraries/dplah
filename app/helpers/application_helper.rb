module ApplicationHelper

	def language_label_rewrite value
    	@language_codes = Array.new
    	@language_codes = language_codes_to_english_terms()
		@language_codes.each do |code, term|
	    	if code === value
	    		value = term
	    	end
	    end
	end


	def language_codes_to_english_terms()
		array_languages = [["eng", "English"],["fr", "French"],["spa", "Spanish"]]
		return array_languages
	end

	def background_color
		config = YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__))
		config[:background_color] ? config[:background_color] : "#ddeffe"
	end

end
