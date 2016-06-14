class HarvestAllByInstitution
  @queue = :harvest
  def self.perform(provider)
  	ruby_obj = JSON.parse(provider.to_json)
    provider_obj = Provider.find(ruby_obj["id"])
  	rec_count = HarvestUtils.harvest_action_all(provider_obj)
  end
end

