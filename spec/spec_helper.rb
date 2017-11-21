require_relative '../lib/nifty_scraper'

RSpec.configure do |c|
  c.raise_errors_for_deprecations!
  c.color = true
  c.before(:example) do
    @states = ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'].map { |state| state.to_sym }
  end
end

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = File.expand_path(File.join(__dir__, 'fixtures', 'cassettes'))
  c.configure_rspec_metadata!
  c.default_cassette_options = { record: :new_episodes }
  c.hook_into :webmock
end
