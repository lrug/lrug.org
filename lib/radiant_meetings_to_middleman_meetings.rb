require 'fileutils'

def filter_to_extension(filter)
  case filter
  when SmartyPantsFilter
    '.smarty'
  when MarkdownFilter
    '.md'
  when ScssFilter
    '.scss'
  when SassFilter
    '.sass'
  when CoffeeFilter
    '.coffee'
  when TextileFilter
    '.textile'
  end
end

def user_to_hash(user)
  user.attributes.slice('name', 'email', 'login')
end

def attrs_to_frontmatter(page)
  page.attributes.slice('published_at', 'updated_at', 'slug', 'class_name', 'breadcrumb', 'created_at', 'title').tap do |frontmatter|
    frontmatter['status'] = page.status.name
    frontmatter['created_by'] = user_to_hash(page.created_by) unless page.created_by.nil?
    frontmatter['updated_by'] = user_to_hash(page.updated_by) unless page.updated_by.nil?
    frontmatter['category'] = 'meeting'
  end
end

def format_frontmatter(frontmatter)
  unless frontmatter.blank?
    %{#{frontmatter.to_yaml.chomp}
---

}
  end
end

def body_and_extended_to_middleman_file_contents(page, frontmatter)
  content = %Q{#{format_frontmatter(frontmatter)}#{page.part('body').content}}
  
  extended_part = page.part('extended')
  if extended_part && extended_part.content.present?
    if filter_to_extension(extended_part.filter) != filter_to_extension(page.part('body').filter)
      content << %{\n\n##### filter: #{filter_to_extension(extended_part.filter)}}
    end
    content << "\n\n"
    content << extended_part.content
  end
  content
end

def part_to_frontmatter(part, body_filter)
  return nil unless part.content.present?
  {
    :content => part.content,
    :filter => filter_to_extension(part.filter)
  }
end

def page_to_middleman_file(page, path, name = 'index')
  frontmatter = attrs_to_frontmatter(page)
  frontmatter['parts'] = {}
  body_part = page.part('body')
  (page.parts.map(&:name) - ['body', 'extended']).each do |part_name|
    as_frontmatter = part_to_frontmatter(page.part(part_name), body_part.filter)
    frontmatter['parts'][part_name] = as_frontmatter unless as_frontmatter.blank?
  end
  content = body_and_extended_to_middleman_file_contents(page, frontmatter)

  File.open(path.join("#{name}.html#{filter_to_extension(body_part.filter)}"), 'w') { |f| f.write(content); f.write("\n") }
end

def radiant_meeting_name_to_middleman_meeting_name(name)
  md = name.match /(january|february|march|april|may|june|july|august|september|october|november|december)-(\d{4})/
  if md.nil?
    name
  else
    "#{md[2]}/#{md[1]}"
  end
end

def export_page(page, path, name = page.title.parameterize)
  meeting_name = radiant_meeting_name_to_middleman_meeting_name(name)
  page_path = path.join(meeting_name)
  FileUtils.mkdir_p page_path
  page_to_middleman_file(page, page_path)
  page.children.each do |child_page|
    export_page(child_page, page_path)
  end
end

path = Rails.root.join('export')
FileUtils.mkdir_p path
meeting_root = Page.find(:first, :conditions => {:title => 'Meetings'})
export_page(meeting_root, path, 'meetings_root')
