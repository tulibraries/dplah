require "active-fedora"
require "open-uri"
require "fileutils"

module ThumbnailUtils
  private
  
  config = YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__))

  class CommonRepositories
  	class Contentdm
  		def self.asset_url
  		  
  		end
  	end

  	class Islandora

  	end

  	class Omeka

  	end

  	class Bepress
  	end

  end

end