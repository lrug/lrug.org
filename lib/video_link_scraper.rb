require 'open-uri'
require "nokogiri"

class VideoLinkScraper
  def initialize
    @url = 'https://skillsmatter.com/skillscasts/14569-concurrency-in-crystal'
  end 

  def self.call
    scraper = VideoLinkScraper.new
    scraper.scrape
  end

  def scrape
    html = URI.open(@url)
    doc = Nokogiri::HTML(html)
  
    title = doc.css('h1').text
    date = doc.css('span.keydetails__datesdrawertrigger').text

    month, year = split_month_and_year(date)
  end

  private

  def split_month_and_year(date)
    date.split(' ')[1..2]
  end
 
end

VideoLinkScraper.call