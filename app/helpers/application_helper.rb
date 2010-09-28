module ApplicationHelper
  def set_title(title)
    content_for(:title) { title }
  end

  def menu_link(name, path)
    link = link_to(name, path)
    if path == request.path
      raw %!<span class="selected">#{link}</span>!
    else
      link
    end
  end

  def catch_errors_for(model)
    @e_model = model
  end

  def error_messages_for(model)
    return if model.errors.empty?
    str = '<div class="error">'
    str += "<h2>Tekkisid järgnevad vead:</h2>"
    str += "<ul>"
    model.errors.each do |key, msg|
      str += "<li>#{msg}</li>"
    end
    str += "</ul></div>"
    str
  end
end
