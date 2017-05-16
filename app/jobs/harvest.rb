class Harvest
	
  @queue = :harvest
  def self.perform(provider)
	  dbg_logger ||= Logger.new("job-debug.log")
  	ruby_obj = JSON.parse(provider.to_json)
    provider_obj = Provider.find(ruby_obj["id"])
    dbg_logger.info "Harvest.perform: contributing_institution #{provider_obj.contributing_institution}"
  	rec_count = HarvestUtils.harvest_action(provider_obj)
  end
end
