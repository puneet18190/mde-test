source 'https://rubygems.org'

gem 'rails', '4.0.4'

gem 'ancestry'
gem 'bcrypt',                   '~> 3.1.2'
gem 'carrierwave'
gem 'daemons'
gem 'delayed_job_active_record'
gem 'erubis'
gem 'eventmachine',                         platforms: :ruby
gem 'facter',                               platforms: :ruby
gem 'jquery-rails',             '~> 2.1.4'
gem 'kaminari'
gem 'mini_magick'
gem 'nokogiri',                             platforms: :ruby
gem 'oj'
gem 'pg'
gem 'rack-maintenance'
gem 'recursive-open-struct'
gem 'rubyzip'
gem 'schema_plus'
# This fork has support for output redirection
gem 'subexec',                                                 github: 'mdesantis/subexec'
gem 'tinymce-rails',            '~> 3.0'
gem 'tinymce-rails-langs'
gem 'threach'
# TODO da mettere dopo
# gem 'turbolinks'
gem 'unicorn',                              platforms: :ruby
gem 'whenever',                                                                             require: false
gem 'win32-dir',                            platforms: :mingw

# CSS, JS and assets stuff
gem 'bootstrap-sass',          '~> 2.2.2.0'
gem 'coffee-rails',            '~> 4.0.0'
gem 'jquery-fileupload-rails'
gem 'sass-rails',              '~> 4.0.2'
# Sass 3.3 leads to this issue https://github.com/nex3/sass/issues/1162
gem 'sass',                    '~> 3.2.0'
gem 'therubyracer',                         platforms: :ruby
gem 'uglifier',                '>= 1.3.0'

group :development do
  gem 'irb-benchmark'
  # mailcatcher is not suggested to be in the Gemfile http://mailcatcher.me/#bundler
  # gem 'mailcatcher',        '>= 0.5.12',    platforms: :ruby
  # Basta assets che monopolizzano il log dell'application server!
  gem 'quiet_assets'
  gem 'rails-erd'
end

group :development, :test do
  gem 'colorize'
  gem 'rspec-rails',          '~> 3.0.0.beta2'
  gem 'ruby_parser'
  gem 'file-tail'
  gem 'sourcify'
end

group :doc do
  gem 'sdoc',                                                                                require: false
end

group :irbtools do
  gem 'irbtools',                           platforms: :ruby
end

group :production do
  gem 'exception_notification'
end
