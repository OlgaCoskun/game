source 'https://rubygems.org'

gem 'rails', '~> 4.2.6'

# gem 'devise', '~> 4.1.1'
gem 'devise'
gem 'devise-i18n'

gem 'uglifier', '>= 1.3.0'

gem 'jquery-rails'
gem 'twitter-bootstrap-rails'
gem 'font-awesome-rails'
gem 'russian'

gem "pry",      :group => :development

group :development, :test do
  gem 'sqlite3'
  gem 'byebug'
  gem 'rspec-rails', '~> 3.4'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers'
end

# Гемы для интегрального тестирования
# capybara - эмулирует действия пользователя в rspec
# launchy помогает смотреть страницы в браузере
group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'pry-byebug'
end

group :production do
  # гем, улучшающий вывод логов на Heroku
  # https://devcenter.heroku.com/articles/getting-started-with-rails4#heroku-gems
  gem 'rails_12factor'
  gem 'pg'
end
