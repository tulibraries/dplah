# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :provider do
    name "Institution Name"
    collection_name "Collection Name"
    description "Collection description"
    endpoint_url "http://example.com"
    metadata_prefix "oai_dc"
    set "setname"
    provider_id_prefix "prvdr"
    contributing_institution "The Contributing Instition"
    email "provider@example.com"
    thumbnail_pattern "http://repository.org/oai/$1/thumbnails/$2.jpg"
    thumbnail_token_1 "thumbnail_token_1"
    thumbnail_token_2 "thumbnail_token_2"
  end

  factory :provider_small_collection, class: Provider do
    name "SCRC Ephemera"
    collection_name "SCRC Ephemera"
    description "Collection description"
    endpoint_url "http://cdm16002.contentdm.oclc.org/oai/oai.php"
    metadata_prefix "oai_dc"
    set "p16002coll6"
    provider_id_prefix "temple"
    contributing_institution "Temple University"
    email "temple@example.com"
  end

  factory :edited_provider_small_collection, class: Provider do
    name "SCRC Ephemera"
    collection_name "SCRC Ephemera"
    description "Edited collection description"
    endpoint_url "http://cdm16002.contentdm.oclc.org/oai/oai.php"
    metadata_prefix "oai_dc"
    set "p16002coll6"
    provider_id_prefix "temple"
    contributing_institution "Temple University"
    email "temple@example.com"
  end

  factory :provider_transient_records, class: Provider do
    name "Thomas W. Benson Political Protest Collection"
    collection_name "Thomas W. Benson Political Protest Collection"
    description "Collection description"
    endpoint_url "http://collection1.libraries.psu.edu/oai/oai.php"
    metadata_prefix "oai_dc"
    provider_id_prefix "psu"
    set "benson"
    contributing_institution "Penn State"
  end

  factory :multiple_providers, class: Provider do
    name "SCRC Ephemera"
    collection_name "SCRC Ephemera"
    description "Collection description"
    endpoint_url "http://cdm16002.contentdm.oclc.org/oai/oai.php"
    metadata_prefix "oai_dc"
    set "p16002coll6"
    sequence(:provider_id_prefix) { |n| "temple#{n}" }
    sequence(:email) { |n| "temple#{n}@example.com" }
    contributing_institution "Temple University"
  end

  factory :invalid_provider, class: Provider do
    name "SCRC Ephemera"
    collection_name "SCRC Ephemera"
    description "Collection description"
    endpoint_url ""
    metadata_prefix "oai_dc"
    set "p16002coll6"
    provider_id_prefix "temple"
    contributing_institution "Temple University"
    email "temple@example.com"
  end

  factory :provider_resumption_token, class: Provider do
    name "Benson Collection"
    collection_name "Thomas W. Benson Political Protest Collection"
    description "Collection description"
    endpoint_url "http://collection1.libraries.psu.edu/oai/oai.php"
    metadata_prefix "oai_dc"
    set "benson"
    provider_id_prefix "psu"
    contributing_institution "Penn State"
    email "psu@example.com"
  end

end
