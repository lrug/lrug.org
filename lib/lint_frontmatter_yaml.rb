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
    map = {}
    linestart = line = 1
    output = ""
    Open3.popen2("yamllint -") do |stdin, stdout_and_stderr, wait_thread|
      Dir.glob("source/**/*", File::FNM_EXTGLOB | File::FNM_DOTMATCH).each do |f|
        next unless File.file? f
        next unless starts_with_yaml? f
        next if File.fnmatch? ignore_glob, f, File::FNM_EXTGLOB | File::FNM_DOTMATCH

        print "."
        frontmatter = read_frontmatter(f)
        stdin << frontmatter
        linestart = line
        line += frontmatter.lines.size
        map[linestart...line] = f
      end
      stdin.close
      puts # newline after progress dots
      unless wait_thread.value.success?
        output = stdout_and_stderr.read
        success = false
      end
    end
    exit if success

    puts rewrite_output(output, map)
    exit false
  end

  private

  def rewrite_output(...)
    # These are the env vars that yamllint looks for to automatically output github annotation formatting:
    # See: https://github.com/adrienverge/yamllint/blob/30a25fe087e31d0345be0ffed4360e4651a44b6e/yamllint/cli.py#L96-L97
    if ENV.key?("GITHUB_ACTIONS") && ENV.key?("GITHUB_WORKFLOW")
      rewrite_github_output(...)
    else
      rewrite_standard_output(...)
    end
  end

  def rewrite_github_output(output, map)
    rewritten = ["::group::Linting YAML frontmatter\n"]

    # remove group / endgroup top + tail
    current_file = [(-2..-1), "stdin"]
    output.lines[1..-2].each do |line|
      next if line.starts_with? "::endgroup::"
      next if line.starts_with? "::group::"
      next if line.blank?

      md = line.match(/line=(\d+),col=(\d+)::(\d+):(\d+) /)
      next if md.blank?

      row = md[1].to_i
      col = md[2].to_i
      unless row == md[3].to_i && col == md[4].to_i
        raise "What is going on?! line=x,col=y don't match ::x:y, row: #{row}, col:#{col}, line:#{line}"
      end

      current_file = find_file_for_row(row, map) unless current_file.first.cover? row

      translated_row = row.to_i - current_file.first.first + 1
      rewritten << line.gsub("file=stdin,line=#{row},col=#{col}::#{row}:#{col} ",
                             "file=#{current_file.last},line=#{translated_row},col=#{col}::#{translated_row}:#{col} ",)
    end

    rewritten << "::endgroup::\n"
    rewritten.join
  end

  def rewrite_standard_output(output, map)
    rewritten = []

    current_file = [(-2..-1), "stdin"]
    output.lines[1..].each do |line|
      next if line.blank?

      location = line.split.first
      row, col = location.split(":").map &:to_i
      unless current_file.first.cover? row
        current_file = find_file_for_row(row, map)
        rewritten << "\n" unless rewritten.empty?
        rewritten << "#{current_file.last}\n"
      end
      translated_row = row.to_i - current_file.first.first + 1
      rewritten << line.gsub(location, "#{translated_row}:#{col}")
    end

    rewritten.join
  end

  def compile_ignore_glob
    yamllint_config = YAML.load_file(".yamllint")
    patterns = [*yamllint_config["ignore-from-file"]].map { File.read it }.join
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

  def find_file_for_row(row, map)
    while (file = map.shift)
      break if file.nil?
      return file if file.first.cover? row
    end
    raise "Can't find file to cover line #{row} in remainig map: #{map}"
  end
end

LintFrontmatterYaml.new.main
