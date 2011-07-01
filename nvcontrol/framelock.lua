--[[
framelock.lua

Canned methods to enable and disable framelock on a collection of NVidia-powered
display devices.  Uses nvcontrol to interact with devices - nvcontrol.XScreen(<screen identifier>)
will return an object representing that X screen, which is suitable for input to these methods.
See the main nvcontrol file for more information.


nvcontrol.framelock.enable(masters, nonmasters) - Given a table of one or more master X screens and one or more non-master X screens, follows the NVidia-recommended procedure for enabling framelock.

nvcontrol.framelock.disable(allscreens) or
nvcontrol.framelock.disable(masters, nonmasters) - Given one or two tables of X screens, disable framelock on all of them.
]]

require("nvcontrol")

--[[ Utility Function ]]

local function foreach(list, func)
	for i, v in ipairs(list) do
		func(i, v)
	end
end

--[[ Main Functions ]]

local function enable(masters, nonmasters)
	local allscreens = {unpack(masters), unpack(nonmasters)}

	--[[ General Process:
	1.	Disable frame lock on all Quadros.
	2.	Make sure all display devices that are to be frame- locked have the same refresh rate.
	3. Configure which Quadro/display device is to be the master.
	4. Configure the house sync (if applicable). Skipped here, and a step to turn on sync to vblank is inserted.
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

	print_step("3.	Configure which Quadro/display device is to be the master.")
	foreach(masters, function(_, screen) screen.FrameLockMaster = screen.EnabledDisplays end)

	print_step("4.	Enable Sync to VBlank")
	foreach(allscreens, function(_, screen) screen.SyncToVBlank = true end)

	print_step("5.	Configure the slave display devices.")
	foreach(nonmasters, function(_, screen) screen.FrameLockSlaves = screen.EnabledDisplays end)

	print_step("6.	Enable frame lock on the master Quadro.")
	foreach(masters, function(_, screen) screen.FrameLockEnable = true end)

	print_step("7.	Enable frame lock on the slave Quadros.")
	foreach(nonmasters, function(_, screen) screen.FrameLockEnable = true end)

	--print_step("8.	Test the hardware connections using the test signal on the master Quadro. (SKIPPED)")
end

local function disable(masters, nonmasters)
	local allscreens
	if nonmasters == nil then
		allscreens = { unpack(masters) }
	else
		allscreens = { unpack(masters), unpack(nonmasters) }
	end
	print_step("1.	Disable frame lock on all Quadros.")
	foreach(allscreens, function(_, screen) screen.FrameLockEnable = false end)
end

nvcontrol.framelock = {}
nvcontrol.framelock.enable = enable
nvcontrol.framelock.disable = disable
return framelock


