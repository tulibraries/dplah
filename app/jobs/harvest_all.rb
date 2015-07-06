class HarvestAll
  @queue = :harvest
  def self.perform()
  	HarvestUtils.harvest_all()
  end
end

