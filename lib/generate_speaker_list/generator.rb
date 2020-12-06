require 'json'

module GenerateSpeakerList
  class Generator
    SPEAKERS_DATA_FILE = 'data/speakers.json'

    def initialize
      @files = Dir['source/meetings/*/*/index.html.md'].sort.reverse
      @talks = []
    end

    def call
      load_all_talks_from_files!

      @talks = @talks.flatten.group_by { |talk| talk[:author] }

      pp @talks

      save_talks_to_json!
    end

    private

    def load_all_talks_from_files!
      @files.each do |file|
        @talks << ParseFile.new(file).call
      end
    end

    def save_talks_to_json!
      File.write(SPEAKERS_DATA_FILE, JSON.pretty_generate(@talks))
    end
  end
end
