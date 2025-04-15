return {
	minos = {},					-- list of all the minos (pieces) that will spawn into the board (populated from /lib/minodata.lua)
	kickTables = {},			-- list of all kick tables for pieces (populated from /lib/kicktables.lua)
	lock_delay = 0.5,			-- (Lock Delay) amount of seconds it will take for a resting mino to lock into placed
	currentKickTable = "SRS",	-- current kick table
	randomBag = "singlebag",	-- current pseudorandom number generator
								-- "singlebag" = normal tetris guideline random
								-- "doublebag" = doubled bag size
								-- "random" = using math.random
	board_width = 10,			-- width of play area
	board_height = 40,			-- height of play area
	board_height_visible = 20,	-- height of play area that will render on screen (anchored to bottom)
	spin_mode = 1,				-- 1 = allows T-spins
								-- 2 = allows J/L-spins
								-- 3 = allows ALL SPINS! Similar to STUPID mode in tetr.io
	can_180_spin = true,		-- if false, 180 spins are disallowed
	can_rotate = true,			-- if false, will disallow ALL piece rotation (meme mode)
	startingGravity = 0.15,		-- gravity per tick for minos
	lock_move_limit = 30,		-- amount of moves a mino can do after descending below its lowest point yet traversed
								-- used as a method of preventing stalling -- set it to math.huge for infinite
	tickDelay = 0.05,			-- time between game ticks
	garbage_cap = 4,			-- highest amount of garbage that will push to the board at once
	enable_sound = true,		-- enables use of speaker peripheral for game sounds
	enable_noteblocksound = false,	-- if true, opts for noteblock sounds intead of the included .ogg files
	minos = require "lib.minodata"
}
