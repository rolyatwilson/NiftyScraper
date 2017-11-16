module NiftyScrapper
  class WikiStates
    class << self
      def url
        @url ||= 'https://en.wikipedia.org/wiki/List_of_states_and_territories_of_the_United_States'
      end
    end

    # parse html
    def parse
      document = Nokogiri::HTML(open(WikiStates.url))

      headers = []
      data = []

      table = document.at('table')
      table.search('tr').each_with_index do |row, index|
        # First Row
        # Name & postal abbreviations | Cities | Established | Population | Total Area | Land Area | Water Area | Reps.
        #
        if index == 0
          cells = row.search('th').map do |cell|
            # strip off useless characters, eg: "Population\n[B][10]", "Reps."
            text = cell.text.strip.gsub(/\s?\[\S+\]?|\./, '')

            # strip off leading or trailing white space
            text.gsub(/\A\s|\s\z/, '')
          end

          cells.each do |cell|
            tokens = cell.split('&').map do |str|
              # split "Name & postal abbreviation" into 2 headers
              text = str.gsub(/\A\s|\s\z/, '')

              # convert to snake_case
              text = text.gsub(/\s/, '_')
              text = text.downcase
              text = '_city' if text == 'cities'
              text
            end
            headers << tokens.first
            headers << tokens.last if tokens.length > 1
          end
          next
        end

        if index == 1
          # First Row
          #   0  |   1    |   2    |      3      |     4      |      5     |     6     |      7     |   8   |
          # Name | Postal | Cities | Established | Population | Total Area | Land Area | Water Area | Reps. |
          #
          # Merge Second Row with First Row
          #   0  |   1    |    2    |    2    |      3      |      4     |    5   |   5    |   6    |   6    |   7    |   7    |  8   |
          # Name | Postal | Capital | Largest | Established | Population | TA_mi2 | TA_km2 | LA_mi2 | LA_km2 | WA_mi2 | WA_km2 | Reps |
          #   -  |   -    |    0    |    1    |      -      |      -     |    2   |   3    |   4    |   5    |   6    |   7    |  -   |
          cells = row.search('th').map do |cell|
            text = cell.text.strip
            text.gsub(/\[\S+\]?/, '').downcase
          end

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
          next
        end

        # th contains state name, td contains all other data
        state_name = row.search('th').text.gsub(/\A[^a-zA-Z]|\s\z|\[\S+\]?/, '')
        object = { headers.first => state_name }
        cells = row.search('td').map { |cell| cell.text.gsub(/\A\s|\s\z/, '') }


        # some states have 1 less cell because their capital city is also their largest city
        if cells.length == 11
          cells.insert(1, cells[1])
        end

        cells.each_with_index do |cell, index|
          object[headers[index + 1]] = cell
        end

        data << object
      end

      # convert to json
      json = data.to_json

      # write json file
      path = File.expand_path(File.join(__dir__, '../../results', 'states.json'))
      File.open(path, 'w') { |f| f.write(JSON.pretty_generate(JSON[json])) }
    end
  end
end
