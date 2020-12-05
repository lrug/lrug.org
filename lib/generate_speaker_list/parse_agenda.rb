module GenerateSpeakerList
  class ParseAgenda
    def initialize(agenda, year, month)
      @agenda = agenda
      @year = year
      @month = month
      @agenda_item_index = -1
      @agenda_items = {}
    end

    def call
      @agenda.each do |line|
        split_agenda_into_items_by_line(line)
      end

      @agenda_items
        .collect { |index, agenda_item| ParseAgendaItem.new(agenda_item, @year, @month) }
        .select(&:valid?)
        .collect(&:to_h)
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
