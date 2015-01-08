---
status: Published
---
articles = pages_in_category(category).take(10)
site_url = "http://lrug.org/"

xml.instruct!
xml.rss version: '2.0', 'xmlns:dc' => 'http://purl.org/dc/elements/1.1/' do
  xml.channel do
    xml.title "LRUG #{category.pluralize.titleize} RSS Feed"
    xml.link URI.join(site_url, category)
    xml.language 'en-gb'
    xml.ttl 40
    xml.description "LRUG.org London Ruby User Group : #{category.pluralize.titleize}"
    xml.lastBuildDate rfc_1123_date(articles.first.data.updated_at) unless articles.empty?
    articles.each do |article|
      article_url = URI.join(site_url, url_for(article))
      xml.item do
        xml.title article.data.title
        xml.description article.render(layout: false)
        xml.pubDate rfc_1123_date(article.data.published_at)
        xml.guid article_url, isPermaLink: 'true'
        xml.link article_url
      end
    end
  end
end
