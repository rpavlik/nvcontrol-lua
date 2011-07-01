
hosts = {
	render = "metal-render.vrac.iastate.edu",
}


--[[ Configuration Section ]]--
masters = {
	XScreen(hosts.render .. ":0.1"),
}
nonmasters = {
	XScreen(hosts.render .. ":0.0"),
	XScreen(hosts.render .. ":0.2"),
}

