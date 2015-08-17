#DPLAH Hydra Head README

DPLAH is a proof-of-concept aggregator for OAI-PMH metadata with additional features specific to the DPLA's discovery interface needs.

##System dependencies

* [Hydra](https://github.com/projecthydra) and therefore everything Hydra needs
* [Redis](http://redis.io/) key-value store
* [xsltproc](http://xmlsoft.org/XSLT/xsltproc.html) for processing XSLT at the command line
* [tcl](http://www.tcl.tk/) for supporting make test in Redis
* [Apache](http://httpd.apache.org/) for serving harvesting logs in the browser, and for later production deployment

##Clone the source files

Clone the Hydra head from the Git repository:

```bash
git clone https://github.com/tulibraries/dplah.git
```

Execute the remaining tasks from the Hydra head application directory:

```bash
cd dplah
```

##Configuration

To use this head, create a file under "`config/dpla.yml`" (you may copy the example file, "`config/dpla.yml.example`" and add the following:

```yaml
harvest_data_directory: "/path/to/metadata/from/contributors"
converted_foxml_directory: "/path/to/foxml/converted/metadata"
pid_prefix: "changeme"
partner: "Name of hub"
human_log_path: '/abs/path/to/log/files'
human_log_url: 'http://fullurltologfiles'
email_sender: "from@example.edu"
email_recipient: "to@example.edu"
noharvest_stopword: "string_in_record_metadata_that_signals_not_to_harvest"
```

Substitute your own values as follows for the YML fields:

* `harvest_data_directory` refers to the value of the absolute location on your filesystem where you want the application to store harvested, unprocessed metadata from providers
* `converted_foxml_directory` refers to the value of the absolute location on your filesystem where you want the application to store converted FOXML files generated from the harvested metadata, for ingestion into Fedora
* `pid_prefix` refers to the namespace for your Fedora objects
* `partner` refers to the name of the DPLA Partner hub
* `human_log_path` refers to the absolute path on the file system where the OAI management logs should go
* `human_log_url` refers to the full clickable URL path to the directory on your web server where OAI management logs live
* `email_sender` refers to the sending address for harvest utility email reports
* `email_recipient` refers to the recipient address for harvest utility email reports
* `noharvest_stopword` refers to an optional string that the aggregator can use as a signal to skip over any records containing that string in their metadata, excluding it from ingest
##Start up locally

To start up locally, be sure that your pid_prefix as defined in `config/dpla.yml` matches the pid prefix in your `fedora.fcfg` file under `fedora_conf/`.

Install the Ruby necessary gems:

```bash
bundle install
```

Ensure you have jetty installed and configured, and all tables are migrated (can use the following commands if needed):

```bash
rake db:migrate
rails g hydra:jetty
rake jetty:config
```

Start the jetty server:

```bash
rake jetty:start
```

Give jetty time to start up (about 10-30 seconds) before starting the Rails application:

```bash
rails server -d -b 127.0.0.1
```

On your web browser, go to `http://localhost:3000` to verify that hydra head is up and running. If you get a SOLR connection error, wait a few more seconds for Jetty to complete its startup and try again.


##Redis and Resque

Harvest and delete jobs are backgrounded once assigned through the dashboard, with the use of Redis and Resque.  In order to do this, Redis must be installed and configured.
* [Tutorial on installing/configuring Redis on Ubuntu and CentOS from projecthydra-labs hydradam](https://github.com/projecthydra-labs/hydradam/wiki/Installation:-Redis)
* This Hydra head uses the resque-pool gem to make configuration of queues easier.  See the `config/resque-pool.yml` file for the default configuration.  It is recommended that users configure two queues for instances of this application, one for Harvest jobs and one for DumpReindex jobs.  These are set and allocate two workers per job by default.  Adjust the number of workers as needed for your application.
* To initialize a resque pool's workers, issue the following command at the terminal:
```bash
env TERM_CHILD=1 VVERBOSE=1 COUNT='NUM' QUEUE=NAME_OF_QUEUE bundle exec rake resque:workers
```
**NOTE:**
* `NUM` refers to the number of workers you want to activate in this pool
* `NAME_OF_QUEUE` refers to the name of the queue you are initializing (ie, harvest)

###Deployment instructions
* Start and verify Redis.
* Clone the repository locally.
* Run Hydra generators/set up jetty/tomcat, etc.
* Start Fedora/Solr services.
* Initiate the Resque queues you'll be using for your backgrounded harvest and delete tasks -- these default to "harvest" and "delete."
* Start the Rails server.

###Managing OAI Seeds
* To begin harvesting, go to the relative path "/providers" (the "Manage OAI Seeds" dashboard -- you will need to create a devise user account first if using the default setup) and input data for an OAI-PMH harvestable repository (see "OAI Resources" below for tips on getting started)
* Save the provider.
* From the dashboard, click the "Harvest from OAI Source" button in the OAI seeds table.  You should see the ajax spinner and a prompt to check the harvesting logs.  Click this link to go to the directory listing page of OAI management logs.  These are textual logs created every time an OAI seed action is performed from within the dashboard (that is, harvest, delete, etc).  Harvesting/ingesting and deleting from the index can take a while, especially for seeds with many records, so you can monitor the progress of an ingest by refreshing the textual log periodically.  
* Go to your Hydra head in the browser to see if the metadata was harvested and has been made discoverable.

####More Actions for OAI Seeds
* From the dashboard, you may delete all records from a collection, from an institution, or delete all records in the aggregator.  You can also re-harvest records from seeds (not deleting before doing so will result in the older ones being overwritten), and harvest everything available from all seeds via the actions underneath the OAI seeds table.  The "harvest all" and "delete all" tasks will take a while if you have many seeds, and many records in the index respectively.

###Rake tasks

* To harvest just the raw OAI from a specific OAI seed in the application, run the following in the terminal:
```
rake oai:harvest[NUM]
```
**NOTE:**
* `NUM` = the ID of the provider/OAI seed that you are attempting to harvest

This will harvest the raw OAI available from the seed, save as XML (broken into separate files on the resumption token), and place in the directory defined by "harvest_data_directory" in `config/dpla.yml`.  This can be handy if you are trying to troubleshoot XML-related issues with a seed's OAI content as it is being delivered to the hub.

* To harvest all metadata and view the immediately-delivered OAI-PMH before it is converted and ingested, go to the the command line from the root of your Rails application and run the following:
```
rake oai:harvest_all
```
If the provider is harvestable, you should see metadata fly past you in the terminal. If there are errors with the metadata, you should (hopefully) see those too.  Go to the path on your filesystem specified in dpla.yml under the "harvest_data_directory" value, and you should see an XML file containing the harvested metadata in one large file.  

* To see the FOXML output before it is ingested into the repository, go to the the command line from the root of your Rails application and run the following:
```
rake oai:convert_all
```
You should see a message displaying the absolute path to your harvested XML, stating that it was "converted." If you see errors, make sure you have xsltproc installed on your system.  If you do and you still see errors, the XML may be invalid or contain problematic characters.

* To harvest and ingest all records from all OAI seeds present in the application, run the following in the terminal:
```
rake oai:harvest_ingest_all
```
This will harvest, convert, normalize, and ingest all OAI-PMH records from all OAI seeds in the Hydra head into the repository.

* To remove all records from the aggregator index, run the following in the terminal:
```
rake oai:delete_all
```
This will delete all harvested records from the local repository.

##Tests
From within the root of your Rails application, run the following:

```
rake jetty:config
rake jetty:start
redis-server
rake spec
```

This will run the whole test suite, which may take several minutes, especially the first time.  

This application currently tests baseline functionality of Providers and OAI Records.  Additional code for scheduled harvests and less-easily-tested features of XML conversion are pending, so there should be 160 examples, 30 pending, 0 failures out of the box, if all system dependencies are up and running.

The test suite uses [rspec](https://github.com/rspec/rspec-rails), [factory_girl](https://github.com/thoughtbot/factory_girl), [vcr](https://github.com/vcr/vcr), and [resque_spec](https://github.com/leshill/resque_spec).

##OAI-PMH Resources
* [OAI-PMH for Beginners Tutorial](http://www.oaforum.org/tutorial/)
* [Sample OAI-PMH Requests from the Library of Congress](http://memory.loc.gov/ammem/oamh/oai_request.html)
* [Open Archives Registered Data Providers](http://www.openarchives.org/Register/BrowseSites)
  * Note with this one, not all listed necessarily still provide OAI-PMH metadata in a harvestable format

##Credit
This Hydra head was developed as part of the [Pennsylvania Digital Collections Project for DPLA](http://www.powerlibrary.org/librarians/special-projects-office-of-commonwealth-libraries/project-for-dpla/). [[See the Prototype](http://libcollab.temple.edu/aggregator/)]

Some code in this project (and much research) is based on the talented Chris Beer's work in the following invaluable repos:
* [Blacklight OAI Provider](https://github.com/cbeer/blacklight_oai_provider)
* [Blacklight OAI Harvester Demo](https://github.com/cbeer/blacklight_oai_harvester_demo)

##Acknowledgments

This software has been developed by and is brought to you by the Hydra community. Learn more at the [Project Hydra website](http://projecthydra.org/).

![Powered by Hydra with Hydra logo](https://github.com/uvalib/libra-oa/raw/a6564a9e5c13b7873dc883367f5e307bf715d6cf/public/images/powered_by_hydra.png?raw=true)
