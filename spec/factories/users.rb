# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :user do
    email {"fred@example.com"}
    password {"fredpa55"}
    password_confirmation {"fredpa55"}
  end
end
