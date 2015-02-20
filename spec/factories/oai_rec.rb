# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :oai_rec do
    sequence(:title) { |n| "Record Title #{n}"}
    creator "Record creator"
    subject "Record subject"
    description "Record description"
    publisher "Record publisher"
    contributor "Record contributor"
    date "2014"
    type "Rec%ype"
    format "Record format"
    sequence(:identifier) { |n| "recid:#{n}"}
    source "Record source"
    language "Record language"
    relation "Record relation"
    coverage "Record coverage"
    rights "Record rights"
    contributing_institution "Record contributing institution"
    partner "Record partner"
  end
end
