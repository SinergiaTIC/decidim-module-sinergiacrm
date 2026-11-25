# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/sinergiacrm/version"

DECIDIM_VERSION = Decidim::Sinergiacrm::DECIDIM_VERSION

gem "decidim", DECIDIM_VERSION
gem "decidim-sinergiacrm", path: "."

gem "bootsnap", "~> 1.23"
gem "puma", ">= 6.3.1"

group :development, :test do
  gem "byebug", "~> 13.0", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  gem "decidim-initiatives", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 3.0"
  gem "listen", "~> 3.10"
  gem "web-console", "~> 4.3"
end
