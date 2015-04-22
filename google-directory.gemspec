$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "google-directory/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
	s.name        = "google-directory"
	s.version     = GoogleDirectory::VERSION
	s.authors     = ["Omar Osorio"]
	s.email       = ["omar@kioru.com"]
	s.homepage    = "https://github.com/Omac/google-directory"
	s.summary     = ""
	s.description = ""
	s.license     = "MIT"

	s.files = Dir["{app,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
	s.test_files = Dir["test/**/*"]

	s.add_dependency 'google-api-client', '~> 0.8'

	s.add_development_dependency 'rails', '~> 4.2.0'
	s.add_development_dependency "sqlite3"
end