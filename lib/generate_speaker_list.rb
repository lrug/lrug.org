# This file opens the meeting markdown files
# and attempts to extract the speakers & their 
class GenerateSpeakerList
  def initialize
    @files = [
      'source/meetings/2020/august/index.html.md'
    ]

    @authors = []
  end

  def call
    @files.each do |file|
      @authors << ParseFile.new(file).call
    end

    @authors
  end

  private

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

      ParseAgenda.new(@agenda_block).call
    end

    private

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

  class ParseAgenda
    def initialize(agenda)
      @agenda = agenda
      @agenda_item_index = -1
      @agenda_items = {}
    end
    
    def call
      @agenda.each do |line|
        split_agenda_into_items_by_line(line)
      end

      @agenda_items
    end

    private

    def split_agenda_into_items_by_line(line)
      if line.start_with?('### ')
        @agenda_item_index += 1
        @agenda_items[@agenda_item_index] ||= []
      end

      if @agenda_item_index >= 0
        @agenda_items[@agenda_item_index] << line
      end
    end
  end
end

pp GenerateSpeakerList.new.call
