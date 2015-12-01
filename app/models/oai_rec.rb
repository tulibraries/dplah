class OaiRec < ActiveFedora::Base
	include HarvestUtils

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
		g = self.identifier.select {|a| !a.include?("http")}
		g.each {|f|
      h = "<dc:identifier>#{f}</dc:identifier>"
      begin
	    self.DC.content=self.DC.content.gsub(h,"")
	  rescue
        fail "oh no #{self.DC.content}"
	  end
      self.save
		}
		self.identifier = self.identifier.delete_if{|a| !a.starts_with?("http")}
	end

	def add_identifier(new_identifier)
		f = self.identifier
		j = f.push("#{new_identifier}")
		add_ident = "<dc:identifier>#{new_identifier}</dc:identifier>\n"
		self.update_attributes({"identifier" => j})
		self.DC.content=self.DC.content.gsub("\n</oai_dc:dc>\n","#{add_ident}\n</oai_dc:dc>\n")
		self.save
	end

	def add_type(provider)
		f = self.type
		types_ongoing ||= []
		unless self.type.empty?
			self.type.each do |a|
				if provider.type_sound.present?
				  new_val = HarvestUtils.transform_types("Sound", provider.type_sound, types_ongoing, a)
				end
				if provider.type_text.present?
				  new_val = HarvestUtils.transform_types("Text", provider.type_text, types_ongoing, a)
				end
				if provider.type_image.present?
				  new_val = HarvestUtils.transform_types("Image", provider.type_image, types_ongoing, a)
				end
				if provider.type_moving_image.present?
				  new_val = HarvestUtils.transform_types("Moving image", provider.type_moving_image, types_ongoing, a)
				end
				if provider.type_physical_object.present?
				  new_val = HarvestUtils.transform_types("Physical object", provider.type_physical_object, types_ongoing, a)
				end
				types_ongoing.push(a, new_val)
	        end 
	        self.type ||= []
	        types_ongoing.uniq!
	        types_ongoing.reject! { |item| item.blank? }
	        types_ongoing.each do |new_type|
				j = f.push("#{new_type}")
				add_type = "<dc:type>#{new_type}</dc:type>\n"
				j.uniq!
	            j.reject! { |item| item.blank? }
				self.update_attributes({"type" => j})
				self.DC.content=self.DC.content.gsub("\n</oai_dc:dc>\n","#{add_type}\n</oai_dc:dc>\n")
			end
			self.save
		end
	end

	def remove_fake_identifiers_oaidc(passthrough_url)
		g = self.identifier.select {|b| b.include?(passthrough_url)}
		h = "<dc:identifier>#{g[0]}</dc:identifier>"
		self.DC.content=self.DC.content.gsub(h,"")
		self.save
		self.identifier = self.identifier.delete_if{|a| a.include?(passthrough_url)}
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
