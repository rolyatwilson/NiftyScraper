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

      # First Row -- Main Headers
      # Name & postal abbreviations | Cities | Established | Population | Total Area | Land Area | Water Area | Reps.
      def parse_main_headers(cell)
        # split "Name & postal abbreviation" into 2 headers
        tokens = cell.split('&').map do |text|
          text = sanitize(text)
          text == 'cities' ? '_city' : text
        end
        tokens
      end

      # Main Headers
      #   0  |   1    |   2    |      3      |     4      |      5     |     6     |      7     |   8   |
      # Name | Postal | Cities | Established | Population | Total Area | Land Area | Water Area | Reps. |
      #
      # Merge Main Headers with Sub Headers
      #   0  |   1    |    2    |    2    |      3      |      4     |    5   |   5    |   6    |   6    |   7    |   7    |  8   |
      # Name | Postal | Capital | Largest | Established | Population | TA_mi2 | TA_km2 | LA_mi2 | LA_km2 | WA_mi2 | WA_km2 | Reps |
      #   -  |   -    |    0    |    1    |      -      |      -     |    2   |   3    |   4    |   5    |   6    |   7    |  -   |
      def merge_sub_headers(headers, cells)
        cells.each_with_index do |cell, index|
          case index
          when 0
            headers[2] = cell + '_city'
          when 1
            headers.insert(3, cell + '_city')
          when 2
            headers[6] = 'total_area_' + cell
          when 3
            headers.insert(7, 'total_area_' + cell)
          when 4
            headers[8] = 'land_area_' + cell
          when 5
            headers.insert(9, 'land_area_' + cell)
          when 6
            headers[10] = 'water_area_' + cell
          when 7
            headers.insert(11, 'water_area_' + cell)
          end
        end
        headers
      end

      def write_json_file(data, path = File.expand_path(File.join(__dir__, '../../results', 'states.json')))
        File.open(path, 'w') { |f| f.write(JSON.pretty_generate(JSON[data.to_json])) }
      end

      def parse
        document = Nokogiri::HTML(open(url))
        headers = []
        data = []

        document.at('table').search('tr').each_with_index do |row, index|
          # main headers
          if index == 0
            cells = row.search('th').map do |cell|
              clean(cell.text)
            end

            cells.each do |cell|
              parse_main_headers(cell).each { |h| headers << h }
            end
            next
          end

          # sub headers
          if index == 1
            cells = row.search('th').map do |cell|
              sanitize(cell.text)
            end
            headers = merge_sub_headers(headers, cells)
            next
          end

          # state data
          # th contains state name, td contains all other data
          t = row.search('th').text
          state_name = clean(t, false)
          object = { headers.first => state_name }
          cells = row.search('td').map { |cell| clean(cell.text, false) }

          # some states have 1 less cell because their capital city is also their largest city
          cells.insert(1, cells[1]) if cells.length == 11

          cells.each_with_index do |cell, index|
            object[headers[index + 1]] = cell
          end

          data << object
        end
        data
      end
    end
  end
end
