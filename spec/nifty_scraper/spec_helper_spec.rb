require_relative '../spec_helper'

describe 'states' do
  subject{ @states }
  it { is_expected.to be_a(Array) }
  it { is_expected.not_to be_empty }
end
