# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :provider do
    name "Institution Name"
    description "Collection description"
    endpoint_url "http://example.com"
    metadata_prefix "oai_dc"
    set "setname"
    contributing_institution "The Contributing Instition"
  end
end
