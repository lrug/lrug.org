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
  page.attributes.slice('published_at', 'updated_at', 'slug', 'class_name', 'breadcrumb', 'created_at').tap do |frontmatter|
    frontmatter['status'] = page.status.name
    frontmatter['created_by'] = user_to_hash(page.created_by) unless page.created_by.nil?
    frontmatter['updated_by'] = user_to_hash(page.updated_by) unless page.updated_by.nil?
  end
end

def format_frontmatter(frontmatter)
  unless frontmatter.blank?
    %{#{frontmatter.to_yaml.chomp}
---

}
  end
end

def part_to_middleman_file(part, frontmatter, path, name)
  content = %Q{#{format_frontmatter(frontmatter)}#{part.content}}

  File.open(path.join("#{name}.html#{filter_to_extension(part.filter)}"), 'w') { |f| f.write(content); f.write("\n") }
end

def page_to_middleman_file(page, path, name = 'index')
  frontmatter = attrs_to_frontmatter(page)
  frontmatter['parts'] = (page.parts.map(&:name) - ['body'])
  part_to_middleman_file(page.part('body'), frontmatter, path, name)
  frontmatter['parts'].each do |part_name|
    part_to_middleman_file(page.part(part_name), {}, path, '_' + name + '_' + part_name)
  end
end

def export_page(page, path, name = page.title.parameterize)
  page_path = path.join(name)
  FileUtils.mkdir_p page_path
  page_to_middleman_file(page, page_path)
  page.children.each do |child_page|
    export_page(child_page, page_path)
  end
end

path = Rails.root.join('export')
FileUtils.mkdir_p path
Page.roots.each do |root_page|
  export_page(root_page, path, root_page.title.parameterize+'_root')
end