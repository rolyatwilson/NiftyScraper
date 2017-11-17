#!/usr/bin/env ruby

require_relative '../lib/nifty_scraper'

module NiftyScraper
  module CLI
    class Main < Thor
      desc 'wiki_states', 'Nifty Scraper'
      def wiki_states
        data = WikiStates.parse
        WikiStates.write_json_file(data)
        puts 'So Nifty! \o/'
      end

      default_command :wiki_states
    end
  end
end

NiftyScraper::CLI::Main.start(ARGV)
