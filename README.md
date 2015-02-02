#DPLAH Hydra Head README

DPLAH is a proof-of-concept aggregator for OAI-PMH metadata with additional features specific to the DPLA's discovery interface needs.

##System dependencies

* Hydra, and therefore everything Hydra needs
* xsltproc for processing XSLT at the command line
* Apache for serving harvesting logs in the browser, and for later production deployment

##Configuration

To use this head, create a file under "config/dpla.yml" and add the following:

```yaml
harvest_data_directory: "/path/to/metadata/from/contributors"
converted_foxml_directory: "/path/to/foxml/converted/metadata"
pid_prefix: "changeme"
partner: "Name of hub"
human_log_path: '/abs/path/to/log/files'
human_log_url: 'http://fullurltologfiles'

```

Substitute your own values as follows for the YML fields:

* **harvest_data_directory**
..Value of the absolute location on your filesystem where you want the application to store harvested, unprocessed metadata from providers
* **converted_foxml_directory**
..Value of the absolute location on your filesystem where you want the application to store converted FOXML files generated from the harvested metadata, for ingestion into Fedora
* **pid_prefix**
..The namespace for your Fedora objects
* **partner**
..The name of the DPLA Partner hub
* **human_log_path**
..Absolute path on the file system where the OAI management logs should go
* **human_log_url**
..Full clickable URL path to the directory on your web server where OAI management logs live

##Start up locally

To start up locally, be sure you have jetty installed and configured, and all tables are migrated (can use the following commands if needed):

```
rake db:migrate
rails g hydra:jetty
rake jetty:config
rake jetty:start
```

##Credit
Some code in this project (and much research) is based on the talented Chris Beer's work in the following invaluable repos:
* [Blacklight OAI Provider](https://github.com/cbeer/blacklight_oai_provider)
* [Blacklight OAI Harvester Demo](https://github.com/cbeer/blacklight_oai_harvester_demo)

##Tests
Coming soon!  Promise.

###Deployment instructions
* Clone the repository locally.
* Run Hydra generators/set up jetty/tomcat, etc.
* Start Fedora/Solr services.
* Start the Rails server.

###Managing OAI Seeds
* To begin harvesting, go to the relative path "/providers" (the "Manage OAI Seeds" dashboard) and input data for an OAI-PMH harvestable repository (see "OAI Resources" below for tips on getting started)
* Save the provider.
* From the dashboard, click the "Harvest from OAI Source" button in the OAI seeds table.  You should see the ajax spinner and a prompt to check the harvesting logs.  Click this link to go to the directory listing page of OAI management logs.  These are textual logs created every time an OAI seed action is performed from within the dashboard (that is, harvest, delete, etc).  Harvesting/ingesting and deleting from the index can take a while, especially for seeds with many records, so you can monitor the progress of an ingest by refreshing the textual log periodically.  
* Go to your Hydra head in the browser to see if the metadata was harvested and has been made discoverable. 

####More Actions for OAI Seeds
* From the dashboard, you may delete all records from a collection, from an institution, or delete all records in the aggregator.  You can also re-harvest records from seeds (not deleting before doing so will result in duplication), and harvest everything available from all seeds via the actions underneath the OAI seeds table.

###Rake tasks

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

*In the terminal, run the following:
```
rake oai:harvest_ingest_all 
```
This will harvest, convert, normalize, and ingest all OAI-PMH records from all OAI seeds in the Hydra head into the repository.

*In the terminal, run the following:
```
rake oai:delete_all 
```
This will delete all harvested records from the local repository. 

##OAI-PMH Resources
* [OAI-PMH for Beginners Tutorial](http://www.oaforum.org/tutorial/)
* [Sample OAI-PMH Requests from the Library of Congress](http://memory.loc.gov/ammem/oamh/oai_request.html)
* [Open Archives Registered Data Providers](http://www.openarchives.org/Register/BrowseSites)
  * Note with this one, not all listed necessarily still provide OAI-PMH metadata in a harvestable format

