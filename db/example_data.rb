module FixtureReplacement
  attributes_for :asset do |a|
    a.title = random_string(15)
    a.category = create_category
  end

  attributes_for :category do |c|
    c.name = random_string(14)
  end

  attributes_for :link do |l|
    l.url = 'http://google.com'
    l.description = random_string(20)
  end

  attributes_for :message do |m|
    m.author = random_string(10)
    m.body   = random_string(20)
  end
end
