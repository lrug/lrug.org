articles = sitemap
             .resources
             .select { |p| page_has_data? p, category: category, status: 'Published' }
             .sort_by { |p| p.data.published_at }
             .reverse
             .take(10)
xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  site_url = "http://lrug.org/"
  xml.title "Article RSS Feed"
  xml.language "en-us"
  xml.ttl 40
  xml.link "href" => URI.join(site_url, current_page.path), "rel" => "self"
  xml.description "LRUG.org London Ruby User Group : #{category.pluralize.titleize}"
  xml.updated(articles.first.data.updated_at.iso8601) unless articles.empty?
  articles.each do |article|
    xml.entry do
      xml.title article.metadata[:page]["title"]
      xml.link "rel" => "alternate", "href" => URI.join(site_url, article.url)
      xml.published article.metadata[:page]["published_at"]
      xml.author article.metadata[:page]["created_by"]["name"]
      xml.description article.render(layout: false), "type" => "html"
    end
  end
end
