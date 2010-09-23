# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wrong/version.rb', __FILE__)

Gem::Specification.new do |s|
  s.name      = "wrong"
  s.version   = Wrong::VERSION
  s.authors   = ["Steve Conover", "Alex Chaffee"]
  s.email     = "sconover@gmail.com"
  s.homepage  = "http://github.com/sconover/wrong"
  s.summary   = "Wrong provides a general assert method that takes a predicate block.  Assertion failure messages are rich in detail."
  s.description  = <<-EOS.strip
Wrong provides a general assert method that takes a predicate block. Assertion failure
messages are rich in detail. The Wrong idea is to replace all those countless assert_this,
assert_that library methods which only exist to give a more useful failure message than
"assertion failed". Wrong replaces all of them in one fell swoop, since if you can write it
in Ruby, Wrong can make a sensible failure message out of it.
  EOS
  s.rubyforge_project = "wrong"

  s.files      = Dir['lib/**/*']
  s.test_files = Dir['test/**/*.rb']

  s.has_rdoc = true
  s.extra_rdoc_files = %w[README.markdown]

  s.add_dependency "predicated", "~> 0.2.1"
  s.add_dependency "ruby_parser", ">= 2.0.4"
  s.add_dependency "ruby2ruby", ">= 1.2.4"

  s.add_dependency "diff", ">= 0.3.6"
  s.add_dependency "diff-lcs", ">= 1.1.2"
end
