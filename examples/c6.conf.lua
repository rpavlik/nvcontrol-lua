masterscreen = "right1:0.0"

masters = {
	XScreen(masterscreen),
}

-- Non-masters is initially an empty table - the loops below generate the
-- elements.
nonmasters = {}

-- Nodes are named first by wall
for _, wall in ipairs{"front", "right", "left", "floor", "top", "back"} do
	-- and then by node number 1-8 inclusive.
	for nodenum=1,8 do
		-- Each node has two screens, numbered 0 and 1.
		for screennum=0,1 do
			-- Produce the full identifier of the screen.
			local screen = ("%s%d:0.%d"):format(wall, nodenum, screennum)

			-- For every screen that isn't the master screen,
			if screen ~= masterscreen then
				-- add it to the list of nonmasters
				table.insert(nonmasters, XScreen(screen))
			end
		end
	end
end

