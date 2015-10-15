class Datastreams::DcMetadata < ActiveFedora::Datastream
  attr_accessor :title
  
  def attributes
    { 'title' => @title }
  end
  
  def self.xml_template
    Nokogiri::XML.parse("<fields/>")
  end

  def prefix
    # set a datastream prefix if you need to namespace terms that might occur in multiple data streams 
    ""
  end

end