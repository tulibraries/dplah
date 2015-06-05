# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :oai_rec do
    sequence(:title) { |n| ["Record Title #{n}"]}
    creator ["Record creator"]
    subject ["Record subject"]
    description ["Record description"]
    publisher ["Record publisher"]
    contributor ["Record contributor"]
    date ["2014"]
    type ["Rec%ype"]
    format ["Record format"]
    identifier ["Record identifier"]
    source ["Record source"]
    language ["Record language"]
    relation ["Record relation"]
    coverage ["Record coverage"]
    rights ["Record rights"]
	  common_repository_type ["Record common repository type"]
	  endpoint_url ["http://example.com"]
	  thumbnail ["http://example.com/thumbnail.jpg"]
    contributing_institution ["Record contributing institution"]
	  intermediate_provider ["Record intermediate provider"]
	  collection_name ["Record collection name"]
    partner ["Record partner"]
	  set_spec ["Record set"]
	  provider_id_prefix ["Record provider id prefix"]
  end
  
  factory :oai_rec_invalid, class: OaiRec do
    sequence(:title) { |n| ["Record Title #{n}"]}
    creator ["Record creator"]
    subject ["Record subject"]
    description ["Record description"]
    publisher ["Record publisher"]
    contributor ["Record contributor"]
    date ["2014"]
    type ["Rec%ype"]
    format ["Record format"]
    identifier ["Record identifier"]
    source ["Record source"]
    language ["Record language"]
    relation ["Record relation"]
    coverage ["Record coverage"]
    rights ["Record rights"]
	  common_repository_type ["Record common repository type"]
	  endpoint_url ["bad!//badurl"]
	  thumbnail ["bad!!!//badurl/thumbnail.jpg"]
    contributing_institution ["Record contributing institution"]
	  intermediate_provider ["Record intermediate provider"]
	  collection_name ["Record collection name"]
    partner ["Record partner"]
	  set_spec ["Record set"]
	  provider_id_prefix ["Record provider id prefix"]
  end
end
