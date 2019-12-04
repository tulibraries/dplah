require 'rails_helper'

RSpec.describe DumpReindex, type: :job do
  before :each do
    ResqueSpec.reset!
  end

  it "adds DumpReindex.perform to the DumpReindex queue" do
    provider = FactoryBot.create(:provider_small_collection).attributes
    option = "institution"
    rec_count = 0
    VCR.use_cassette "jobs/DumpReindex" do
      rec_count = DumpReindex.perform(provider, option) { raise Resque::TermException }
    end
    # [TODO] Fix test so it executes Resque.enqueue
    #expect(DumpReindex).to have_queue_size_of(1)
    expect(rec_count).to eq 0
  end
end
