source "http://rubygems.org"

gem "rails", "~> 3.1.1"

gem "hpricot", :require => false
gem "rack"
gem "paperclip", "~> 3.4.0"
gem "json"
gem "tork"

# for deployment
group :deployment do
  gem "hoe"
  gem "vlad"
  gem "vlad-git"
end

# for test env
group :test do
  gem "rspec-rails", ">= 2.0.0", :require => false
  gem "factory_girl_rails"
end

group :production do
  gem "pg"
end

group :development, :test do
  gem "sqlite3-ruby", :require => "sqlite3"
end
