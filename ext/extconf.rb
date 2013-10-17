require "rubygems"
require "rubygems/command_manager"

begin
	require "libxml"

rescue LoadError

	libxml_install_exception = nil

	begin
		Gem::CommandManager.instance.run("install libxml-ruby")

	rescue Exception => libxml_install_exception
	# XXX intended to be empty
	end

	begin
		require "libxml"

	rescue LoadError

		raise libxml_install_exception unless libxml_install_exception.nil?

		# this should never happen
		raise Gem::InstallError, "something is wrong...\n\n" +
		                         "this should never happen, please report to author\n\n"
	end
end

filename = File.expand_path("..", __FILE__) + "/Makefile"

makefile = File::open(filename, "w")
makefile.write("install:\n\t@echo fake libxml install\n")
makefile.close
