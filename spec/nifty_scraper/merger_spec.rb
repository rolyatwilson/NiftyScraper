require_relative '../spec_helper'

module NiftyScraper
  describe Merger do
    describe 'default_path' do
      subject { Merger.default_path }
      it { is_expected.to be_a(String) }
    end

    describe 'states_path' do
      subject { Merger.states_path }
      it { is_expected.to be_a(String) }
      it { is_expected.to eq(WikiStates.default_path) }
    end

    describe 'states_exist?' do
      subject { Merger.states_exist? }
      it { is_expected.to be(true).or be(false)}
    end

    describe 'generate_states' do
      let(:path) { File.expand_path(File.join(__dir__, '../fixtures', 'test.json')) }
      let(:data) { { hello: :world } }
      before(:each) do
        File.delete(path) if File.exist?(path)
        Merger.generate_states(data, path)
      end

      it 'creates new file' do
        expect(File.exist?(path))
      end

      it 'writes contents to disk' do
        json = JSON.parse(File.read(path)).deep_symbolize_keys!
        expect(json[:hello]).to eq('world')
      end
    end

    describe 'squash' do
      subject { Merger.squash }
      it { is_expected.to be_a(Hash) }
      it { is_expected.not_to be_empty }

      it 'has 50 keys' do
        expect(subject.keys.length).to eq(50)
      end

      it 'has a key for each state' do
        @states.each do |state|
          expect(subject[state]).to be_a(Hash)
        end
      end

      it 'squashes both json files' do
          subject.values.each do |state|
          expect(state[:postal_abbreviation].length).to be(2)
          expect(state[:capital_city]).not_to be_empty
          expect(state[:largest_city]).not_to be_empty
          expect(state[:established]).not_to be_empty
          expect(state[:population]).not_to be_empty
          expect(state[:borders]).to be_a(Array)
        end
      end
    end
  end
end