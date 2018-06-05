require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe OaiRecsController, :type => :controller do
skip "TRAVIS-CI Fails: 503 Service Unavailable" do

  # This should return the minimal set of attributes required to create a valid
  # OaiRec. As you add validations to OaiRec, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    rec = FactoryGirl.build(:oai_rec).attributes
    # There is no id field in oai_rec
    rec.delete('id') if rec.has_key?('id')
    rec
  }

  let(:invalid_attributes) {
    rec = FactoryGirl.build(:oai_rec_invalid).attributes
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # OaiRecsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before (:each) do
    # Clean out all records
    ActiveFedora::Base.destroy_all
  end

  describe "GET index" do
    it "assigns all oai_recs as @oai_recs" do
      oai_rec = OaiRec.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:oai_recs)).to eq([oai_rec])
    end
  end

  describe "GET show" do
    it "assigns the requested oai_rec as @oai_rec" do
      oai_rec = OaiRec.create! valid_attributes
      get :show, {:id => oai_rec.to_param}, valid_session
      expect(assigns(:oai_rec)).to eq(oai_rec)
    end
  end

  describe "GET new" do
    it "assigns a new oai_rec as @oai_rec" do
      get :new, {}, valid_session
      expect(assigns(:oai_rec)).to be_a_new(OaiRec)
    end
  end

  describe "GET edit" do
    it "assigns the requested oai_rec as @oai_rec" do
      oai_rec = OaiRec.create! valid_attributes
      get :edit, {:id => oai_rec.to_param}, valid_session
      expect(assigns(:oai_rec)).to eq(oai_rec)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new OaiRec" do
        expect {
          post :create, {:oai_rec => valid_attributes}, valid_session
        }.to change(OaiRec, :count).by(1)
      end

      it "assigns a newly created oai_rec as @oai_rec" do
        post :create, {:oai_rec => valid_attributes}, valid_session
        expect(assigns(:oai_rec)).to be_a(OaiRec)
        expect(assigns(:oai_rec)).to be_persisted
      end

      it "redirects to the created oai_rec" do
        post :create, {:oai_rec => valid_attributes}, valid_session
        expect(response).to redirect_to(OaiRec.last)
      end
    end

    describe "with invalid params" do
      xit "assigns a newly created but unsaved oai_rec as @oai_rec" do
        post :create, {:oai_rec => invalid_attributes}, valid_session
        expect(assigns(:oai_rec)).to be_a_new(OaiRec)
      end

      xit "re-renders the 'new' template" do
        post :create, {:oai_rec => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested oai_rec" do
        oai_rec = OaiRec.create! valid_attributes
        put :update, {:id => oai_rec.to_param, :oai_rec => new_attributes}, valid_session
        oai_rec.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested oai_rec as @oai_rec" do
        oai_rec = OaiRec.create! valid_attributes
        put :update, {:id => oai_rec.to_param, :oai_rec => valid_attributes}, valid_session
        expect(assigns(:oai_rec)).to eq(oai_rec)
      end

      it "redirects to the oai_rec" do
        oai_rec = OaiRec.create! valid_attributes
        put :update, {:id => oai_rec.to_param, :oai_rec => valid_attributes}, valid_session
        expect(response).to redirect_to(oai_rec)
      end
    end

    describe "with invalid params" do
      xit "assigns the oai_rec as @oai_rec" do
        oai_rec = OaiRec.create! valid_attributes
        put :update, {:id => oai_rec.to_param, :oai_rec => invalid_attributes}, valid_session
        expect(assigns(:oai_rec)).to eq(oai_rec)
      end

      xit "re-renders the 'edit' template" do
        oai_rec = OaiRec.create! valid_attributes
        put :update, {:id => oai_rec.to_param, :oai_rec => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested oai_rec" do
      oai_rec = OaiRec.create! valid_attributes
      expect {
        delete :destroy, {:id => oai_rec.to_param}, valid_session
      }.to change(OaiRec, :count).by(-1)
    end

    it "redirects to the oai_recs list" do
      oai_rec = OaiRec.create! valid_attributes
      delete :destroy, {:id => oai_rec.to_param}, valid_session
      expect(response).to redirect_to(oai_recs_url)
    end
  end

end #Skip
end
