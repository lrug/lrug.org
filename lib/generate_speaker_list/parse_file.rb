module GenerateSpeakerList
  class ParseFile
    def initialize(file)
      @file = file
      @agenda_block = []
      @recording = false
    end

    def call
      File.open(@file).each do |line|
        parse_file_line(line)
      end

      ParseAgenda.new(@agenda_block, year, month).call
    end

    private

    def year
      @file.split('/')[2]
    end

    def month
      @file.split('/')[3]
    end

    def parse_file_line(line)
      if @recording && line.start_with?('## ')
        @recording = false
      elsif !@recording && line.start_with?('## Agenda')
        @recording = true
      end

      if @recording
        @agenda_block << line
      end
    end
  end
end
