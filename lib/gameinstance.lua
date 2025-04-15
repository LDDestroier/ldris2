-- game instance object
-- returns a function that resumes the game state for 1 tick and returns event info

local Mino = require "lib.mino"
local Board = require "lib.board"
local gameConfig = require "lib.gameconfig"
local GameDebug = require "lib.gamedebug"
local cospc_debuglog = GameDebug.cospc_debuglog
local GameInstance = {}

local scr_x, scr_y = term.getSize()

function GameInstance:New(control, board_xmod, board_ymod, clientConfig)
	local game = setmetatable({}, self)
	self.__index = self

	game.board_xmod = board_xmod or 0
	game.board_ymod = board_ymod or 0
	game.clientConfig = clientConfig
	game.control = control
	game.didControlTick = false
	game.message = {}

	return game
end

function GameInstance:Initiate()
	self.state = {
		gravity = gameConfig.startingGravity,
		targetPlayer = 0,
		score = 0,
		topOut = false,
		canHold = true,
		didHold = false,
		didJustClearLine = false,
		heldPiece = false,
		paused = false,
		queue = {},
		queueMinos = {},
		linesCleared = 0,
		random_bag = {},
		gameTickCount = 0,
		controlTickCount = 0,
		animFrame = 0,
		controlsDown = {},
		incomingGarbage = 0, -- amount of garbage that will be added to board after non-line-clearing mino placement
		combo = 0,           -- amount of successive line clears
		backToBack = 0,      -- amount of tetris/t-spins comboed
		spinLevel = 0        -- 0 = no special spin
	}                        -- 1 = mini spin
							 -- 2 = Z/S/J/L spin
							 -- 3 = T spin

	-- create boards
	-- main gameplay board
	self.state.board = Board:New(
		7 + self.board_xmod,
		1 + self.board_ymod,
		gameConfig.board_width,
		gameConfig.board_height
	)

	-- queue of upcoming minos
	self.state.queueBoard = Board:New(
		self.state.board.x + self.state.board.width + 1,
		self.state.board.y,
		4,
		28
	)

	-- display of currently held mino
	self.state.holdBoard = Board:New(
		2 + self.board_xmod,
		1 + self.board_ymod,
		self.state.queueBoard.width,
		4
	)
	self.state.holdBoard.visibleHeight = 4


	-- indicator of incoming garbage
	self.state.garbageBoard = Board:New(
		self.state.board.x - 1,
		self.state.board.y,
		1,
		self.state.board.visibleHeight,
		"f"
	)
	self.state.garbageBoard.visibleHeight = self.state.garbageBoard.height

	self.width = gameConfig.board_width + 10
	self.height = math.ceil(self.state.board.visibleHeight * 0.666)

	-- populate the queue
	for i = 1, self.clientConfig.queue_length + 1 do
		self.state.queue[i] = self:PseudoRandom(state)
	end

	for i = 1, self.clientConfig.queue_length do
		self.state.queueMinos[i] = Mino:New(
			nil,
			self.state.queue[i + 1],
			self.state.queueBoard,
			1,
			i * 3 + 12
		)
	end

	self.queue_anim = 0

	self.state.mino = self:MakeDefaultMino()
	self.state.ghostMino = Mino:New(nil, self.state.mino.minoID, self.state.board, self.state.mino.x, self.state.mino.y,
	{})
	self.state.ghostMino.doWriteColor = true

	local garbageMinoShape = {}
	for i = 1, self.state.board.height * 4 do
		if i > 32 then
			garbageMinoShape[i] = "6" -- you're super fucked
		elseif i > 24 then
			garbageMinoShape[i] = "b" -- you're fucked
		elseif i > 16 then
			garbageMinoShape[i] = "1"
		elseif i > 8 then
			garbageMinoShape[i] = "4"
		else
			garbageMinoShape[i] = "e"
		end
	end

	self.state.garbageMino = Mino:New({
		[1] = {
			shape = garbageMinoShape,
			color = "e"
		}
	}, 1, self.state.garbageBoard, 1, self.state.garbageBoard.height + 1)

	self.control.keysDown = {}

	return self
end

function GameInstance:Move(x, y)
	local board = self.state.board
	local queueBoard = self.state.queueBoard
	local holdBoard = self.state.holdBoard
	local garbageBoard = self.state.garbageBoard

	self.board_xmod = math.floor(x or self.board_xmod)
	self.board_ymod = math.floor(y or self.board_ymod)

	board.x = 7 + self.board_xmod
	board.y = 1 + self.board_ymod

	queueBoard.x = board.x + board.width + 1
	queueBoard.y = board.y

	holdBoard.x = 2 + self.board_xmod
	holdBoard.y = 1 + self.board_ymod

	garbageBoard.x = board.x - 1
	garbageBoard.y = board.y
