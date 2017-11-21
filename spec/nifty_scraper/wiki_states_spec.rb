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
        exp_string  = 'test'
        expect(WikiStates.clean(test_string)).to eq(exp_string)
      end

      it 'removes leading whitespace' do
        test_string = "\nTest"
        exp_string  = 'test'
        expect(WikiStates.clean(test_string)).to eq(exp_string)
      end

      it 'removes 1 set of brackets"' do
        test_string = "Test\n[B]"
        exp_string  = 'test'
        expect(WikiStates.clean(test_string)).to eq(exp_string)
      end

      it 'removes 2 sets of brackets' do
        test_string = "Test\n[B][10]"
        exp_string  = 'test'
        expect(WikiStates.clean(test_string)).to eq(exp_string)
      end

      it 'removes special characters' do
        test_string = '@Alabama'
        exp_string  = 'Alabama'
        expect(WikiStates.clean(test_string, false)).to eq(exp_string)
      end

      # "North Dakota has 2 leading special characters, ¯\_(ツ)_/¯"
      it 'remove multiple leading special characters' do
        test_string = '@!North Dakota'
        exp_string  = 'North Dakota'
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
        exp_string  = 'test_test'
        expect(WikiStates.to_snake(test_string)).to eq(exp_string)
      end

      it 'handles strings with no spaces' do
        exp_string = 'test'
        expect(WikiStates.to_snake(exp_string)).to eq(exp_string)
      end
    end

    describe 'headers' do
      let(:headers) { WikiStates.headers }
      it 'has array of values' do
        expect(headers).to be_a(Array)
      end

      it 'has set number of values' do
        expect(headers.length).to eq(13) # magic number 13
      end

      it 'has strings' do
        headers.each do |header|
          expect(header).to be_a(Symbol)
          expect(header).not_to be_empty
        end
      end

      it 'has snake case strings' do
        headers.each do |header|
          expect(header).not_to match(/[A-Z]/) # no caps
          expect(header).not_to match(/\s/)    # no white space
        end
      end
    end

    describe 'parse', :vcr do
      let(:data) { WikiStates.parse }

      it 'returns a hash' do
        expect(data).to be_a(Hash)
      end

      it 'returns 50 states' do
        expect(data.keys.length).to eq(50)
        expect(data.keys.length).to eq(@states.length)
      end

      it 'returns states with the correct names' do
        data.keys.each do |state|
          expect(@states).to include(state)
        end
      end

      it 'returns state properties' do
        data.values.each do |state|
          expect(state[:postal_abbreviation].length).to be(2)
          expect(state[:capital_city]).not_to be_empty
          expect(state[:largest_city]).not_to be_empty
          expect(state[:established]).not_to be_empty
          expect(state[:population]).not_to be_empty
        end
      end

      it 'returns states with established dates' do
        data.values.each do |state|
          date = Date.strptime(state[:established], '%b %d, %Y')
          expect(date).to be_a(Date)
          expect(date).to be > (Date.parse('01-01-1787')) # Delaware
          expect(date).to be < (Date.parse('01-09-1959')) # Hawaii
        end
      end
    end
  end
end
