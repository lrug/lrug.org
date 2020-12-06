require 'json'

module GenerateSpeakerList
  class Generator
    SPEAKERS_DATA_FILE = 'data/speakers.json'

    def initialize
      @files = Dir['source/meetings/*/*/index.html.md'].sort.reverse
      @talks = []
      @authors = {}
    end

    def call
      load_all_talks_from_files!

      @talks = @talks.flatten.select { |talk| talk[:author] != nil }.group_by { |talk| talk[:author] }

      @talks.each do |author_name, talks|
        @authors[author_name] = {
          name: author_name,
          links: talks.collect { |talk| talk[:author_link] }.uniq.compact,
          talks: talks.collect do |talk|
            {
              title: talk[:title],
              coverage: talk[:coverage],
              summary: talk[:summary],
              year: talk[:year],
              month: talk[:month]
            }
          end
        }
      end


      pp @authors

      save_authors_to_json!
    end

    private

    def load_all_talks_from_files!
      @files.each do |file|
        @talks << ParseFile.new(file).call
      end
    end

    def save_authors_to_json!
      File.write(SPEAKERS_DATA_FILE, JSON.pretty_generate(@authors))
    end
  end
end
