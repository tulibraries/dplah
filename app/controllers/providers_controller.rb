class ProvidersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_provider, only: [:show, :edit, :update, :destroy, :harvest, :dump_and_reindex_by_institution, :dump_and_reindex_by_set]

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
        format.html { redirect_to @provider, notice: 'OAI seed was successfully created.' }
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
        format.html { redirect_to @provider, notice: 'OAI seed was successfully updated.' }
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
      format.html { redirect_to providers_url, notice: 'OAI seed was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def harvest
    rec_count = HarvestUtils.harvest_action(@provider)
    redirect_to providers_url, notice: "#{rec_count} records harvested from OAI seed"
  end

  def dump_and_reindex_by_institution
    rec_count = HarvestUtils.cleanout_and_reindex(@provider,  :reindex_by => "institution")
    redirect_to providers_url, notice: "#{rec_count} records removed from aggregator index"
  end

  def dump_and_reindex_by_set
    rec_count = HarvestUtils.cleanout_and_reindex(@provider, :reindex_by => "set")
    redirect_to providers_url, notice: "#{rec_count} records removed from aggregator index"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_provider
      @provider = Provider.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def provider_params
      params.require(:provider).permit(:name, :description, :endpoint_url, :new_endpoint_url, :email, :metadata_prefix, :set, :contributing_institution, :new_contributing_institution, :collection_name, :in_production, :provider_id_prefix, :new_provider_id_prefix, :common_repository_type)
    end

end
