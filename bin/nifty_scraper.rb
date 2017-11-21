#!/usr/bin/env ruby

require_relative '../lib/nifty_scraper'

module NiftyScraper
  module CLI
    class Main < Thor
      desc 'wiki_states', 'Parses states and basic data from Wikipedia and outputs json to disk'
      def wiki_states
        NiftyScraper.write_json_file(WikiStates.parse, WikiStates.default_path)
        puts 'So Nifty! \o/'
      end

      desc 'start', 'Merges custom json data with scraped json data.'
      def start
        NiftyScraper.write_json_file(Merger.squash, Merger.default_path)
        puts 'So Nifty! \o/'
      end

      default_command :start
    end
  end
end

NiftyScraper::CLI::Main.start(ARGV)
