# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.2'
  s.required_rubygems_version = ">= 1.3.6"

  s.name        = "bsm-sso-client"
  s.summary     = "BSM's internal SSO client"
  s.description = ""
  s.version     = '0.4.1'

  s.authors     = ["Dimitrij Denissenko"]
  s.email       = "dimitrij@blacksquaremedia.com"
  s.homepage    = "https://github.com/bsm/sso-client"

  s.require_path = 'lib'
  s.files        = Dir['lib/**/*']

  s.add_dependency "activeresource", ">= 3.1.0", "< 3.2.0"
  s.add_dependency "actionpack", ">= 3.1.0", "< 3.2.0"
  s.add_dependency "railties", ">= 3.1.0", "< 3.2.0"
  s.add_dependency "rails_warden", "~> 0.5.0"

  s.add_development_dependency "activerecord"
  s.add_development_dependency "rake"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "rspec"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "webmock"
  s.add_development_dependency "sqlite3-ruby"

end
