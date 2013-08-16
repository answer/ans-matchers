# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ans-matchers/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["sakai shunsuke"]
  gem.email         = ["sakai@ans-web.co.jp"]
  gem.description   = %q{rspec マッチャ}
  gem.summary       = %q{rspec マッチャ}
  gem.homepage      = "https://github.com/answer/ans-matchers"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ans-matchers"
  gem.require_paths = ["lib"]
  gem.version       = Ans::Matchers::VERSION
end
