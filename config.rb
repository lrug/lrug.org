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

require "lib/speaker_helpers"
helpers SpeakerHelpers

# get our kramdown `{::blah}` extensions
require 'lib/lrug_extended_kramdown'
# we have to refer to this via `@app` as otherwise it ends up being a
# Middleman::CoreExtensions::Collections::LazyCollectorStep instead
# of the actual data we want.
Kramdown::Parser::LRUGExtendedKramdown.sponsors = @app.data.sponsors
Kramdown::Parser::LRUGExtendedKramdown.coverage = @app.data.coverage
set :markdown, input: 'LRUGExtendedKramdown'

# get our kramdown renderer extensions
# NOTE: this just extends the default middleman kramdown renderer because
# there's no extension hook for changing this class
require 'lib/lrug_extended_middleman_kramdown_html'

configure :build do
  ignore 'archive/*'
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
