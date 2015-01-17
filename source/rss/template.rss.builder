---
status: Published
---
articles = pages_in_category(category).take(10)
site_url = "http://lrug.org/"

xml.instruct!
xml.rss version: '2.0', 'xmlns:dc' => 'http://purl.org/dc/elements/1.1/' do
  xml.channel do
    channel_title = "LRUG #{category.pluralize.titleize} RSS Feed"
    channel_url = URI.join(site_url, category)
    channel_description = "LRUG.org London Ruby User Group : #{description || category.pluralize.titleize}"
    xml << indent_xml(4, partial(
      'rss/channel',
      locals: {
        title: channel_title,
        url: channel_url,
        description: channel_description,
        updated_at: articles.empty? ? nil : articles.first.data.updated_at,
        with_copyright: true
      }
    ))
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
