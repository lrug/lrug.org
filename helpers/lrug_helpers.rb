require "nokogiri"

module LrugHelpers
  def generate_description(for_page = current_page)
    extracted = for_page.data[:description] || _extract_description_from_page(for_page)
    extracted.presence || "An exciting page about #{page_title(for_page)} as it relates to the London Ruby User Group."
  end

  private

  def _extract_description_from_page(for_page)
    rendered = for_page.render layout: false

    doc = Nokogiri::HTML::DocumentFragment.parse(rendered)
    doc.css("p").first.text
  rescue StandardError
    ""
  end

  public

  def page_title(for_page = current_page)
    yield_content(:title) || for_page.data.title
  end

  def rss_path(_for_page = current_page)
    "/rss/#{yield_content :rss_path}"
  end

  def show_sponsors(for_page = current_page)
    partial "sponsors", locals: { for_page: for_page }
  end

  def link_to_most_recent(category)
    meeting = most_recent(category)
    link_to meeting.data.title, meeting
  end

  def most_recent(category)
    pages_in_category(category).first
  end

  def pages_in_category(category)
    sitemap
      .resources
      .select { |page| page_has_data?(page, status: "Published", category: category) }
      .sort_by { |page| page.data.published_at }
      .reverse
  end

  def meeting_pages
    pages_in_category "meeting"
  end

  def book_reviews
    pages_in_category "book-review"
  end

  def podcast_episodes
    pages_in_category "podcast"
  end

  def nights_episodes
    pages_in_category "nights"
  end

  def page_has_data?(page, args)
    args.all? do |key, value|
      page.data[key.to_s] == value
    end
  end

  def content_part_exists?(part_name, page, inherit: false)
    find_page_part(part_name, page, inherit: inherit).present?
  end

  def render_content_part(part_name, page, inherit: false)
    part = find_page_part(part_name, page, inherit: inherit)
    if part
      if part["render_as"].present?
        renderers = part["render_as"].split(".").reverse.reject(&:blank?)
        # Add all the render_as extensions to the fake path
        pathname = "#{page.path}#content-part-#{part_name}#{part['render_as']}"
        # Always push things through erb even if it's not an explicit render_as
        unless renderers.first == "erb"
          renderers.prepend("erb")
          pathname.concat(".erb")
        end
        renderers.inject(part["content"]) do |body, renderer|
          current_path = pathname.dup
          # strip off the current renderer for the next iteration of the loop
          pathname.gsub!(/\.#{renderer}$/, "")
          inline_content_render(body, current_path, locals: { page: page })
        end
      else
        part["content"]
      end
    else
      ""
    end
  end

  def month_of_meeting(meeting)
    match =
      meeting
        .data
        .title
        .match(/(January|February|March|April|May|June|July|August|September|October|November|December)/i)
    if match
      match[1]
    else
      meeting.data.title
    end
  end

  def hosting_sponsors(most_recent_first: false, without: [])
    sponsor_list("hosted_by", most_recent_first: most_recent_first, without: without)
  end

  def meeting_sponsors(most_recent_first: false, without: [])
    sponsor_list("sponsors", most_recent_first: most_recent_first, without: without)
  end

  SponsorData = Struct.new(:name, :occurrences, :most_recent) do
    def <=>(other)
      return nil unless other.respond_to?(:occurrences) && other.respond_to?(:most_recent)

      case other.occurrences
      when occurrences
        most_recent <=> other.most_recent
      else
        occurrences <=> other.occurrences
      end
    end
  end

  private

  def sponsor_list(data_key, most_recent_first:, without:)
    sponsors =
      meeting_pages
        .select { |meeting_page| meeting_page.data.key? data_key }
        .map do |meeting_page|
          [
            meeting_page.data[data_key].first,
            meeting_page.data.meeting_date,
          ]
        end
        .group_by { |(sponsor, _date)| sponsor.name }
        .map do |sponsor_name, occurrences|
          SponsorData.new(
            name: sponsor_name,
            occurrences: occurrences.size,
            most_recent: occurrences.map { |(_sponsor, date)| date }.max,
          )
        end
        .reject { |sponsor_data| without.include? sponsor_data.name }
        .sort
        .reverse
    return sponsors unless most_recent_first

    most_recent = sponsors.max_by(&:most_recent)
    [most_recent] + (sponsors - [most_recent])
  end

  public

  def sponsor_logo(sponsor_name, size: "sidebar")
    sponsor = data.sponsors.detect { |sponsor| sponsor.name == sponsor_name }
    return unless sponsor

    link_text =
      if sponsor.logo? && sponsor.logo[size]
        # rubocop:disable Layout/LineLength -- we could write this on multiple lines with HEREDOCS, but with less control of the output and more CPU to get there
        %(<img src="#{sponsor.logo[size].url}" width="#{sponsor.logo[size].width}" height="#{sponsor.logo[size].height}" alt="#{sponsor.name}" title="#{sponsor.name} Logo" loading="lazy"/>)
        # rubocop:enable Layout/LineLength
      else
        sponsor.name
      end
    link_to link_text, sponsor.url
  end

  private

  def find_page_part(part_name, page, inherit: false)
    if page.data.parts? && page.data.parts.key?(part_name)
      page.data.parts[part_name]
    elsif inherit && page.parent.present?
      find_page_part(part_name, page.parent, inherit: inherit)
    end
  end

  public

  def date_format(date, format)
    date&.strftime(format)
  end

  def rfc_1123_date(date)
    date&.rfc2822
  end

  def render_markdown(markdown)
    inline_content_render(markdown, "inline-markdown-fragment.md")
  end

  def meeting_calendar_link
    # rubocop:disable Layout/LineLength -- we could write this on multiple lines with HEREDOCS, but with less control of the output and more CPU to get there
    %(<span class="calendar-link"><a href="/meetings.ics"><img src="https://assets.lrug.org/images/calendar_down.gif" alt="Calendar subscription" loading="lazy"> Meeting Calendar</a></span>)
    # rubocop:enable Layout/LineLength
  end

  def indent_xml(indent, xml_string)
    xml_string.gsub(/^/, " " * indent)
  end

  def format_redirect_from_regex(redirect_from)
    regex = redirect_from.dup
    regex.prepend "^" unless redirect_from.start_with? "^"
    regex.concat "($|/)" unless redirect_from.end_with? "$"
    regex
  end

  def thanks_needed?(page)
    page_has_sponsors?(page) || page_has_host?(page)
  end

  def page_has_sponsors?(page)
    content_part_exists?("sponsors", page) || page.data.key?("sponsors")
  end

  def page_has_host?(page)
    content_part_exists?("hosted_by", page) || page.data.key?("hosted_by")
  end

  def ical_time(datetime, timezone_identifier)
    Icalendar::Values::DateTime.new(datetime, tzid: timezone_identifier)
  end

  def events_calendar(site_url:)
    calendar = Icalendar::Calendar.new

    timezone_identifier = "Europe/London"
    zone = ActiveSupport::TimeZone[timezone_identifier]

    calendar.timezone do |timezone|
      timezone.tzid = timezone_identifier
    end

    all_meetings = meeting_pages

    upcoming = all_meetings.take_while { |page| page.metadata[:page][:meeting_date] >= Date.today }
    next_12 = all_meetings.drop(upcoming.length).take(12)

    (upcoming + next_12).each do |page|
      url = URI.join(site_url, page.url)
      date = page.metadata[:page][:meeting_date]
      title = page.metadata[:page][:title]
      hosts = page.metadata[:page][:hosted_by]

      calendar.event do |event|
        event.uid      = "lrug-monthly-#{date.strftime('%Y-%m')}"
        event.dtstart  = ical_time(date.in_time_zone(zone).change(hour: 18), timezone_identifier)
        event.dtend    = ical_time(date.in_time_zone(zone).change(hour: 20), timezone_identifier)
        event.summary  = "London Ruby User Group - #{title}"
        event.location = "London, UK"
        event.url      = url

        hosted_by = "Hosted by: #{hosts.map { |h| h[:name] }.join(', ')}" if hosts.present?

        event.description = <<~DESC
          London Ruby User Group - #{title}

          #{hosted_by}
        DESC
      end
    end

    calendar
  end

  module PrettierYamlTree
    class << self
      def output_rubyevents!
        @_outputting_rubyevents = true
      end

      def outputting_rubyevents?
        @_outputting_rubyevents
      end

      def stop_outputting_rubyevents!
        @_outputting_rubyevents = false
      end
    end

    # rubocop:disable all -- this isn't our code, so don't lint it
    # TODO: feels like we should be able to do our work via a custom
    # `encode_with` on `String` but I couldn't get it to work, and the
    # behaviour here is very complex, not sure I could replicate it
    def visit_String(o)
      # do the default unless we've asked it not to
      return super(o) unless PrettierYamlTree.outputting_rubyevents?

      # copy in original impl of this method as it doesn't lend itself to
      # extension via super
      plain = true
      quote = true
      style = Psych::Nodes::Scalar::PLAIN
      tag   = nil

      if binary?(o)
        o     = [o].pack('m0')
        tag   = '!binary' # FIXME: change to below when syck is removed
        #tag   = 'tag:yaml.org,2002:binary'
        style = Psych::Nodes::Scalar::LITERAL
        plain = false
        quote = false
      elsif o.match?(/\n(?!\Z)/)  # match \n except blank line at the end of string
        style = Psych::Nodes::Scalar::LITERAL
      elsif o == '<<'
        style = Psych::Nodes::Scalar::SINGLE_QUOTED
        tag   = 'tag:yaml.org,2002:str'
        plain = false
        quote = false
      elsif o == 'y' || o == 'Y' || o == 'n' || o == 'N'
        style = Psych::Nodes::Scalar::DOUBLE_QUOTED
      elsif @line_width && o.length > @line_width
        style = Psych::Nodes::Scalar::FOLDED
      elsif o.match?(/^[^[:word:]][^"]*$/)
        style = Psych::Nodes::Scalar::DOUBLE_QUOTED
      elsif not String === @ss.tokenize(o) or /\A0[0-7]*[89]/.match?(o)
        # our change 1: prefer double quotes here
        style = Psych::Nodes::Scalar::DOUBLE_QUOTED
      else
        # our change 2: work out if this is a value or a key, we want to double
        #               quote values, but leave keys plain.  E.g. we want
        #               `key: "value"` not `"key": "value"`
        cur_node = @emitter.instance_variable_get('@last')
        if cur_node.class == Psych::Nodes::Mapping && cur_node.children.size.even?
          # even means we're about to add a key, don't quote it
          style = Psych::Nodes::Scalar::PLAIN
        else
          # odd means we're about to add a value, quote it
          style = Psych::Nodes::Scalar::DOUBLE_QUOTED
        end
      end

      is_primitive = o.class == ::String
      ivars = is_primitive ? [] : o.instance_variables

      if ivars.empty?
        unless is_primitive
          tag = "!ruby/string:#{o.class}"
          plain = false
          quote = false
        end
        @emitter.scalar o, nil, tag, plain, quote, style
      else
        maptag = '!ruby/string'.dup
        maptag << ":#{o.class}" unless o.class == ::String

        register o, @emitter.start_mapping(nil, maptag, false, Nodes::Mapping::BLOCK)
        @emitter.scalar 'str', nil, nil, true, false, Nodes::Scalar::ANY
        @emitter.scalar o, nil, tag, plain, quote, style

        dump_ivars o

        @emitter.end_mapping
      end
    end
    # rubocop:enable all -- ...and we're back in the room
  end

  def rubyevents_video_playlist(site_url:)
    # rubyevents uses prettier but psych's `to_yaml` doesn't agree with those
    # rules, and also doesn't make it easy to change the output format _at all_
    # so we re-implment the visitor to make some changes that will reduce the
    # git diff while importing this generated yaml and make it more "prettier"
    unless Psych::Visitors::YAMLTree.ancestors.include? PrettierYamlTree
      Psych::Visitors::YAMLTree.prepend PrettierYamlTree
    end
    PrettierYamlTree.output_rubyevents!
    data.talks.keys.sort.each.filter_map do |year|
      # for now - only share 2020+ talks
      next if Integer(year) < 2020

      data.talks[year].each.filter_map do |month, talks|
        page = meeting_pages.detect { it.path.starts_with? "meetings/#{year}/#{month}" }
        next unless page

        url = URI.join(site_url, page.url)
        title = "LRUG #{month.titleize} #{year}"
        meeting_date = page.data.meeting_date.strftime("%Y-%m-%d")
        published_at = page.data.published_at.to_s
        {
          "id" => title.parameterize,
          "title" => title,
          "event_name" => title,
          "date" => meeting_date,
          "announced_at" => published_at,
          "video_provider" => "children",
          "video_id" => title.parameterize,
          "description" => url.to_s,
          "talks" => talks_for_rubyevents_video_playlist(talks, title, meeting_date, published_at),
        }
      end
    end.flatten(1).to_yaml
  ensure
    PrettierYamlTree.stop_outputting_rubyevents!
  end

  def talks_for_rubyevents_video_playlist(talks, title, meeting_date, published_at)
    return [] unless talks.present?

    talks.map do |id, talk|
      video_coverage = talk.coverage&.detect { it.type == "video" }
      slides_coverage = talk.coverage&.detect { it.type == "slides" }

      talk_details = {
        "id" => "#{Array.wrap(talk.speaker).map(&:name).map(&:parameterize).join('-')}-#{title.parameterize}",
        "title" => talk.title,
        "event_name" => title,
        "date" => meeting_date,
        "announced_at" => published_at,
        "speakers" => Array.wrap(talk.speaker).map(&:name),
        "description" => talk.description,
      }

      additional_resources = talk.coverage&.filter_map do |coverage|
        next if coverage.type.in?(%w[video slides])

        name =
          case coverage.type
          when "write-up" then "Write-Up"
          when "code" then "Source Code"
          when "repo" then "Repository"
          when "transcript" then "Transcript"
          when "handout" then "Handout"
          when "notes" then "Notes"
          when "photos" then "Photos"
          when "link" then "Link"
          else coverage.type.titleize
          end

        {
          "name" => name,
          "type" => coverage.type,
          "title" => coverage.title,
          "url" => coverage.url,
        }
      end

      talk_details["additional_resources"] = additional_resources if Array.wrap(additional_resources).any?

      if video_coverage&.url&.starts_with?("https://assets.lrug.org")
        talk_details["video_provider"] = "mp4"
        talk_details["video_id"] = video_coverage.url
      else
        # technically this might mean we have a video elsewhere
        # (e.g. like the old skills matter videos or on youtube or
        # something) rather than haven't published it yet and we should
        # work out how to list those
        talk_details["video_id"] = "lrug-#{meeting_date}-#{id}"
        talk_details["video_provider"] = "not_published"
      end
      talk_details["slides_url"] = slides_coverage.url if slides_coverage
      talk_details
    end
  end

  private

  def inline_content_render(content, fake_pathname, locals: {})
    # create a middleman filerenderer to do the work, the extension in
    # the last extension in the path tells it which template engine to use
    # and because it's a middleman object it'll make sure it's properly
    # configured via settings in config.rb, which us creating a Tilt
    # instance directly won't neccessarily do
    content_renderer = ::Middleman::FileRenderer.new(@app, fake_pathname)
    content_renderer.render(
      locals,
      { template_body: content, layout: false },
      @app.template_context_class.new(@app, locals, { layout: false }),
    )
  end
end
