set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'
set :build_dir, 'public'

meeting_years = Dir['source/meetings/*'].each.with_object([]) do |meeting_child, years|
  name = meeting_child.split('/').last
  years << name if name =~ /\A\d{4}\Z/
end
set :years, meeting_years.sort

require "lib/lrug_helpers"
helpers LRUGHelpers

require 'lib/lrug_extended_kramdown'
# we have to refer to this via `@app` as otherwise it ends up being a
# Middleman::CoreExtensions::Collections::LazyCollectorStep instead
# of the actual data we want.
Kramdown::Parser::LRUGExtendedKramdown.sponsors = @app.data.sponsors
Kramdown::Parser::LRUGExtendedKramdown.coverage = @app.data.coverage
set :markdown, input: 'LRUGExtendedKramdown'

configure :build do
  ignore 'archive/*'

  activate :minify_css
  activate :minify_html do |html|
    html.remove_multi_spaces        = true   # Remove multiple spaces
    html.remove_comments            = true   # Remove comments
    html.remove_intertag_spaces     = false  # Remove inter-tag spaces
    html.remove_quotes              = false  # Remove quotes
    html.simple_doctype             = false  # Use simple doctype
    html.remove_script_attributes   = false  # Remove script attributes
    html.remove_style_attributes    = true   # Remove style attributes
    html.remove_link_attributes     = true   # Remove link attributes
    html.remove_form_attributes     = false  # Remove form attributes
    html.remove_input_attributes    = false  # Remove input attributes
    html.remove_javascript_protocol = true   # Remove JS protocol
    html.remove_http_protocol       = false  # Remove HTTP protocol
    html.remove_https_protocol      = false  # Remove HTTPS protocol
    html.preserve_line_breaks       = false  # Preserve line breaks
    html.simple_boolean_attributes  = true   # Use simple boolean attributes
    html.preserve_patterns          = nil    # Patterns to preserve
  end
end

page '/book-reviews/index.html', layout: 'books'
page '/book-reviews/*/index.html', layout: 'book-review'
page '/meetings/*/*/index.html', layout: 'meeting'
page '/podcasts/*/index.html', layout: 'podcast'
page '/nights/index.html', layout: 'nights'
page '/nights/*/index.html', layout: 'nights-episode'

["meeting", "book-review"].each do |category|
  proxy "/rss/#{category.pluralize}/index.rss", "/rss/template.rss", :layout => false, :locals => { :category => category, description: nil }, :ignore => true
end
proxy "/rss/nights/index.rss", "/rss/template.rss", layout: false, locals: { category: 'nights', description: "LRUG Nights : solving' crimes, drinkin' beers" }, ignore: true

config[:years].each do |year|
  proxy "/meetings/#{year}/index.html", "/meetings/meetings_index.html", locals: { year: year }, ignore: true
end

page '/.htaccess', layout: false
page '/version.json', layout: false

ready do
  sitemap.resources.
    select { |r| r.data.status && r.data.status != 'Published' }. # if files have status, only keep published ones
    each do |unpublished|
      ignore unpublished.path
    end
end
