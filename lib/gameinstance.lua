-- game instance object
-- returns a function that resumes the game state for 1 tick and returns event info

local Mino = require "lib.mino"
local Board = require "lib.board"
local gameConfig = require "config.gameconfig"

local modem = peripheral.find("modem")
if (not modem) and (ccemux) then
	ccemux.attach("top", "wireless_modem")
	modem = peripheral.wrap("top")
end
if modem then
	modem.open(100)
end

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
	game.uid = ""

	for i = 1, 8 do
		game.uid = game.uid .. string.char(math.random(1, 255))
	end

	return game
end

local nm_actionlookup = {
	mino_setpos = 1,
	mino_lock = 2,
	board_update = 3,
	send_garbage = 4,
	mino_hold = 5,
}

function GameInstance:AttachDebug(gamedebug)
	self.DEBUG = gamedebug
end

function GameInstance:SerializeNetworkMoment(action, param1, param2, param3, param4)
	local output = self.uid .. (nm_actionlookup[action] or " ")
	if action == "mino_setpos" or action == "mino_lock" then
		-- param1, param 2 = mino x, y
		-- param3 = mino type
		-- param4 = mino rotation
		output = table.concat({
			output,
			string.char((param1 + 127) % 256),
			string.char((param2 + 127) % 256),
			string.char(param3),
			string.char(param4)
		})

	elseif action == "board_update" then
		output = table.concat({
			output,
			self.state.board:SerializeContents()
		})
	
	elseif action == "send_garbage" then
		output = output .. string.char(param1)
	
	elseif action == "mino_hold" then
		output = output .. string.char(param1)

	elseif action == "update" then
		output = table.concat({
			output,
			string.char(param1), -- incomingGarbage
			string.char(param2), -- lines just cleared
			string.char(param3 or 0), -- ???
			string.char(param4 or 0)  -- ???
		})
	
	end

	return "ldris2" .. output
end

