# frozen_string_literal: true

require 'yaml'

class InsertScrapedCoverage
  # the "Skills Matter : ..." boiler plate assigned to the begining of each coverage title 
  END_OF_BOILER_PLATE_TITLE = 40

  def initialize
    @filepath = './data/coverage/scraped_coverage.yml'
  end

  def self.call
    @insert_scraped_coverage = InsertScrapedCoverage.new
    @insert_scraped_coverage.merge_scraped_coverage_into_coverage_file
  end

  def formatted_coverage
    raw_coverage_info = YAML.load_stream(File.open(@filepath))
    raw_coverage_info.map do |coverage|
      {
        'year' => coverage['year'],
        'month' => coverage['month'].downcase,
        'formatted_entry' => {
          format_coverage_title(coverage['title']) => {
            'type' => 'video',
            'url' => coverage['url'],
            'title' => coverage['title']
          }
        }
      }
    end
  end

  def merge_scraped_coverage_into_coverage_file
    # Update array to include all years once the scraper has run
    [2019].each do |year|
      filepath = "./data/coverage/#{year}.yml"
      target_file = File.open(filepath, 'r')
      target_file_yaml = YAML.safe_load(target_file)

      formatted_coverage.each do |coverage|
        if target_file_yaml && target_file_yaml.keys.include?(coverage['month'])
          target_file_yaml[coverage['month']].merge!(coverage['formatted_entry'])
        else
          target_file_yaml.merge!({coverage['month'] => coverage['formatted_entry']})
        end
      end
      
      File.write(filepath, target_file_yaml.to_yaml)
    end
  end

  private

  def format_coverage_title(title)
    title[END_OF_BOILER_PLATE_TITLE..].split(' ').join('-').downcase
  end
end

InsertScrapedCoverage.call
