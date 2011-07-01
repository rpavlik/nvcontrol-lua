#!/usr/bin/env lua
require("nvcontrol.framelock")

-- Figure out where we're running so we don't go over the network needlessly
myhost = os.getenv("HOST")
hosts = {
	render = "metal-render.vrac.iastate.edu",
}

for shortname, hostname in pairs(hosts) do
	if myhost == hostname then
		print("Running on " .. shortname)
		hosts[shortname] = ""
	end
end

--[[ Configuration Section ]]--
masters = {
	nvcontrol.XScreen(hosts.render .. ":0.1"),
}
nonmasters = {
	nvcontrol.XScreen(hosts.render .. ":0.0"),
	nvcontrol.XScreen(hosts.render .. ":0.2"),
}


--[[ Handle command line ]]
commands = {
	on = nvcontrol.framelock.enable;
	off = nvcontrol.framelock.disable;
}

-- default command
command = "on"
if arg[1] ~= nil and commands[arg[1]] ~= nil then
	command = arg[1]
end

-- Perform the requested command
commands[command](masters, nonmasters)


