class OaiRec < ActiveFedora::Base

	has_metadata 'descMetadata', type: Datastreams::OaiRecMetadata
	
	# Just your basic DC OAI-PMH
	has_attributes :title, datastream: 'descMetadata', multiple: false
	has_attributes :creator, datastream: 'descMetadata', multiple: false
	has_attributes :subject, datastream: 'descMetadata', multiple: false
	has_attributes :description, datastream: 'descMetadata', multiple: false
	has_attributes :publisher, datastream: 'descMetadata', multiple: false
	has_attributes :contributor, datastream: 'descMetadata', multiple: false
	has_attributes :date, datastream: 'descMetadata', multiple: false
	has_attributes :type, datastream: 'descMetadata', multiple: false
	has_attributes :format, datastream: 'descMetadata', multiple: false
	has_attributes :identifier, datastream: 'descMetadata', multiple: false
	has_attributes :source, datastream: 'descMetadata', multiple: false
	has_attributes :language, datastream: 'descMetadata', multiple: false
	has_attributes :relation, datastream: 'descMetadata', multiple: false
	has_attributes :coverage, datastream: 'descMetadata', multiple: false
	has_attributes :rights, datastream: 'descMetadata', multiple: false

	#DPLA-specific fields
	has_attributes :contributing_institution, datastream: 'descMetadata', multiple: false
	has_attributes :collection_name, datastream: 'descMetadata', multiple: false
	has_attributes :partner, datastream: 'descMetadata', multiple: false

end
