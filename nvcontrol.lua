local function do_command(cmd)
	print("Running: " .. cmd)
	os.execute(cmd)
end

local function backtick(pipeline)
	--print("Running `" .. pipeline .. "`")
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

local function setAttribute(tgt, attr, value)
	if value == true then
		value = 1
	elseif value == false then
		value = 0
	end
	local cmd = ("nvidia-settings --ctrl-display=%s -a %s/%s=%d"):format(
		tgt.ctrldisplay,
		tgt.id,
		attr,
		tostring(value)
	)
	local ret = do_command(cmd)
	if ret ~= 0 then
		error(("Error setting attribute %s to %s on target %s!"):format(attr, tostring(value), tgt.id), 2)
	end
end

local function getAttribute(tgt, attr)
	local cmd = ([[nvidia-settings --terse --ctrl-display %s -q %s/%s]]):format(
		tgt.ctrldisplay,
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

local function screenToString(screen)
	return ([[nvcontrol.XScreen("%s")]]):format(screen.id)
end

local XScreenMT = {__index = getAttribute, __newindex = setAttribute, __tostring = screenToString }
local function createXScreen(name)
	local s = { id = name, ctrldisplay = name }
	setmetatable(s, XScreenMT)
	return s
end

nvcontrol = {
	XScreen = createXScreen
}

return nvcontrol
