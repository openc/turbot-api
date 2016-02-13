require File.expand_path('../lib/turbot/api/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name    = "turbot-api"
  gem.version = Turbot::API::VERSION

  gem.author      = "OpenCorporates"
  gem.email       = "bots@opencorporates.com"
  gem.homepage    = "https://github.com/openc/turbot-api"
  gem.summary     = "Turbot API client"
  gem.license     = "MIT"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency('rest-client', '~> 1.8')

  gem.add_development_dependency('coveralls')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('rspec', '~> 3.4')
  gem.add_development_dependency('webmock')
end