function GameInstance:ParseNetworkMoment(input)
	local moment = {}
	-- incredibly basic input validation
	-- this WILL be replaced later with something that won't explode if you feed a wrong value
	if input:sub(1, 6) == "ldris2" then
		input = input:sub(7)
	else
		return
	end

	moment.uid = input:sub(1, 8)
	input = input:sub(9)
	local moment_type = input:sub(1, 1)

	if moment_type == "1" then -- mino_setpos
		moment.action = "mino_setpos"
		moment.x = string.byte(input:sub(2, 2)) - 127
		moment.y = string.byte(input:sub(3, 3)) - 127
		moment.minoID = string.byte(input:sub(4, 4))
		moment.rotation = string.byte(input:sub(5, 5))
	
	elseif moment_type == "2" then -- mino_lock
		moment.action = "mino_lock"
		moment.x = string.byte(input:sub(2, 2)) - 127
		moment.y = string.byte(input:sub(3, 3)) - 127
		moment.minoID = string.byte(input:sub(4, 4))
		moment.rotation = string.byte(input:sub(5, 5))

	elseif moment_type == "3" then -- board_update
		moment.action = "board_update"
		moment.contents = {}
		for i = 1, #input - 1, self.state.board.width do
			moment.contents[#moment.contents + 1] = input:sub(i + 1, i + 11)
		end

	elseif moment_type == "4" then -- send_garbage
		moment.action = "send_garbage"
		moment.garbage = string.byte(input:sub(2, 2))

	elseif moment_type == "5" then
		moment.action = "mino_hold"
		moment.minoID = string.byte(input:sub(2, 2))
		
	elseif moment_type == "6" then
		moment.action = "update"
		moment.incomingGarbage = string.byte(input:sub(2, 2))
		moment.linesJustCleared = string.byte(input:sub(3, 3))
		-- third field?
		-- fourth field?
	else
		return
	end

	return moment
end


-- creates a lookup table of the rotated states of every mino
function GameInstance:MakeRotatedMinoLookup(mino_table)
	local output = {}
	local mino
	for i, mData in ipairs(mino_table) do
		output[i] = {
			table.copy( mino_table[i].shape ),
			table.copy( Mino:New(mino_table, i):Rotate(1).shape ),
			table.copy( Mino:New(mino_table, i):Rotate(2).shape ),
			table.copy( Mino:New(mino_table, i):Rotate(-1).shape )
		}
	end
	return output
end

function GameInstance:GetSize()
	return 
		gameConfig.board_width + (self.do_compact_view and 5 or 10),
		math.ceil(self.state.board.visibleHeight * 0.666)
end

function GameInstance:Initiate(mino_table, randomseed)
	self.networked = false
	self.do_compact_view = false -- should set true, if you're doing multiplayer on a pocket computer
								-- do_compact_view moves the queue and hold boards to be above each other
	self.canPause = true
	self.do_render_tiny = false -- should set true, if you're a puppeted networked client
	self.visible = true
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
		linesJustCleared = 0,
		minosMade = 0,
		random_bag = {},
		gameTickCount = 0,
		controlTickCount = 0,
		animFrame = 0,
		controlsDown = {},
		incomingGarbage = 0, -- amount of garbage that will be added to board after non-line-clearing mino placement
		combo = 0,           -- amount of successive line clears
		backToBack = 0,      -- amount of tetris/t-spins comboed
		spinLevel = 0        -- 0 = no special spin
	}                        -- 1 = T spin mini
							 -- 2 = Z/S/J/L spin
							 -- 3 = T spin

	self.randomseed = randomseed or self.randomseed

	if (mino_table or not self.mino_rotable) then
		self.mino_rotable = self:MakeRotatedMinoLookup(mino_table or gameConfig.minos)
	end
	self.mino_table = mino_table

	-- create boards
	-- main gameplay board
	self.state.board = Board:New(
		7 + self.board_xmod,
		1 + self.board_ymod,
		gameConfig.board_width,
		gameConfig.board_height
	)
	self.state.board.overtopHeight = 3
	self.state.board.visibleHeight = 20

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

	self.width, self.height = self:GetSize()

	-- populate the queue
	for i = 1, self.clientConfig.queue_length + 1 do
		self.state.minosMade = self.state.minosMade + 1
		self.state.queue[i] = self:PseudoRandom(state)
	end

	for i = 1, self.clientConfig.queue_length do
		self.state.queueMinos[i] = Mino:New(
			self.mino_table,
			self.state.queue[i + 1],
			self.state.queueBoard,
			1,
			i * 3 + 12
		)
	end

	self.queue_anim = 0

	self.state.mino = self:MakeDefaultMino()
	self.state.ghostMino = Mino:New(self.mino_table, self.state.mino.minoID, self.state.board, self.state.mino.x, self.state.mino.y,
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
	
	if self.networked then
		self.canPause = false
	end

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

	if self.do_compact_view then
		board.x = 5 + self.board_xmod
		board.y = 1 + self.board_ymod
		
		holdBoard.x = board.width + holdBoard.width + board.x - 3
		holdBoard.y = board.y + 5
		
		queueBoard.x = board.width + holdBoard.width + board.x - 3
		queueBoard.y = board.y
	else
		board.x = 7 + self.board_xmod
		board.y = 1 + self.board_ymod
		
		holdBoard.x = 2 + self.board_xmod
		holdBoard.y = 1 + self.board_ymod
		
		queueBoard.x = board.width + holdBoard.width + board.x - 3
		queueBoard.y = board.y
	end

	garbageBoard.x = board.x - 1
	garbageBoard.y = board.y
	
	self.width, self.height = self:GetSize()
	if self.do_render_tiny then
		self:RenderTiny(true, {ignore_dirty = true})
	else
		self:Render(true, {ignore_dirty = true})
	end
end

function GameInstance:MakeSound(name)
	self.message.sound = name
end

function GameInstance:CyclePiece()
	local nextPiece = self.state.queue[1]
	table.remove(self.state.queue, 1)
	self.state.minosMade = self.state.minosMade + 1
	self.state.queue[#self.state.queue + 1] = self:PseudoRandom(state)
	return nextPiece
end

function GameInstance:PseudoRandom()

	math.randomseed(self.state.minosMade, self.randomseed)

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

	return Mino:New(
		self.mino_table,
		nextPiece,
		self.state.board,
		math.floor(self.state.board.width / 2 - 1) + (gameConfig.minos[nextPiece].spawnOffsetX or 0),
		math.floor(gameConfig.board_height_visible - 1) + (gameConfig.minos[nextPiece].spawnOffsetY or 0),
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

	if (self.state.spinLevel == 3) or (
		self.state.spinLevel == 2 and
		gameConfig.spin_mode >= 2 and
		(not gameConfig.are_non_T_spins_mini)
	) then
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
		if not board.contents[y]:find(" ") then
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
			newContents[y] = string.rep(" ", board.width)
		end
		self.state.board.contents = newContents
	end
	
	self.state.linesCleared = self.state.linesCleared + #clearedLines
	self.state.linesJustCleared = #clearedLines

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

function GameInstance:Render(doDrawOtherBoards, tOpts)
	if self.visible then
		if self.clientConfig.do_ghost_piece then
			self.state.board:Render(tOpts, self.state.ghostMino, self.state.mino)
		else
			self.state.board:Render(tOpts, self.state.mino)
		end
		if doDrawOtherBoards then
			self.state.holdBoard:Render(tOpts)
			self.state.queueBoard:Render(tOpts, table.unpack(self.state.queueMinos))
			self.state.garbageBoard:Render(tOpts, self.state.garbageMino)
		end
	end
end

-- intended for previews of an enemy's board over a networked game
function GameInstance:RenderTiny(doDrawOtherBoards)
	if self.visible then
		if self.networked or (not self.clientConfig.do_ghost_piece) then
			self.state.board:RenderTiny(nil, self.state.mino)
		else
			self.state.board:RenderTiny(nil, self.state.ghostMino, self.state.mino)
		end
		if doDrawOtherBoards then
			self.state.holdBoard:RenderTiny({2, 0})
			self.state.garbageBoard:RenderTiny(nil, self.state.garbageMino)
			if not self.networked then
				self.state.queueBoard:RenderTiny({-5, 0}, table.unpack(self.state.queueMinos))
			end
		end
	end
end

function GameInstance:AnimateQueue()
	table.remove(self.state.queueMinos, 1)
	self.state.queueMinos[#self.state.queueMinos + 1] = Mino:New(
		self.mino_table,
		self.state.queue[self.clientConfig.queue_length],
		self.state.queueBoard,
		1,
		(self.clientConfig.queue_length + 1) * 3 + 12
	)
	self.queue_anim = 3
end

function GameInstance:Tick()
	local mino, ghostMino, garbageMino = self.state.mino, self.state.ghostMino, self.state.garbageMino
	local mino_name = mino.name
	
	self.didJustClearLine = false

	local didCollide, didMoveX, didMoveY, yHighestDidChange = mino:Move(0, self.state.gravity, true)
	local doCheckStuff = false
	local doAnimateQueue = false
	local doMakeNewMino = false
	self.state.didHold = false

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
					self.mino_table,
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
			self.state.ghostMino = Mino:New(self.mino_table, mino.minoID, self.state.board, mino.x, mino.y, {}); ghostMino = self.state.ghostMino
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

			if mino:CheckCollision(0, 0) then
				self.state.topOut = true
			end

		end

		-- check for top-out due to obstructed mino upon entry
		-- attempt to move mino at most 2 spaces upwards before considering it fully topped out
		-- NOTE: unsure why, but this fucks up for some reason
		--[[
		if doCheckStuff then
			self.state.topOut = true
			for i = 0, 2 do
				if not mino:CheckCollision(0, -i) then
					mino.y = mino.y - i
					self.state.topOut = false
					break
				end
			end
		end
		--]]

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
						if (
							self.state.spinLevel >= 3 or
							(self.state.spinLevel == 2 and gameConfig.spin_mode >= 2) or
							(self.state.spinLevel == 1 and gameConfig.spin_mode >= 3)
						) then
							self.state.backToBack = self.state.backToBack + 1
						end
						
					else
						self.state.backToBack = 0
					end
				end

				-- calculate garbage to be sent
				local garbage = self:CalculateGarbage(#linesCleared)
				garbage, self.state.incomingGarbage = math.max(0, garbage - self.state.incomingGarbage),
				math.max(0, self.state.incomingGarbage - garbage)

				if garbage > 0 then
					self.DEBUG:Log("Doled out " .. garbage .. " lines")
				end
				
				if self.state.spinLevel == 1 then
					self.DEBUG:Log("T-spin mini!")
				elseif self.state.spinLevel == 2 then
					if gameConfig.are_non_T_spins_mini then
						self.DEBUG:Log(mino_name .. "-spin mini!")
					else
						self.DEBUG:Log(mino_name .. "-spin!")
					end
				elseif self.state.spinLevel == 3 then
					if #linesCleared == 3 then
						self.DEBUG:Log("T-spin triple!")
					else
						self.DEBUG:Log("T-spin!")
					end
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
			mino.board:IsSolid(mino.x, mino.y + mino.height - 1),
			nil
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
	local state = self.state

	if control:CheckControl("pause", false) then
		if self.canPause then
			state.paused = not state.paused
			control.antiControlRepeat["pause"] = true
		end
	end

	if state.paused or not mino.active then
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
			mino:Move(0, state.gravity * self.clientConfig.soft_drop_multiplier, true, false)
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
			--state.topOut = true
			self.message.quit = true
			control.antiControlRepeat["quit"] = true
			didSlowAction = true
		end
	end

	if control:CheckControl("rotate_ccw", false) and gameConfig.can_rotate then
		_, _, kick_count = mino:RotateLookup(-1, true, self.mino_rotable)
		if mino.spinID <= gameConfig.spin_mode then
			state.spinLevel = self:CheckSpecialSpin(mino, kick_count)
		end
		control.antiControlRepeat["rotate_ccw"] = true
	end
	if control:CheckControl("rotate_cw", false) and gameConfig.can_rotate then
		_, _, kick_count = mino:RotateLookup(1, true, self.mino_rotable)
		if mino.spinID <= gameConfig.spin_mode then
			state.spinLevel = self:CheckSpecialSpin(mino, kick_count)
		end
		control.antiControlRepeat["rotate_cw"] = true
	end
	if control:CheckControl("rotate_180", false) and gameConfig.can_rotate and gameConfig.can_180_spin then
		_, _, kick_count = mino:RotateLookup(2, true, self.mino_rotable)
		if mino.spinID <= gameConfig.spin_mode then
			state.spinLevel = self:CheckSpecialSpin(mino, kick_count)
		end
	end

	return didSlowAction
end

function GameInstance:GameOverAnimation()
	local old_overtop_height = self.state.board.overtopHeight
	for i = 1, math.ceil(self.state.board.visibleHeight) do
		if self.do_render_tiny then
			self.state.board:AddGarbage(1, true, (i % 2 == 0) and " " or "0")
			self.state.board:RenderTiny()
		else
			self.state.board:AddGarbage(1, true, (i % 2 == 0) and "0" or "8")
			self.state.board:Render({ignore_dirty = true})
		end
		self.state.board.overtopHeight = 0
		sleep(0.1)
	end
	self.state.board.overtopHeight = old_overtop_height
	sleep(0.5)
end

function GameInstance:Resume(evt, doTick)
	local mino, ghostMino, garbageMino = self.state.mino, self.state.ghostMino, self.state.garbageMino
	local state, control = self.state, self.control
	self.message = {} -- sends back to main
	
	local doRender = false
	local moment -- used for multiplayer
	
	if evt[1] == "network_moment" then
		moment = self:ParseNetworkMoment(evt[2])
	end

	if not self.networked then

		self.control:Resume(evt)

		if evt[1] == "key" and not evt[3] then
			self.control.keysDown[evt[2]] = 1
			self.didControlTick = self:ControlTick(false)
			state.controlTickCount = state.controlTickCount + 1
			doRender = true
			
			if evt[2] == keys.one then
				state.incomingGarbage = state.incomingGarbage + 1
			elseif evt[2] == keys.two then
				self:GameOverAnimation()
				self.message.quit = true
			end

		elseif evt[1] == "key_up" then
			self.control.keysDown[evt[2]] = nil
		end

		if evt[1] == "timer" then
			if doTick then
				for k, v in pairs(self.control.keysDown) do
					self.control.keysDown[k] = 1 + v
				end
				self:ControlTick(self.didControlTick)
				state.controlTickCount = state.controlTickCount + 1
				if not state.paused then
					self:Tick(message)
					state.gameTickCount = state.gameTickCount + 1
				end
				self.didControlTick = false
				self.control.antiControlRepeat = {}

				doRender = true
			end
		end

		if evt[1] == "network_moment" and moment then
			if moment.action == "send_garbage" then
				state.incomingGarbage = moment.garbage
				doRender = true
			end
		end

		if state.topOut then
			-- this will have a more elaborate game over sequence later
			self.message.gameover = true
			DEBUG:Log("Game over!")
			self:GameOverAnimation()
			self.message.quit = true
		end

	else

		-- "network_moments" always come from other clients
		if evt[1] == "network_moment" and moment then
			--moment = self:ParseNetworkMoment(evt[2])
			--_G.moment = moment

			if moment.action == "mino_setpos" then
				mino.x = moment.x
				mino.y = moment.y
				mino.minoID = moment.minoID
				mino:ForceRotateLookup(moment.rotation, self.mino_rotable)
				doRender = true

			elseif moment.action == "mino_lock" then
				mino.x = moment.x
				mino.y = moment.y
				mino.minoID = moment.minoID
				mino:ForceRotateLookup(moment.rotation, self.mino_rotable)
				mino.lock_timer = 0
				doRender = true

			elseif moment.action == "board_update" then
				state.board.contents = moment.contents
				self.visible = true
				doRender = true

			elseif moment.action == "mino_hold" then
				-- draw held piece
				state.holdBoard:Clear()
				Mino:New(
					self.mino_table,
					moment.minoID,
					state.holdBoard,
					1 + (gameConfig.minos[mino.minoID].spawnOffsetX or 0),
					2,
					{}
				):Write()
				doRender = true
			elseif moment.action == "update" then
				state.incomingGarbage = moment.incomingGarbage
				state.linesCleared = state.linesCleared + moment.linesJustCleared
				self.visible = true
			end
		end
	
	end

	if doRender then
		-- handle ghost piece
		if self.clientConfig.do_ghost_piece then
			ghostMino.color = "c"
			ghostMino.shape = mino.shape
			ghostMino.x = mino.x
			ghostMino.y = mino.y
			ghostMino:Move(0, state.board.height, true)

			garbageMino.y = 1 + state.garbageBoard.height - state.incomingGarbage
		end
		
		if self.do_render_tiny then
			self:RenderTiny(true)
		else
			self:Render(true)
		end
		
		if true then
			term.setCursorPos(state.board.x, (state.board.y) * 2 + self.height)
			term.setTextColor(colors.lightGray)
			term.write("Lines: ")
			term.setTextColor(colors.yellow)
			term.write(state.linesCleared)
		end
	end

	if (not self.networked) then
		local packet = {}
		if state.gameTickCount % 3 == 0 then
			packet[#packet + 1] = self:SerializeNetworkMoment("mino_setpos", mino.x, mino.y, mino.minoID, mino.rotation)
			packet[#packet + 1] = self:SerializeNetworkMoment("board_update", state.board.contents)
		end
		
		if (state.gameTickCount % 3 == 0) or (state.linesJustCleared > 0) then
			packet[#packet + 1] = self:SerializeNetworkMoment("update", state.incomingGarbage, state.linesJustCleared)
		end

		if self.message.attack then
			--packet[#packet + 1] = self:SerializeNetworkMoment("send_garbage", self.message.attack)
		end

		if state.didHold then
			packet[#packet + 1] = self.message.packet, self:SerializeNetworkMoment("mino_hold", state.heldPiece)
		end
		
		self.message.packet = packet
	end

	return self.message
end

return GameInstance
