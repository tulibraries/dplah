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
  end

  factory :provider_small_collection, class: Provider do
    name "Voices of Lycoming"
    collection_name "Voices of Lycoming"
    description "Collection description"
    endpoint_url "http://contentdm1.accesspa.org/oai/oai.php"
    metadata_prefix "oai_dc"
    set "alycc-voice"
    provider_id_prefix "lycoming"
    contributing_institution "POWER Library"
    email "lycoming@example.com"
  end

  factory :edited_provider_small_collection, class: Provider do
    name "Voices of Lycoming"
    collection_name "Voices of Lycoming"
    description "Edited collection description"
    endpoint_url "http://contentdm1.accesspa.org/oai/oai.php"
    metadata_prefix "oai_dc"
    set "alycc-voice"
    provider_id_prefix "lycoming"
    contributing_institution "POWER Library"
    email "lycoming@example.com"
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
    name "Voices of Lycoming"
    collection_name "Voices of Lycoming"
    description "Collection description"
    endpoint_url "http://contentdm1.accesspa.org/oai/oai.php"
    metadata_prefix "oai_dc"
    set "alycc-voice"
    sequence(:provider_id_prefix) { |n| "lycoming#{n}" }
    sequence(:email) { |n| "lycoming#{n}@example.com" }
    contributing_institution "POWER Library"
  end

  factory :invalid_provider, class: Provider do
    name "Voices of Lycoming"
    collection_name "Voices of Lycoming"
    description "Collection description"
    endpoint_url ""
    metadata_prefix "oai_dc"
    set "alycc-voice"
    provider_id_prefix "lycoming"
    contributing_institution "POWER Library"
    email "lycoming@example.com"
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
