
# Make sure external requirements are present
command -v redis-server >/dev/null 2>&1 || { echo >&2 "Redis server should be installed  Aborting."; exit 1; }

command -v xsltproc >/dev/null 2>&1 || { echo >&2 "xsltproc should be available at the command line, but it's not installed.  Aborting."; exit 1; }

# copy config files into place

cp config/dpla.yml.example config/dpla.yml
cp config/database.yml.example config/database.yml
cp config/fedora.yml.example config/fedora.yml
cp config/jetty.yml.example config/jetty.yml
cp config/resque-pool.yml.example config/resque-pool.yml
cp config/secrets.yml.example config/secrets.yml
cp config/solr.yml.example config/solr.yml


bundle install

bundle exec rake db:migrate
bundle exec rails g hydra:jetty
bundle exec rake jetty:config

bundle exec rake jetty:start

sleep 10

rails server -d 

RAILS_ENV=development resque-pool --daemon 
