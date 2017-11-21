module NiftyScraper
  class Merger
    class << self
      def default_path
        @default_path ||= File.expand_path(File.join(__dir__, '../../results/states_merged.json'))
      end

      def states_path
        @states_path ||= WikiStates.default_path
      end

      def states_exist?
        File.exist?(states_path)
      end

      def generate_states(data = WikiStates.parse, path = states_path)
        NiftyScraper.write_json_file(data, path)
      end

      def squash
        generate_states unless states_exist?
        states  = JSON.parse(File.read(states_path)).deep_symbolize_keys
        borders = Borders.parse
        borders.each do |state, b|
          states[state][:borders] = b[:borders]
        end
        states
      end
    end
  end
end
