require 'kramdown/parser/kramdown'

class Kramdown::Parser::LRUGExtendedKramdown < Kramdown::Parser::Kramdown
  cattr_accessor :sponsors

  def handle_extension(name, opts, body, type, line_no = nil)
    case name
    when 'sponsor'
      sponsor = render_sponsor(opts['name'], opts['size'])
      @tree.children <<
        if type == :block
          Element.new(:p).tap { |e| e.children << sponsor }
        else
          sponsor
        end
      true
    else
      super
    end
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
        link.value = sponsor_details.name
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
