# turbot-api

[![Gem Version](https://badge.fury.io/rb/turbot-api.svg)](https://badge.fury.io/rb/turbot-api)
[![Build Status](https://secure.travis-ci.org/openc/turbot-api.png)](https://travis-ci.org/openc/turbot-api)
[![Dependency Status](https://gemnasium.com/openc/turbot-api.png)](https://gemnasium.com/openc/turbot-api)
[![Coverage Status](https://coveralls.io/repos/openc/turbot-api/badge.png)](https://coveralls.io/r/openc/turbot-api)
[![Code Climate](https://codeclimate.com/github/openc/turbot-api.png)](https://codeclimate.com/github/openc/turbot-api)

## Releasing a new version

Bump the version in `lib/turbot/api/version.rb` according to the [Semantic Versioning](http://semver.org/) convention, then:

    git commit lib/turbot/api/version.rb -m 'Release new version'
    rake release # requires Rubygems credentials

Finally, [rebuild the Docker image](https://github.com/openc/morph-docker-ruby#readme) and deploy [morph](https://github.com/sebbacon/morph/).
