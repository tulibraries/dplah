class ProvidersController < ApplicationController
  before_action :set_provider, only: [:show, :edit, :update, :destroy, :harvest]

  # GET /providers
  # GET /providers.json
  def index
    @providers = Provider.all
  end

  # GET /providers/1
  # GET /providers/1.json
  def show
  end

  # GET /providers/new
  def new
    @provider = Provider.new
  end

  # GET /providers/1/edit
  def edit
  end


  # POST /providers
  # POST /providers.json
  def create
    @provider = Provider.new(provider_params)

    respond_to do |format|
      if @provider.save
        format.html { redirect_to @provider, notice: 'Provider was successfully created.' }
        format.json { render :show, status: :created, location: @provider }
      else
        format.html { render :new }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /providers/1
  # PATCH/PUT /providers/1.json
  def update
    respond_to do |format|
      if @provider.update(provider_params)
        format.html { redirect_to @provider, notice: 'Provider was successfully updated.' }
        format.json { render :show, status: :ok, location: @provider }
      else
        format.html { render :edit }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end

  

  # DELETE /providers/1
  # DELETE /providers/1.json
  def destroy
    @provider.destroy
    respond_to do |format|
      format.html { redirect_to providers_url, notice: 'Provider was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def harvest
    config = YAML.load_file(File.expand_path("#{Rails.root}/config/dpla.yml", __FILE__))
    @harvest_path = config['harvest_data_directory'] 
    @converted_path = config['converted_foxml_directory']
    @pid_prefix = config['pid_prefix'] 
    @partner = config['partner'] 
    require 'oai'
    full_records = ''
    client = OAI::Client.new @provider.endpoint_url
    response = client.list_records
    set = @provider.set if @provider.set
    response = client.list_records :set => set if set
    response.each do |record|
      puts record.metadata
      full_records += record.metadata.to_s
    end
    while(response.resumption_token and not response.resumption_token.empty?)
      token = response.resumption_token
      response = client.list_records :resumption_token => token if token
      response.each do |record|
        puts record.metadata
        full_records += record.metadata.to_s
      end
    end
    f_name = @provider.name.gsub(/\s+/, "") +  (set ? set : "") + "_" + Time.now.to_i.to_s + ".xml"
    f_name_full = Rails.root + @harvest_path + f_name
    FileUtils::mkdir_p @harvest_path
    File.open(f_name_full, "w") { |file| file.puts full_records }
    add_xml_formatting(f_name_full, :contributing_institution => @provider.contributing_institution, :collection_name => @provider.collection_name)
    redirect_to providers_url, notice: "Provider harvested"
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_provider
      @provider = Provider.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def provider_params
      params.require(:provider).permit(:name, :description, :endpoint_url, :metadata_prefix, :set, :contributing_institution, :collection_name)
    end

    def add_xml_formatting(xml_file, options = {})
      contributing_institution = options[:contributing_institution] || ''
          collection_name = options[:collection_name] || ''
      new_file = "/tmp/xml_hold_file.xml"
      xml_heading = '<?xml version="1.0" encoding="UTF-8"?>'
      unless File.open(xml_file).each_line.any?{|line| line.include?(xml_heading)}
        fopen = File.open(xml_file)
        xml_file_contents = fopen.read
        xml_open = "<records>"
        xml_close = "</records>"
        xml_manifest = get_xml_manifest(contributing_institution, collection_name)
        fopen.close
        File.open(new_file, 'w') do |f|  
          f.puts xml_heading
          f.puts xml_open
          f.puts xml_manifest
          f.puts xml_file_contents
          f.puts xml_close
          File.rename(new_file, xml_file)
          f.close
        end
      end

    end

    def get_xml_manifest(contributing_institution, collection_name)
      harvest_s = @harvest_path.to_s
      converted_s = @converted_path.to_s
      partner_s = @partner.to_s
      xml_manifest = "<manifest><partner>#{partner_s}</partner><contributing_institution>#{contributing_institution}</contributing_institution><collection_name>#{collection_name}</collection_name><harvest_data_directory>#{harvest_s}</harvest_data_directory><converted_foxml_directory>#{converted_s}</converted_foxml_directory></manifest>"
      return xml_manifest
    end

end
