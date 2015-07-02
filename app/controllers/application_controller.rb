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
    queue_name = "harvest"
    workers = "workers"
    Resque.enqueue(HarvestAll)
    redirect_to providers_url, notice: "All OAI seeds being harvested.  Currently at position ##{Resque.size(queue_name) + Resque.working.size} in the queue. #{Resque.working.size} #{workers.pluralize(Resque.working.size)} currently working on a task."
  end

  def dump_whole_index
    queue_name = "delete"
    workers = "workers"
    Resque.enqueue(DumpWholeIndex)
    redirect_to providers_url, notice: "All records are now being deleted from the aggregator index.  Currently at position ##{Resque.size(queue_name) + Resque.working.size} in the queue. #{Resque.working.size} #{workers.pluralize(Resque.working.size)} currently working on a task."
  end

end
