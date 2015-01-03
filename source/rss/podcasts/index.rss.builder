--- 
published_at: 2010-04-03 08:22:33 Z
title: podcasts
created_at: 2010-04-03 15:21:48 Z
slug: podcasts
breadcrumb: podcasts
updated_at: 2013-02-12 23:09:29 Z
status: Published
created_by: 
  email: murray.steele@gmail.com
  login: hlame
  name: Murray Steele
class_name: ""
layout: false
---
podcasts = podcast_episodes.take(10)
site_url = 'http://lrug.org/'

xml.instruct!
xml.rss 'xmlns:itunes' => 'http://www.itunes.com/dtds/podcast-1.0.dtd', version: '2.0', 'xmlns:dc' => 'http://purl.org/dc/elements/1.1/' do
  xml.channel do
    xml.title 'LRUG Podcast'
    xml.link URI.join(site_url, 'podcasts')
    xml.ttl 40
    xml.language 'en-gb'
    xml.copyright 'http://creativecommons.org/licenses/by-nc-sa/2.0/uk/'
    xml.itunes :subtitle, 'The LRUG podcast'
    xml.itunes :author, 'El Rug'
    xml.itunes :summary, "The LRUG podcast is a podcast from the London Ruby User Group.  It's interviews with speakers from our meetings, chats with members, and news from the London Ruby community."
    xml.description "The LRUG podcast is a podcast from the London Ruby User Group.  It's interviews with speakers from our meetings, chats with members, and news from the London Ruby community."
    xml.itunes :owner do
      xml.itunes :name, 'El Rug'
      xml.itunes :email, 'chat@lrug.org'
    end
    xml.itunes :image, href: 'http://assets.lrug.org/images/el-rug-sidebar.png'
    xml.itunes :category, text: 'Technology'
    xml.lastBuildDate rfc_1123_date(podcasts.first.data.updated_at) unless podcasts.empty?
    podcasts.each do |podcast|
      xml.item do
        podcast_url = URI.join site_url, url_for(podcast)
        xml.title podcast.data.title
        xml.itunes :author, podcast.data.created_by.name
        xml.itunes :subtitle, podcast.data.title
        xml.itunes :summary, podcast.render(layout: false)
        xml.description podcast.render(layout: false)
        xml.pubDate rfc_1123_date(podcast.data.published_at)
        xml.guid podcast_url
        xml.link podcast_url
        xml.enclosure url: podcast.data.file_url, length: podcast.data.file_size, type: 'audio/mpeg'
        xml.itunes :duration, podcast.data.duration
        xml.itunes :keywords, podcast.data.keywords
      end
    end
  end
end
