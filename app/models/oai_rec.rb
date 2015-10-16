class OaiRec < ActiveFedora::Base

	# def self.to_class_uri
 #      'info:fedora/afmodel:OaiRec'
 #    end

	has_metadata 'descMetadata', type: Datastreams::OaiRecMetadata

	# Just your basic DC OAI-PMH
	has_attributes :title, datastream: 'descMetadata', multiple: true
	has_attributes :creator, datastream: 'descMetadata', multiple: true
	has_attributes :subject, datastream: 'descMetadata', multiple: true
	has_attributes :description, datastream: 'descMetadata', multiple: true
	has_attributes :publisher, datastream: 'descMetadata', multiple: true
	has_attributes :contributor, datastream: 'descMetadata', multiple: true
	has_attributes :date, datastream: 'descMetadata', multiple: true
	has_attributes :created, datastream: 'descMetadata', multiple: true
	has_attributes :issued, datastream: 'descMetadata', multiple: true
	has_attributes :available, datastream: 'descMetadata', multiple: true
	has_attributes :temporal, datastream: 'descMetadata', multiple: true
	has_attributes :type, datastream: 'descMetadata', multiple: true
	has_attributes :format, datastream: 'descMetadata', multiple: true
	has_attributes :spatial, datastream: 'descMetadata', multiple: true
	has_attributes :identifier, datastream: 'descMetadata', multiple: true
	has_attributes :source, datastream: 'descMetadata', multiple: true
	has_attributes :language, datastream: 'descMetadata', multiple: true
	has_attributes :relation, datastream: 'descMetadata', multiple: true
	has_attributes :coverage, datastream: 'descMetadata', multiple: true
	has_attributes :rights, datastream: 'descMetadata', multiple: true
	has_attributes :access_rights, datastream: 'descMetadata', multiple: true
	has_attributes :rights_holder, datastream: 'descMetadata', multiple: true

	# Partner-specific
	has_attributes :common_repository_type, datastream: 'descMetadata', multiple: false
	has_attributes :endpoint_url, datastream: 'descMetadata', multiple: false
	has_attributes :thumbnail, datastream: 'descMetadata', multiple: false

	#DPLA-specific fields
	has_attributes :contributing_institution, datastream: 'descMetadata', multiple: false
	has_attributes :rights_statement, datastream: 'descMetadata', multiple: false
	has_attributes :intermediate_provider, datastream: 'descMetadata', multiple: false
	has_attributes :collection_name, datastream: 'descMetadata', multiple: false
	has_attributes :partner, datastream: 'descMetadata', multiple: false

    #specifically to allow dump/reindex by set
	has_attributes :set_spec, datastream: 'descMetadata', multiple: false
	has_attributes :provider_id_prefix, datastream: 'descMetadata', multiple: false

	#has_model :oai_rec

	def self.thumbnail_extensions
		%w(jpg png gif)
	end

	def reorg_identifiers
		self.identifier = self.identifier.delete_if{|a| !a.starts_with?("http")}
	end

	def assign_rights
		unless self.rights_statement.blank?
			self.DC.content=self.DC.content.gsub("\n</oai_dc:dc>\n","<dc:rights>#{rights_statement}</dc:rights>\n</oai_dc:dc>\n")
	    self.rights = self.rights_statement unless self.rights_statement.blank?
			self.save
	  end
  end

	def assign_contributing_institution
		case self.contributing_institution
		  when "DC Field: Source"
		  	self.contributing_institution = self.source
				self.DC.content=self.DC.content.gsub("\n</oai_dc:dc>\n","<dc:contributor>#{self.source}</dc:contributor>\n</oai_dc:dc>\n")
				self.save
		  else
			self.contributing_institution = self.contributing_institution
		end
  end

end
