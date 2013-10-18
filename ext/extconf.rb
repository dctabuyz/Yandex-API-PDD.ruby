require "rubygems"

filename = File.expand_path("..", __FILE__) + "/Makefile"

makefile = File::open(filename, "w")

makefile.write("install:\n\t")

begin
	require "libxml"

	makefile.write("@echo fake libxml install\n")

rescue LoadError

	makefile.write("@gem install libxml-ruby\n")
end

makefile.close
