
# Make sure external requirements are present
command -v redis-server >/dev/null 2>&1 || { echo >&2 "Redis server should be installed  Aborting."; exit 1; }

command -v xsltproc >/dev/null 2>&1 || { echo >&2 "xsltproc should be available at the command line, but it's not installed.  Aborting."; exit 1; }

# copy config files into place

cp -n config/dpla.yml.example config/dpla.yml
cp -n config/database.yml.example config/database.yml
cp -n config/facets.yml.example config/facets.yml
cp -n config/fedora.yml.example config/fedora.yml
cp -n config/jetty.yml.example config/jetty.yml
cp -n config/resque-pool.yml.example config/resque-pool.yml
cp -n config/secrets.yml.example config/secrets.yml
cp -n config/solr.yml.example config/solr.yml


bundle install

bundle exec rake db:migrate
bundle exec rails g jetty
bundle exec rake jetty:config

bundle exec rake jetty:start

sleep 10

rails server -d

RAILS_ENV=development resque-pool --daemon
