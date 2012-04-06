require "rubygems"

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require "YandexPDD"

spec = Gem::Specification.new do |s|

	s.name     = "YandexPDD"
	s.version  = Yandex::PDD::VERSION
	s.author   = "dctabuyz"
	s.email    = "dctabuyz@yandex.ru"
	s.homepage = "http://pdd.yandex.ru/"
	s.platform = Gem::Platform::RUBY
	s.summary  = "Yandex mailhosting API wrapper"

	candidates = Dir.glob("{bin,docs,lib,ext,tests}/**/*")

	s.files = candidates.delete_if do |item|

		item.include?("CVS")  ||
		item.include?("rdoc") ||
		item.include?("svn")  ||
		item.include?("swp")  ||
		item.include?("~")    ||
		item.include?("git")
	end

	s.require_path = [ "lib", "." ]
#	s.test_file = "tests/test.rb"
	s.has_rdoc     = false
	s.extensions   = "ext/extconf.rb"
	s.extra_rdoc_files = ["README.rdoc"]
#	s.add_dependency( "libxml-ruby", ">= 1.1.3" )
	s.requirements << "libxml, v1.1.3 or greater"
	s.requirements << "make utility"
end

Gem::Builder.new(spec).build if __FILE__ == $0
