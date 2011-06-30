#!/usr/bin/env lua
require("framelock")
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
function configureScreens()
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
	screens = {
		Screen(challenger .. ":0.0"){
			gpu = challenger .. ":0[gpu:0]",
			framelock = challenger .. ":0[framelock:0]"
		},
		Screen(challenger .. ":0.1"){
			gpu = challenger .. ":0[gpu:0]",
			framelock = challenger .. ":0[framelock:0]",
			master = true
		},
		Screen(challenger .. ":0.2"){
			gpu = challenger .. ":0[gpu:1]",
			framelock = challenger .. ":0[framelock:0]"
		},
		Screen(challenger .. ":0.3"){
			gpu = challenger .. ":0[gpu:1]",
			framelock = challenger .. ":0[framelock:0]"
		},
		--[[
		Screen(columbia .. ":0.0"){
			gpu = columbia .. ":0[gpu:0]",
			--display = primaryDVI,
			framelock = columbia .. ":0[framelock:0]"
		},
		Screen(columbia .. ":0.1"){
			gpu = columbia .. ":0[gpu:0]",
			--display = primaryDVI,
			framelock = columbia .. ":0[framelock:0]"
		},
		Screen(columbia .. ":0.2"){
			gpu = columbia .. ":0[gpu:1]",
			--display = primaryDVI,
			framelock = columbia .. ":0[framelock:0]"
		},
		Screen(columbia .. ":0.3"){
			gpu = columbia .. ":0[gpu:1]",
			--display = primaryDVI,
			framelock = columbia .. ":0[framelock:0]"
		},]]
	}
end

-- call main function
configureFramelock()


