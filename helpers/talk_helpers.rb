module TalkHelpers
  def render_talks(for_page = current_page)
    year = current_page.data.meeting_date.year.to_s
    month = current_page.data.meeting_date.strftime('%B').downcase
    talks = find_talks(year, month)
    if talks.present?
      talks.map { it.render(on: self) }.join
    else
      partial_with_opts_passthrough 'no_talks_yet'
    end
  end

  def partial_with_opts_passthrough(template, options={}, &)
    passthrough_opts = self.instance_variable_get('@opts').dup
    partial(template, passthrough_opts.merge(options), &)
  end

  def find_talks(year, month)
    data.talks.dig(year, month)&.map { Talk.from(year:, month:, id: it[0], details: it[1]) }
  end

  Talk = Data.define(:id, :title, :description, :custom_intro, :use_description_as_intro, :speaker, :coverage_links, :year, :month) do
    def self.from(year:, month:, id:, details:)
      new(
        id:,
        title: details.title,
        description: details.description,
        custom_intro: details.custom_intro,
        use_description_as_intro: details.use_description_as_intro || false,
        speaker: Speaker.from(speaker_details: details.speaker),
        coverage_links: Coverage.from(details.coverage),
        year:,
        month:
      )
    end

    def render(on:)
      on.partial_with_opts_passthrough 'talk', locals: { year:, month:, talk: self }
    end

    def intro
      if use_description_as_intro
        description
      elsif custom_intro
        "#{speaker.formatted_name} #{custom_intro}:"
      else
        "#{speaker.formatted_name} says:"
      end
    end

    def render_coverage(on:)
      return unless coverage_links.any?

      on.partial 'coverage', locals: { coverage_links: }
    end
  end

  Speaker = Data.define(:name, :url) do
    def self.from(speaker_details:)
      if speaker_details.is_a? Array
        Speakers.new(speakers: speaker_details.map { from(speaker_details: it) })
      else
        new(name: speaker_details.name, url: speaker_details.url)
      end
    end

    def formatted_name
      if url
        "[#{name}](#{url})"
      else
        name
      end
    end
  end

  Speakers = Data.define(:speakers) do
    def formatted_name = speakers.map(&:formatted_name).to_sentence
  end

  Coverage = Data.define(:type, :title, :url) do
    def self.from(coverage_details)
      return [] if coverage_details.nil?

      coverage_details.map { new(type: it.type, title: it.title, url: it.url ) }
    end
  end

  def blockquote(content)
    "> #{content.split("\n").join("\n> ")}"
  end
end
