class ProvidersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_provider, only: [:show, :edit, :update, :destroy, :harvest, :dump_and_reindex_by_institution, :dump_and_reindex_by_set]

  def index
    @providers = Provider.all
  end

  def show
  end

  def new
    @provider = Provider.new
  end

  def edit
  end

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

  def destroy
    @provider.destroy
    respond_to do |format|
      format.html { redirect_to providers_url, notice: 'OAI seed was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def harvest
    queue_name = "harvest"
    Resque.enqueue(Harvest, @provider)
    redirect_to providers_url, notice: "Seed is harvesting in the background.  Currently at position ##{Resque.size(queue_name)} in the queue."
  end

  def dump_and_reindex_by_institution
    queue_name = "delete"
    Resque.enqueue(DumpReindex, @provider, "institution")
    redirect_to providers_url, notice: "Records are being removed from aggregator index for institution provider.contributing_institution}. Currently at position ##{Resque.size(queue_name)} in the queue."
  end

  def dump_and_reindex_by_set
    queue_name = "delete"
    Resque.enqueue(DumpReindex, @provider, "set")
    redirect_to providers_url, notice: "Records are being removed from aggregator index for set  \"#{@provider.set}.\" Currently at position ##{Resque.size(queue_name)} in the queue."
  end

  private
    def set_provider
      @provider = Provider.find(params[:id])
    end

    def provider_params
      params.require(:provider).permit(:name, :description, :endpoint_url, :new_endpoint_url, :email, :new_email, :metadata_prefix, :set, :contributing_institution, :new_contributing_institution, :intermediate_provider, :new_intermediate_provider, :collection_name, :in_production, :provider_id_prefix, :new_provider_id_prefix, :common_repository_type, :thumbnail_pattern, :thumbnail_token_1, :thumbnail_token_2)
    end

end
