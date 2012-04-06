require "rubygems"
require "rubygems/command_manager"

ok  = 0

cmd = Gem::CommandManager::new

begin
	require "libxml"
	ok = 1

rescue LoadError

	print "libxml not found, trying to install\n"

	$stdout.flush

	begin
		ok = cmd.run("install libxml-ruby")

	ensure 
		begin
			require "libxml"
			ok = 1

		rescue LoadError

			ok = 0
		end
	end
end

raise Gem::InstallError, "Failed dependencies to install: libxml" unless ok

n = File.expand_path("..", __FILE__) + "/Makefile"

f = File::open(n, "w")
f.write("install:\n")
f.write("\t@echo fake libxml install\n")
f.close
