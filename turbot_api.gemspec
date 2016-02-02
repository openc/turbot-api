require File.expand_path('../lib/turbot_api/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name    = "turbot-api"
  gem.version = Turbot::TURBOT_API_VERSION

  gem.author      = "OpenCorporates"
  gem.email       = "bots@opencorporates.com"
  gem.homepage    = "https://github.com/openc/turbot-api"
  gem.summary     = "Turbot API"
  gem.license     = "MIT"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency "rest-client", "~> 1.6.1"
  gem.add_dependency "rubyzip"
  gem.add_development_dependency "coveralls"
  gem.add_development_dependency "excon"
  gem.add_development_dependency "fakefs"
  gem.add_development_dependency "fpm"
  gem.add_development_dependency "json"
  gem.add_development_dependency "rake", ">= 0.8.7"
  gem.add_development_dependency "rr", "~> 1.0.2"
  gem.add_development_dependency "rspec", ">= 2.0"
  gem.add_development_dependency "rubyzip"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "webmock"
end
