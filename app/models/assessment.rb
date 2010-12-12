require "hpricot"
require "paperclip_processors/assessment_processor"

class Assessment < ActiveRecord::Base
  module Sources
    WEBCT = "webct"
    MOODLE = "moodle"
    UNKNOWN = "unknown"
  end

  has_attached_file :test, :processors => [:assessment_processor], :styles => {:clean => true}

  # Callbacks
  before_validation(:on => :create) do
    if self.year.blank? || self.year > Time.now.year || self.year < 2000
      self.year = Time.now.year
    end
  end
  before_validation do
    self.assign_category unless self.category_name.blank?
  end

  before_update Proc.new {|a| a.confirmed = true}

  # Associations
  belongs_to :category, :counter_cache => true

  # Validations
  validates :title, :presence => true, :on => :update
  validates :category_name, :presence => true, :if => Proc.new {|a| a[:category].blank?}, :on => :update
  validates :attempt_id, :uniqueness => {:scope => :source}, :allow_blank => true

  validates_attachment_presence :test
  validates_attachment_content_type :test, :content_type => [/application/, /plain/, /htm/]
  validates_attachment_size :test, :less_than => 300.kilobytes

  scope :confirmed, :conditions => {:confirmed => true}
  scope :unconfirmed, :conditions => {:confirmed => false}

  def body
    self.test ? File.read(self.test.path(:clean)) : ""
  end

  def title=(t)
    self[:title] = t.to_s.strip
  end

  attr_writer :category_name
  def category_name
    @category_name || self.category && self.category.name
  end

  def parse_questions_and_answers
    unless self.source == Sources::WEBCT ||
        self.category_name =~ /Sissejuhatus matemaatilisse loogikasse/i
      return
    end

    sanitizer = HTML::FullSanitizer.new
    results = []

    case self.source
    when Sources::WEBCT
      doc = Hpricot.parse(self.body)
      question_rows = doc.search("tr.questionrow/../tr[@class!='questionrow']")
      question_rows.each do |question_row|
        result = {:answers => [], :question => nil}

        question = question_row.search("td[2]/table/tr[1]/td").innerHTML
        result[:question] = sanitizer.sanitize(question.strip.gsub(/\r/, "").gsub(/\n/, "").gsub(/\<.{0,1}b\>/, ""))

        answers_table = question_row.search("td[2]/table/tr[3]/td/table.tablebody/tbody")
        answer_rows = answers_table.search("tr/td/img/../../td[2]")
        answer_rows.each do |answer_row|
          result[:answers] << answer_row.innerHTML.strip.
            gsub(/\r/, "").gsub(/\n/, "").gsub(/\<.{0,1}b\>/, "")
        end
        results << result
      end

      results.to_yaml
    end
  end

  protected

  def assign_category
    cat = Category.first(:conditions => ["LOWER(name) = ?", self.category_name.downcase])
    cat ||= Category.create(:name => self.category_name)

    self[:category_id] = cat.id
  end
end
