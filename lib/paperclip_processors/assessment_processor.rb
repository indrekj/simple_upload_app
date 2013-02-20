class AssessmentProcessor < Paperclip::Processor
  def initialize(file, options = {}, attachment = nil)
    super
    @assessment = attachment.instance
    @body = file.read
  end

  def make
    # Source
    @assessment.source = self.class.determine_source(@body)

    # Title, category
    @assessment.title, @assessment.category_name =
      self.class.determine_title_and_type(@assessment.source, @body)

    # Clean body
    body = self.class.remove_delicate_info(@assessment.source, @body)

    tmp = Tempfile.new(".tmp.assessment-processor", :encoding => "ascii-8bit")
    tmp.puts(body)
    tmp
  end

  def self.determine_source(body)
    case body
    when /moodle/i then Assessment::Sources::MOODLE
    when /webct/i then Assessment::Sources::WEBCT
    else
      Assessment::Sources::UNKNOWN
    end
  end

  def self.determine_title_and_type(source, body)
    title, category_name = nil, nil

    case source
    when Assessment::Sources::MOODLE
      doc = Hpricot.parse(body)
      title = doc.search("title").innerHTML.strip
      category_name = doc.search("h1.headermain").innerHTML.strip
    when Assessment::Sources::WEBCT
      doc = Hpricot.parse(body)
      title = doc.search(".controlset/table/tr[1]/td[2]").innerHTML.strip
    end
    title = "" if title.to_s.downcase == "test"

    [title, category_name]
  end

  def self.remove_delicate_info(source, body)
    return body if source != Assessment::Sources::MOODLE

    doc = Hpricot.parse(body)

    # No need for header (including user real name)
    doc.search(".headermenu").remove

    # Hacking attempts? No need for these either.
    doc.search("//input[@name=sesskey]").remove

    html = doc.to_html

    # Hacking attempts? No need for these either.
    html.gsub!(/sesskey=.{10}/, "")
    html.gsub!(/\"sesskey\":\".{10}\",/, "")

    html
  end
end
