module Lrug
  Talk = Data.define(:id, :title, :description, :custom_intro,
                     :use_description_as_intro, :use_name_as_intro,
                     :speaker, :coverage_links,
                     :year, :month,) do
    def self.from(year:, month:, id:, details:)
      new(
        id:,
        title: details.title,
        description: details.description,
        custom_intro: details.custom_intro,
        use_description_as_intro: details.use_description_as_intro || false,
        use_name_as_intro: details.use_name_as_intro || false,
        speaker: Speaker.from(speaker_details: details.speaker),
        coverage_links: Coverage.from(details.coverage),
        year:,
        month:,
      )
    end

    def render(on:)
      on.partial_with_opts_passthrough "talk", locals: { year:, month:, talk: self }
    end

    def intro
      if use_description_as_intro
        description
      elsif custom_intro
        "#{speaker.formatted_name} #{custom_intro}:"
      elsif use_name_as_intro
        "#{speaker.formatted_name}:"
      else
        "#{speaker.formatted_name} says:"
      end
    end

    def render_coverage(on:)
      return unless coverage_links.any?

      on.partial "coverage", locals: { coverage_links: }
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
    # skillsmatter-video and google-video are dead video links we shouldn't publish
    const_set("BAD_COVERAGE", %w[skillsmatter-video google-video])
    def self.from(coverage_details)
      return [] if coverage_details.nil?

      coverage_details
        .reject { self::BAD_COVERAGE.include? it.type }
        .map { new(type: it.type, title: it.title, url: it.url) }
    end
  end
end
