module GenerateSpeakerList
  class ParseAgendaItem
    MARKDOWN_LINK_REGEX = /(.*)\[([^\]]+)\]\(([^)]+)\)(.*+)/

    def initialize(agenda_item, year, month)
      @agenda_item = agenda_item
      @year = year
      @month = month
    end

    def to_h
      {
        title: title,
        author: author,
        author_link: author_link,
        coverage: coverage,
        summary: summary,
        year: @year,
        month: @month
      }
    end

    def valid?
      title != "" && author != "" && summary != "" && coverage != nil
    end

    def title
      @agenda_item[0].strip.sub('### ', '')
    end

    def author
      return unless @agenda_item[2].match?(MARKDOWN_LINK_REGEX)

      @agenda_item[2].strip.gsub(MARKDOWN_LINK_REGEX, '\2')
    end

    def author_link
      return unless @agenda_item[2].match?(MARKDOWN_LINK_REGEX)

      @agenda_item[2].strip.gsub(MARKDOWN_LINK_REGEX, '\3')
    end

    def coverage
      coverage_line = @agenda_item.select do |line|
        line.start_with?('{::coverage')
      end

      coverage_line.first&.strip
    end

    def summary
      @agenda_item
        .select { |line| line.start_with?('> ') }
        .collect { |line| line.gsub(/^\> /, '') }
        .join.strip
    end
  end
end
