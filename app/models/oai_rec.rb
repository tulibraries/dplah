class OaiRec < ActiveFedora::Base

	# def self.to_class_uri
 #      'info:fedora/afmodel:OaiRec'
 #    end

	has_metadata 'descMetadata', type: Datastreams::OaiRecMetadata
	has_metadata 'DC', type: ActiveFedora::Datastream

	# Just your basic DC OAI-PMH
	has_attributes :title, datastream: 'descMetadata', multiple: true
	has_attributes :creator, datastream: 'descMetadata', multiple: true
	has_attributes :subject, datastream: 'descMetadata', multiple: true
	has_attributes :description, datastream: 'descMetadata', multiple: true
	has_attributes :publisher, datastream: 'descMetadata', multiple: true
	has_attributes :contributor, datastream: 'descMetadata', multiple: true
	has_attributes :date, datastream: 'descMetadata', multiple: true
	has_attributes :type, datastream: 'descMetadata', multiple: true
	has_attributes :format, datastream: 'descMetadata', multiple: true
	has_attributes :identifier, datastream: 'descMetadata', multiple: true
	has_attributes :source, datastream: 'descMetadata', multiple: true
	has_attributes :language, datastream: 'descMetadata', multiple: true
	has_attributes :relation, datastream: 'descMetadata', multiple: true
	has_attributes :coverage, datastream: 'descMetadata', multiple: true
	has_attributes :rights, datastream: 'descMetadata', multiple: true


	has_attributes :title, datastream: 'DC', multiple: true
	has_attributes :creator, datastream: 'DC', multiple: true
	has_attributes :subject, datastream: 'DC', multiple: true
	has_attributes :description, datastream: 'DC', multiple: true
	has_attributes :publisher, datastream: 'DC', multiple: true
	has_attributes :contributor, datastream: 'DC', multiple: true
	has_attributes :date, datastream: 'DC', multiple: true
	has_attributes :type, datastream: 'DC', multiple: true
	has_attributes :format, datastream: 'DC', multiple: true
	has_attributes :identifier, datastream: 'DC', multiple: true
	has_attributes :source, datastream: 'DC', multiple: true
	has_attributes :language, datastream: 'DC', multiple: true
	has_attributes :relation, datastream: 'DC', multiple: true
	has_attributes :coverage, datastream: 'DC', multiple: true
	has_attributes :rights, datastream: 'DC', multiple: true

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



	# Partner-specific
	has_attributes :common_repository_type, datastream: 'DC', multiple: false
	has_attributes :endpoint_url, datastream: 'DC', multiple: false
	has_attributes :thumbnail, datastream: 'DC', multiple: false

	#DPLA-specific fields
	has_attributes :contributing_institution, datastream: 'DC', multiple: false
	has_attributes :rights_statement, datastream: 'DC', multiple: false
	has_attributes :intermediate_provider, datastream: 'DC', multiple: false
	has_attributes :collection_name, datastream: 'DC', multiple: false
	has_attributes :partner, datastream: 'DC', multiple: false

    #specifically to allow dump/reindex by set
	has_attributes :set_spec, datastream: 'DC', multiple: false
	has_attributes :provider_id_prefix, datastream: 'DC', multiple: false

	#has_model :oai_rec

	def self.thumbnail_extensions
		%w(jpg png gif)
	end

	def reorg_identifiers
		self.identifier = self.identifier.delete_if{|a| !a.starts_with?("http")}
	end

	def add_identifier(new_identifier)
		f = self.identifier
		j = f.push("#{new_identifier}")
		add_ident = "<dc:identifier>#{new_identifier}</dc:identifier>\n  "
		self.update_attributes({"identifier" => j})
		self.DC.content=self.DC.content.gsub("</dc:identifier>\n  ","</dc:identifier>\n  <dc:identifier>#{add_ident}</dc:identifier>\n  ")
		self.save
	end

	def assign_rights
	  self.rights = self.rights_statement unless self.rights_statement.blank?
    end

	def assign_contributing_institution
		case self.contributing_institution
		  when "DC Field: Source"
		  	self.contributing_institution = self.source
		  else
			self.contributing_institution = self.contributing_institution
		end
    end

end
