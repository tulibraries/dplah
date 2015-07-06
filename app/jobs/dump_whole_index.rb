class DumpWholeIndex
  @queue = :delete
  def self.perform()
  	HarvestUtils.delete_all()
  end
end

