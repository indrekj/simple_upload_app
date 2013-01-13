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
      title = doc.search("tr/td/div[3]/div/ul/li[4]/a").innerHTML.strip
      category_name = doc.search("tr/td/div/h1").innerHTML.strip
    when Assessment::Sources::WEBCT
      doc = Hpricot.parse(body)
      title = doc.search(".controlset/table/tr[1]/td[2]").innerHTML.strip
    end
    title = "" if title.to_s.downcase == "test"

    [title, category_name]
  end

  def self.remove_delicate_info(source, body)
    content = body.dup

    case source
    when Assessment::Sources::MOODLE
      # No need for header (including user real name)
      content.gsub!(/<div id="header" .*?(<div id="content")/m, '\1')

      # No need for submit forms
      content.gsub!(/<form.*?<\/form>/m, "")

      # Hacking attempts? No need for these either.
      content.gsub!(/sesskey=.{10}/, "")
    end

    content
  end
end
