source "http://rubygems.org"

gem "rails", "3.0.0"

gem "sqlite3-ruby", :require => "sqlite3"
gem "hpricot", :require => false
gem "rack"
gem "dropio", :git => "git://github.com/dropio/dropio.git", :branch => "version-3-0"
gem "paperclip"

# Postgresql
gem "pg"

# for deployment
group :deployment do
  gem "hoe"
  gem "vlad", "2.0"
  gem "vlad-git", "2.1.0"
end

# for test env
group :test do
  gem "rspec-rails", ">= 2.0.0.beta.22", :require => false
  gem "factory_girl", :require => false
  gem "faker"
end
