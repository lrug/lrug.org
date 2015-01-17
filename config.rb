###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# configure :development do
#   activate :livereload
# end

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

activate :build_reporter do |br|
  br.reporter_file_formats = ['json']
  br.reporter_file = 'version'
end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

set :build_dir, 'public'

meeting_years = Dir['source/meetings/*'].each.with_object([]) do |meeting_child, years|
  name = meeting_child.split('/').last
  years << name if name =~ /\A\d{4}\Z/
end
set :years, meeting_years

require "lib/lrug_helpers"
helpers LRUGHelpers

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"

  ignore 'lrug_root/meetings/*'
  ignore 'lrug_root/rss-feed/*'
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

years.each do |year|
  proxy "/meetings/#{year}/index.html", "/meetings/meetings_index.html", locals: { year: year }, ignore: true
end

proxy '/.htaccess', '/.htaccess.html', layout: false, ignore: true

ready do
  sitemap.resources.
    reject { |r| r.data.status && r.data.status == 'Published' }. # keep published files
    reject { |r| r.path =~ %r{(javascripts|images|stylesheets)/} }. # and assets
    reject { |r| r.path =~ %r{\.htaccess\Z} }. # and .htaccess files
    each do |unpublished|
      ignore unpublished.path
    end
end
