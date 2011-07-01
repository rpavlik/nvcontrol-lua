#!/usr/bin/env lua

require("nvcontrol")

function print_step(step)
	print()
	print(step)
end


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

--[[ Configuration Section ]]--

--[[
challenger.vrac:~/src/framelocker> nvidia-settings -q screens -q gpus -q framelocks -q vcs -q gvis -q fans

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

2 Fans on challenger.vrac.iastate.edu:0

    [0] challenger.vrac.iastate.edu:0[fan:0] (Fan 0)

    [1] challenger.vrac.iastate.edu:0[fan:1] (Fan 1)

]]

masters = {
	nvcontrol.XScreen(challenger .. ":0.0"),
}
nonmasters = {	
	nvcontrol.XScreen(challenger .. ":0.1"),
	nvcontrol.XScreen(challenger .. ":0.2"),
	nvcontrol.XScreen(challenger .. ":0.3"),
}

allscreens = {unpack(masters), unpack(nonmasters)}
function foreach(list, func)
	for i, v in ipairs(list) do
		func(i, v)
	end
end


--[[ General Process:
1.	Disable frame lock on all Quadros.
2.	Make sure all display devices that are to be frame- locked have the same refresh rate.
3. Configure which Quadro/display device is to be the master.
4. Configure the house sync (if applicable)
5. Configure the slave display devices.
6.	Enable frame lock on the master Quadro.
7.	Enable frame lock on the slave Quadros.
8.	Test the hardware connections using the test signal on the master Quadro.
]]

print_step("1.	Disable frame lock on all Quadros.")
foreach(allscreens, function(_, screen) screen.FrameLockEnable = false end)

print_step("2.	Make sure all display devices that are to be frame- locked have the same refresh rate.")
local refreshrate = nil
foreach(allscreens,
	function(_, screen)
		local rr = screen.RefreshRate
		if refreshrate == nil then
			refreshrate = rr
		else
			if rr ~= refreshrate then
				error(("Refresh rates don't match! Established standard was %s, but %s was %s!"):format(
					refreshrate,
					tostring(screen),
					rr
				))
			end
		end
	end
)
print("All displays have the same refresh rate: " .. refreshrate)

print_step("3. Configure which Quadro/display device is to be the master.")
foreach(masters, function(_, screen) screen.FrameLockMaster = screen.EnabledDisplays end)

print_step("4. Enable Sync to VBlank (recommended by NVidia, according to the C6 scripts)")
foreach(allscreens, function(_, screen) screen.SyncToVBlank = true end)

print_step("5. Configure the slave display devices.")
foreach(nonmasters, function(_, screen) screen.FrameLockSlaves = screen.EnabledDisplays end)

print_step("6.	Enable frame lock on the master Quadro.")
foreach(masters, function(_, screen) screen.FrameLockEnable = true end)

print_step("7.	Enable frame lock on the slave Quadros.")
foreach(nonmasters, function(_, screen) screen.FrameLockEnable = true end)

print_step("8.	Test the hardware connections using the test signal on the master Quadro. (SKIPPED)")


