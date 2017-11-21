module NiftyScraper
  class Borders
    class << self
      def path
        @path ||= File.expand_path(File.join(__dir__, '../json/borders.json'))
      end

      def exist?
        File.exist?(path)
      end

      def parse
        JSON.parse(File.read(path)).deep_symbolize_keys
      end
    end
  end
end
