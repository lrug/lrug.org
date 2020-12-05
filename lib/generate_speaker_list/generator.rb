module GenerateSpeakerList
  class Generator
    def initialize
      @files = Dir['source/meetings/*/*/index.html.md'].sort
      @authors = []
    end

    def call
      @files.each do |file|
        @authors << ParseFile.new(file).call
      end

      pp @authors
    end
  end
end
