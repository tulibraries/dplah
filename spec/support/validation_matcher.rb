module ValidationMatchers
  RSpec::Matchers.define :be_valid do
    match do |target|
      not target.valid?
    end
  end

end
