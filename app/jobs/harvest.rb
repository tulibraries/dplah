class Harvest
  @queue = :harvest
  def self.perform(provider)
  	sleep(10)
  	rec_count = HarvestUtils.harvest_action(provider)
  end
end
