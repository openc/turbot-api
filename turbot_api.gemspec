$:.unshift File.expand_path("../lib", __FILE__)
require "turbot_api/version"

Gem::Specification.new do |gem|
  gem.name    = "turbot-api"
  gem.version = TurbotApi::VERSION

  gem.author      = "Turbot"
  gem.email       = "support@opencorporates.com"
  gem.homepage    = "http://opencorporates.com/"
  gem.summary     = "Client library to deploy apps on Turbot."
  gem.description = "Client library to deploy apps on Turbot."
  gem.license     = "MIT"

  gem.files = %x{ git ls-files }.split("\n").select { |d| d =~ %r{^(License|README|bin/|data/|ext/|lib/|spec/|test/)} }

  gem.add_dependency "rest-client", "~> 1.6.1"
  gem.add_dependency "rubyzip"
end
