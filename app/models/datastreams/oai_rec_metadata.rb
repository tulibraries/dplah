class Datastreams::OaiRecMetadata < ActiveFedora::OmDatastream

  set_terminology do |t|
    t.root(path: "fields")
    t.title(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.creator(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.subject(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.description(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.publisher(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.contributor(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.date(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.type(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.format(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.identifier(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.source(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.language(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.relation(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.coverage(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.rights(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.contributing_institution(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.collection_name(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
    t.partner(:index_as=>[:facetable, :sortable, :stored_searchable], :type=>:string)
  end

  def self.xml_template
    Nokogiri::XML.parse("<fields/>")
  end

  def prefix
    # set a datastream prefix if you need to namespace terms that might occur in multiple data streams 
    ""
  end

end