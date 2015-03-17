class DumpReindexInstitution
  @queue = :harvest
  def self.perform(provider, institution)
  	ruby_obj = JSON.parse(provider.to_json)
    provider_obj = Provider.find(ruby_obj["id"])
  	rec_count = HarvestUtils.cleanout_and_reindex(provider_obj,  :reindex_by => "#{institution}")
  end
end
