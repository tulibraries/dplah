class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller 
   include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  layout 'blacklight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def harvest_all_providers
    Provider.all.select { |x| Time.now > x.next_harvest_at }.each do |provider|
      HarvestUtils.harvest_action(provider)
    end
    redirect_to providers_url, notice: "All OAI seeds harvested"

  end

  def dump_whole_index
    HarvestUtils.delete_all
    redirect_to providers_url, notice: "Index deleted from Aggregator"
  end

end
