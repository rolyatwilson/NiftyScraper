require_relative '../lib/nifty_scraper'

RSpec.configure do |c|
  c.raise_errors_for_deprecations!
  c.color = true
end

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = File.expand_path(File.join(__dir__, 'fixtures', 'cassettes'))
  c.configure_rspec_metadata!
  c.default_cassette_options = { record: :new_episodes }
  c.hook_into :webmock
end
