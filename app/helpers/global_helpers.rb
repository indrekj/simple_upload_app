module Merb
  module GlobalHelpers
    def error_messages_for(asset)
      str = '<div class="error">'
      str += "<h2>Tekkisid järgnevad vead:</h2>"
      str += "<ul>"
      asset.errors.to_a.each do |type, msg|
        str += "<li>#{msg}</li>"
      end
      str += "</ul></div>"
      str
    end
  end
end
