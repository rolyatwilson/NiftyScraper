require_relative '../../lib/nifty_scrapper'

module NiftyScrapper
  w = WikiStates.new
  w.parse
  w
end
