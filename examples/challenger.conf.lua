challenger = "challenger.vrac.iastate.edu"
columbia = "columbia.vrac.iastate.edu"
--[[ Configuration Section ]]--

--[[
challenger.vrac:~/src/framelocker> nvidia-settings -q screens -q gpus -q framelocks -q vcs

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
]]

masters = {
	XScreen(challenger .. ":0.0"),
}
nonmasters = {
	XScreen(challenger .. ":0.1"),
	XScreen(challenger .. ":0.2"),
	XScreen(challenger .. ":0.3"),
	--XScreen(columbia .. ":0.0"),
}

