# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :provider do
    name "Institution Name"
    collection_name "Collection Name"
    description "Collection description"
    endpoint_url "http://example.com"
    metadata_prefix "oai_dc"
    set "setname"
    contributing_institution "The Contributing Instition"
  end

  factory :provider_small_collection, class: Provider do
    name "Voices of Lycoming"
    collection_name "Voices of Lycoming"
    description "Collection description"
    endpoint_url "http://contentdm1.accesspa.org/oai/oai.php"
    metadata_prefix "oai_dc"
    set "alycc-voice"
    contributing_institution "POWER Library"
  end

  factory :provider_transient_records, class: Provider do
    name "Thomas W. Benson Political Protest Collection"
    collection_name "Thomas W. Benson Political Protest Collection"
    description "Collection description"
    endpoint_url "http://collection1.libraries.psu.edu/oai/oai.php"
    metadata_prefix "oai_dc"
    set "benson"
    contributing_institution "Penn State"
  end
end
