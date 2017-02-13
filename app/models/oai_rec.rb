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
      rescue => e
        Rails.logger.tagged("ERROR") { Rails.logger.error "'#{f}' - #{e.message}" }
        if e.inspect.match "Encoding::CompatibilityError"
          Rails.logger.tagged("INFO") { Rails.logger.info "'#{f}' - encoding forced to UTF-8" }
          self.DC.content=self.DC.content.force_encoding("UTF-8").gsub(h,"")
        else
          return
        end
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

	def add_dcmi_terms_to_type(provider)
		dcmi_terms_to_add = []
		unless self.type.empty?
			self.type.each do |type_to_check|
				if provider.type_sound.present?
					dcmi_terms_to_add.push(HarvestUtils.map_type_term_to_dcmi("Sound", provider.type_sound, type_to_check))
				end
				if provider.type_text.present?
					dcmi_terms_to_add.push(HarvestUtils.map_type_term_to_dcmi("Text", provider.type_text, type_to_check))
				end
				if provider.type_image.present?
					dcmi_terms_to_add.push(HarvestUtils.map_type_term_to_dcmi("Image", provider.type_image, type_to_check))
				end
				if provider.type_moving_image.present?
					dcmi_terms_to_add.push(HarvestUtils.map_type_term_to_dcmi("Moving image", provider.type_moving_image, type_to_check))
				end
				if provider.type_physical_object.present?
					dcmi_terms_to_add.push(HarvestUtils.map_type_term_to_dcmi("Physical object", provider.type_physical_object, type_to_check))
				end
			end

			dcmi_terms_to_add.uniq!
			dcmi_terms_to_add.reject! { |item| item.blank? }
			dcmi_terms_to_add.each do |dcmi_term|
				add_type = "<dc:type>#{dcmi_term}</dc:type>\n"
				self.DC.content = self.DC.content.gsub("\n</oai_dc:dc>\n","#{add_type}\n</oai_dc:dc>\n") unless self.DC.content.include? add_type
			end
			self.update_attributes({:type => self.type.push(dcmi_terms_to_add).uniq })
			self.save
		end
	end

	def remove_identifier_containing(search_on_string)
		dc_content = self.DC.content.split("\n")
		self.DC.content = dc_content.delete_if{|a| a.include?(search_on_string)}.join("\n")
		self.identifier = self.identifier.delete_if{|a| a.include?(search_on_string)}
		self.save

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

	def clean_iso8601_date_field
		new_dates = self.date.dup
		self.date.each_with_index do |zdate, index|
			if (zdate.include? "T") && (zdate.include? "Z")
				begin
				ymddate = Date.parse(zdate).to_formatted_s(:db)
				new_dates[index]= ymddate
				rescue
					Rails.logger.warn "Malformed iso8601 date, cannot parse #{self.date}"
				end
			end
		end
		self.update_attributes({:date => new_dates})
	end

end
