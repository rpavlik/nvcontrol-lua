#!/usr/bin/env lua
require("nvcontrol.framelock")
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

host = os.getenv("HOST")
if host == "challenger.vrac.iastate.edu" then
	print("OK, running on Challenger")
	challenger, columbia = "", "columbia.vrac.iastate.edu"
elseif host == "columbia.vrac.iastate.edu" then
	print("OK, running on Columbia")
	challenger, columbia = "challenger.vrac.iastate.edu", ""
else
	print("You are brave - not running on either machine!")
	challenger, columbia = "challenger.vrac.iastate.edu", "columbia.vrac.iastate.edu"
end

masters = {
	nvcontrol.XScreen(challenger .. ":0.0"),
}
nonmasters = {
	nvcontrol.XScreen(challenger .. ":0.1"),
	nvcontrol.XScreen(challenger .. ":0.2"),
	nvcontrol.XScreen(challenger .. ":0.3"),
	--nvcontrol.XScreen(columbia .. ":0.0"),
}

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

