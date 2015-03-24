require 'resque'
require 'resque/job_with_status'
require 'resque/errors'

Resque.redis = "localhost:6379"
Resque::Plugins::Status::Hash.expire_in = (60*5)
