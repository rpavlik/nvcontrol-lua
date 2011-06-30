#!/usr/bin/env lua

--[[ Main Function ]]--
function configureFramelock()
	configureScreens()

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
	apply_to_all_screens(function(screen) screen:setFramelock(false) end)

	print_step("2.	Make sure all display devices that are to be frame- locked have the same refresh rate.")
	local refreshrate = nil
	apply_to_all_screens(
		function(screen)
			local rr = screen:getRefreshRate()
			if refreshrate == nil then
				refreshrate = rr
			else
				if rr ~= refreshrate then
					error(("Refresh rates don't match! Established standard was %s, but %s was %s!"):format(
						refreshrate,
						screen.name,
						rr
					))
				end
			end
		end
	)
	print("All displays have the same refresh rate: " .. refreshrate)

	print_step("3. Configure which Quadro/display device is to be the master.")
	apply_to_master_screens(function(screen) screen:setFramelockRole("Master") end)

	print_step("4. Configure the house sync (if applicable)")
	apply_to_all(disableHouseSync, framelocks)

	print_step("5. Configure the slave display devices.")
	apply_to_nonmaster_screens(function(screen) screen:setFramelockRole("Slaves") end)

	print_step("6.	Enable frame lock on the master Quadro.")
	apply_to_master_screens(function(screen) screen:setFramelock(true) end)

	print_step("7.	Enable frame lock on the slave Quadros.")
	apply_to_nonmaster_screens(function(screen) screen:setFramelock(true) end)

	print_step("8.	Test the hardware connections using the test signal on the master Quadro. (SKIPPED)")
end

--[[ Utility Functions and "Innards" ]]--
function do_command(cmd)
	print("Running: " .. cmd)
	os.execute(cmd)
end

function backtick(pipeline)
	--print("Running `" .. pipeline .. "`")
	io.write(".")
	local proc = io.popen(pipeline)
	local output = proc:read("*a")
	proc:close()
	return output
end
-- remove trailing and leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(8programming)
local function trim(s)
  -- from PiL2 20.4
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local ScreenClass = {}
function ScreenClass.getDisplayDevice(screen)
	return trim(backtick(([[nvidia-settings --terse --ctrl-display %s -q %s/EnabledDisplays]]):format(screen.ctrldisplay, screen.name)))
end

function ScreenClass.setFramelock(screen, enabled)
	local val = 0
	if enabled then
		val = 1
	end
	local cmd = ("nvidia-settings --ctrl-display=%s -a %s/FrameLockEnable=%d"):format(
		screen.ctrldisplay,
		screen.gpu,
		val
	)
	do_command(cmd)
end
function ScreenClass.setSyncToVBlank(screen, enabled)
	local val = 0
	if enabled then
		val = 1
	end
	local cmd = ("nvidia-settings --ctrl-display=%s -a %s/SyncToVBlank=%d"):format(
		screen.ctrldisplay,
		screen.name,
		val
	)
	do_command(cmd)
end

function ScreenClass.setFramelockRole(screen, status)
	if status ~= "Master" and status ~= "Slaves" then
		error("Framelock status is either 'Master' or 'Slaves'", 2)
	end
	local cmd = ("nvidia-settings --ctrl-display=%s -a %s/FrameLock%s=%s"):format(
		screen.ctrldisplay,
		screen.gpu,
		status,
		screen.display
	)
	do_command(cmd)
end


function ScreenClass.disableHouseSync(fl)
	local cmd = ("nvidia-settings --ctrl-display=%s -a %s/FrameLockUseHouseSync=0"):format(
		fl.ctrldisplay,
		fl.framelock
	)
	do_command(cmd)
end

function ScreenClass.getRefreshRate(screen)
	local cmd = ([[nvidia-settings --terse --ctrl-display %s -q %s/RefreshRate]]):format(
		screen.ctrldisplay,
		screen.name
	)
	return trim(backtick(cmd))
end
--[[
local ScreenClass = {
	getDisplayDevice = getDisplayDevice,
	setFramelock = setFramelock,
	setFramelockRole = setFramelockRole,
	disableHouseSync = disableHouseSync,
	getRefreshRate = getRefreshRate
}
]]
local screenmt = { __index = ScreenClass }

screens = {}
framelocks = {}
function Screen(screenName)
	return function(screen)
				setmetatable(screen, screenmt)
				screen.name = screenName
				if not screen.ctrldisplay then
					screen.ctrldisplay = screenName
				end
				if not screen.display then
					screen.display = screen:getDisplayDevice()
					print("Found display device to be " .. screen.display)
				end
				if framelocks[screen.framelock] then
					if screen.master then
						framelocks[screen.framelock].ctrldisplay = screen.ctrldisplay
						framelocks[screen.framelock].master = screen.master
					end
				else
					framelocks[screen.framelock] = {
						framelock = screen.framelock,
						ctrldisplay = screen.ctrldisplay,
						master = screen.master
					}
				
				end
				return screen	
		end
end


function print_step(step)
	print()
	print(step)
end

function apply_to_all(f, list)
	for _, val in ipairs(list) do
		f(val)
	end
end

function apply_to_all_screens(f)
	apply_to_all(f, screens)
end

function apply_to_master_screens(f)
	apply_to_all_screens(
		function(screen)
			if screen.master then
				f(screen)
			end
		end
	)
end

function apply_to_nonmaster_screens(f)
	apply_to_all_screens(
		function(screen)
			if not screen.master then
				f(screen)
			end
		end
	)
end


