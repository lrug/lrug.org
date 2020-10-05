require 'middleman-core/renderers/kramdown'

class Middleman::Renderers::MiddlemanKramdownHTML < Kramdown::Converter::Html
  def format_as_block_html(name, attr, body, indent)
    return super unless name =~ /\Ah\d\Z/ && attr['id'].present?

    anchor = %{ <a href="##{attr['id']}" class="heading-anchor" aria-hidden="true">#</a>}
    super(name, attr, body + anchor, indent)
  end
end
