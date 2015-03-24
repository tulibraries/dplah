class Harvest
  include Resque::Plugins::Status
  def self.perform(name, provider)
  	ruby_obj = JSON.parse(provider.to_json)
    provider_obj = Provider.find(ruby_obj["id"])
  	rec_count = HarvestUtils.harvest_action(provider_obj)
    set_status({"my variable" => "my value" })	
	rescue Resque::TermException
	  Resque.enqueue(self, key)
  end
end
