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

  def ignore_glob
    @ignore_glob ||= compile_ignore_glob
  end

  def main
    success = true
    Dir.glob("source/**/*", File::FNM_EXTGLOB | File::FNM_DOTMATCH).each do |f|
      next unless File.file? f
      next unless starts_with_yaml? f
      next if File.fnmatch? ignore_glob, f, File::FNM_EXTGLOB | File::FNM_DOTMATCH

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

  private

  def compile_ignore_glob
    patterns = File.read(".gitignore") + File.read(".yamlignore")
    negative_entries, positive_entries = patterns
      .lines
      .reject { it.starts_with? "#" }
      .reject(&:blank?)
      .map(&:chomp)
      .partition { it.starts_with? "!" }
    puts "WARNING: can't (currently) deal with negative gitignore patterns" if negative_entries.any?
    "{#{positive_entries.map { gitignore_to_glob(it) }.join(',')}}"
  end

  def gitignore_to_glob(path)
    # TODO: https://git-scm.com/docs/gitignore#_pattern_format
    # 1. entries starting / needs to have it removed, globbing _already_ anchors
    #    at the start
    # 2. entries not starting / need to be duplicated and prefixed with **/ to
    #    pick up the exact path in the root and any descendant path
    paths = if path.starts_with? "/"
              [path.delete_prefix("/")]
            elsif path.starts_with? "**/"
              # do nothing
              [path]
            else
              [path, "**/#{path}"]
            end

    # 3. entries ending in / need to have it duplicated and augmented with /**
    #    to capture files in subdirs
    # 4. our usecase only cares about files otherwise we'd need to duplicate
    #    and trim `/` too)
    paths = paths.map { [it.delete_suffix("/"), "#{it.delete_suffix('/')}/**"] } if path.ends_with? "/"

    paths.join(",")
  end
end

LintFrontmatterYaml.new.main
