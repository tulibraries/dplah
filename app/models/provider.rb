class Provider < ActiveRecord::Base

	include Filterable

	validate :clean_data
	validate :endpoint_url_is_valid_and_present
	validates :email, :format => { :with => /@/, :message => "must be a valid email address"}, :allow_blank => true
	validates_length_of :new_provider_id_prefix, :maximum => 8

	scope :unique_by_contributing_institution, lambda { select(:contributing_institution).uniq.order('contributing_institution ASC') }
	scope :unique_by_intermediate_provider, lambda { select(:intermediate_provider).uniq.order('intermediate_provider ASC') }
	scope :unique_by_provider_id_prefix, lambda { select(:provider_id_prefix).uniq.order('provider_id_prefix ASC') }
	scope :unique_by_endpoint_url, lambda { select(:endpoint_url).uniq.order('endpoint_url ASC') }
	scope :unique_by_email, lambda { select(:email).uniq.order('email ASC') }
	scope :contributing_institution, -> (contributing_institution) { where contributing_institution: contributing_institution }

	before_save do
	  self.name = nil if self.name.blank?
	  self.set = nil if self.set.blank?
	  self.metadata_prefix = nil if self.metadata_prefix.blank?
	  self.email = self.new_email unless self.new_email.blank?
	  self.contributing_institution = self.contributing_institution_dc_field unless self.contributing_institution_dc_field.blank?
	  self.contributing_institution = self.new_contributing_institution unless self.new_contributing_institution.blank?
	  self.intermediate_provider = self.new_intermediate_provider unless self.new_intermediate_provider.blank?
	  self.endpoint_url = self.new_endpoint_url unless self.new_endpoint_url.blank?
	  self.provider_id_prefix = self.new_provider_id_prefix unless self.new_provider_id_prefix.blank?
	end

	def client
		OAI::Client.new(self.endpoint_url, :parser => 'libxml')
	end

	def granularity
		client.identify.granularity
	end

	def each_record(options = {}, &block)
		response = nil
		count = 0
		begin
			local_options = {}
			local_options[:resumption_token] = response.resumption_token if response and response.resumption_token.present?
			local_options = oai_client_options if local_options.empty?
			response = client.list_records(local_options)
			response.doc.find("/OAI-PMH/ListRecords/record").each do |record|
			count += 1
			yield record
			break if options[:limit] and count >= options[:limit]
		end

		rescue
			raise unless $!.respond_to?(:code) and $!.try(:code) == "noRecordsMatch"
			end while (options[:limit].blank? or count < options[:limit]) and not response.try(:resumption_token).blank?
		end

	def name
		read_attribute(:name) || endpoint_url
	end

	def email
		read_attribute(:email) || ''
	end

	def new_email
		read_attribute(:new_email) || ''
	end

	def metadata_prefix
		read_attribute(:metadata_prefix) || 'oai_dc'
	end

	def contributing_institution
		read_attribute(:contributing_institution) || ''
	end

	def new_contributing_institution
		read_attribute(:new_contributing_institution) || ''
	end

	def intermediate_provider
		read_attribute(:intermediate_provider) || ''
	end

	def new_intermediate_provider
		read_attribute(:new_intermediate_provider) || ''
	end

	def collection_name
		read_attribute(:collection_name) || ''
	end

	def in_production
		read_attribute(:in_production) || ''
	end

	def provider_id_prefix
		read_attribute(:provider_id_prefix) || ''
	end

	def rights_statement
		read_attribute(:rights_statement) || ''
	end

	def common_repository_type
		read_attribute(:common_repository_type) || ''
	end

	def thumbnail_pattern
		read_attribute(:thumbnail_pattern) || ''
	end

	def thumbnail_token_1
		read_attribute(:thumbnail_token_1) || ''
	end

	def thumbnail_token_2
		read_attribute(:thumbnail_token_2) || ''
	end

	def type_image
		read_attribute(:type_image) || ''
	end

	def type_moving_image
		read_attribute(:type_moving_image) || ''
	end

	def type_text
		read_attribute(:type_text) || ''
	end

	def type_sound
		read_attribute(:type_sound) || ''
	end

	def type_physical_object
		read_attribute(:type_physical_object) || ''
	end

	def next_harvest_at
		last_harvested + interval
	end

	def last_harvested
		read_attribute(:last_harvested) || ''
	end

	def interval
		(read_attribute(:interval) || 1.day).seconds
	end

	protected

		def oai_client_options
			options = {}
			options[:set] = set unless set.blank?
			options[:from] = last_harvested.utc.xmlschema.to_s.slice(0,granularity.length) unless last_harvested.blank?
			options[:metadata_prefix] = metadata_prefix
			options
		end

		def process_record xml
			record = record_class.from_xml xml.to_s
			record.provider = self
			record.update_index
			record
		end

		def endpoint_url_is_valid_and_present
			if self.endpoint_url.blank? && self.new_endpoint_url.blank?
				errors.add :endpoint_url, "Please specify an endpoint URL for this OAI seed"
			end
		    self.endpoint_url = self.new_endpoint_url unless self.new_endpoint_url.blank?
		    errors.add :endpoint_url, " must begin with http/https" unless self.endpoint_url =~ /^https?/
		end

		def clean_data
			attribute_names().each do |name|
				if self.send(name.to_sym).respond_to?(:strip)
					self.send("#{name}=".to_sym, self.send(name).strip)
				end
			end
		end
	private

	    def self.common_repositories
          common_repositories = [['CONTENTdm', 'CONTENTdm'], ['CONTENTdm SSL (Redirect Method)', 'CONTENTdm SSL'],['Bepress', 'Bepress'],['Omeka', 'Omeka'], ['Passthrough Workflow', 'Passthrough Workflow'], ['VuDL', 'VuDL']]
	    end

	    def self.possible_thumbnail_fields
          oai_dc_fields = [['OAI seed set','set'],['title','title'],['creator','creator'],['subject','subject'],['description','description'],['publisher','publisher'],['contributor','contributor'],['date','date'],['type','type'],['format','format'],['identifier','identifier'],['source','source'],['language','language'],['relation','relation'],['coverage','coverage'],['rights','rights']]
          oai_dc_fields
	    end

	    def self.possible_identifier_fields
          oai_dc_fields = [['title','title'],['creator','creator'],['subject','subject'],['contributor','contributor'],['identifier','identifier'],['source','source']]
          oai_dc_fields
	    end

			def self.possible_ci_fields
				possible_ci_fields = [['DC Field: Creator','DC Field: Creator'],['DC Field: Publisher','DC Field: Publisher'],['DC Field: Contributor','DC Field: Contributor'],['DC Field: Source','DC Field: Source']]
				possible_ci_fields
			end

end
