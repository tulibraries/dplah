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
    thumbnail_pattern "http://example.com/oai/$1/thumbnails/$2.jpg"
    thumbnail_token_1 "thumbnail_token_1"
    thumbnail_token_2 "thumbnail_token_2"
  end

  factory :provider_small_collection, class: Provider do
    name "SCRC Photographs"
    collection_name "SCRC Photographs"
    description "Collection description"
    endpoint_url "http://cdm16002.contentdm.oclc.org/oai/oai.php"
    metadata_prefix "oai_dc"
    set "p16002coll2"
    provider_id_prefix "temple"
    contributing_institution "Temple University"
    email "temple@example.com"
  end

  factory :edited_provider_small_collection, class: Provider do
    name "SCRC Photographs"
    collection_name "SCRC Photographs"
    description "Edited collection description"
    endpoint_url "http://cdm16002.contentdm.oclc.org/oai/oai.php"
    metadata_prefix "oai_dc"
    set "p16002coll2"
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
    name "SCRC Photographs"
    collection_name "SCRC Photographs"
    description "Collection description"
    endpoint_url "http://cdm16002.contentdm.oclc.org/oai/oai.php"
    metadata_prefix "oai_dc"
    set "p16002coll2"
    sequence(:provider_id_prefix) { |n| "temple#{n}" }
    sequence(:email) { |n| "temple#{n}@example.com" }
    contributing_institution "Temple University"
  end

  factory :invalid_provider, class: Provider do
    name "SCRC Photographs"
    collection_name "SCRC Photographs"
    description "Collection description"
    endpoint_url ""
    metadata_prefix "oai_dc"
    set "p16002coll2"
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

  factory :provider_upenn_wheeler, class: Provider do
    name "UPENN Wheeler Images"
    collection_name "Wheeler Image Collection"
    description ""
    endpoint_url "http://dla.library.upenn.edu/dla/wheeler/oai-pmh.xml"
    metadata_prefix "oai_dc"
    set ""
    provider_id_prefix "UPENNWHL"
    contributing_institution "University of Pennsylvania"
    email ""
    thumbnail_pattern "https://repo.library.upenn.edu/thumbs/$1.jpg"
    thumbnail_token_1 "identifier"
    thumbnail_token_2 ""
  end

  factory :provider_upenn_holyland, class: Provider do
    name "UPENN Holy Land"
    collection_name "Holy Land Digital Image Collections"
    description ""
    endpoint_url "http://dla.library.upenn.edu/dla/holyland/oai-pmh.xml"
    metadata_prefix "oai_dc"
    set ""
    provider_id_prefix "UPENNHOL"
    contributing_institution "University of Pennsylvania"
    email ""
    thumbnail_pattern "https://repo.library.upenn.edu/thumbs/$1.jpg"
    thumbnail_token_1 "identifier"
    thumbnail_token_2 ""
  end

  factory :provider_upenn_archives, class: Provider do
    name "UPENN Archives Photos"
    collection_name "University Archives Digital Image Collection"
    description ""
    endpoint_url "http://dla.library.upenn.edu/dla/archives/oai-pmh.xml"
    metadata_prefix "oai_dc"
    set ""
    provider_id_prefix "UPENNARC"
    contributing_institution "University of Pennsylvania"
    email ""
    thumbnail_pattern "https://repo.library.upenn.edu/thumbs/$1.jpg"
    thumbnail_token_1 "identifier"
    thumbnail_token_2 ""
  end
end
