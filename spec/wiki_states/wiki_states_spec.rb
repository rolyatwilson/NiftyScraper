require_relative '../spec_helper'

module NiftyScraper
  describe WikiStates do
    describe 'url' do
      it 'has a valid url' do
        uri = URI.parse(WikiStates.url)
        expect(uri.host).not_to be_empty
        expect(uri.port).to eq(443)
      end
    end

    describe 'clean' do
      it 'removes trailing whitespace' do
        test_string = "Test\n"
        exp_string = 'test'
        expect(WikiStates.clean(test_string)).to eq(exp_string)
      end

      it 'removes leading whitespace' do
        test_string = "\nTest"
        exp_string = 'test'
        expect(WikiStates.clean(test_string)).to eq(exp_string)
      end

      it 'removes 1 set of brackets"' do
        test_string = "Test\n[B]"
        exp_string = 'test'
        expect(WikiStates.clean(test_string)).to eq(exp_string)
      end

      it 'removes 2 sets of brackets' do
        test_string = "Test\n[B][10]"
        exp_string = 'test'
        expect(WikiStates.clean(test_string)).to eq(exp_string)
      end

      it 'removes special characters' do
        test_string = '@Alabama'
        exp_string = 'Alabama'
        expect(WikiStates.clean(test_string, false)).to eq(exp_string)
      end

      # "North Dakota has 2 leading special characters, ¯\_(ツ)_/¯"
      it 'remove multiple leading special characters' do
        test_string = '@!North Dakota'
        exp_string = 'North Dakota'
        expect(WikiStates.clean(test_string, false)).to eq(exp_string)
      end

      it 'does not alter numbers' do
        exp_string = '11,222,333'
        expect(WikiStates.clean(exp_string)).to eq(exp_string)
      end

      it 'handles empty strings' do
        expect(WikiStates.clean('')).to eq('')
      end
    end

    describe 'to_snake' do
      it 'converts middle whitespace to "_"' do
        test_string = 'test test'
        exp_string = 'test_test'
        expect(WikiStates.to_snake(test_string)).to eq(exp_string)
      end

      it 'handles strings with no spaces' do
        exp_string = 'test'
        expect(WikiStates.to_snake(exp_string)).to eq(exp_string)
      end
    end

    describe 'parse_main_headers' do
      it 'handles single word headers' do
        header = 'name'
        expect(WikiStates.parse_main_headers(header)).to eq([header])
      end

      it 'handles & compounds' do
        header = 'name & postal'
        exp = %w[name postal]
        expect(WikiStates.parse_main_headers(header)).to eq(exp)
      end
    end

    describe 'merge sub_header' do
      it 'merges sub headers into main headers' do
        main_headers = ['name', 'postal', 'cities', 'established', 'population', 'total area', 'land area', 'water area', 'reps']
        sub_headers = %w[capital largest mi2 km2 mi2 km2 mi2 km2]
        merged_headers = %w[name postal capital_city largest_city established population total_area_mi2 total_area_km2 land_area_mi2 land_area_km2 water_area_mi2 water_area_km2 reps]
        expect(WikiStates.merge_sub_headers(main_headers, sub_headers)).to eq(merged_headers)
      end
    end

    describe 'write_json_file' do
      let(:path) { File.expand_path(File.join(__dir__, '../fixtures', 'test.json')) }
      let(:data) { { 'hello' => 'world' } }
      before(:each) do
        File.delete(path) if File.exist?(path)
        WikiStates.write_json_file(data, path)
      end

      it 'creates new file' do
        expect(File.exist?(path))
      end

      it 'writes contents to disk' do
        json = JSON.parse(File.read(path))
        expect(json['hello']).to eq('world')
      end
    end

    describe 'parse', :vcr do
      let(:data) { WikiStates.parse }
      let(:states) { ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'] }

      it 'returns an array' do
        expect(data).to be_a(Array)
      end

      it 'returns 50 states' do
        expect(data.length).to eq(50)
        expect(data.length).to eq(states.length)
      end

      it 'returns states with the correct names' do
        expect(data.map { |state| state['name'] }).to eq(states)
      end

      it 'returns state properties' do
        data.each do |state|
          expect(state['name']).not_to be_empty
          expect(state['postal_abbreviation'].length).to be(2)
          expect(state['capital_city']).not_to be_empty
          expect(state['largest_city']).not_to be_empty
          expect(state['established']).not_to be_empty
          expect(state['population']).not_to be_empty
        end
      end

      it 'returns states with established dates' do
        data.each do |state|
          date = Date.strptime(state['established'], '%b %d, %Y')
          expect(date).to be_a(Date)
          expect(date).to be > (Date.parse('01-01-1787')) # Delaware
          expect(date).to be < (Date.parse('01-09-1959')) # Hawaii
        end
      end
    end
  end
end
