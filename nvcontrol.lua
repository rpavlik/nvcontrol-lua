--[[
nvcontrol.lua

A dynamic binding to the nvcontrol capabilities accessed through the
nvidia-settings command line application.

nvcontrol.XScreen( <screen identifier> ) - returns an object representing
an X screen.  Attributes can be accessed with . for getting and setting,
where permitted.

nvcontrol.verbose - set to true to see all command lines executed along with
additional debug info. If the environment variable NVCONTROL_VERBOSE is "1",
this defaults to true.

nvcontrol.dryrun - set to true to just have the commands printed, not actually run.
If the environment variable NVCONTROL_DRYRUN is "1", this defaults to true.

Example interactive session:

$ lua -l nvcontrol
Lua 5.1.4  Copyright (C) 1994-2008 Lua.org, PUC-Rio
> s = nvcontrol.XScreen(":0.0")
> print(tostring(s))
nvcontrol.XScreen(":0.0")
> print(s.RefreshRate)
59.97 Hz

]]

--[[
Original author: Ryan Pavlik <rpavlik@iastate.edu> <abiryan@ryand.net>
http://academic.cleardefinition.com

//          Copyright Iowa State University 2011.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

]]

--[[ Data ]]
local nv = "nvidia-settings "
local knownAttributes = {}
nvcontrol = {}

--[[ Utility Functions ]]

local function do_command(cmd)
	if nvcontrol.verbose or nvcontrol.dryrun then
		print("nvcontrol.lua: Running: " .. cmd)
	else
		cmd = cmd .. " > /dev/null"
	end
	if nvcontrol.dryrun then
		return 0
	end
	local status = os.execute(cmd)
	if nvcontrol.verbose then
		print("nvcontrol.lua: exited with status " .. tostring(status))
	end
	return status
end

local function backtick(pipeline)
	if nvcontrol.verbose or nvcontrol.dryrun then
		print("nvcontrol.lua: Running `" .. pipeline .. "`")
	end
	if nvcontrol.dryrun then
		return "`" .. pipeline .. "`"
	end
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

local function initializeAttributeList(list)
	if nvcontrol.dryrun then
		return
	end
	local cmd = nv .. "-e list"
	local proc = io.popen(cmd)
	for v in proc:lines() do
		local line = trim(v)
		if #line > 0 then
			list[line] = true
			table.insert(list, line)
		end
	end
	if nvcontrol.verbose then
		print("nvcontrol.lua: " .. tostring(#list) .. " attributes recognized.")
	end
	if #list == 0 then
		error("Could not get an attribute list! " ..
			"Tried command '" .. cmd .. "' and got no (usable) output.")
	end
	return list
end

local function nvidiaSettings(tgt)
	if rawget(tgt, "ctrldisplay") ~= nil then
		return nv .. "--ctrl-display=" .. rawget(tgt, "ctrldisplay")
	else
		return nv
	end

end


--[[ Metatable Methods ]]

-- Getter
local function setAttribute(tgt, attr, value)
	if knownAttributes[attr] == nil and not nvcontrol.dryrun then
		error(nv .. "knows no attribute named " .. attr, 2)
	end
	if value == true then
		value = 1
	elseif value == false then
		value = 0
	end
	local cmd = ("%s -a %s/%s=%s"):format(
		nvidiaSettings(tgt),
		tgt.id,
		attr,
		tostring(value)
	)
	local ret = do_command(cmd)
	if ret ~= 0 then
		--error(("Error setting attribute %s to %s on target %s!"):format(attr, tostring(value), tgt.id), 2)
		--print(("WARNING: %s exited with code %d setting attribute %s to %s on target %s!"):format(nv, ret, attr, tostring(value), tgt.id))
	end
end

-- Setter
local function getAttribute(tgt, attr)
	if knownAttributes[attr] == nil and not nvcontrol.dryrun then
		error(nv .. "knows no attribute named " .. attr, 2)
	end
	local cmd = ([[%s --terse -q %s/%s]]):format(
		nvidiaSettings(tgt),
		tgt.id,
		attr
	)
	local output = trim(backtick(cmd))
	if #output == 0 then
		error(
			("Could not get attribute %s on target %s - look for a message on stderr")
			:format(
				attr,
				tgt.id
			), 2
		)
	end
	return output
end

-- tostring for XScreens
local function screenToString(screen)
	return ([[nvcontrol.XScreen("%s")]]):format(screen.id)
end

--[[ Object Creation Methods and Metatables ]]

-- XScreen
local XScreenMT = {__index = getAttribute, __newindex = setAttribute, __tostring = screenToString }
local function createXScreen(name)
	local s = { id = name }
	if name ~= os.getenv("DISPLAY") then
		s.ctrldisplay = name
	end
	setmetatable(s, XScreenMT)
	return s
end

--[[ Initialization ]]
nvcontrol.verbose = (os.getenv("NVCONTROL_VERBOSE") == "1")
nvcontrol.dryrun = (os.getenv("NVCONTROL_DRYRUN") == "1")
nvcontrol.XScreen = createXScreen
initializeAttributeList(knownAttributes)

return nvcontrol
