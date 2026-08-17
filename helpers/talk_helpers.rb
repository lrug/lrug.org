require_relative "../lib/lrug/models"

module TalkHelpers
  def render_talks(_for_page = current_page)
    year = current_page.data.meeting_date.year.to_s
    month = current_page.data.meeting_date.strftime("%B").downcase
    talks = find_talks(year, month)
    if talks.present?
      talks.map { it.render(on: self) }.join
    else
      partial_with_opts_passthrough "no_talks_yet"
    end
  end

  def partial_with_opts_passthrough(template, options = {}, &)
    passthrough_opts = instance_variable_get("@opts").dup
    partial(template, passthrough_opts.merge(options), &)
  end

  def find_talks(year, month)
    data.talks.dig(year, month)&.map { Lrug::Talk.from(year:, month:, id: it[0], details: it[1]) }
  end

  def blockquote(content)
    "> #{content.split("\n").join("\n> ")}"
  end
end
