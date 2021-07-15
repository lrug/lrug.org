require 'kramdown/parser/kramdown'

class Kramdown::Parser::LRUGExtendedKramdown < Kramdown::Parser::Kramdown
  cattr_accessor :sponsors
  cattr_accessor :coverage

  def handle_extension(name, opts, body, type, line_no = nil)
    case name
    when 'sponsor'
      sponsor = render_sponsor(opts['name'], opts['size'])
      if sponsor
        @tree.children <<
          if type == :block
            new_block_el(:p, location: line_no).tap { |e| e.children << sponsor }
          else
            sponsor
          end
      end
      true
    when 'coverage'
      coverage = render_coverage(opts['year'], opts['month'], opts['talk'])
      @tree.children << coverage if coverage
      true
    else
      super
    end
  end

  def render_coverage(year, month, talk_id)
    coverage = find_coverage(year, month, talk_id)
    raise "Missing coverage for #{year}, #{month}, #{talk_id}" if coverage.nil?
    if coverage&.any?
      list = new_block_el(:ol, nil, nil, location: @src.current_line_number)
      list.attr['class'] = 'coverage'
      coverage.each do |coverage|
        coverage_elem = new_block_el(:li, nil, nil, location: @src.current_line_number)
        coverage_elem.attr['class'] = "coverage-item #{coverage['type']}"
        link = Element.new(:a, nil, nil, location: @src.current_line_number)
        link.attr['href'] = coverage['url']
        link.attr['rel'] = 'nofollow'
        add_text(coverage['title'], link)
        coverage_elem.children << link
        list.children << coverage_elem
      end
      list
    end
  end

  def find_coverage(year, month, talk_id)
    self.class.coverage.dig(year, month, talk_id)
  end

  def render_sponsor(sponsor_name, image_size)
    sponsor_details = find_sponsor(sponsor_name)
    if sponsor_details
      image_size = 'sidebar' if image_size.blank?
      link = Element.new(:a, nil, nil, location: @src.current_line_number)
      link.attr['href'] = sponsor_details.url
      if sponsor_details.logo && sponsor_details.logo[image_size]
        link.children << render_sponsor_image(sponsor_details.name, sponsor_details.logo[image_size])
      else
        add_text(sponsor_details.name, link)
      end
      link
    else
      Element.new(:raw, @src.matched)
    end
  end

  def render_sponsor_image(sponsor_name, logo_details)
    Element.new(:img, nil, {
      src: logo_details.url,
      width: logo_details.width,
      height: logo_details.height,
      alt: sponsor_name,
      title: "#{sponsor_name} Logo"
    })
  end

  def find_sponsor(sponsor_name)
    self.class.sponsors.detect { |sponsor| sponsor.name == sponsor_name }
  end

end
