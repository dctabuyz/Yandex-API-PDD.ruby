require 'rubygems'

spec = Gem::Specification.new do |s|

	s.name     = "YandexPDD"
	s.version  = "0.0.1"
	s.author   = "dctabuyz"
	s.email    = "dctabuyz@yandex.ru"
	s.homepage = "http://pdd.yandex.ru/"
	s.platform = Gem::Platform::RUBY
	s.summary  = "Yandex mailhosting API wrapper"

	candidates = Dir.glob("{bin,docs,lib,ext,tests}/**/*")

	s.files = candidates.delete_if do |item|

		item.include?("CVS") ||
		item.include?("rdoc") ||
		item.include?("svn") 
	end

	s.require_path = [ "lib", "." ]
#	s.test_file = "tests/test.rb"
	s.has_rdoc = false
	s.extra_rdoc_files = ["README"]
	s.add_dependency( "libxml-ruby", ">= 1.1.3" )
end

Gem::Builder.new(spec).build if __FILE__ == $0
