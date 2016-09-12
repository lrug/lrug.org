require 'nokogiri'

module LRUGHelpers
  def generate_description(for_page = current_page)
    extracted = _extract_description_from_page(for_page)
    extracted.presence || "An exciting page about #{page_title(for_page)} as it relates to the London Ruby User Group."
  end

  private
  def _extract_description_from_page(for_page)
    rendered = for_page.render layout: false

    doc = Nokogiri::HTML::DocumentFragment.parse(rendered)
    doc.css('p').first.text
  rescue
    ''
  end
  public

  def page_title(for_page = current_page)
    yield_content(:title) || for_page.data.title
  end

  def rss_path(for_page = current_page)
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
      .select { |page| page_has_data?(page, status: 'Published', category: category) }
      .sort_by { |page| page.data.published_at }
      .reverse
  end

  def meeting_pages
    pages_in_category 'meeting'
  end

  def book_reviews
    pages_in_category 'book-review'
  end

  def podcast_episodes
    pages_in_category 'podcast'
  end

  def nights_episodes
    pages_in_category 'nights'
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
      if part['filter'].present?
        renderers = part['filter'].split('.').reverse.reject { |renderer| renderer.blank? }
        renderers.prepend('erb') unless renderers.first == 'erb'
        renderers.inject(part['content']) do |body, renderer|
          Tilt.new(renderer, 1, options_for_ext(renderer)) do
            body
          end.render(self, page: page)
        end
      else
        part['content']
      end
    else
      ''
    end
  end

  def month_of_meeting(meeting)
    match = meeting.data.title.match(/(January|February|March|April|May|June|July|August|September|October|November|December)/i)
    if match
      match[1]
    else
      meeting.data.title
    end
  end

  def meeting_sponsors
    meeting_pages.select { |mp| mp.data.sponsors? }.flat_map { |mp| mp.data.sponsors }.uniq
  end

  def sponsor_logo(sponsor_name, size: 'sidebar')
    sponsor = data.sponsors.detect { |sponsor| sponsor.name == sponsor_name }
    if sponsor
      link_text =
        if sponsor.logo? && sponsor.logo[size]
          %{<image src="#{sponsor.logo[size].url}" width="#{sponsor.logo[size].width}" height="#{sponsor.logo[size].height}" alt="#{sponsor.name}" title="#{sponsor.name} Logo"/>}
        else
          sponsor.name
        end
      link_to link_text, sponsor.url
    end
  end

  private
  def find_page_part(part_name, page, inherit: false)
    if page.data.parts? && page.data.parts.has_key?(part_name)
      page.data.parts[part_name]
    elsif inherit && page.parent.present?
      find_page_part(part_name, page.parent, inherit: inherit)
    else
      nil
    end
  end

  public
  def date_format(date, format)
    date.strftime(format) unless date.nil?
  end

  def rfc_1123_date(date)
    date.rfc2822 unless date.nil?
  end

  def render_markdown(md)
    Tilt['markdown'].new do
      md
    end.render
  end

  def meeting_calendar_link
    render_markdown(
      %{<span class="calendar-link">[![Calendar subscription](http://assets.lrug.org/images/calendar_down.gif) Meeting Calendar](/meeting-calendar)</span>}
    )
  end

  def indent_xml(indent, xml_string)
    xml_string.gsub(/^/,' ' * indent)
  end

  def format_redirect_from_regex(redirect_from)
    regex = redirect_from.dup
    regex.prepend '^' unless redirect_from.start_with? '^'
    regex.concat '($|/)' unless redirect_from.end_with? '$'
    regex
  end
end
