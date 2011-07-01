#!/usr/bin/env lua
require("nvcontrol.framelock")

-- Figure out where we're running so we don't go over the network needlessly
myhost = os.getenv("HOST")
hosts = {
	challenger = "challenger.vrac.iastate.edu",
	columbia = "columbia.vrac.iastate.edu",
}

for shortname, hostname in pairs(hosts) do
	if myhost == hostname then
		print("Running on " .. shortname)
		hosts[shortname] = ""
	end
end


--[[ Configuration Section ]]--

--[[
challenger.vrac:~/src/framelocker> nvidia-settings -q screens -q gpus -q framelocks -q vcs

4 X Screens on challenger.vrac.iastate.edu:0

    [0] challenger.vrac.iastate.edu:0.0 (Quadro 7000)

    [1] challenger.vrac.iastate.edu:0.1 (Quadro 7000)

    [2] challenger.vrac.iastate.edu:0.2 (Quadro 7000)

    [3] challenger.vrac.iastate.edu:0.3 (Quadro 7000)

2 GPUs on challenger.vrac.iastate.edu:0

    [0] challenger.vrac.iastate.edu:0[gpu:0] (Quadro 7000)

    [1] challenger.vrac.iastate.edu:0[gpu:1] (Quadro 7000)

1 Frame Lock Device on challenger.vrac.iastate.edu:0

    [0] challenger.vrac.iastate.edu:0[framelock:0] (G-Sync 0)

1 VCS on challenger.vrac.iastate.edu:0

    [0] challenger.vrac.iastate.edu:0[vcs:0] (NVIDIA QuadroPlex 7000)
]]

masters = {
	nvcontrol.XScreen(hosts.challenger .. ":0.0"),
}
nonmasters = {
	nvcontrol.XScreen(hosts.challenger .. ":0.1"),
	nvcontrol.XScreen(hosts.challenger .. ":0.2"),
	nvcontrol.XScreen(hosts.challenger .. ":0.3"),
	--nvcontrol.XScreen(hosts.columbia .. ":0.0"),
}

--[[ Handle command line ]]
commands = {
	on = nvcontrol.framelock.enable;
	off = nvcontrol.framelock.disable;
}

command = "on"
if arg[1] ~= nil and commands[arg[1]] ~= nil then
	command = arg[1]
end

-- Perform the requested command
commands[command](masters, nonmasters)

