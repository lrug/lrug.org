xml.title title
xml.link url
xml.language 'en-gb'
xml.ttl 40
xml.description description
xml.copyright strip_tags(partial('license')) if with_copyright
xml.image do
  xml.title title
  xml.link url
  xml.url 'https://assets.lrug.org/images/el-rug-logo.png'
end
xml.lastBuildDate rfc_1123_date(updated_at) unless updated_at.nil?
