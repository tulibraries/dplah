require "active-fedora"
require "open-uri"
require "fileutils"

module ThumbnailUtils
  private
  
  config = YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__))

  class CommonRepositories
  	class Contentdm
  		def self.asset_url(obj)
  		  endpoint_url = obj.endpoint_url
  		  g = endpoint_url.slice!('/oai/oai.php')
  		  set = obj.set_spec
  		  p = obj.pid
  		  p = p.split("_").last
  		  asset_url = "#{endpoint_url}/utils/getthumbnail/collection/#{set}/id/#{p}"
  		  asset_url
  		end
  	end

  	class Bepress
  	  def self.asset_url(obj)
        asset_url = ''
		obj.description.each do |desc|
		  thumb = desc if desc.include? 'thumbnail.jpg'  
		  asset_url = thumb if thumb
		end
        asset_url
  	  end
  	end

  	class Omeka
  	  def self.asset_url(obj)
  	  	binding.pry
        asset_url = ''
		obj.identifier.each do |ident|
		  thumb = ident if ident.include? '/files/thumbnails/'  
		  asset_url = thumb if thumb
          binding.pry
		end
		binding.pry
        asset_url

  	  end
  	end

  	# class Omeka
   #    def self.asset_url(obj)

   #    end
  	# end

  	# class Islandora
   #    def self.asset_url(obj)		  
  	#   end
  	# end

  end

  def define_thumbnail(obj, provider)
	case provider.common_repository_type
	when "CONTENTdm"
		asset_url = ThumbnailUtils::CommonRepositories::Contentdm.asset_url(obj)
	when "Omeka"
		asset_url = ThumbnailUtils::CommonRepositories::Omeka.asset_url(obj)
	when "Bepress"
		asset_url = ThumbnailUtils::CommonRepositories::Bepress.asset_url(obj)
	else
		abort "Invalid common repository type - #{provider.common_repository_type}"
	end
	set_and_save_thumbnail(obj.pid, asset_url)
  end
  module_function :define_thumbnail


  def self.set_and_save_thumbnail(pid, asset_url)
  	obj = OaiRec.find(pid)
	obj.thumbnail = asset_url if Faraday.head(asset_url).status == 200
	obj.save
	obj.to_solr
	obj.update_index
  end

end