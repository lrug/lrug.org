require 'page_context' # make sure we have the previous definition first

class PageContext < Radius::Context
  alias_method :old_init, :initialize

  def initialize(page)
    old_init page

    # <r:hello [name="Sean"] />
    define_tag "hello" do |tag|
      name = tag.attr['name'] || "World" 
      "Hello, #{name}!" 
    end

    # <r:hcard fn="Murray" [url="http://...."] [nickname="Muz,h-lame"] [photo="http://..."] [elem="li"]/>
    define_tag "hcard" do |tag|
      elem = tag.attr['elem'] || 'li'
      open_card = "<#{elem} class=\"vcard\">"
      close_card = "</#{elem}>"
      fn_tag = "<span class=\"fn\">#{tag.attr['fn']}</span>"
      nickname_tag = if tag.attr['nickname'].nil?
        ''
      else
        " (<span class=\"nickname\">#{tag.attr['nickname'].split(',').join('</span>, <span class="nickname">')}</span>)"
      end
      open_url = if tag.attr['url'].nil?
        ''
      else
        "<a class=\"url\" href=\"#{tag.attr['url']}\" title=\"#{tag.attr['url']}\">"
      end
      close_url = if tag.attr['url'].nil?
        ''
      else
        '</a>'
      end
      photo_tag = if tag.attr['photo'].nil?
        ''
      else
        "<img class=\"photo\" src=\"#{tag.attr['photo']}\"/>"
      end
      "#{open_card}#{open_url}#{fn_tag}#{nickname_tag}#{photo_tag}#{close_url}#{close_card}"
    end
  end

end
