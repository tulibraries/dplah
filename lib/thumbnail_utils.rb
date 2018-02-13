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
        endpoint_url.slice! '/oai/oai.php'
        set = obj.set_spec
        p = obj.pid
        p = p.split("_").last
        asset_url = "#{endpoint_url}/utils/getthumbnail/collection/#{set}/id/#{p}"
        asset_url
      end
    end

    class ContentdmSsl
  		def self.asset_url(obj)
  		  endpoint_url = obj.endpoint_url
  		  set = obj.set_spec
  		  p = obj.pid
  		  p = p.split("_").last
        url = URI.parse(endpoint_url)
        asset_url = "#{url.scheme}://#{url.host}/utils/getthumbnail/collection/#{set}/id/#{p}"
        asset_url
  		end
  	end

  	class Bepress
      def self.asset_url(obj)
        asset_url = ''
        obj.description.each do |desc|
          asset_url = desc if desc.include? 'thumbnail.jpg'
        end
        asset_url.downcase
      end
    end

    class Vudl
      def self.asset_url(obj)
        asset_url = ''
        rec = obj.identifier.first
        thumb = rec.gsub("/Record/", "/files/") << "/THUMBNAIL"
        asset_url = thumb if thumb
        asset_url
      end
    end

  	class Omeka
  	  def self.asset_url(obj)
        asset_url = ''
        obj.identifier.each do |ident|
          thumb = ident if ident.include? '/files/thumbnails/'
          asset_url = thumb ? thumb : ''
        end
        asset_url
      end
    end

    class Islandora
      def self.asset_url(obj)
        asset_url = ''
        url = URI.parse(obj.endpoint_url)
        obj.identifier.select{|id| !id.include?(' ')}.each do |ident|
          special_handling = ["PRESBY", "APS"]
          ident = /[[:alnum:]]:#{obj.provider_id_prefix}_(.*)/.match(obj.pid)[1].gsub("_",":") if special_handling.include? obj.provider_id_prefix
          Rails.logger.info "ISLANDORA_IDENTIFIER IS #{ident}"
          asset_url = "#{url.scheme}://#{url.host}/islandora/object/#{ident}/datastream/TN/view/"
        end
        asset_url
      end
    end
  end

  def define_thumbnail_common(obj, provider)
  	case provider.common_repository_type
    	when "CONTENTdm"
    		asset_url = ThumbnailUtils::CommonRepositories::Contentdm.asset_url(obj)
      when "CONTENTdm SSL"
        asset_url = ThumbnailUtils::CommonRepositories::ContentdmSsl.asset_url(obj)
      when "Bepress"
        asset_url = ThumbnailUtils::CommonRepositories::Bepress.asset_url(obj)
    	when "VuDL"
        asset_url = ThumbnailUtils::CommonRepositories::Vudl.asset_url(obj)
      when "Omeka"
        asset_url = ThumbnailUtils::CommonRepositories::Omeka.asset_url(obj)
      when "Passthrough Workflow"
        asset_url = check_for_thumbnail(obj)
      when "Islandora"
        asset_url = ThumbnailUtils::CommonRepositories::Islandora.asset_url(obj)
    	else
    		abort "Invalid common repository type - #{provider.common_repository_type}"
  	end
    asset_url
  end
  module_function :define_thumbnail_common

  def define_thumbnail_pattern(obj, provider)
    asset_url = provider.thumbnail_pattern
    if !provider.thumbnail_token_1.blank?
      token_1 = obj.send(provider.thumbnail_token_1).find {|i| i.exclude?("http")}
      token_1 = custom_thumbnail_prefixing(token_1, provider)
      asset_url = asset_url.gsub("$1", token_1)
    end
    if !provider.thumbnail_token_2.blank?
      token_2 = obj.send(provider.thumbnail_token_2).find {|i| i.exclude?("http")}
      asset_url = asset_url.gsub("$2", token_2)
    end
    asset_url
  end
  module_function :define_thumbnail_pattern

  def define_thumbnail(obj, provider)
    asset_url = ''
    if !provider.common_repository_type.blank?
      asset_url = define_thumbnail_common(obj, provider)
    elsif !provider.thumbnail_pattern.blank?
      asset_url = define_thumbnail_pattern(obj, provider)
    else
      asset_url = check_for_thumbnail(obj)
    end
    set_thumbnail(asset_url)
  end
  module_function :define_thumbnail

  def check_for_thumbnail(obj)
    thumbnail = ""
    f = obj.identifier
    f.each do |thumb|
      if thumb.start_with?('http') && (thumb.end_with?(*(OaiRec.thumbnail_extensions)) || thumb.include?('archive.org/services/img'))
        thumbnail = thumb
      end
    end
    thumbnail
  end
  module_function :check_for_thumbnail

  def self.set_thumbnail(asset_url)
    if !asset_url.blank?
      thumbnail = (asset_url)
    else
      thumbnail = nil
    end
  end

  def custom_thumbnail_prefixing(token, provider)
    case provider.endpoint_url
      when "http://dla.library.upenn.edu/dla/wheeler/oai-pmh.xml"
        token.gsub("WHEELER_","wheeler_")
      when "http://dla.library.upenn.edu/dla/holyland/oai-pmh.xml"
        token.gsub("HOLYLAND_","")
      when "http://dla.library.upenn.edu/dla/archives/oai-pmh.xml"
        token.gsub("ARCHIVES_","archives_")
      else
        token
      end
  end
  module_function :custom_thumbnail_prefixing

end
