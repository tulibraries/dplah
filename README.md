#DPLAH Hydra Head README

DPLAH is a proof-of-concept aggregator for OAI-PMH metadata with additional features specific to the DPLA's discovery interface needs.

##System dependencies

* Hydra, and therefore everything Hydra needs
* xsltproc for processing XSLT at the command line

##Configuration

To use this head, create a file under "config/dpla.yml" and add the following:

```yaml
harvest_data_directory: "/path/to/metadata/from/contributors"
converted_foxml_directory: "/path/to/foxml/converted/metadata"
pid_prefix: "changeme"
partner: "Name of hub"
```

##Start up locally

To start up locally, be sure you have jetty installed and configured, and all tables are migrated (can use the following commands if needed):

```
rake db:migrate
rails g hydra:jetty
rake jetty:config
rake jetty:start

```


Substitute your own values as follows for the YML fields:

* **harvest_data_directory**
  Value of the absolute location on your filesystem where you want the application to store harvested, unprocessed metadata from providers
* **converted_foxml_directory**
  Value of the absolute location on your filesystem where you want the application to store converted FOXML files generated from the harvested metadata, for ingestion into Fedora
* **pid_prefix**
  The namespace for your Fedora objects
* **partner**
  The name of the DPLA Partner hub

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
* To begin harvesting, go to the relative path "/providers" and input data for an OAI-PMH harvestable repository (see "OAI Resources" below for tips on getting started)
* Save the provider.
* At the command line, run the following:
```
rake oai:harvest
```
If the provider is harvestable, you should see metadata fly past you in the terminal. If there are errors with the metadata, you should (hopefully) see those.
* Go to the path on your filesystem specified in dpla.yml under the "harvest_data_directory" value, and you should see an XML file containing the harvested metadata from your provider.
* Back in the root of your Hydra repo, run the following:
```
rake oai:convert
```
You should see a message displaying the absolute path to your harvested XML, stating that it was "converted." If you see errors, make sure you have xsltproc installed on your system.  If you do and you still see errors, the XML may not be valid.
*In the terminal, run the following:
```
rake oai:ingest DIR=/converted_foxml_directory(THE ACTUAL PATH, NOT THIS STRING/
```
The ingest task will look at whatever relative or absolute path is given to DIR. It should match the value that you added to the dpla.yml file for "converted_foxml_directory."

* Go to your Hydra head in the browser to see if the metadata was harvested and has been made discoverable. 

##OAI-PMH Resources
* [OAI-PMH for Beginners Tutorial](http://www.oaforum.org/tutorial/)
* [Sample OAI-PMH Requests from the Library of Congress](http://memory.loc.gov/ammem/oamh/oai_request.html)
* [Open Archives Registered Data Providers](http://www.openarchives.org/Register/BrowseSites)
  * Note with this one, not all listed necessarily still provide OAI-PMH metadata in a harvestable format

