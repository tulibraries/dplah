module TermMatchers
  RSpec::Matchers.define :have_term do |name|
    match do |target|
      target.class.terminology.has_term?(name)
    end
  end

end