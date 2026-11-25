# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/sinergiacrm/version"

Gem::Specification.new do |s|
  s.version = Decidim::Sinergiacrm::VERSION
  s.authors = ["Ivan Vergés", "Anna Topalidi"]
  s.email = ["ivan@pokecode.net"]
  s.license = "AGPL-3.0-or-later"
  s.homepage = "https://github.com/SinergiaTIC/decidim-module-sinergiacrm"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/SinergiaTIC/decidim-module-sinergiacrm/issues",
    "homepage_uri" => "https://github.com/SinergiaTIC/decidim-module-sinergiacrm",
    "source_code_uri" => "https://github.com/SinergiaTIC/decidim-module-sinergiacrm",
    "rubygems_mfa_required" => "true"
  }
  s.required_ruby_version = ">= 3.4"

  s.name = "decidim-sinergiacrm"
  s.summary = "SinergiaCRM integration for Decidim"
  s.description = "SinergiaCRM integration for Decidim: OAuth login, synchronization of contacts, relationship types and projects, and verifications based on them."

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "package.json", "README.md"]

  s.add_dependency "decidim-core", Decidim::Sinergiacrm::COMPAT_DECIDIM_VERSION
  s.add_dependency "deface", ">= 1.9"
  s.add_dependency "omniauth-oauth2", "~> 1.8"
end
