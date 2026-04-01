require "middleman-core/util/data"
require "middleman-core/util"
require "open3"

class LintFrontmatterYaml
  def starts_with_yaml?(file)
    # TODO: is `--- ` actually valid yaml?
    ["---\n", "--- "].include? File.read(file, 4)
  end

  def read_frontmatter(file)
    frontmatter = []
    File.open(file) do |f|
      frontmatter << f.readline
      while (line = f.readline)
        break if line.starts_with?("---")

        frontmatter << line
      end
    rescue EOFError
      # EOF is expected if the file is _only_ frontmatter
    end
    frontmatter.join
  end

  def main
    success = true
    Dir["source/**/*"].each do |f|
      next unless File.file? f
      next unless starts_with_yaml? f

      Open3.popen2("yamllint -") do |stdin, stdout_and_stderr, wait_thread|
        frontmatter = read_frontmatter(f)
        stdin << frontmatter
        stdin.close
        unless wait_thread.value.success?
          puts stdout_and_stderr.read.gsub("stdin", f)
          success = false
        end
      end
    end
    exit success
  end
end

LintFrontmatterYaml.new.main
