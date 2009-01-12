module Merb
  module GlobalHelpers
    def set_title(title)
      throw_content(:title) { title }
    end

    def menu_link(name, path)
      link = link_to(name, path)
      if path == @request.path
        %!<span class="selected">#{link}</span>!
      else
        link
      end
    end
    
    def catch_errors_for(asset)
      @e_model = asset
    end

    def error_messages_for(asset)
      return if asset.errors.blank?
      str = '<div class="error">'
      str += "<h2>Tekkisid järgnevad vead:</h2>"
      str += "<ul>"
      asset.errors.to_a.each do |type, msg|
        str += "<li>#{msg}</li>"
      end
      str += "</ul></div>"
      str
    end

    def truncate(text, length, omission = '...')
      if text.length > length
        text[0..length] + ' ' + omission
      else
        text
      end
    end
  end
end
