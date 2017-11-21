require 'rubygems'
require 'active_support/core_ext/hash/keys'
require 'json'
require 'open-uri'
require 'nokogiri'
require 'thor'

require_relative 'nifty_scraper/wiki_states'
require_relative 'nifty_scraper/borders'
require_relative 'nifty_scraper/merger'

module NiftyScraper
  def self.write_json_file(data, path)
    File.open(path, 'w') { |f| f.write(JSON.pretty_generate(JSON[data.to_json])) }
  end
end
