require 'date'
require 'yaml'
require 'active_support/all'

extracted_talks = {}

Dir['source/meetings/**/*.md.orig'].each do |f|
  puts f

  year_and_month_match = f.match(/\Asource\/meetings\/(\d\d\d\d)\/(january|february|march|april|may|june|july|august|september|october|november|december)\//)
  if year_and_month_match.nil?
    puts "******** ARG - meeting has no month and year name"
    puts f
    next
  end

  data = File.read(f)

  _, frontmatter, content = data.split(/---\s*\n/)

  parsed_frontmatter = YAML.load("---\n#{frontmatter}", permitted_classes: [Time, Date, Symbol])
  puts parsed_frontmatter['meeting_date']
  meeting_date = parsed_frontmatter['meeting_date']

  unless content.split('## Agenda').size > 1
    puts "*** no agenda section for"
    puts f
    next
  end

  unless content.split('## Agenda')[1].split(/## (Afterwards|Pub)/).size > 1
    puts "*** no afterwards or pub section for"
    puts f
    next
  end

  talks = content.split('## Agenda')[1].split(/## (Afterwards|Pub)/)[0].split('### ')[1..]

  parsed_talks = talks.map do |talk|
    talk_lines = talk.lines
    title = talk_lines.shift.chomp
    use_description_as_intro = false

    coverage_line = talk_lines.detect { it.start_with? '{::coverage' }
    if coverage_line
      coverage_id = coverage_line.match(/talk="([^"]*)"/)[1]
      talk_lines.delete(coverage_line)
    end

    intro_lines = talk_lines.take_while { !it.start_with? '>' }.map(&:chomp)

    speaker = intro_lines.reject { it.blank? }.join("\n")
    speaker_bits = speaker.match(/\A\[([^\]]*)\]\(([^\)]*)\)(?:\s+([^:]*))?:?\Z/m)
    if speaker_bits
      speaker = {
        'name' => speaker_bits[1],
        'url' => speaker_bits[2],
        'raw' => speaker
      }
      custom_intro = speaker_bits[3].strip if speaker_bits[3] && speaker_bits[3].strip != 'says'
    end

    description_lines = talk_lines[intro_lines.size..].select { it.start_with? '>' }.map { it.sub(/>\s*/,'').chomp }

    if description_lines.reject { it.blank? }.join("\n").strip.blank?
      puts "No blockquotes for #{title} in #{f} assuming intro is description"
      description = intro_lines
    else
      description = description_lines.join("\n")
    end

    outro_lines = talk_lines[(intro_lines.size + description_lines.size)..].map { it.strip.chomp }
    unless outro_lines.reject { it.blank? }.join("\n").strip.blank?
      puts "found some outro lines after the description for #{title} in #{f} assume everything is the description"
      puts outro_lines
      description = talk_lines.join
      use_description_as_intro = true
    end

    talk_details = {title:, speaker:, description:, coverage_id: }
    talk_details[:custom_intro] = custom_intro if custom_intro
    talk_details[:use_description_as_intro] = true if use_description_as_intro

    coverage = YAML.load(File.read("data/coverage/#{meeting_date.year}.yml")).dig(meeting_date.strftime('%B').downcase, coverage_id)
    talk_details[:coverage] = coverage || []

    talk_details
  end

  extracted_talks[meeting_date.year] ||= {}
  extracted_talks[meeting_date.year][meeting_date.strftime('%B').downcase] = { 'order' => meeting_date.month }
  parsed_talks.each do |parsed_talk|
    talk_id = parsed_talk[:coverage_id] || parsed_talk[:title].split(':')[0].parameterize
    extracted_talks[meeting_date.year][meeting_date.strftime('%B').downcase][talk_id] = {
      'title' => parsed_talk[:title],
      'description' => parsed_talk[:description],
      'speaker' => parsed_talk[:speaker],
      'coverage' => parsed_talk[:coverage],
    }
    if parsed_talk[:custom_intro]
      extracted_talks[meeting_date.year][meeting_date.strftime('%B').downcase][talk_id]['custom_intro'] = parsed_talk[:custom_intro]
    end
    if parsed_talk[:use_description_as_intro]
      extracted_talks[meeting_date.year][meeting_date.strftime('%B').downcase][talk_id]['use_description_as_intro'] = true
    end
  end

  File.write(f.sub(/\.orig/, '.erb'),
    if data.match? /\#\# Afterwards/
      data.sub(/\#\# Agenda\s+.*\#\# Afterwards/m, "## Agenda\n\n<%= render_talks %>\n\n## Afterwards")
    else
      data.sub(/\#\# Agenda\s+.*\#\# Pub/m, "## Agenda\n\n<%= render_talks %>\n\n## Pub")
    end
  )
end

extracted_talks.keys.each do |year|
  extracted_talks[year] = Hash[extracted_talks[year].sort_by { |_,talk| talk['order'] }]
  extracted_talks[year].each { |_, talk| talk.delete('order') }
  puts "data/talks/#{year}.yml"
  puts '------'
  puts extracted_talks[year].to_yaml
  File.write "data/talks/#{year}.yml", extracted_talks[year].to_yaml
end
