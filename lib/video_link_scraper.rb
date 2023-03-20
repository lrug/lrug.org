require 'open-uri'
require "nokogiri"
require 'yaml'

class VideoLinkScraper
  def initialize
    @url = 'https://skillsmatter.com/skillscasts/14569-concurrency-in-crystal'
    @filepath = './data/coverage/scraped_coverage.yml'
  end 

  def self.call
    @scraper = VideoLinkScraper.new
    @scraper.scrape
  end

  def scrape
    html = URI.open(@url)
    doc = Nokogiri::HTML(html)
  
    title = doc.css('h1').text
    date = doc.css('span.keydetails__datesdrawertrigger').text

    month, year = split_month_and_year(date)
    add_to_yaml_file(title, month, year, @url)
  end

  private

  def split_month_and_year(date)
    date.split(' ')[1..2]
  end

  def add_to_yaml_file(title, month, year, url)
    coverage_info = { 
      year.to_i => {
        month => {
          'type' => 'video',
          'url' => url,
          'title' => 'Skills Matter : London Ruby User Group : ' + title, 
        }
      }  
    }

    File.open(@filepath, "w") { |f| f.write(coverage_info.to_yaml) }
  end 
end

VideoLinkScraper.call