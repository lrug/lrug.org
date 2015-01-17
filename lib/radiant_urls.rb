export_path = Rails.root.join('all_urls.txt')
File.open(export_path, 'w') do |out|
  Page.all.each do |page|
    out.write(page.url)
    out.write("\n")
  end
end
