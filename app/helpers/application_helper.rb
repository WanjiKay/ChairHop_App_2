module ApplicationHelper
  DEFAULT_AVATAR_URL = "https://res.cloudinary.com/dxxsqdiay/image/upload/v1775931118/ChairHop_Icon_Light_FIXED_ieefrl.png".freeze

  def markdown_to_html(text)
    return "" if text.blank?

    # Use kramdown to convert markdown to HTML
    require 'kramdown'
    html = Kramdown::Document.new(text, input: 'GFM', hard_wrap: true).to_html

    # Add target="_blank" to all links for opening in new tab
    html = html.gsub(/<a /, '<a target="_blank" rel="noopener noreferrer" ')

    # Sanitize and mark as safe
    sanitize(html, tags: %w[p br a strong em ul ol li], attributes: %w[href target rel])
  end
end
