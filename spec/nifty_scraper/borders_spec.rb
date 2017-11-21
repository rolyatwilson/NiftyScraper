require_relative '../spec_helper'

module NiftyScraper
  describe Borders do
    describe 'path' do
      subject { Borders.path }
      it { is_expected.to be_a(String) }
      it { is_expected.not_to be_empty }
    end

    describe 'exist?' do
      subject { Borders.exist? }
      it { is_expected.to be true }
    end

    describe 'parse' do
      subject { Borders.parse }
      it { is_expected.to be_a(Hash) }
      it { is_expected.not_to be_empty }
      it 'includes each state' do
        @states.each do |state|
          expect do
            raise "#{state} not found!" if subject[state].nil?
          end.not_to raise_error
        end
      end

      it 'has borders array for each state' do
        @states.each do |state|
          expect do
            raise "#{state} borders not found!" unless subject[state] && !subject[state][:borders].nil?
            expect(subject[state][:borders]).to be_a(Array)
          end.not_to raise_error
        end
      end
    end
  end
end