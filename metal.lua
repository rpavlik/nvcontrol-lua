#!/usr/bin/env lua
require("framelock")
--[[ Configuration Section ]]--
function configureScreens()
	primaryDVI = "0x00010000"

	screens = {
		Screen(":0.0"){
			gpu = ":0[gpu:0]",
			display = primaryDVI,
			framelock = ":0[framelock:0]"
		},
		Screen(":0.1"){
			gpu = ":0[gpu:1]",
			display = primaryDVI,
			framelock = ":0[framelock:0]",
			master = true
		},
		Screen(":0.2"){
			gpu = ":0[gpu:2]",  -- is this right?
			display = primaryDVI,
			framelock = ":0[framelock:1]"
		}
	}
end

-- call main function
configureFramelock()


