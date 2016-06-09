require 'rails_helper'

RSpec.describe DplaUtils do

  describe 'ID Minter' do
    let(:prefix) {'oai:libcollab.temple.edu:'}
    let(:id) { 'dplapa:TEMPLE_p15037coll3_489'}

    it 'returns the expected ID hash' do
      id_hash = '615f0221d75c72acd40ede56f7971265'
      expect(DplaUtils.id_minter(id, prefix)).to eql id_hash
    end

  end

end