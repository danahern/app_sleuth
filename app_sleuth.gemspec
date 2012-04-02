# -*- encoding: utf-8 -*-
require File.expand_path('../lib/app_sleuth/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Dan Ahern", "Lynn Wallenstein"]
  gem.email         = ["danahern@gmail.com", "lwallenstein@gmail.com"]
  gem.description   = %q{Generates color, font, image information about your project}
  gem.summary       = %q{Generate Design Info about Project}
  gem.homepage      = "https://github.com/danahern/app_sleuth"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "app_sleuth"
  gem.require_paths = ["lib"]
  gem.version       = AppSleuth::VERSION

  gem.add_dependency "sinatra"
  gem.add_dependency "color"
  gem.add_dependency "css_parser"
  gem.add_dependency "activesupport"

end
