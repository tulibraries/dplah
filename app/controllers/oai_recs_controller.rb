class OaiRecsController < ApplicationController
  before_action :set_oai_rec, only: [:show, :edit, :update, :destroy]

  # GET /oai_recs
  # GET /oai_recs.json
  def index
    @oai_recs = OaiRec.all
  end

  # GET /oai_recs/1
  # GET /oai_recs/1.json
  def show
  end

  # GET /oai_recs/new
  def new
    @oai_rec = OaiRec.new
  end

  # GET /oai_recs/1/edit
  def edit
  end

  # POST /oai_recs
  # POST /oai_recs.json
  def create
    @oai_rec = OaiRec.new(oai_rec_params)

    respond_to do |format|
      if @oai_rec.save
        format.html { redirect_to @oai_rec, notice: 'Oai rec was successfully created.' }
        format.json { render :show, status: :created, location: @oai_rec }
      else
        format.html { render :new }
        format.json { render json: @oai_rec.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /oai_recs/1
  # PATCH/PUT /oai_recs/1.json
  def update
    respond_to do |format|
      if @oai_rec.update(oai_rec_params)
        format.html { redirect_to @oai_rec, notice: 'Oai rec was successfully updated.' }
        format.json { render :show, status: :ok, location: @oai_rec }
      else
        format.html { render :edit }
        format.json { render json: @oai_rec.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /oai_recs/1
  # DELETE /oai_recs/1.json
  def destroy
    @oai_rec.destroy
    respond_to do |format|
      format.html { redirect_to oai_recs_url, notice: 'Oai rec was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_oai_rec
      @oai_rec = OaiRec.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def oai_rec_params
      params.require(:oai_rec).permit(:title, :creator, :subject, :description, :publisher, :contributor, :date, :type, :format, :identifier, :source, :language, :relation, :coverage, :rights)
    end
end