end

function GameInstance:MakeSound(name)
	self.message.sound = name
end

function GameInstance:CyclePiece()
	local nextPiece = self.state.queue[1]
	table.remove(self.state.queue, 1)
	self.state.queue[#self.state.queue + 1] = self:PseudoRandom(state)
	return nextPiece
end

function GameInstance:PseudoRandom()
	if gameConfig.randomBag == "random" then
		return math.random(1, #gameConfig.minos)

	elseif gameConfig.randomBag == "singlebag" then
		if #self.state.random_bag == 0 then
			-- repopulate random bag
			for i = 1, #gameConfig.minos do
				if math.random(0, 1) == 0 then
					self.state.random_bag[#self.state.random_bag + 1] = i
				else
					table.insert(self.state.random_bag, 1, i)
				end
			end
		end
		local pick = math.random(1, #self.state.random_bag)
		local output = self.state.random_bag[pick]
		table.remove(self.state.random_bag, pick)
		return output

	elseif gameConfig.randomBag == "doublebag" then
		if #self.state.random_bag == 0 then
			for r = 1, 2 do
				-- repopulate random bag
				for i = 1, #gameConfig.minos do
					if math.random(0, 1) == 0 then
						self.state.random_bag[#self.state.random_bag + 1] = i
					else
						table.insert(self.state.random_bag, 1, i)
					end
				end
			end
		end
		local pick = math.random(1, #self.state.random_bag)
		local output = self.state.random_bag[pick]
		table.remove(self.state.random_bag, pick)
		return output
	end
end

function GameInstance:MakeDefaultMino()
	local nextPiece
	if self.state.didHold then
		if self.state.heldPiece then
			nextPiece, self.state.heldPiece = self.state.heldPiece, self.state.mino.minoID
		else
			nextPiece, self.state.heldPiece = self:CyclePiece(), self.state.mino.minoID
		end
	else
		nextPiece = self:CyclePiece()
	end

	return Mino:New(nil,
		nextPiece,
		self.state.board,
		math.floor(self.state.board.width / 2 - 1) + (gameConfig.minos[nextPiece].spawnOffsetX or 0),
		math.floor(gameConfig.board_height_visible + 1) + (gameConfig.minos[nextPiece].spawnOffsetY or 0),
		self.state.mino
	)
end

function GameInstance:CalculateGarbage(linesCleared)
	local output = 0
	local lncleartbl = {
		[0] = 0,
		[1] = 0,
		[2] = 1,
		[3] = 2,
		[4] = 4,
		[5] = 5,
		[6] = 6,
		[7] = 7,
		[8] = 8
	}

	if (self.state.spinLevel == 3) or (self.state.spinLevel == 2 and gameConfig.spin_mode >= 2) then
		output = output + linesCleared * 2
	else
		output = output + (lncleartbl[linesCleared] or 0)
	end

	-- add combo bonus
	output = output + math.max(0, math.floor((self.state.combo - 1) / 2))

	
	if self.didJustClearLine then
		-- add back-to-back bonus
		if self.state.backToBack >= 2 then
			output = output + 1
		end

		-- add perfect clear bonus
		if self.state.board:CheckPerfectClear() then
			output = output + 10
		end
	end

	return output
end

function GameInstance:HandleLineClears()
	local mino, board = self.state.mino, self.state.board

	-- get list of full lines
	local clearedLines = { lookup = {} }
	for y = 1, board.height do
		if not board.contents[y]:find(board.blankColor) then
			clearedLines[#clearedLines + 1] = y
			clearedLines.lookup[y] = true
		end
	end

	-- clear the lines, baby
	if #clearedLines > 0 then
		local newContents = {}
		local i = board.height
		for y = board.height, 1, -1 do
			if not clearedLines.lookup[y] then
				newContents[i] = board.contents[y]
				i = i - 1
			end
		end
		for y = 1, #clearedLines do
			newContents[y] = string.rep(board.blankColor, board.width)
		end
		self.state.board.contents = newContents
	end

	self.state.linesCleared = self.state.linesCleared + #clearedLines

	return clearedLines
end

function GameInstance:SendGarbage(amount)
	if amount ~= 0 then
		self.message.attack = (self.message.attack or 0) + amount
	end
end

function GameInstance:ReceiveGarbage(amount)
	if amount ~= 0 then
		self.state.incomingGarbage = math.floor(self.state.incomingGarbage + amount)
	end
end

function GameInstance:Render(doDrawOtherBoards)
	self.state.board:Render(self.state.ghostMino, self.state.mino)
	if doDrawOtherBoards then
		self.state.holdBoard:Render()
		self.state.queueBoard:Render(table.unpack(self.state.queueMinos))
		self.state.garbageBoard:Render(self.state.garbageMino)
	end
end

function GameInstance:AnimateQueue()
	table.remove(self.state.queueMinos, 1)
	self.state.queueMinos[#self.state.queueMinos + 1] = Mino:New(
		nil,
		self.state.queue[self.clientConfig.queue_length],
		self.state.queueBoard,
		1,
		(self.clientConfig.queue_length + 1) * 3 + 12
	)
	self.queue_anim = 3
end

function GameInstance:Tick()
	local mino, ghostMino, garbageMino = self.state.mino, self.state.ghostMino, self.state.garbageMino
	--	local holdBoard, queueBoard, garbageBoard = self.state.holdBoard, self.state.queueBoard, self.state.garbageBoard

	self.didJustClearLine = false

	local didCollide, didMoveX, didMoveY, yHighestDidChange = mino:Move(0, self.state.gravity, true)
	local doCheckStuff = false
	local doAnimateQueue = false
	local doMakeNewMino = false

	self.queue_anim = math.max(0, self.queue_anim - 0.8)
	self.state.gravity = gameConfig.startingGravity + (math.floor(self.state.linesCleared / 10) * 0.1)

	-- position queue minos properly
	for i = 1, #self.state.queueMinos do
		self.state.queueMinos[i].y = (i * 3 + 12) + math.min(3, math.floor(self.queue_anim))
	end

	if not mino.finished then
		mino.resting = (not didMoveY) and mino:CheckCollision(0, 1)

		if yHighestDidChange then
			mino.movesLeft = gameConfig.lock_move_limit
		end

		if mino.resting then
			mino.lockTimer = mino.lockTimer - gameConfig.tickDelay
			if mino.lockTimer <= 0 then
				mino.finished = 1
			end
		else
			mino.lockTimer = gameConfig.lock_delay
		end
	end

	mino.spawnTimer = math.max(0, mino.spawnTimer - gameConfig.tickDelay)
	if mino.spawnTimer == 0 then
		if (not mino.active) then
			self:MakeSound(gameConfig.minos[mino.minoID].sound)
			self:AnimateQueue()
		end
		mino.active = true
		mino.visible = true
		ghostMino.active = true
		ghostMino.visible = true
	end

	if mino.finished then
		if mino.finished == 1 then -- piece will lock
			self.state.didHold = false
			self.state.canHold = true
			-- check for top-out due to placing a piece outside the visible area of its board
			if false then -- I'm doing that later
				
			else
				doAnimateQueue = true
				mino:Write()
				doMakeNewMino = true
				doCheckStuff = true
			end

		elseif mino.finished == 2 then -- piece will attempt hold
			if self.state.canHold then
				self.state.didHold = true
				self.state.canHold = false

				if self.state.heldPiece then
					doAnimateQueue = false
				else
					doAnimateQueue = true
				end

				-- draw held piece
				self.state.holdBoard:Clear()
				Mino:New(
					nil,
					mino.minoID,
					self.state.holdBoard,
					1 + (gameConfig.minos[mino.minoID].spawnOffsetX or 0),
					2,
					{}
				):Write()

				doMakeNewMino = true
				doCheckStuff = true
			else
				mino.finished = false
			end
		else
			error("somehow mino.finished is " .. tostring(mino.finished))
		end

		local linesCleared = self:HandleLineClears()
		local _delay = (#linesCleared > 0 and self.clientConfig.line_clear_delay or self.clientConfig.appearance_delay)

		if doMakeNewMino then
			self.state.mino = self:MakeDefaultMino(); mino = self.state.mino
			self.state.ghostMino = Mino:New(nil, mino.minoID, self.state.board, mino.x, mino.y, {}); ghostMino = self.state.ghostMino
			self.state.ghostMino.doWriteColor = true

			if (not self.state.didHold) and (_delay > 0) then
				mino.spawnTimer = _delay
				mino.active = false
				mino.visible = false
				ghostMino.active = false
				ghostMino.visible = false

			else
				self:MakeSound(gameConfig.minos[mino.minoID].sound)
				if doAnimateQueue then
					self:AnimateQueue()
				end
			end
		end

		if doMakeNewMino then
			-- check for top-out due to obstructed mino upon entry
			-- attempt to move mino at most 2 spaces upwards before considering it fully topped out
			self.state.topOut = true
			for i = 0, 2 do
				if mino:CheckCollision(0, 1) then
					mino.y = mino.y - 1
				else
					self.state.topOut = false
					break
				end
			end

			-- TODO: this is where I'd put initial rotation
		end

		-- calls the frame when a new mino is generated
		-- if the hold attempt fails (say, you already held a piece), it wouldn't do to check for a top-out or line clears
		if doCheckStuff then

			if not self.state.didHold then
				if #linesCleared == 0 then
					self.state.combo = 0
				else
					self:MakeSound("lineclear")
					self.didJustClearLine = true
					self.state.combo = self.state.combo + 1
					if #linesCleared >= 4 or self.state.spinLevel >= 1 then
						self.state.backToBack = self.state.backToBack + 1
					else
						self.state.backToBack = 0
					end
				end

				-- calculate garbage to be sent
				local garbage = self:CalculateGarbage(#linesCleared)
				garbage, self.state.incomingGarbage = math.max(0, garbage - self.state.incomingGarbage),
				math.max(0, self.state.incomingGarbage - garbage)

				if garbage > 0 then
					cospc_debuglog(nil, "Doled out " .. garbage .. " lines")
				end

				-- send garbage to enemy player
				self:SendGarbage(garbage)

				-- generate garbage lines
				local taken_garbage = math.min(self.state.incomingGarbage, gameConfig.garbage_cap)
				self.state.board:AddGarbage(taken_garbage)
				self.state.incomingGarbage = self.state.incomingGarbage - taken_garbage
			end

			if doMakeNewMino then
				self.state.spinLevel = 0
			end
		end

	end

end

function GameInstance:CheckSpecialSpin(mino, kick_count)
	-- intended for T-tetraminos
	-- if spinID == 1 and not all 3 corners are occupied on the board, no speical spin (return 0)
	-- if spinID == 1 and only one of the "top" corners are occupied on the board, it is a T-spin mini (return 1)
	-- (exception: if kick_count == 6, which is the TST kick, return 3)
	-- if spinID == 2 (for z/s spins) or 3 (for I spins), run separate logic (return 2)
	-- if spinID == 1 and both "top" corners are occupied, it's a full T-spin (return 3)
	
	if mino.spinID == 1 then
		-- sheesh
		local corners = {
			mino.board:IsSolid(mino.x, mino.y),
			mino.board:IsSolid(mino.x + mino.width - 1, mino.y),
			mino.board:IsSolid(mino.x + mino.width - 1, mino.y + mino.height - 1),
			mino.board:IsSolid(mino.x, mino.y + mino.height),
		}
		local solid_count = 0
		for i = 1, #corners do
			if corners[i] then
				solid_count = solid_count + 1
			end
		end

		if solid_count >= 3 then
			if (corners[mino.rotation + 1] and corners[((mino.rotation + 1) % 4) + 1]) or kick_count == 6 then
				return 3
			else
				return 1
			end
		end

	elseif mino.spinID == 2 or mino.spinID == 3 then
		if (
			mino:CheckCollision(1, 0) and
			mino:CheckCollision(-1, 0) and
			mino:CheckCollision(0, -1)
		) then return 2 else return 0 end
	end
	
	return 0
	
end

-- keep this in gameinstance.lua
-- fast actions are ones that should be possible to do multiple times per game tick, such as rotation or movement
-- i should make a separate function for instant controls and held controls...
function GameInstance:ControlTick(onlyFastActions)
	local dc, dmx, dmy -- did collide, did move X, did move Y
	local didSlowAction = false
	local _, kick_count

	local control = self.control
	local mino = self.state.mino
	local board = self.state.board

	if control:CheckControl("pause", false) then
		self.state.paused = not self.state.paused
		control.antiControlRepeat["pause"] = true
	end

	if self.state.paused or not mino.active then
		return false
	end

	if not onlyFastActions then
		if control:CheckControl("move_left", self.clientConfig.move_repeat_delay, self.clientConfig.move_repeat_interval) then
			if not mino.finished then
				mino:Move(-1, 0, true, true)
				didSlowAction = true
				control.antiControlRepeat["move_left"] = true
			end
		end
		if control:CheckControl("move_right", self.clientConfig.move_repeat_delay, self.clientConfig.move_repeat_interval) then
			if not mino.finished then
				mino:Move(1, 0, true, true)
				didSlowAction = true
				control.antiControlRepeat["move_right"] = true
			end
		end
		if control:CheckControl("soft_drop", 0) then
			mino:Move(0, self.state.gravity * self.clientConfig.soft_drop_multiplier, true, false)
			didSlowAction = true
			control.antiControlRepeat["soft_drop"] = true
		end
		if control:CheckControl("hard_drop", false) then
			mino:Move(0, board.height, true, false)
			mino.finished = 1
			self:MakeSound("drop")
			didSlowAction = true
			control.antiControlRepeat["hard_drop"] = true
		end
		if control:CheckControl("sonic_drop", false) then
			if mino:Move(0, board.height, true, true) then
				self:MakeSound("drop")
			end
			didSlowAction = true
			control.antiControlRepeat["sonic_drop"] = true
		end
		if control:CheckControl("hold", false) then
			if not mino.finished then
				mino.finished = 2
				control.antiControlRepeat["hold"] = true
				didSlowAction = true
			end
		end
		if control:CheckControl("quit", false) then
			self.state.topOut = true
			control.antiControlRepeat["quit"] = true
			didSlowAction = true
		end
	end

	if control:CheckControl("rotate_ccw", false) and gameConfig.can_rotate then
		_, _, kick_count = mino:Rotate(-1, true)
		if mino.spinID <= gameConfig.spin_mode then
			self.state.spinLevel = self:CheckSpecialSpin(mino, kick_count)
			--[[
			if (
				mino:CheckCollision(1, 0) and
				mino:CheckCollision(-1, 0) and
				mino:CheckCollision(0, -1)
			) then
				self.state.spinLevel = 3
			else
				self.state.spinLevel = 0
			end
			--]]
		end
		control.antiControlRepeat["rotate_ccw"] = true
	end
	if control:CheckControl("rotate_cw", false) and gameConfig.can_rotate then
		_, _, kick_count = mino:Rotate(1, true)
		if mino.spinID <= gameConfig.spin_mode then
			self.state.spinLevel = self:CheckSpecialSpin(mino, kick_count)
			--[[
			if (
				mino:CheckCollision(1, 0) and
				mino:CheckCollision(-1, 0) and
				mino:CheckCollision(0, -1)
			) then
				self.state.spinLevel = 3
			else
				self.state.spinLevel = 0
			end
			--]]
		end
		control.antiControlRepeat["rotate_cw"] = true
	end
	if control:CheckControl("rotate_180", false) and gameConfig.can_rotate and gameConfig.can_180_spin then
		_, _, kick_count = mino:Rotate(2, true)
		if mino.spinID <= gameConfig.spin_mode then
			self.state.spinLevel = self:CheckSpecialSpin(mino, kick_count)
		end
	end

	return didSlowAction
end

function GameInstance:Resume(evt, doTick)
	local mino, ghostMino, garbageMino = self.state.mino, self.state.ghostMino, self.state.garbageMino
	self.message = {} -- sends back to main
	local doRender = false

	if evt[1] == "key" and not evt[3] then
		self.control.keysDown[evt[2]] = 1
		self.didControlTick = self:ControlTick(false)
		self.state.controlTickCount = self.state.controlTickCount + 1
		doRender = true

	elseif evt[1] == "key_up" then
		self.control.keysDown[evt[2]] = nil
	end

	if evt[1] == "timer" then
		if doTick then
			--			tickTimer = os.startTimer(0.05)
			for k, v in pairs(self.control.keysDown) do
				self.control.keysDown[k] = 1 + v
			end
			self:ControlTick(self.didControlTick)
			self.state.controlTickCount = self.state.controlTickCount + 1
			if not self.state.paused then
				self:Tick(message)
				self.state.gameTickCount = self.state.gameTickCount + 1
			end
			self.didControlTick = false
			self.control.antiControlRepeat = {}

			doRender = true
		end
	end

	if self.state.topOut then
		-- this will have a more elaborate game over sequence later
		self.message.finished = true
	end

	if doRender then
		-- handle ghost piece
		ghostMino.color = "c"
		ghostMino.shape = mino.shape
		ghostMino.x = mino.x
		ghostMino.y = mino.y
		ghostMino:Move(0, self.state.board.height, true)

		garbageMino.y = 1 + self.state.garbageBoard.height - self.state.incomingGarbage

		--self:Render(true)
		GameDebug.profile("Render", scr_y-3, function() self:Render(true) end)
	end

	return self.message
end

return GameInstance
