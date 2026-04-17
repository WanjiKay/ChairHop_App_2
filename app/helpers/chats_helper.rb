module ChatsHelper
  def render_markdown(text)
    return "" if text.blank?
    Kramdown::Document.new(text, input: "GFM", hard_wrap: true).to_html.html_safe
  end

  def parse_hopps_bio_marker(content)
    return { body: content, bio: nil } if content.blank?
    marker_pattern = /\[APPLY_BIO:\s*(.*?)\]/m
    match = content.match(marker_pattern)
    if match
      bio = match[1].strip
      body = content.sub(marker_pattern, "").strip
      { body: body, bio: bio }
    else
      { body: content, bio: nil }
    end
  end
end
