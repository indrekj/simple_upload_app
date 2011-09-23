source "http://rubygems.org"

gem "rails", "3.0.10"

gem "hpricot", :require => false
gem "rack"
gem "paperclip", "2.3.8"
gem "json"

# for deployment
group :deployment do
  gem "mongrel"
  gem "hoe"
  gem "vlad", "2.0"
  gem "vlad-git", "2.1.0"
end

# for test env
group :test do
  gem "rspec-rails", ">= 2.0.0.beta.22", :require => false
  gem "factory_girl_rails"
end

group :production do
  gem "pg"
end

group :development, :test do
  gem "sqlite3-ruby", :require => "sqlite3"
end
