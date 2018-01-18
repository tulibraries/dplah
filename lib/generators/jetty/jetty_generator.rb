require 'jettywrapper'

class Jetty < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc """
Installs a jetty container with a solr and fedora installed in it.
Requires system('unzip... ') to work, probably won't work on Windows.
"""

  def download_jetty
    Jettywrapper.unzip
  end

end
