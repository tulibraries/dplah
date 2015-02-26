require "active-fedora"
require "open-uri"
require "fileutils"

module ThumbnailUtils
  private
  
  config = YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__))

  class CommonRepositories
  	class Contentdm
  		def self.asset_url
  		  #http://contentdm1.accesspa.org/utils/getthumbnail/collection/churchslide/id/11
  		  #churchslide = collection alias
  		  # id/11 the "11" = CONTENTdm number/id (in local identifier)
  		end
  	end

  	class Islandora
  		#http://unbsj.cairnrepo.org/fedora/repository/unbsj:997/TN 
  		#from
  		#http://unbsj.cairnrepo.org/fedora/repository/unbsj:997

  		#http://rudr.coalliance.org/fedora/repository/codr:2852/TN

  		#AND

  		#http://digitalcollections.detroitpubliclibrary.org/islandora/object/islandora%3A145930/datastream/TN/view
  		#from 
  		#http://digitalcollections.detroitpubliclibrary.org/islandora/object/islandora%3A145930



  	end

  	class Omeka
  	end

  	class Bepress
  	end

  end

end