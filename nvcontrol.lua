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

Example interactive session:

$ lua -l nvcontrol
Lua 5.1.4  Copyright (C) 1994-2008 Lua.org, PUC-Rio
> s = nvcontrol.XScreen(":0.0")
> print(tostring(s))
nvcontrol.XScreen(":0.0")
> print(s.RefreshRate)
59.97 Hz

]]
--[[ Utility Functions ]]

local function do_command(cmd)
	if nvcontrol.verbose then
		print("Running: " .. cmd)
	end
	os.execute(cmd)
end

local function backtick(pipeline)
	if nvcontrol.verbose then
		print("Running `" .. pipeline .. "`")
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
	local proc = io.popen("nvidia-settings -e list")
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
	return list
end

local function nvidiaSettings(tgt)
	if rawget(tgt, "ctrldisplay") ~= nil then
		return "nvidia-settings --ctrl-display=" .. rawget(tgt, "ctrldisplay")
	else
		return "nvidia-settings"
	end

end

--[[ Data ]]
local knownAttributes = {}
nvcontrol = {}

--[[ Metatable Methods ]]

-- Getter
local function setAttribute(tgt, attr, value)
	if knownAttributes[attr] == nil then
		error("nvidia-settings knows no attribute named " .. attr, 2)
	end
	if value == true then
		value = 1
	elseif value == false then
		value = 0
	end
	local cmd = ("%s -a %s/%s=%d"):format(
		nvidiaSettings(tgt),
		tgt.id,
		attr,
		tostring(value)
	)
	local ret = do_command(cmd)
	if ret ~= 0 then
		error(("Error setting attribute %s to %s on target %s!"):format(attr, tostring(value), tgt.id), 2)
	end
end

-- Setter
local function getAttribute(tgt, attr)
	if knownAttributes[attr] == nil then
		error("nvidia-settings knows no attribute named " .. attr, 2)
	end
	local cmd = ([[%s --terse -q %s/%s]]):format(
		nvidiaSettings(tgt),
		tgt.id,
		attr
	)
	local output = trim(backtick(cmd))
	if #output == 0 then
		error(
			("Could not get attribute %s on target %s - nvidia-settings printed a message to stderr")
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
	local s = { id = name, ctrldisplay = name }
	setmetatable(s, XScreenMT)
	return s
end

--[[ Initialization ]]
nvcontrol.verbose = (os.getenv("NVCONTROL_VERBOSE") == "1")
nvcontrol.XScreen = createXScreen
initializeAttributeList(knownAttributes)

return nvcontrol
