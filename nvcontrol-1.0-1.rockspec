package = "nvcontrol"
version = "1.0-1"
source = {
   url = "https://github.com/rpavlik/nvcontrol-lua/tarball/master"
}
description = {
   summary = "Control NVidia driver attributes",
   detailed = [[
      nvcontrol provides a dynamic binding to the nvcontrol capabilities
      accessed through the nvidia-settings command line application. Objects
      can be created to represent targets (typically X Screens), and their
      attributes accessed and modified as a Lua table.
      
      Also includes nvcontrol.framelock, a related module making setting up
      framelock on complex graphics systems easier.
      
      framelocker is a command to enable or disable framelock given a Lua-based
      config file for a system.
   ]],
   homepage = "https://github.com/rpavlik/nvcontrol-lua",
   maintainer = "Ryan Pavlik",
   license = "Boost Software License 1.0"
}
dependencies = {
   "lua >= 5.1"
}
build = {
	type = "builtin",
	modules = {
		nvcontrol = "nvcontrol.lua",
		["nvcontrol.framelock"] = "nvcontrol/framelock.lua"
	}
	install = {
		bin = {
			framelocker = "framelocker", 
		}
	}
}
