local kicktables = {}

--  0     1     2     3
--      
--  @  |  @  |     |  @
-- @@@ |  @@ | @@@ | @@
--     |  @  |  @  |  @

-- keep in mind that in these tables, Y+ faces UP so that the tables correspond with the tetris wiki

kicktables["SRS"] = {
	[1] = { -- used on J, L, S, T, Z tetraminos
		["01"] = {{ 0, 0}, {-1, 0}, {-1, 1}, { 0,-2}, {-1,-2}},
		["10"] = {{ 0, 0}, { 1, 0}, { 1,-1}, { 0, 2}, { 1, 2}},
		["12"] = {{ 0, 0}, { 1, 0}, { 1,-1}, { 0, 2}, { 1, 2}},
		["21"] = {{ 0, 0}, {-1, 0}, {-1, 1}, { 0,-2}, {-1,-2}},
		["23"] = {{ 0, 0}, { 1, 0}, { 1, 1}, { 0,-2}, { 1,-2}},
		["32"] = {{ 0, 0}, {-1, 0}, {-1,-1}, { 0, 2}, {-1, 2}},
		["30"] = {{ 0, 0}, {-1, 0}, {-1,-1}, { 0, 2}, {-1, 2}},
		["03"] = {{ 0, 0}, { 1, 0}, { 1, 1}, { 0,-2}, { 1,-2}},
		["02"] = {{ 0, 0}, { 0, 1}, { 1, 1}, {-1, 1}, { 1, 0}, {-1, 0}},
		["13"] = {{ 0, 0}, { 1, 0}, { 1, 2}, { 1, 1}, { 0, 2}, { 0, 1}},
		["20"] = {{ 0, 0}, { 0,-1}, {-1,-1}, { 1,-1}, {-1, 0}, { 1, 0}},
		["31"] = {{ 0, 0}, {-1, 0}, {-1, 2}, {-1, 1}, { 0, 2}, { 0, 1}},
	},
	
	[2] = {	-- used on I tetraminos
		["01"] = {{ 0, 0}, {-2, 0}, { 1, 0}, {-2,-1}, { 1, 2}},
		["10"] = {{ 0, 0}, { 2, 0}, {-1, 0}, { 2, 1}, {-1,-2}},
		["12"] = {{ 0, 0}, {-1, 0}, { 2, 0}, {-1, 2}, { 2,-1}},
		["21"] = {{ 0, 0}, { 1, 0}, {-2, 0}, { 1,-2}, {-2, 1}},
		["23"] = {{ 0, 0}, { 2, 0}, {-1, 0}, { 2, 1}, {-1,-2}},
		["32"] = {{ 0, 0}, {-2, 0}, { 1, 0}, {-2,-1}, { 1, 2}},
		["30"] = {{ 0, 0}, { 1, 0}, {-2, 0}, { 1,-2}, {-2, 1}},
		["03"] = {{ 0, 0}, {-1, 0}, { 2, 0}, {-1, 2}, { 2,-1}},
		["02"] = {{ 0, 0}, { 0, 1}},
		["13"] = {{ 0, 0}, { 1, 0}},
		["20"] = {{ 0, 0}, { 0,-1}},
		["31"] = {{ 0, 0}, {-1, 0}}
	},
}

return kicktables
