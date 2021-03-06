class DumpReindex

  @queue = :delete
  def self.perform(provider, option)
  	ruby_obj = JSON.parse(provider.to_json)
    provider_obj = Provider.find(ruby_obj["id"])
  	rec_count = HarvestUtils.cleanout_and_reindex(provider_obj,  :reindex_by => "#{option}")
  	rescue Resque::TermException
	  Resque.enqueue(self, key)
  end
end
