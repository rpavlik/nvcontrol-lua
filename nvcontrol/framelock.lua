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


--[[
Original author: Ryan Pavlik <rpavlik@iastate.edu> <abiryan@ryand.net>
http://academic.cleardefinition.com

//          Copyright Iowa State University 2011.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

]]

require("nvcontrol")

--[[ Utility Function ]]

local function foreach(list, func)
	for i, v in ipairs(list) do
		func(i, v)
	end
end

local function print_step(step)
	print()
	print()
	print("------------------------------------------------------")
	print(step)
end

--[[ Main Functions ]]

local function enable(masters, nonmasters)
	local allscreens = {unpack(masters), unpack(nonmasters)}

	--[[ General Process:
	1.	Disable frame lock on all Quadros.
	2.	Make sure all display devices that are to be frame-locked have the same refresh rate.
	3.	Enable Sync to VBlank.
	4.	Configure which Quadro/display device is to be the master.
	5.	Configure the house sync (if applicable).
	6.	Configure the slave display devices.
	7.	Enable frame lock on the master Quadro.
	8.	Enable frame lock on the slave Quadros.
	9.	Test the hardware connections using the test signal on the master Quadro. (skipped)

	This is from the NVIDIA documentation, with the sync to vblank step added.
	]]

	print_step("1.	Disable frame lock on all Quadros.")
	foreach(allscreens, function(_, screen) screen.FrameLockEnable = false; io.write(".") end)

	print_step("2.	Make sure all display devices that are to be frame- locked have the same refresh rate.")
	local refreshrate = nil
	foreach(allscreens,
		function(_, screen)
			local rr = screen.RefreshRate
			if refreshrate == nil then
				refreshrate = rr
			else
				if rr ~= refreshrate and not nvcontrol.dryrun then
					error(("Refresh rates don't match! Established standard was %s, but %s was %s!"):format(
						refreshrate,
						tostring(screen),
						rr
					))
				end
			end
			io.write(".")
		end
	)
	print("\nAll displays have the same refresh rate: " .. refreshrate)

	print_step("3.	Enable Sync to VBlank")
	foreach(allscreens, function(_, screen) screen.SyncToVBlank = true; io.write(".") end)

	print_step("4.	Configure which Quadro/display device is to be the master.")
	foreach(masters, function(_, screen) screen.FrameLockMaster = screen.EnabledDisplays; io.write(".") end)

	print_step("5.	Configure the house sync (if applicable).")
	foreach(masters, function(_, screen) screen.FrameLockMaster = screen.EnabledDisplays; io.write(".") end)

	print_step("6.	Configure the slave display devices.")
	foreach(nonmasters, function(_, screen) screen.FrameLockSlaves = screen.EnabledDisplays; io.write(".") end)

	os.execute("sleep 0.2")

	print_step("7.	Enable frame lock on the master Quadro.")
	foreach(masters, function(_, screen) screen.FrameLockEnable = true; io.write(".") end)

	print_step("8.	Enable frame lock on the slave Quadros.")
	foreach(nonmasters, function(_, screen) screen.FrameLockEnable = true; io.write(".") end)

	--print_step("9.	Test the hardware connections using the test signal on the master Quadro. (SKIPPED)")
	print_step("Done!")
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


