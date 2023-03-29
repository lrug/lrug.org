require 'yaml'

class InsertScrapedCoverage 
  END_OF_BOILER_PLATE_TITLE = 40

  def initialize
    @filepath = './data/coverage/scraped_coverage.yml'
  end

  def self.call
    @insert_scraped_coverage = InsertScrapedCoverage.new
    @insert_scraped_coverage.format_coverage
  end

  def format_coverage
    raw_coverage_info = YAML.load_stream(File.open(@filepath))

    raw_coverage_info.each do |coverage|
      year = coverage['year']
      target_file = File.open("./data/coverage/#{year}.yml", "a+")
      target_file_yaml = YAML.load_stream(target_file)
 
      formatted_coverage = { 
        coverage['title'][END_OF_BOILER_PLATE_TITLE..-1].split(' ').join('-').downcase => {
          'type' => coverage['video'],
          'url' => coverage['url'],
          'title' => coverage['title']
        }
      }

      merged_data = target_file_yaml[coverage['month'].downcase].merge(formatted_coverage)
      target_file.write(merged_data.to_yaml)
    end
  end

  def filter_coverage_by_date
    format_coverage.each do |single_video_entry|
      year = single_video_entry['year']

      target_file = File.open("./data/coverage/#{year}.yml", "r")


      break
      # if single_video_entry['month'] == target_file['']
      #    target_file.deep_merge!(single_video_coverage)
      # else
      #    target_file.write(single_video_entry.to_yaml)
      # end
    end
  end
end

InsertScrapedCoverage.call