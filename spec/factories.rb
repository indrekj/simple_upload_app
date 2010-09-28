require "factory_girl"
require "faker"

Factory.define :assessment do |a|
  a.title { Faker::Lorem.words(1).to_s }
  a.association :category
end

Factory.define :category do |c|
  c.name { Faker::Lorem.words(1).to_s }
end

Factory.define :link do |l|
  l.url "http://google.com"
  l.description "this is google"
end

Factory.define :message do |m|
  m.author { Faker::Name.name }
  m.body { Faker::Lorem.paragraph[0, 30] }
end
