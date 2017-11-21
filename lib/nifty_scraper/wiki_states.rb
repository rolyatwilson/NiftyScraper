module NiftyScraper
  class WikiStates
    class << self
      def url
        @url ||= 'https://en.wikipedia.org/wiki/List_of_states_and_territories_of_the_United_States'
      end

      def clean(text, downcase = true)
        # just trim whitespace for numbers
        return text.strip if text.strip =~ /\A[0-9]+/

        # strip off useless characters, eg: "Population\n[B][10]", "Reps."
        # strip off leading special characters: eg: "@@North Dakota", ND has 2, others have 1 ¯\_(ツ)_/¯
        t = text.strip.gsub(/\A[^a-zA-Z]*|\s?\[\S+\]?|\./, '')
        t.downcase! if downcase
        t
      end

      def to_snake(text)
        text.gsub(/\s/, '_')
      end

      def sanitize(text)
        to_snake(clean(text))
      end

      def default_path
        @default_path ||= File.expand_path(File.join(__dir__, '../../results', 'states.json'))
      end

      def write_json_file(data, path = default_path)
        File.open(path, 'w') { |f| f.write(JSON.pretty_generate(JSON[data.to_json])) }
      end

      def headers
        @headers ||= %i{name postal_abbreviation capital_city largest_city established population total_area_mi2 total_area_km2 land_area_mi2 land_area_km2 water_area_mi2 water_area_km2 reps}
      end

      def parse
        document = Nokogiri::HTML(open(url))
        data     = {}

        document.at('table').search('tr').each_with_index do |row, index|
          next if index < 2

          # state data
          # th contains state name, td contains all other data
          state_name = clean(row.search('th').text, false)
          object     = {}
          cells      = row.search('td').map { |cell| clean(cell.text, false) }

          # some states have 1 less cell because their capital city is also their largest city
          cells.insert(1, cells[1]) if cells.length == 11

          cells.each_with_index do |cell, index|
            object[headers[index + 1]] = cell
          end

          # data[state] << object
          data[state_name] = object
        end
        data.deep_symbolize_keys
      end
    end
  end
end
