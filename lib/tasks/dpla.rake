namespace :dpla do

  """
  This command compares the records in the local fedora instance with the a file of
  ids from the DPLA. The easiest way to generate the file of ids is to download the
  latest bulk export of Pennsylvania data from https://dp.la/info/developers/download/
  and then use jq to extract the is. An example command would be:

  gunzip -c pennsylvania.json.gz |jq --raw-output '.[] ._id' > dpla_pa_ids

  """

  desc 'Compares records in Aggregator a list of record IDs from DPLA bulk download'
  task :compare_with, [:file] => :environment do |t, args|

    dpla_ids = open(args[:file]).read.split

    # TODO: Extract to config file
    prefix = "oai:libcollab.temple.edu:"
    link_base = "http://libcollab.temple.edu/aggregator/catalog"

    local_pids = {}
    ActiveFedora::RubydoraConnection.new(ActiveFedora.config.credentials).connection.search(nil) do |object|
      next if object.pid.start_with?('fedora-system:')
      local_pids["#{prefix}#{object.pid}"] = object.pid
    end

    pids_not_in_dpla = local_pids.keys - dpla_ids

    CSV.open("tmp/not-in-dpla-#{Time.now.to_formatted_s(:number)}.csv", 'w', headers: true) do |csv|
      csv << ['id', 'title', 'contributing institution', 'collection name', 'url']

      pids_not_in_dpla.each do |pid|
        rec = OaiRec.find(local_pids[pid])
        csv << [rec.pid, rec.title[0], rec.contributing_institution, rec.collection_name, "#{link_base}/#{rec.pid}"]
      end
    end
  end
end
