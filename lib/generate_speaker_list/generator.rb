module GenerateSpeakerList
  class Generator
    def initialize
      @files = Dir['source/meetings/*/*/index.html.md']
      @authors = []
    end

    def call
      @files.each do |file|
        @authors << ParseFile.new(file).call
      end

      puts "File: #{file}"
      pp @authors
    end
  end
end
