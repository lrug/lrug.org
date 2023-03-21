require 'open-uri'
require "nokogiri"
require 'yaml'

class VideoLinkScraper
  BASE_URL = 'https://skillsmatter.com'

  def initialize
    @filepath = './data/coverage/scraped_coverage.yml'
    @page_numbers = 0..38
  end 

  def self.call
    @scraper = VideoLinkScraper.new
    @scraper.skillsmatter_scrape
  end

  def skillsmatter_scrape
    talk_links = []
    # just for testing - replace [0] with @page_numbers
    [0].each do |number|
      page_url = "#{BASE_URL}/groups/3-london-ruby-user-group?page=#{number}&#past_events"
      
      html = URI.open(page_url)
      document = Nokogiri::HTML(html)

      talk_links << document.css("div.event-info").map do |node| 
				             BASE_URL + node.css("a").first.attr("href")
                   end
    end

    talk_links.flatten!
  end

  def video_info_scrape(url)
    html = URI.open(url)
    doc = Nokogiri::HTML(html)
  
    title = doc.css('h1').text
    date = doc.css('span.keydetails__datesdrawertrigger').text

    month, year = split_month_and_year(date)
    add_to_yaml_file(title, month, year, url)
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