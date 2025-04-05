return {
	controls = {
		rotate_ccw = keys.z,
		rotate_cw = keys.x,
		move_left = keys.left,
		move_right = keys.right,
		soft_drop = keys.down,
		hard_drop = keys.up,
		sonic_drop = keys.space,	-- drop mino to bottom, but don't lock
		hold = keys.leftShift,
		pause = keys.p,
		restart = keys.r,
		open_chat = keys.t,
		quit = keys.q,
	},
	-- (SDF) the factor in which soft dropping effects the gravity
	soft_drop_multiplier = 4.0,
	
	-- (DAS) amount of time you must be holding the movement keys for it to start repeatedly moving (seconds)
	move_repeat_delay = 0.25,
	
	-- (ARR) speed at which the pieces move when holding the movement keys (seconds per tick)
	move_repeat_interval = 0.05,
	
	-- (ARE) amount of seconds it will take for the next piece to arrive after the current one locks into place
	-- settings this to something above 0 will let you preload a rotation (IRS) or hold (IHS) (unimplemented)
	appearance_delay = 0,
	
	-- alternate appearance delay for when a line is cleared
	line_clear_delay = 0.3,
	
	-- amount of pieces visible in the queue (limited by size of UI)
	queue_length = 5,
}