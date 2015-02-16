require 'rails_helper'

RSpec.describe Ability, :type => :model do
  subject { Ability.new(nil) }

  it { is_expected.to respond_to(:custom_permissions) }

end
