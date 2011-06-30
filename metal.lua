#!/usr/bin/env lua
require("framelock")
--[[ Configuration Section ]]--
screens = {
	Screen(":0.0"){
		gpu = ":0[gpu:0]",
		framelock = ":0[framelock:0]"
	},
	Screen(":0.1"){
		gpu = ":0[gpu:1]",
		framelock = ":0[framelock:0]",
		master = true
	},
	Screen(":0.2"){
		gpu = ":0[gpu:2]",  -- is this right?
		framelock = ":0[framelock:1]"
	}
}

-- call main function
enableFramelock()


