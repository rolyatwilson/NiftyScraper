require_relative '../spec_helper'

module NiftyScaper
  describe 'write_json_file' do
    let(:path) { File.expand_path(File.join(__dir__, '../fixtures', 'test.json')) }
    let(:data) { { hello: :world } }
    before(:each) do
      File.delete(path) if File.exist?(path)
      NiftyScraper.write_json_file(data, path)
    end

    it 'creates new file' do
      expect(File.exist?(path))
    end

    it 'writes contents to disk' do
      json = JSON.parse(File.read(path)).deep_symbolize_keys!
      expect(json[:hello]).to eq('world')
    end
  end
end
