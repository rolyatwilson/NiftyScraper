#!/usr/bin/env ruby

require_relative '../lib/nifty_scrapper'

module NiftyScrapper
  module CLI
    class Main < Thor
      desc 'wiki_states', 'Nifty Scrapper'
      def wiki_states
        data = WikiStates.parse
        WikiStates.write_json_file(data)
        puts 'So Nifty! \o/'
      end

      default_command :wiki_states
    end
  end
end

NiftyScrapper::CLI::Main.start(ARGV)
