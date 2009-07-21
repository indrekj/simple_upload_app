module FixtureReplacement
  attributes_for :link do |l|
    l.url = 'http://google.com'
    l.description = random_string(20)
  end

  attributes_for :message do |m|
    m.author = random_string(10)
    m.body   = random_string(20)
  end
end
