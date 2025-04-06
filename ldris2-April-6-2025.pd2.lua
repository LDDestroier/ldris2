local tArg = {...}
local selfDelete = false -- if true, deletes extractor after running
local file
local outputPath = tArg[1] and shell.resolve(tArg[1]) or "ldris2" -- shell.getRunningProgram()
local safeColorList = {[colors.white] = true,[colors.lightGray] = true,[colors.gray] = true,[colors.black] = true}
local stc = function(color) if (term.isColor() or safeColorList[color]) then term.setTextColor(color) end end
local choice = function()
	local input = "yn"
	write("[")
	for a = 1, #input do
		write(input:sub(a,a):upper())
		if a < #input then
			write(",")
		end
	end
	print("]?")
	local evt,char
	repeat
		evt,char = os.pullEvent("char")
	until string.find(input:lower(),char:lower())
	if verbose then
		print(char:upper())
	end
	local pos = string.find(input:lower(), char:lower())
	return pos, char:lower()
end
local archive = textutils.unserialize("{\
  mainFile = false,\
  compressed = false,\
  data = {\
    [ \"backup/lib/minodata.lua\" ] = \"return {\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\"    \\\",\\r\\\
			\\\"@@@@\\\",\\r\\\
			\\\"    \\\",\\r\\\
			\\\"    \\\",\\r\\\
		},\\r\\\
		spinID = 3,\\r\\\
		color = \\\"3\\\",\\r\\\
		name = \\\"I\\\",\\r\\\
		kickID = 2,\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\" @ \\\",\\r\\\
			\\\"@@@\\\",\\r\\\
			\\\"    \\\",\\r\\\
		},\\r\\\
		spinID = 1,\\r\\\
		color = \\\"a\\\",\\r\\\
		name = \\\"I\\\",\\r\\\
		kickID = 1,\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\"  @\\\",\\r\\\
			\\\"@@@\\\",\\r\\\
			\\\"   \\\",\\r\\\
		},\\r\\\
		spinID = 2,\\r\\\
		color = \\\"1\\\",\\r\\\
		name = \\\"L\\\",\\r\\\
		kickID = 1,\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\"@  \\\",\\r\\\
			\\\"@@@\\\",\\r\\\
			\\\"   \\\",\\r\\\
		},\\r\\\
		spinID = 2,\\r\\\
		color = \\\"b\\\",\\r\\\
		name = \\\"J\\\",\\r\\\
		kickID = 1,\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\"@@\\\",\\r\\\
			\\\"@@\\\",\\r\\\
		},\\r\\\
		spinID = 3,\\r\\\
		color = \\\"4\\\",\\r\\\
		name = \\\"O\\\",\\r\\\
		kickID = 2,\\r\\\
		spawnOffsetX = 1,\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\" @@\\\",\\r\\\
			\\\"@@ \\\",\\r\\\
			\\\"   \\\",\\r\\\
		},\\r\\\
		spinID = 2,\\r\\\
		color = \\\"5\\\",\\r\\\
		name = \\\"S\\\",\\r\\\
		kickID = 1,\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\"@@ \\\",\\r\\\
			\\\" @@\\\",\\r\\\
			\\\"   \\\",\\r\\\
		},\\r\\\
		spinID = 2,\\r\\\
		color = \\\"e\\\",\\r\\\
		name = \\\"Z\\\",\\r\\\
		kickID = 1,\\r\\\
	}\\r\\\
}\",\
    [ \"lib/gameinstance.lua\" ] = \"-- game instance object\\r\\\
-- returns a function that resumes the game state for 1 tick and returns event info\\r\\\
\\r\\\
-- current status: total fuck\\r\\\
\\r\\\
local Mino = require \\\"lib.mino\\\"\\r\\\
local Board = require \\\"lib.board\\\"\\r\\\
local gameConfig = require \\\"lib.gameconfig\\\"\\r\\\
--gameConfig.minos = require \\\"lib.minodata\\\"\\r\\\
local cospc_debuglog = require \\\"lib.debug\\\"\\r\\\
\\r\\\
\\r\\\
local scr_x, scr_y = term.getSize()\\r\\\
local speaker = peripheral.find(\\\"speaker\\\")\\r\\\
if (not speaker) and periphemu then\\r\\\
	periphemu.create(\\\"speaker\\\", \\\"speaker\\\")\\r\\\
	speaker = peripheral.wrap(\\\"speaker\\\")\\r\\\
end\\r\\\
\\r\\\
local function makeSound(name)\\r\\\
	if speaker and gameConfig.enable_sound then\\r\\\
		speaker.playLocalMusic(fs.combine(shell.dir(), \\\"sound/\\\" .. name))\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
-- emulation of switch case in Lua\\r\\\
local switch = function(check)\\r\\\
    return function(cases)\\r\\\
        if type(cases[check]) == \\\"function\\\" then\\r\\\
            return cases[check]()\\r\\\
        elseif type(cases[\\\"default\\\"] == \\\"function\\\") then\\r\\\
            return cases[\\\"default\\\"]()\\r\\\
        end\\r\\\
    end\\r\\\
end\\r\\\
\\r\\\
local GameInstance = {}\\r\\\
\\r\\\
--local StartGame = function(player_number, native_control, board_xmod, board_ymod)\\r\\\
function GameInstance:New(player_number, control, board_xmod, board_ymod, clientConfig)\\r\\\
	local game = setmetatable({}, self)\\r\\\
	self.__index = self\\r\\\
\\r\\\
	game.board_xmod = board_xmod or 0\\r\\\
	game.board_ymod = board_ymod or 0\\r\\\
	game.clientConfig = clientConfig\\r\\\
	game.control = control\\r\\\
	game.didControlTick = false\\r\\\
	game.player_number = player_number\\r\\\
	game.message = {}\\r\\\
\\r\\\
	return game\\r\\\
end\\r\\\
\\r\\\
-- TODO: unfuck this please\\r\\\
\\r\\\
function GameInstance:Initiate()\\r\\\
\\r\\\
	self.state = {\\r\\\
		gravity = gameConfig.startingGravity,\\r\\\
		targetPlayer = 0,\\r\\\
		score = 0,\\r\\\
		topOut = false,\\r\\\
		canHold = true,\\r\\\
		didHold = false,\\r\\\
		didJustClearLine = false,\\r\\\
		heldPiece = false,\\r\\\
		paused = false,\\r\\\
		queue = {},\\r\\\
		queueMinos = {},\\r\\\
		linesCleared = 0,\\r\\\
		random_bag = {},\\r\\\
		gameTickCount = 0,\\r\\\
		controlTickCount = 0,\\r\\\
		animFrame = 0,\\r\\\
		state = \\\"halt\\\",	-- ???\\r\\\
		controlsDown = {}, \\r\\\
		incomingGarbage = 0,	-- amount of garbage that will be added to board after non-line-clearing mino placement\\r\\\
		combo = 0,				-- amount of successive line clears\\r\\\
		backToBack = 0,			-- amount of tetris/t-spins comboed\\r\\\
		spinLevel = 0			-- 0 = no special spin\\r\\\
	}							-- 1 = mini spin\\r\\\
								-- 2 = Z/S/J/L spin\\r\\\
								-- 3 = T spin\\r\\\
	\\r\\\
	\\r\\\
	-- create boards\\r\\\
	-- main gameplay board\\r\\\
	self.state.board = Board:New(\\r\\\
		7 + self.board_xmod,\\r\\\
		1 + self.board_ymod,\\r\\\
		gameConfig.board_width,\\r\\\
		gameConfig.board_height\\r\\\
	)\\r\\\
\\r\\\
	-- queue of upcoming minos\\r\\\
	self.state.queueBoard = Board:New(\\r\\\
		self.state.board.x + self.state.board.width + 1,\\r\\\
		self.state.board.y,\\r\\\
		4,\\r\\\
		28\\r\\\
	)\\r\\\
\\r\\\
	-- display of currently held mino\\r\\\
	self.state.holdBoard = Board:New(\\r\\\
		2 + self.board_xmod,\\r\\\
		1 + self.board_ymod,\\r\\\
		self.state.queueBoard.width,\\r\\\
		4\\r\\\
	)\\r\\\
	self.state.holdBoard.visibleHeight = 4\\r\\\
	\\r\\\
	\\r\\\
	-- indicator of incoming garbage\\r\\\
	self.state.garbageBoard = Board:New(\\r\\\
		self.state.board.x - 1,\\r\\\
		self.state.board.y,\\r\\\
		1,\\r\\\
		self.state.board.visibleHeight,\\r\\\
		\\\"f\\\"\\r\\\
	)\\r\\\
	self.state.garbageBoard.visibleHeight = self.state.garbageBoard.height\\r\\\
\\r\\\
\\r\\\
	-- populate the queue\\r\\\
	for i = 1, self.clientConfig.queue_length + 1 do\\r\\\
		self.state.queue[i] = self:PseudoRandom(state)\\r\\\
	end\\r\\\
\\r\\\
	for i = 1, self.clientConfig.queue_length do\\r\\\
		self.state.queueMinos[i] = Mino:New(nil,\\r\\\
			self.state.queue[i + 1],\\r\\\
			self.state.queueBoard,\\r\\\
			1,\\r\\\
			i * 3 + 12\\r\\\
		)\\r\\\
	end\\r\\\
\\r\\\
	self.queue_anim = 0\\r\\\
\\r\\\
	self.state.mino = self:MakeDefaultMino()\\r\\\
	self.state.ghostMino = Mino:New(nil, self.state.mino.minoID, self.state.board, self.state.mino.x, self.state.mino.y, {})\\r\\\
\\r\\\
	local garbageMinoShape = {}\\r\\\
	for i = 1, self.state.garbageBoard.height do\\r\\\
		garbageMinoShape[i] = \\\"@\\\"\\r\\\
	end\\r\\\
\\r\\\
	self.state.garbageMino = Mino:New({\\r\\\
		[1] = {\\r\\\
			shape = garbageMinoShape,\\r\\\
			color = \\\"e\\\"\\r\\\
		}\\r\\\
	}, 1, self.state.garbageBoard, 1, self.state.garbageBoard.height + 1)\\r\\\
	\\r\\\
	self.control.keysDown = {}\\r\\\
\\r\\\
	return self\\r\\\
end\\r\\\
\\r\\\
function GameInstance:CyclePiece()\\r\\\
	local nextPiece = self.state.queue[1]\\r\\\
	table.remove(self.state.queue, 1)\\r\\\
	self.state.queue[#self.state.queue + 1] = self:PseudoRandom(state)\\r\\\
	return nextPiece\\r\\\
end\\r\\\
\\r\\\
function GameInstance:PseudoRandom()\\r\\\
	return switch(gameConfig.randomBag) {\\r\\\
		[\\\"random\\\"] = function()\\r\\\
			return math.random(1, #gameConfig.minos)\\r\\\
		end,\\r\\\
		[\\\"singlebag\\\"] = function()\\r\\\
			if #self.state.random_bag == 0 then\\r\\\
				-- repopulate random bag\\r\\\
				for i = 1, #gameConfig.minos do\\r\\\
					if math.random(0, 1) == 0 then\\r\\\
						self.state.random_bag[#self.state.random_bag + 1] = i\\r\\\
					else\\r\\\
						table.insert(self.state.random_bag, 1, i)\\r\\\
					end\\r\\\
				end\\r\\\
			end\\r\\\
			local pick = math.random(1, #self.state.random_bag)\\r\\\
			local output = self.state.random_bag[pick]\\r\\\
			table.remove(self.state.random_bag, pick)\\r\\\
			return output\\r\\\
		end,\\r\\\
		[\\\"doublebag\\\"] = function()\\r\\\
			if #self.state.random_bag == 0 then\\r\\\
				for r = 1, 2 do\\r\\\
					-- repopulate random bag\\r\\\
					for i = 1, #gameConfig.minos do\\r\\\
						if math.random(0, 1) == 0 then\\r\\\
							self.state.random_bag[#self.state.random_bag + 1] = i\\r\\\
						else\\r\\\
							table.insert(self.state.random_bag, 1, i)\\r\\\
						end\\r\\\
					end\\r\\\
				end\\r\\\
			end\\r\\\
			local pick = math.random(1, #self.state.random_bag)\\r\\\
			local output = self.state.random_bag[pick]\\r\\\
			table.remove(self.state.random_bag, pick)\\r\\\
			return output\\r\\\
		end\\r\\\
	}\\r\\\
end\\r\\\
\\r\\\
function GameInstance:MakeDefaultMino()\\r\\\
	local nextPiece\\r\\\
	if self.state.didHold then\\r\\\
		if self.state.heldPiece then\\r\\\
			nextPiece, self.state.heldPiece = self.state.heldPiece, self.state.mino.minoID\\r\\\
		else\\r\\\
			nextPiece, self.state.heldPiece = self:CyclePiece(), self.state.mino.minoID\\r\\\
		end\\r\\\
	else\\r\\\
		nextPiece = self:CyclePiece()\\r\\\
	end\\r\\\
	\\r\\\
	return Mino:New(nil,\\r\\\
		nextPiece,\\r\\\
		self.state.board,\\r\\\
		math.floor(\\r\\\
			self.state.board.width / 2 - 1\\r\\\
		) + (\\r\\\
			gameConfig.minos[nextPiece].spawnOffsetX or 0\\r\\\
		),\\r\\\
		math.floor(gameConfig.board_height_visible + 1) + (gameConfig.minos[nextPiece].spawnOffsetY or 0),\\r\\\
		self.state.mino\\r\\\
	)\\r\\\
end\\r\\\
\\r\\\
function GameInstance:CalculateGarbage(linesCleared)\\r\\\
	local output = 0\\r\\\
	local lncleartbl = {\\r\\\
		[0] = 0,\\r\\\
		[1] = 0,\\r\\\
		[2] = 1,\\r\\\
		[3] = 2,\\r\\\
		[4] = 4,\\r\\\
		[5] = 5,\\r\\\
		[6] = 6,\\r\\\
		[7] = 7,\\r\\\
		[8] = 8\\r\\\
	}\\r\\\
\\r\\\
	if (self.state.spinLevel == 3) or (self.state.spinLevel == 2 and gameConfig.spin_mode >= 2) then\\r\\\
		output = output + linesCleared * 2\\r\\\
	else\\r\\\
		output = output + (lncleartbl[linesCleared] or 0)\\r\\\
	end\\r\\\
\\r\\\
	-- add combo bonus\\r\\\
	output = output + math.max(0, math.floor(-1 + self.state.combo / 2))\\r\\\
\\r\\\
	return output\\r\\\
end\\r\\\
\\r\\\
function GameInstance:HandleLineClears()\\r\\\
	local mino, board = self.state.mino, self.state.board\\r\\\
\\r\\\
	-- get list of full lines\\r\\\
	local clearedLines = {lookup = {}}\\r\\\
	for y = 1, board.height do\\r\\\
		if not board.contents[y]:find(board.blankColor) then\\r\\\
			clearedLines[#clearedLines + 1] = y\\r\\\
			clearedLines.lookup[y] = true\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	-- clear the lines, baby\\r\\\
	if #clearedLines > 0 then\\r\\\
		local newContents = {}\\r\\\
		local i = board.height\\r\\\
		for y = board.height, 1, -1 do\\r\\\
			if not clearedLines.lookup[y] then\\r\\\
				newContents[i] = board.contents[y]\\r\\\
				i = i - 1\\r\\\
			end\\r\\\
		end\\r\\\
		for y = 1, #clearedLines do\\r\\\
			newContents[y] = string.rep(board.blankColor, board.width)\\r\\\
		end\\r\\\
		self.state.board.contents = newContents\\r\\\
	end\\r\\\
\\r\\\
	self.state.linesCleared = self.state.linesCleared + #clearedLines\\r\\\
\\r\\\
	return clearedLines\\r\\\
\\r\\\
end\\r\\\
\\r\\\
function GameInstance:SendGarbage(amount)\\r\\\
	if amount ~= 0 then\\r\\\
		self.message.attack = (self.message.attack or 0) + amount\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
function GameInstance:ReceiveGarbage(amount)\\r\\\
	if amount ~= 0 then\\r\\\
		self.state.incomingGarbage = self.state.incomingGarbage + amount\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
function GameInstance:Render(doDrawOtherBoards)\\r\\\
	self.state.board:Render(self.state.ghostMino, self.state.mino)\\r\\\
	if doDrawOtherBoards then\\r\\\
		self.state.holdBoard:Render()\\r\\\
		self.state.queueBoard:Render(table.unpack(self.state.queueMinos))\\r\\\
		self.state.garbageBoard:Render(self.state.garbageMino)\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
function GameInstance:AnimateQueue()\\r\\\
	table.remove(self.state.queueMinos, 1)\\r\\\
	self.state.queueMinos[#self.state.queueMinos + 1] = Mino:New(nil,\\r\\\
		self.state.queue[self.clientConfig.queue_length],\\r\\\
		self.state.queueBoard,\\r\\\
		1,\\r\\\
		(self.clientConfig.queue_length + 1) * 3 + 12\\r\\\
	)\\r\\\
	self.queue_anim = 3\\r\\\
end\\r\\\
\\r\\\
function GameInstance:Tick()\\r\\\
	local mino, ghostMino, garbageMino = self.state.mino, self.state.ghostMino, self.state.garbageMino\\r\\\
	--	local holdBoard, queueBoard, garbageBoard = self.state.holdBoard, self.state.queueBoard, self.state.garbageBoard\\r\\\
	\\r\\\
	self.didJustClearLine = false\\r\\\
\\r\\\
	local didCollide, didMoveX, didMoveY, yHighestDidChange = mino:Move(0, self.state.gravity, true)\\r\\\
	local doCheckStuff = false\\r\\\
	local doAnimateQueue = false\\r\\\
	local doMakeNewMino = false\\r\\\
\\r\\\
	self.queue_anim = math.max(0, self.queue_anim - 0.8)\\r\\\
\\r\\\
	-- position queue minos properly\\r\\\
	for i = 1, #self.state.queueMinos do\\r\\\
		self.state.queueMinos[i].y = (i * 3 + 12) + math.min(3, math.floor(self.queue_anim))\\r\\\
	end\\r\\\
\\r\\\
	if not mino.finished then\\r\\\
		mino.resting = (not didMoveY) and mino:CheckCollision(0, 1)\\r\\\
\\r\\\
		if yHighestDidChange then\\r\\\
			mino.movesLeft = gameConfig.lock_move_limit\\r\\\
		end\\r\\\
\\r\\\
		if mino.resting then\\r\\\
			mino.lockTimer = mino.lockTimer - gameConfig.tickDelay\\r\\\
			if mino.lockTimer <= 0 then\\r\\\
				mino.finished = 1\\r\\\
			end\\r\\\
		else\\r\\\
			mino.lockTimer = gameConfig.lock_delay\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	mino.spawnTimer = math.max(0, mino.spawnTimer - gameConfig.tickDelay)\\r\\\
	if mino.spawnTimer == 0 then\\r\\\
		if (not mino.active) then\\r\\\
			makeSound(gameConfig.minos[mino.minoID].sound)\\r\\\
			self:AnimateQueue()\\r\\\
		end\\r\\\
		mino.active = true\\r\\\
		mino.visible = true\\r\\\
		ghostMino.active = true\\r\\\
		ghostMino.visible = true\\r\\\
	end\\r\\\
\\r\\\
	if mino.finished then\\r\\\
		if mino.finished == 1 then -- piece will lock\\r\\\
			self.state.didHold = false\\r\\\
			self.state.canHold = true\\r\\\
			-- check for top-out due to placing a piece outside the visible area of its board\\r\\\
			if false then	-- I'm doing that later\\r\\\
				\\r\\\
			else\\r\\\
				doAnimateQueue = true\\r\\\
				mino:Write()\\r\\\
				doMakeNewMino = true\\r\\\
				doCheckStuff = true\\r\\\
			end\\r\\\
			\\r\\\
		elseif mino.finished == 2 then -- piece will attempt hold\\r\\\
			if self.state.canHold then\\r\\\
				self.state.didHold = true\\r\\\
				self.state.canHold = false\\r\\\
				\\r\\\
				if self.state.heldPiece then\\r\\\
					doAnimateQueue = false\\r\\\
				else\\r\\\
					doAnimateQueue = true\\r\\\
				end\\r\\\
				\\r\\\
				-- draw held piece\\r\\\
				self.state.holdBoard:Clear()\\r\\\
				Mino:New(nil,\\r\\\
					mino.minoID,\\r\\\
					self.state.holdBoard,\\r\\\
					1 + (gameConfig.minos[mino.minoID].spawnOffsetX or 0),\\r\\\
					2,\\r\\\
					{}\\r\\\
				):Write()\\r\\\
\\r\\\
				doMakeNewMino = true\\r\\\
				doCheckStuff = true\\r\\\
				\\r\\\
			else\\r\\\
				mino.finished = false\\r\\\
			end\\r\\\
			\\r\\\
		else\\r\\\
			error(\\\"I don't know how, but that polyomino's finished!\\\")\\r\\\
		end\\r\\\
		\\r\\\
		local linesCleared = self:HandleLineClears()\\r\\\
		local _delay = (#linesCleared > 0 and self.clientConfig.line_clear_delay or self.clientConfig.appearance_delay)\\r\\\
\\r\\\
		if doMakeNewMino then\\r\\\
			self.state.mino = self:MakeDefaultMino(); mino = self.state.mino\\r\\\
			self.state.ghostMino = Mino:New(nil, mino.minoID, self.state.board, mino.x, mino.y, {}); ghostMino = self.state.ghostMino\\r\\\
			\\r\\\
			if (not self.state.didHold) and (_delay > 0) then\\r\\\
				mino.spawnTimer = _delay\\r\\\
				mino.active = false\\r\\\
				mino.visible = false\\r\\\
				ghostMino.active = false\\r\\\
				ghostMino.visible = false\\r\\\
				\\r\\\
			else\\r\\\
				makeSound(gameConfig.minos[mino.minoID].sound)\\r\\\
				if doAnimateQueue then\\r\\\
					self:AnimateQueue()\\r\\\
				end\\r\\\
			end\\r\\\
		end\\r\\\
		\\r\\\
		-- if the hold attempt fails (say, you already held a piece), it wouldn't do to check for a top-out or line clears\\r\\\
		if doCheckStuff then\\r\\\
			-- check for top-out due to obstructed mino upon entry\\r\\\
			-- attempt to move mino at most 2 spaces upwards before considering it fully topped out\\r\\\
			self.state.topOut = true\\r\\\
			for i = 0, 2 do\\r\\\
				if mino:CheckCollision(0, 1) then\\r\\\
					mino.y = mino.y - 1\\r\\\
				else\\r\\\
					self.state.topOut = false\\r\\\
					break\\r\\\
				end\\r\\\
			end\\r\\\
\\r\\\
			if #linesCleared == 0 then\\r\\\
				self.state.combo = 0\\r\\\
				self.state.backToBack = 0\\r\\\
			else\\r\\\
				makeSound(\\\"lineclear.ogg\\\")\\r\\\
				self.didJustClearLine = true\\r\\\
				self.state.combo = self.state.combo + 1\\r\\\
				if #linesCleared == 4 or self.state.spinLevel >= 1 then\\r\\\
					self.state.backToBack = self.state.backToBack + 1\\r\\\
				else\\r\\\
					self.state.backToBack = 0\\r\\\
				end\\r\\\
			end\\r\\\
			-- calculate garbage to be sent\\r\\\
			local garbage = self:CalculateGarbage(#linesCleared)\\r\\\
			garbage, self.state.incomingGarbage = math.max(0, garbage - self.state.incomingGarbage), math.max(0, self.state.incomingGarbage - garbage)\\r\\\
			\\r\\\
			if garbage > 0 then\\r\\\
				cospc_debuglog(self.player_number, \\\"Doled out \\\" .. garbage .. \\\" lines\\\")\\r\\\
			end\\r\\\
			\\r\\\
			-- send garbage to enemy player\\r\\\
			self:SendGarbage(garbage)\\r\\\
			\\r\\\
			-- generate garbage lines\\r\\\
			self.state.board:AddGarbage(self.state.incomingGarbage)\\r\\\
			self.state.incomingGarbage = 0\\r\\\
\\r\\\
			if doMakeNewMino then\\r\\\
				self.state.spinLevel = 0\\r\\\
			end\\r\\\
\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
\\r\\\
	-- debug info\\r\\\
	if self.control.native_control then\\r\\\
		term.setCursorPos(2, scr_y - 2)\\r\\\
		term.write(\\\"Lines: \\\" .. self.state.linesCleared .. \\\"      \\\")\\r\\\
\\r\\\
		term.setCursorPos(2, scr_y - 1)\\r\\\
		term.write(\\\"M=\\\" .. mino.movesLeft .. \\\", TTL=\\\" .. tostring(mino.lockTimer):sub(1, 4) .. \\\"      \\\")\\r\\\
\\r\\\
		term.setCursorPos(2, scr_y - 0)\\r\\\
		term.write(\\\"POS=(\\\" .. mino.x .. \\\":\\\" .. tostring(mino.xFloat):sub(1, 5) .. \\\", \\\" .. mino.y .. \\\":\\\" .. tostring(mino.yFloat):sub(1, 5) .. \\\")      \\\")\\r\\\
	end\\r\\\
	\\r\\\
end\\r\\\
\\r\\\
-- keep this in gameinstance.lua\\r\\\
function GameInstance:ControlTick(onlyFastActions)\\r\\\
	local dc, dmx, dmy	-- did collide, did move X, did move Y\\r\\\
	local didSlowAction = false\\r\\\
	\\r\\\
	local control = self.control\\r\\\
	local mino = self.state.mino\\r\\\
	local board = self.state.board\\r\\\
	\\r\\\
	if (not self.state.paused) and self.state.mino.active then\\r\\\
		if not onlyFastActions then\\r\\\
			if control:CheckControl(\\\"move_left\\\", self.clientConfig.move_repeat_delay, self.clientConfig.move_repeat_interval) then\\r\\\
				if not mino.finished then\\r\\\
					mino:Move(-1, 0, true, true)\\r\\\
					didSlowAction = true\\r\\\
					control.antiControlRepeat[\\\"move_left\\\"] = true\\r\\\
				end\\r\\\
			end\\r\\\
			if control:CheckControl(\\\"move_right\\\", self.clientConfig.move_repeat_delay, self.clientConfig.move_repeat_interval) then\\r\\\
				if not mino.finished then\\r\\\
					mino:Move(1, 0, true, true)\\r\\\
					didSlowAction = true\\r\\\
					control.antiControlRepeat[\\\"move_right\\\"] = true\\r\\\
				end\\r\\\
			end\\r\\\
			if control:CheckControl(\\\"soft_drop\\\", 0) then\\r\\\
				mino:Move(0, self.state.gravity * self.clientConfig.soft_drop_multiplier, true, false)\\r\\\
				didSlowAction = true\\r\\\
				control.antiControlRepeat[\\\"soft_drop\\\"] = true\\r\\\
			end\\r\\\
			if control:CheckControl(\\\"hard_drop\\\", false) then\\r\\\
				mino:Move(0, board.height, true, false)\\r\\\
				mino.finished = 1\\r\\\
				makeSound(\\\"drop.ogg\\\")\\r\\\
				didSlowAction = true\\r\\\
				control.antiControlRepeat[\\\"hard_drop\\\"] = true\\r\\\
			end\\r\\\
			if control:CheckControl(\\\"sonic_drop\\\", false) then\\r\\\
				if mino:Move(0, board.height, true, true) then\\r\\\
					makeSound(\\\"drop.ogg\\\")\\r\\\
				end\\r\\\
				didSlowAction = true\\r\\\
				control.antiControlRepeat[\\\"sonic_drop\\\"] = true\\r\\\
			end\\r\\\
			if control:CheckControl(\\\"hold\\\", false) then\\r\\\
				if not mino.finished then\\r\\\
					mino.finished = 2\\r\\\
					control.antiControlRepeat[\\\"hold\\\"] = true\\r\\\
					didSlowAction = true\\r\\\
				end\\r\\\
			end\\r\\\
			if control:CheckControl(\\\"quit\\\", false) then\\r\\\
				self.state.topOut = true\\r\\\
				control.antiControlRepeat[\\\"quit\\\"] = true\\r\\\
				didSlowAction = true\\r\\\
			end\\r\\\
		end\\r\\\
		if control:CheckControl(\\\"rotate_ccw\\\", false) then\\r\\\
			mino:Rotate(-1, true)\\r\\\
			if mino.spinID <= gameConfig.spin_mode then\\r\\\
				if (\\r\\\
					mino:CheckCollision(1, 0) and\\r\\\
					mino:CheckCollision(-1, 0) and\\r\\\
					mino:CheckCollision(0, -1)\\r\\\
				) then\\r\\\
					self.state.spinLevel = 3\\r\\\
				else\\r\\\
					self.state.spinLevel = 0\\r\\\
				end\\r\\\
			end\\r\\\
			control.antiControlRepeat[\\\"rotate_ccw\\\"] = true\\r\\\
		end\\r\\\
		if control:CheckControl(\\\"rotate_cw\\\", false) then\\r\\\
			mino:Rotate(1, true)\\r\\\
			if mino.spinID <= gameConfig.spin_mode then\\r\\\
				if (\\r\\\
					mino:CheckCollision(1, 0) and\\r\\\
					mino:CheckCollision(-1, 0) and\\r\\\
					mino:CheckCollision(0, -1)\\r\\\
				) then\\r\\\
					self.state.spinLevel = 3\\r\\\
				else\\r\\\
					self.state.spinLevel = 0\\r\\\
				end\\r\\\
			end\\r\\\
			control.antiControlRepeat[\\\"rotate_cw\\\"] = true\\r\\\
		end\\r\\\
	end\\r\\\
	if control:CheckControl(\\\"pause\\\", false) then\\r\\\
		self.state.paused = not self.state.paused\\r\\\
		control.antiControlRepeat[\\\"pause\\\"] = true\\r\\\
	end\\r\\\
	return didSlowAction\\r\\\
end\\r\\\
\\r\\\
local evt\\r\\\
\\r\\\
-- TODO: make each instance of the game into an object\\r\\\
\\r\\\
function GameInstance:Resume(evt, doTick)\\r\\\
\\r\\\
	local mino, ghostMino, garbageMino = self.state.mino, self.state.ghostMino, self.state.garbageMino\\r\\\
	self.message = {} -- sends back to main\\r\\\
\\r\\\
	-- handle ghost piece\\r\\\
	ghostMino.color = \\\"c\\\"\\r\\\
	ghostMino.shape = mino.shape\\r\\\
	ghostMino.x = mino.x\\r\\\
	ghostMino.y = mino.y\\r\\\
	ghostMino:Move(0, self.state.board.height, true)\\r\\\
\\r\\\
	self.state.garbageMino.y = 1 + self.state.garbageBoard.height - self.state.incomingGarbage\\r\\\
\\r\\\
	-- render board\\r\\\
	self:Render(true)\\r\\\
\\r\\\
	--evt = {os.pullEvent()}\\r\\\
\\r\\\
	if evt[1] == \\\"key\\\" and not evt[3] then\\r\\\
		self.control.keysDown[evt[2]] = 1\\r\\\
		self.didControlTick = self:ControlTick(false)\\r\\\
		self.state.controlTickCount = self.state.controlTickCount + 1\\r\\\
		\\r\\\
	elseif evt[1] == \\\"key_up\\\" then\\r\\\
		self.control.keysDown[evt[2]] = nil\\r\\\
	end\\r\\\
\\r\\\
	if evt[1] == \\\"timer\\\" then\\r\\\
		if doTick then\\r\\\
--			tickTimer = os.startTimer(0.05)\\r\\\
			for k,v in pairs(self.control.keysDown) do\\r\\\
				self.control.keysDown[k] = 1 + v\\r\\\
			end\\r\\\
			self:ControlTick(self.didControlTick)\\r\\\
			self.state.controlTickCount = self.state.controlTickCount + 1\\r\\\
			if not self.state.paused then\\r\\\
				self:Tick(message)\\r\\\
				self.state.gameTickCount = self.state.gameTickCount + 1\\r\\\
			end\\r\\\
			self.didControlTick = false\\r\\\
			self.control.antiControlRepeat = {}\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	if self.state.topOut then\\r\\\
		-- this will have a more elaborate game over sequence later\\r\\\
		self.message.finished = true\\r\\\
	end\\r\\\
	\\r\\\
	return self.message\\r\\\
end\\r\\\
\\r\\\
return GameInstance\",\
    [ \"sound/mino_Z.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000]a\\000\\000\\000\\000\\000\\000\\\"Êvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000]a\\000\\000\\000\\000\\00027òDÿÿÿÿÿÿÿÿÿÿÿÿvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000 \\\
ÆÐU\\000\\000\\000\\000BFÆP§GÄPóPjé xJaÉôkBß{Ï½÷Þ{ 4d\\000\\000\\000@bà1	B¡Å	Q)Ba9	r:	B÷ .çÞrî½÷\\rY\\000\\000\\0000!B!B\\\
)¥R)¦bÊ1ÇsÌ1È :è¤N2©¤2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊc1Æc1Æc1ÆBCV\\000 \\000\\000AdB!R)¦sÌ1ÇÐU\\000\\000 \\000\\000\\000\\000\\000GÉÉ$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û}ÛwuÙ·}ÙvuYeYwm[uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9#)¬\\000d\\000\\000\\000à(â8#9cI¤IåYåi&j¢¬\\000\\000\\000\\000\\000\\000\\000\\000 (â(#I¥iç©(¦ªª¢iªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i@hÈ*\\000@\\000@ÇqÇQÇqÉ$	\\rY\\000È\\000\\000\\000ÀPGË±$ÍÒ,Ïò4Ñ3=WMÝÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓÐU\\000\\000\\000\\000 B1 4d\\000\\000\\000¢1Ô)%Á¥`!Ä1Ô!ä<Z:RX2&=ÅÂ÷Þsï½÷\\rY\\000\\000\\000FxLB(FqBg\\\
BXN¥NÐ=!Ë¹·{ï½BCV\\000\\000\\000B!B!BJ)b)¦rÌ1Çs2È :é¤L*é¤£L2ê(µRK1Å[n1ÖZkÍ9÷2Æc1Æc1Æc1ÐU\\000\\000\\000\\000aABH!b)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I,É4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeÝÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäH¤\\000¡!«\\000\\000\\000\\000\\0008£8äHåX%ifygy§è¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(¢8ãHeiæyª'¢©ªªhªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i&²\\\
\\000\\000\\000ÐqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç<É³<Çs<É4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000 Ç´$	 äÄÄ¤ ä:%Åä!§ bä9ÉAäÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥9ç¤tR¡¥Rg©´ZbÌ(ÚR­\\rRH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,BCV\\000Q\\000\\0001H)¤b9ÈD1èd1!sNAÇT*uPRÃsA¨ T:GPRG\\000\\000\\000\\000\\000¡Ð@\\000A4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUÝvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×eÓumÙue[WeYø5UeÓumÙt]ÙveW·UYÖmÑu}]eá7eÙ÷e[×}Y·at]ÛWeY÷MY~ÙÝÕu_DQU=U]QU]×t][W]×¶5Õ]ÓumÙT]YVeY÷]WÖuMUeÙeÛ6]WUYöuWu[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}Uu_ÖuauÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_máXeÙøuá[×ßs]_WmÙVÙ6Ý÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^Ý6êÆO¸ß¨©ª¯®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VYÕaÖuaÙa©Úº2¼ºo¯­+ÃíßWªmË«ÛÂ0û¶ðÛÂo»±3\\000\\0008\\000\\000P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEUeÕeYu]]MÓEÕteÓT]Yu]WV]W%M3MÍóLSó<Ó4UÓMSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓMSeÓUmÙUeW]Ù¶MUeS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨²kªl«ªª»²kë¾,Ë¶,ªªë®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï¦,ª)Û¦ªÊ²,»¶mË²/¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À\\000@	e Ð\\000@\\000\\000`cAhrÎ9RÎ9!sB©dÎA¡¤Ì9¥¤9¡B¥¤ÔZ¡Z+\\000\\000 À\\000 ÀMÅ\\\
\\rY	\\000¤\\000GÓLÓueÙËEUeÛ6Å²DQUeÙ¶cEUeÛÖu4QTUY¶mÝWSUeÙ¶}]82UUm[×}#Um[×¡*Ë¶më¾QI¶m]7ã¨$Û¶îû¾q,ñ¡°,ð_8*\\000\\000ð\\000 VG8),4d%\\000\\000\\000¤QJ)£RJ)ÆR	\\000\\000p\\000\\0000¡²\\\"\\000\\000\\000sÎ9çsÎ9çsÎ9çsÎ9çc1Æc1Æc1Æc1Æc1Æc1Æ\\000ìD8\\000ìDX¬\\000Â\\000\\000R)¥9ç¤RJ)¥ÈA¥RJ)¥DÒI)¥RJ)¥qPJ)¥RJ)¡RJ)¥RJ	¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ\\000&\\000P	6Î°tV8\\\\hÈJ\\000 7\\000\\000P9Æ$JH%JåÎI	)µVB\\\
­\\\
:h£RK­JIB(¡RZ)%µR2¡PJ!¥RJ	¡ePB\\\
%RI-´TJÉ PZ	©ÔZ\\\
%A)©R*­µJJ­ÒR)­µÖJJ!R¥¤R)¥µJk­µNR)-¤ÖRk­VJ)¥JI­µZk)¥VB)­´ÒZ)%µÖRk-ÔZK­¥ÖRk­¥ÖJ)%¥Zk­µZ*)µB)¥Bj©¥ÖJ*-ÐRI¥VZk)¥J(%Z*©µRh¥ÒJI%¥J*)¥ÔR*¡R*¡ÔRk©¥J*-µÔR+©JJ©\\000\\000tà\\000\\000`D¥ØiÆGàB	(\\000\\000\\000@ \\000\\\
d\\000ÀB\\000PX`(]è\\\"HA\\\\8qãNèÐ\\000\\000¡\\\"$dÀEt\\000°¸À(]è\\\"HA\\\\8qãNèÐ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\ÆGÇH\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000OggS\\000]%\\000\\000\\000\\000\\000\\000]a\\000\\000\\000\\000\\000æ`idBIPOVKZINO?O@AJA;AWV¡«O£ÍAàb¼-à-\\000Îxh`3ïõ<íÒÞÚOÞýÑFµIW\\r­¡F\\r¼äÚÓÞ{	@½½_õ<ÞbÀJÀúæÏ,¼µsU.j\\000u<)©å	\\000r­«I§Úl·/\\000J\\000\\000.\\000\\000\\000µÆ\\000°ä¢\\000¢@àüÊ\\000ë(`x³\\000tùW\\000³?Ú\\r\\000r¯«eû|*Õj¸\\000XY@-\\000\\000À\\000¬\\000HuÚ\\000hï\\000\\000\\\\9z \\000¶\\000À@Å Àçû$¨B9\\000R£¶Ó>ð²ÐÚ¤N\\000à\\rÎuÐ.¬ëúÝ~ÿÿ÷Ì\\000f]ÓuÜ<ì|ûå_eÝ;3»ÀøX\\000ÏìêÔÛ ÄùM\\000¸¸*\\000f§©e Ç\\\\ÐGúK\\000 HDUµ÷6YîÇó»·xÐH\\000ÆaÂdù6°¡;\\000 9í±puè8qÄjøD<h;\\\\Cû	\\000v£èoL¸\\000ý³Ð\\000]<=À\\000{èßþÇ;0jk£X\\000\\000NÿùSKÂåÐ³\\000(k|\\r²ÃâQwtª&¤ù\\000^¡à\\000ºÚá/éù.ðÔ%LÝ­	cjÝ¯#Á`2å¿\\\
\\000`_í]	àç\\\"\\000kO°¾ÑH_+>6ñEyÐÊÓù\\000RVëÁ4Áá«ìc¬µò_¥øÿÒ_·ÔÃvNn&nFJ¹õÿªýyZàÿ¶\\\
à/ËÛS\\r%p\\\"úá:KbF}®AÉ°	 n¥\\\"ï&$'ÆÕ\\000\\000n?\\\"\\000£U\\000\\000\\rß\\\
È\\000\\\"×8@öÒ%\\000×_ïQ\\000\\000¾ðhHùêVcÐÁèéABÔ¡À\\000j£T),xô»;Ê\\000*\\000\\000ØÖ\\\
P©¦yºÂäÐ'H 6`À\\000xyoÊ\\000Ô¾¡º+Ã:ð_Ñ\\\" ÇC\\000V^óP5H>@2Oèt@ Y¶\\\"n_Êëö\\000T·ð¨¨ÑË\\000láb`k0.à7\\\
ckøÀå¯AÚª£3Õ *[àQ§¥ìn\\000ì¶±B*íÚãÐ&ôa\\000Lþ: X x	°N0e,©á zbøÀrB¦\\000¬§0µÀËY)ØUu5R¤æ­¯ß´4ð¢\\000L_Àí8\\000ä©KÀÞÆ*Übì'¸6ìÔ-\\rä\\\
ê$Ô­àë°°zÍÊÁø\\000&5 «N\\000%ÊÁjdÿh`{ûp-üÇÌ?¦aEÏaÛãe¶\\\\À¾À\\000&5 {<@¥`!´f@~öK*HÀ¿\\000ú5`\\000 ì4:9@[X'9ÇC ÛáQë urar\\000{}PÀÎw{¶°Ùªuk[vFÌßÃ,ß\\000ZÃÅEM.Âôh9NKxÛ²±Æ:Q®ë1ñ°9_Ó»ÝÆ\\000\\\"¨¦/¢±ÀèS·eY´m[KóK:_|\\\"l	\\000ð*ÀWÎqá\\\
j(P 2}Ò[G&þ=º\\000VP\\000ÜÞª¸µÑ¤ÕH\\000PP\\000|\\000\\rð:4xÆ	âÃA£)\\000y³\\\"=Àú,ÇÄÀ»li;òÆT	<a<¨\\000|`, \\\
øMØð\\r.!!_5º\\000[´èMò\\000ëR2þÈR³¨öû²|Y®[êÁ@¿ÈG'býô¸®uqüëyæÁò2pÛ8ï\\ràÍÖÞÍú°ðî$6¨BÇU/­«°Ab\\\\\\000\",\
    [ \"lib/debug.lua\" ] = \"local _WRITE_TO_DEBUG_MONITOR = true\\r\\\
\\r\\\
local cospc_debuglog = function(header, text)\\r\\\
	if _WRITE_TO_DEBUG_MONITOR then\\r\\\
		if ccemux then\\r\\\
			if not peripheral.find(\\\"monitor\\\") then\\r\\\
				ccemux.attach(\\\"right\\\", \\\"monitor\\\")\\r\\\
			end\\r\\\
			local t = term.redirect(peripheral.wrap(\\\"right\\\"))\\r\\\
			if text == 0 then\\r\\\
				term.clear()\\r\\\
				term.setCursorPos(1, 1)\\r\\\
			else\\r\\\
				term.setTextColor(colors.yellow)\\r\\\
				term.write(header or \\\"SYS\\\")\\r\\\
				term.setTextColor(colors.white)\\r\\\
				print(\\\": \\\" .. text)\\r\\\
			end\\r\\\
			term.redirect(t)\\r\\\
		end\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
return cospc_debuglog\",\
    [ \"lib/gameconfig.lua\" ] = \"return {\\r\\\
	minos = {},					-- list of all the minos (pieces) that will spawn into the board (populated from /lib/minodata.lua)\\r\\\
	kickTables = {},			-- list of all kick tables for pieces (populated from /lib/kicktables.lua)\\r\\\
	lock_delay = 0.5,			-- (Lock Delay) amount of seconds it will take for a resting mino to lock into placed\\r\\\
	currentKickTable = \\\"SRS\\\",	-- current kick table\\r\\\
	randomBag = \\\"singlebag\\\",	-- current pseudorandom number generator\\r\\\
								-- \\\"singlebag\\\" = normal tetris guideline random\\r\\\
								-- \\\"doublebag\\\" = doubled bag size\\r\\\
								-- \\\"random\\\" = using math.random\\r\\\
	board_width = 10,			-- width of play area\\r\\\
	board_height = 40,			-- height of play area\\r\\\
	board_height_visible = 20,	-- height of play area that will render on screen (anchored to bottom)\\r\\\
	spin_mode = 1,				-- 1 = allows T-spins\\r\\\
								-- 2 = allows J/L-spins\\r\\\
								-- 3 = allows ALL SPINS! Similar to STUPID mode in tetr.io\\r\\\
	can_rotate = true,			-- if false, will disallow ALL piece rotation (meme mode)\\r\\\
	startingGravity = 0.15,		-- gravity per tick for minos\\r\\\
	lock_move_limit = 30,		-- amount of moves a mino can do after descending below its lowest point yet traversed\\r\\\
								-- used as a method of preventing stalling -- set it to math.huge for infinite\\r\\\
	tickDelay = 0.05,			-- time between game ticks\\r\\\
	enable_sound = true,\\r\\\
	minos = require \\\"lib.minodata\\\"\\r\\\
}\",\
    [ \"backup/lib/gameinstance.lua\" ] = \"-- game instance object\\r\\\
-- returns a function that resumes the game state for 1 tick and returns event info\",\
    [ \"lib/kicktables.lua\" ] = \"local kicktables = {}\\r\\\
\\r\\\
kicktables[\\\"SRS\\\"] = {\\r\\\
	[1] = { -- used on J, L, S, T, Z tetraminos\\r\\\
		[\\\"01\\\"] = {{ 0, 0}, {-1, 0}, {-1, 1}, { 0,-2}, {-1,-2}},\\r\\\
		[\\\"10\\\"] = {{ 0, 0}, { 1, 0}, { 1,-1}, { 0, 2}, { 1, 2}},\\r\\\
		[\\\"12\\\"] = {{ 0, 0}, { 1, 0}, { 1,-1}, { 0, 2}, { 1, 2}},\\r\\\
		[\\\"21\\\"] = {{ 0, 0}, {-1, 0}, {-1, 1}, { 0,-2}, {-1,-2}},\\r\\\
		[\\\"23\\\"] = {{ 0, 0}, { 1, 0}, { 1, 1}, { 0,-2}, { 1,-2}},\\r\\\
		[\\\"32\\\"] = {{ 0, 0}, {-1, 0}, {-1,-1}, { 0, 2}, {-1, 2}},\\r\\\
		[\\\"30\\\"] = {{ 0, 0}, {-1, 0}, {-1,-1}, { 0, 2}, {-1, 2}},\\r\\\
		[\\\"03\\\"] = {{ 0, 0}, { 1, 0}, { 1, 1}, { 0,-2}, { 1,-2}},\\r\\\
		[\\\"02\\\"] = {{ 0, 0}, { 0, 1}, { 1, 1}, {-1, 1}, { 1, 0}, {-1, 0}},\\r\\\
		[\\\"13\\\"] = {{ 0, 0}, { 1, 0}, { 1, 2}, { 1, 1}, { 0, 2}, { 0, 1}},\\r\\\
		[\\\"20\\\"] = {{ 0, 0}, { 0,-1}, {-1,-1}, { 1,-1}, {-1, 0}, { 1, 0}},\\r\\\
		[\\\"31\\\"] = {{ 0, 0}, {-1, 0}, {-1, 2}, {-1, 1}, { 0, 2}, { 0, 1}}\\r\\\
	},\\r\\\
	\\r\\\
	[2] = {	-- used on I tetraminos\\r\\\
		[\\\"01\\\"] = {{ 0, 0}, {-2, 0}, { 1, 0}, {-2,-1}, { 1, 2}},\\r\\\
		[\\\"10\\\"] = {{ 0, 0}, { 2, 0}, {-1, 0}, { 2, 1}, {-1,-2}},\\r\\\
		[\\\"12\\\"] = {{ 0, 0}, {-1, 0}, { 2, 0}, {-1, 2}, { 2,-1}},\\r\\\
		[\\\"21\\\"] = {{ 0, 0}, { 1, 0}, {-2, 0}, { 1,-2}, {-2, 1}},\\r\\\
		[\\\"23\\\"] = {{ 0, 0}, { 2, 0}, {-1, 0}, { 2, 1}, {-1,-2}},\\r\\\
		[\\\"32\\\"] = {{ 0, 0}, {-2, 0}, { 1, 0}, {-2,-1}, { 1, 2}},\\r\\\
		[\\\"30\\\"] = {{ 0, 0}, { 1, 0}, {-2, 0}, { 1,-2}, {-2, 1}},\\r\\\
		[\\\"03\\\"] = {{ 0, 0}, {-1, 0}, { 2, 0}, {-1, 2}, { 2,-1}},\\r\\\
		[\\\"02\\\"] = {{ 0, 0}},\\r\\\
		[\\\"13\\\"] = {{ 0, 0}},\\r\\\
		[\\\"20\\\"] = {{ 0, 0}},\\r\\\
		[\\\"31\\\"] = {{ 0, 0}}\\r\\\
	}\\r\\\
}\\r\\\
\\r\\\
return kicktables\",\
    [ \"sound/mino_T.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000`\\000\\000\\000\\000\\000\\000UµEvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000`\\000\\000\\000\\000\\000í')iDÿÿÿÿÿÿÿÿÿÿÿÿvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000 \\\
ÆÐU\\000\\000\\000\\000BFÆP§GÄPóPjé xJaÉôkBß{Ï½÷Þ{ 4d\\000\\000\\000@bà1	B¡Å	Q)Ba9	r:	B÷ .çÞrî½÷\\rY\\000\\000\\0000!B!B\\\
)¥R)¦bÊ1ÇsÌ1È :è¤N2©¤2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊc1Æc1Æc1ÆBCV\\000 \\000\\000AdB!R)¦sÌ1ÇÐU\\000\\000 \\000\\000\\000\\000\\000GÉÉ$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û}ÛwuÙ·}ÙvuYeYwm[uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9#)¬\\000d\\000\\000\\000à(â8#9cI¤IåYåi&j¢¬\\000\\000\\000\\000\\000\\000\\000\\000 (â(#I¥iç©(¦ªª¢iªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i@hÈ*\\000@\\000@ÇqÇQÇqÉ$	\\rY\\000È\\000\\000\\000ÀPGË±$ÍÒ,Ïò4Ñ3=WMÝÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓÐU\\000\\000\\000\\000 B1 4d\\000\\000\\000¢1Ô)%Á¥`!Ä1Ô!ä<Z:RX2&=ÅÂ÷Þsï½÷\\rY\\000\\000\\000FxLB(FqBg\\\
BXN¥NÐ=!Ë¹·{ï½BCV\\000\\000\\000B!B!BJ)b)¦rÌ1Çs2È :é¤L*é¤£L2ê(µRK1Å[n1ÖZkÍ9÷2Æc1Æc1Æc1ÐU\\000\\000\\000\\000aABH!b)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I,É4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeÝÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäH¤\\000¡!«\\000\\000\\000\\000\\0008£8äHåX%ifygy§è¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(¢8ãHeiæyª'¢©ªªhªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i&²\\\
\\000\\000\\000ÐqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç<É³<Çs<É4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000 Ç´$	 äÄÄ¤ ä:%Åä!§ bä9ÉAäÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥9ç¤tR¡¥Rg©´ZbÌ(ÚR­\\rRH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,BCV\\000Q\\000\\0001H)¤b9ÈD1èd1!sNAÇT*uPRÃsA¨ T:GPRG\\000\\000\\000\\000\\000¡Ð@\\000A4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUÝvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×eÓumÙue[WeYø5UeÓumÙt]ÙveW·UYÖmÑu}]eá7eÙ÷e[×}Y·at]ÛWeY÷MY~ÙÝÕu_DQU=U]QU]×t][W]×¶5Õ]ÓumÙT]YVeY÷]WÖuMUeÙeÛ6]WUYöuWu[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}Uu_ÖuauÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_máXeÙøuá[×ßs]_WmÙVÙ6Ý÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^Ý6êÆO¸ß¨©ª¯®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VYÕaÖuaÙa©Úº2¼ºo¯­+ÃíßWªmË«ÛÂ0û¶ðÛÂo»±3\\000\\0008\\000\\000P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEUeÕeYu]]MÓEÕteÓT]Yu]WV]W%M3MÍóLSó<Ó4UÓMSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓMSeÓUmÙUeW]Ù¶MUeS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨²kªl«ªª»²kë¾,Ë¶,ªªë®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï¦,ª)Û¦ªÊ²,»¶mË²/¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À\\000@	e Ð\\000@\\000\\000`cAhrÎ9RÎ9!sB©dÎA¡¤Ì9¥¤9¡B¥¤ÔZ¡Z+\\000\\000 À\\000 ÀMÅ\\\
\\rY	\\000¤\\000GÓLÓueÙËEUeÛ6Å²DQUeÙ¶cEUeÛÖu4QTUY¶mÝWSUeÙ¶}]82UUm[×}#Um[×¡*Ë¶më¾QI¶m]7ã¨$Û¶îû¾q,ñ¡°,ð_8*\\000\\000ð\\000 VG8),4d%\\000\\000\\000¤QJ)£RJ)ÆR	\\000\\000p\\000\\0000¡²\\\"\\000\\000\\000sÎ9çsÎ9çsÎ9çsÎ9çc1Æc1Æc1Æc1Æc1Æc1Æ\\000ìD8\\000ìDX¬\\000Â\\000\\000R)¥9ç¤RJ)¥ÈA¥RJ)¥DÒI)¥RJ)¥qPJ)¥RJ)¡RJ)¥RJ	¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ\\000&\\000P	6Î°tV8\\\\hÈJ\\000 7\\000\\000P9Æ$JH%JåÎI	)µVB\\\
­\\\
:h£RK­JIB(¡RZ)%µR2¡PJ!¥RJ	¡ePB\\\
%RI-´TJÉ PZ	©ÔZ\\\
%A)©R*­µJJ­ÒR)­µÖJJ!R¥¤R)¥µJk­µNR)-¤ÖRk­VJ)¥JI­µZk)¥VB)­´ÒZ)%µÖRk-ÔZK­¥ÖRk­¥ÖJ)%¥Zk­µZ*)µB)¥Bj©¥ÖJ*-ÐRI¥VZk)¥J(%Z*©µRh¥ÒJI%¥J*)¥ÔR*¡R*¡ÔRk©¥J*-µÔR+©JJ©\\000\\000tà\\000\\000`D¥ØiÆGàB	(\\000\\000\\000@ \\000\\\
d\\000ÀB\\000PX`(]è\\\"HA\\\\8qãNèÐ\\000\\000¡\\\"$dÀEt\\000°¸À(]è\\\"HA\\\\8qãNèÐ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\ÆGÇH\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000OggS\\000g!\\000\\000\\000\\000\\000\\000`\\000\\000\\000\\000\\000>63dOEbHH]HKBDG7BD6@SRÄë´ø[Õ\\\
?@.èz:,1ÝøOýºÓUÀºSS1Ëz>Þ!¶ï²Uôß7HÀY?EÛ(aþZÕ½;sUüßÆE¬¦!X\\r\\\\Êâ«¬=`\\000j£Êßò\\\
l&¹°î«!À@\\000\\000¦=°\\000@\\000(GmbkA!Ñ`ÿUÀo\\000ï\\000|@ïz´@o0<¦	E3pA\\000n«&óë7$Ôm.@Eº\\0008¶0Ta¥ú.ú°¦Ï\\\
*\\\
08ôD4ÄðC¥\\\
äÃ\\000VÒ«Ç_Oó\\000uvÂ«ØWèLºvjÝ®§ùÝ&tëZaê9rjÓë±8Ê¦°Ã¹õ×\\000Ü÷Lì±ØpÂ°\\\
ÞÚniW/!¾»a=8þ6U \\0003Ùy´\\000n©D¯Ì¹³æÚ s@. ß ôÖ«À¼·û\\r\\000\\\\	 ¤Âµp Z{¢&P$øÂ(wÐ`®f©Û¯W$ÕyÇ\\000Þÿï|\\000ÀÃÜ¶ºLj7Â\\000iR®â ëàt#\\000;¸\\000,àÍ ¼Y¦èrn	V¥+:@) )_ .Þ´	¨´ÖÊM¾Õç¿÷ïW:®H`n[$µuoÿð9DC\\rf\\rÜ>Ý4@¶}bíXÙ\\000ÜÐQ_RtÈðÄ Üø`ÁVv n­uLØTz2QÔ@§\\000\\000.\\000ÀmÆr|\\\
\\000¸\\000¿äP\\000×\\000\\000Á¬¾À|¤.	Wc\\\
`;:\\000j­}/*=%qv+\\000¸Ð\\000-ÀMav¶5õÏc\\000ª\\rØgÐ\\000ìS\\000°52·àNð\\\
HBJäyK²A¶è(OLCNd=På~=7Î\\000D§gU¶N`_OXI.WìÀXGCb¶;U&5((*\\000&ÚRuæ3=Q[útc¨jbÖÔn·/á| *ð1k	\\000|èïð(ï8àl1Ñ@4 &|`\\0004R/_,ñG³Bµ ¬Ù+Ýme­4ïocë'®»åõûlS¸r\\000à¬p-\\000'éìo-íp PÁ`	+±p\\\".$Ûß¯h$*x¸±®(Ë\\000CZÒ\\\
\\0000ðM¡@ØL÷44	~\\000\\\"qý&Øq« É·UëfºÝÖÉº&þMº\\000ø,áf®+,FöchNJ.p Ð+H3+Øø*TóPTäN\\000X0 ºUfùý¶¨µea2Ë6|@ÐGÀ¶Ð|pãe/lOÅ\\\
è\\00065>|L õ\\000PÄN5P¤$ÑG\\000\\r\\000üp¾\\000?\\000<|@ù	4À£\\000&ð¼6¡Y\\\\]¾Üþ\\000 C#¹ëû¸òïoÖìE\\000=w~5(=íÌ( \\\
\\\
Û1:\\000aí¸Etñ7Îc!_ÿ_áü~5ÖÃæqD-°ú@OÃ@Õ_:`·\\000°´lóë*¼ÉQxÛç,2saQÏx`fý´æª \",\
    [ \"backup/lib/gameconfig.lua\" ] = \"return {\\r\\\
	minos = {},					-- list of all the minos (pieces) that will spawn into the board (populated from /lib/minodata.lua)\\r\\\
	kickTables = {},			-- list of all kick tables for pieces (populated from /lib/kicktables.lua)\\r\\\
	lock_delay = 0.5,			-- (Lock Delay) amount of seconds it will take for a resting mino to lock into placed\\r\\\
	currentKickTable = \\\"SRS\\\",	-- current kick table\\r\\\
	randomBag = \\\"singlebag\\\",	-- current pseudorandom number generator\\r\\\
								-- \\\"singlebag\\\" = normal tetris guideline random\\r\\\
								-- \\\"doublebag\\\" = doubled bag size\\r\\\
								-- \\\"random\\\" = using math.random\\r\\\
	board_width = 10,			-- width of play area\\r\\\
	board_height = 40,			-- height of play area\\r\\\
	board_height_visible = 20,	-- height of play area that will render on screen (anchored to bottom)\\r\\\
	spin_mode = 1,				-- 1 = allows T-spins\\r\\\
								-- 2 = allows J/L-spins\\r\\\
								-- 3 = allows ALL SPINS! Similar to STUPID mode in tetr.io\\r\\\
	can_rotate = true,			-- if false, will disallow ALL piece rotation (meme mode)\\r\\\
	startingGravity = 0.15,		-- gravity per tick for minos\\r\\\
	lock_move_limit = 30,		-- amount of moves a mino can do after descending below its lowest point yet traversed\\r\\\
								-- used as a method of preventing stalling -- set it to math.huge for infinite\\r\\\
}\",\
    [ \"lib/minodata.lua\" ] = \"return {\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\"    \\\",\\r\\\
			\\\"@@@@\\\",\\r\\\
			\\\"    \\\",\\r\\\
			\\\"    \\\",\\r\\\
		},\\r\\\
		spinID = 3,\\r\\\
		color = \\\"3\\\",\\r\\\
		name = \\\"I\\\",\\r\\\
		kickID = 2,\\r\\\
		sound = \\\"mino_I.ogg\\\"\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\" @ \\\",\\r\\\
			\\\"@@@\\\",\\r\\\
			\\\"    \\\",\\r\\\
		},\\r\\\
		spinID = 1,\\r\\\
		color = \\\"a\\\",\\r\\\
		name = \\\"I\\\",\\r\\\
		kickID = 1,\\r\\\
		sound = \\\"mino_T.ogg\\\"\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\"  @\\\",\\r\\\
			\\\"@@@\\\",\\r\\\
			\\\"   \\\",\\r\\\
		},\\r\\\
		spinID = 2,\\r\\\
		color = \\\"1\\\",\\r\\\
		name = \\\"L\\\",\\r\\\
		kickID = 1,\\r\\\
		sound = \\\"mino_L.ogg\\\"\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\"@  \\\",\\r\\\
			\\\"@@@\\\",\\r\\\
			\\\"   \\\",\\r\\\
		},\\r\\\
		spinID = 2,\\r\\\
		color = \\\"b\\\",\\r\\\
		name = \\\"J\\\",\\r\\\
		kickID = 1,\\r\\\
		sound = \\\"mino_J.ogg\\\"\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\"@@\\\",\\r\\\
			\\\"@@\\\",\\r\\\
		},\\r\\\
		spinID = 3,\\r\\\
		color = \\\"4\\\",\\r\\\
		name = \\\"O\\\",\\r\\\
		kickID = 2,\\r\\\
		sound = \\\"mino_O.ogg\\\",\\r\\\
		spawnOffsetX = 1,\\r\\\
		noDelayLock = true\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\" @@\\\",\\r\\\
			\\\"@@ \\\",\\r\\\
			\\\"   \\\",\\r\\\
		},\\r\\\
		spinID = 2,\\r\\\
		color = \\\"5\\\",\\r\\\
		name = \\\"S\\\",\\r\\\
		kickID = 1,\\r\\\
		sound = \\\"mino_S.ogg\\\"\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\"@@ \\\",\\r\\\
			\\\" @@\\\",\\r\\\
			\\\"   \\\",\\r\\\
		},\\r\\\
		spinID = 2,\\r\\\
		color = \\\"e\\\",\\r\\\
		name = \\\"Z\\\",\\r\\\
		kickID = 1,\\r\\\
		sound = \\\"mino_Z.ogg\\\"\\r\\\
	}\\r\\\
}\",\
    [ \"sound/mino_S.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000Ë_\\000\\000\\000\\000\\000\\000£Lfúvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000Ë_\\000\\000\\000\\000\\000uDÿÿÿÿÿÿÿÿÿÿÿÿvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000 \\\
ÆÐU\\000\\000\\000\\000BFÆP§GÄPóPjé xJaÉôkBß{Ï½÷Þ{ 4d\\000\\000\\000@bà1	B¡Å	Q)Ba9	r:	B÷ .çÞrî½÷\\rY\\000\\000\\0000!B!B\\\
)¥R)¦bÊ1ÇsÌ1È :è¤N2©¤2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊc1Æc1Æc1ÆBCV\\000 \\000\\000AdB!R)¦sÌ1ÇÐU\\000\\000 \\000\\000\\000\\000\\000GÉÉ$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û}ÛwuÙ·}ÙvuYeYwm[uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9#)¬\\000d\\000\\000\\000à(â8#9cI¤IåYåi&j¢¬\\000\\000\\000\\000\\000\\000\\000\\000 (â(#I¥iç©(¦ªª¢iªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i@hÈ*\\000@\\000@ÇqÇQÇqÉ$	\\rY\\000È\\000\\000\\000ÀPGË±$ÍÒ,Ïò4Ñ3=WMÝÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓÐU\\000\\000\\000\\000 B1 4d\\000\\000\\000¢1Ô)%Á¥`!Ä1Ô!ä<Z:RX2&=ÅÂ÷Þsï½÷\\rY\\000\\000\\000FxLB(FqBg\\\
BXN¥NÐ=!Ë¹·{ï½BCV\\000\\000\\000B!B!BJ)b)¦rÌ1Çs2È :é¤L*é¤£L2ê(µRK1Å[n1ÖZkÍ9÷2Æc1Æc1Æc1ÐU\\000\\000\\000\\000aABH!b)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I,É4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeÝÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäH¤\\000¡!«\\000\\000\\000\\000\\0008£8äHåX%ifygy§è¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(¢8ãHeiæyª'¢©ªªhªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i&²\\\
\\000\\000\\000ÐqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç<É³<Çs<É4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000 Ç´$	 äÄÄ¤ ä:%Åä!§ bä9ÉAäÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥9ç¤tR¡¥Rg©´ZbÌ(ÚR­\\rRH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,BCV\\000Q\\000\\0001H)¤b9ÈD1èd1!sNAÇT*uPRÃsA¨ T:GPRG\\000\\000\\000\\000\\000¡Ð@\\000A4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUÝvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×eÓumÙue[WeYø5UeÓumÙt]ÙveW·UYÖmÑu}]eá7eÙ÷e[×}Y·at]ÛWeY÷MY~ÙÝÕu_DQU=U]QU]×t][W]×¶5Õ]ÓumÙT]YVeY÷]WÖuMUeÙeÛ6]WUYöuWu[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}Uu_ÖuauÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_máXeÙøuá[×ßs]_WmÙVÙ6Ý÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^Ý6êÆO¸ß¨©ª¯®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VYÕaÖuaÙa©Úº2¼ºo¯­+ÃíßWªmË«ÛÂ0û¶ðÛÂo»±3\\000\\0008\\000\\000P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEUeÕeYu]]MÓEÕteÓT]Yu]WV]W%M3MÍóLSó<Ó4UÓMSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓMSeÓUmÙUeW]Ù¶MUeS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨²kªl«ªª»²kë¾,Ë¶,ªªë®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï¦,ª)Û¦ªÊ²,»¶mË²/¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À\\000@	e Ð\\000@\\000\\000`cAhrÎ9RÎ9!sB©dÎA¡¤Ì9¥¤9¡B¥¤ÔZ¡Z+\\000\\000 À\\000 ÀMÅ\\\
\\rY	\\000¤\\000GÓLÓueÙËEUeÛ6Å²DQUeÙ¶cEUeÛÖu4QTUY¶mÝWSUeÙ¶}]82UUm[×}#Um[×¡*Ë¶më¾QI¶m]7ã¨$Û¶îû¾q,ñ¡°,ð_8*\\000\\000ð\\000 VG8),4d%\\000\\000\\000¤QJ)£RJ)ÆR	\\000\\000p\\000\\0000¡²\\\"\\000\\000\\000sÎ9çsÎ9çsÎ9çsÎ9çc1Æc1Æc1Æc1Æc1Æc1Æ\\000ìD8\\000ìDX¬\\000Â\\000\\000R)¥9ç¤RJ)¥ÈA¥RJ)¥DÒI)¥RJ)¥qPJ)¥RJ)¡RJ)¥RJ	¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ\\000&\\000P	6Î°tV8\\\\hÈJ\\000 7\\000\\000P9Æ$JH%JåÎI	)µVB\\\
­\\\
:h£RK­JIB(¡RZ)%µR2¡PJ!¥RJ	¡ePB\\\
%RI-´TJÉ PZ	©ÔZ\\\
%A)©R*­µJJ­ÒR)­µÖJJ!R¥¤R)¥µJk­µNR)-¤ÖRk­VJ)¥JI­µZk)¥VB)­´ÒZ)%µÖRk-ÔZK­¥ÖRk­¥ÖJ)%¥Zk­µZ*)µB)¥Bj©¥ÖJ*-ÐRI¥VZk)¥J(%Z*©µRh¥ÒJI%¥J*)¥ÔR*¡R*¡ÔRk©¥J*-µÔR+©JJ©\\000\\000tà\\000\\000`D¥ØiÆGàB	(\\000\\000\\000@ \\000\\\
d\\000ÀB\\000PX`(]è\\\"HA\\\\8qãNèÐ\\000\\000¡\\\"$dÀEt\\000°¸À(]è\\\"HA\\\\8qãNèÐ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\ÆGÇH\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000OggS\\000)\\000\\000\\000\\000\\000\\000Ë_\\000\\000\\000\\000\\000°$bI1F5F5G=D5A5-689<2:5+1^Ûëi»©Ì'jçj7cO7g7Ï¯_ÞÝcU¹\\\\Ø?J¥\\000àEe\\000_giG`?úÒ	ÀÞà\\000z§¥ïÙv#µ7`Ú\\000T¶*H\\000`kp\\000\\000x*b\\000¼Ðê\\000¬à'\\000\\000\\000Øn«Iëu±nÊë÷ô \\000¢ÆÖH|	\\0009ÆïþæßÇx¡jÔÁ¤¯g¥\\000Þ\\000oxv\\000ðCÒ\\000T\\000WìÍu\\000n¥µ:þjÍïªY_\\rm4\\0000H	öÀ»aÇ\\000PG\\000@|+\\000¼x8\\000f­«áxÝiùrDwÚ\\\
j¨ÊÚ´ÿÛs=^¨xPuyìµë7{¨úñÁ&ôñ°%\\000<KB9@vu\\000z«+I÷Órci*\\000DdU«,»å\\000D±ñ@¼Àãÿx	\\000­\\000	À4\\000r­Û­ìÇÕÍ&öN\\000@Ré¹ £Òr}·l¿ý¾c[\\000 ÅÈþ\\000\\000NÿUM`ö	ß\\\\@ cÆL\\000Þq¬\\000j¥9¾èãZ$GR3Õ\\000uq\\000ÎZ1Y\\0003ö2L\\0000ðiÂµ@Ðßa jÀb\\000^§=vßÒZÞ>¡j{êâÝÅiøýç×ÃÔ`}	ÿåT*Fà¢Ëð\\0002À@\\\\ÀÒ`ûtÐ\\000n§µ;þ0>j¦_U³ßD5\\000`\\000ûf\\000ð5øK\\000:à[°Ð(à\\000°.\\000^³ýp|×4~òC!s\\\
 \\000¦hPeéÒ®K&\\000\\0001L§ÿÀz\\\
à#\\000`\\000[ÛO¢\\000RÌ´\\000>û	b¯}×®xÄWo¹\\\"9\\000 ¬r¶\\000\\000Öé\\000¼,\\000N?\\000\\000°£À\\0004\\\\\\r\\000\\000fµ½²?u´÷J}Û;ª44¶¨¬r\\000ÿ\\\
\\000£\\000ÀÀ.\\000 W\\000ï\\000*òøCS¶êX¿íÓ¹¨q«C2ö·c½\\000\\rðãà{\\000\\000\\r¾M.\\000$v}«¡ýò8gUªåü%Øb¬Y`Ï«÷öÎ;_¾ï!\\000¼û6ð(`1¾\\000 \\000¾\\000r\\000{SÑº~Ìn×chÍ Nðz°®hº~·>1¥Ù(DH½%ª8¥F	¼ÑUàÐà\\000ylg°uâ¶êÎ·@a±¶e8ûmOX*?_Ëî·À#YeL@v\\000°@ÀÆ\\000Â>\\000y9®í·¢CÍRm¿S©	æ²ó°Pz÷\\000¼\\000N.`00Ø*\\000{9þÞ<®MÌûj+}¨¤{\\000º?Ròü|u\\000J	\\000 á\\000'9&@ðØ»Ã\\000	Ø\\r\\000ýõñT-§ }PùMl4Ì&aÂó«ÐQ:ÓÈ\\000\\000`:@à\\000>ðU4À>\\000uÿti~S.ñÖâ=44-*c½w\\000úh\\000\\000¿M\\000\\0004\\000zqx×Ò»ÊVÛïy¨,,*cÛæÓ,~¡ðCàýb\\000\\0007.~Ú<\\000|`\",\
    [ \"lib/control.lua\" ] = \"local ControlAPI = {}\\\
\\\
local gameConfig = require \\\"lib.gameconfig\\\"\\\
\\\
function ControlAPI:New(clientConfig, native_control)\\\
	local control = setmetatable({}, self)\\\
	self.__index = self\\\
	\\\
	control.keysDown = {}\\\
	control.controlsDown = {}\\\
	control.antiControlRepeat = {}\\\
	control.clientConfig = clientConfig\\\
	control.native_control = native_control\\\
	\\\
	return control\\\
end\\\
\\\
function ControlAPI:Clear()\\\
	self.keysDown = {}\\\
	self.controlsDown = {}\\\
end\\\
\\\
function ControlAPI:CheckControl(controlName, repeatTime, repeatDelay)\\\
	repeatDelay = repeatDelay or 1\\\
	\\\
	local clientConfig = self.clientConfig\\\
	\\\
	if self.native_control then\\\
		-- populate self.controlsDown based on self.keysDown\\\
		for name, _key in pairs(clientConfig.controls) do\\\
			self.controlsDown[name] = self.keysDown[_key]\\\
		end\\\
	end\\\
	\\\
	if self.controlsDown[controlName] then\\\
		if not self.antiControlRepeat[controlName] then\\\
			if repeatTime then\\\
				return 	self.controlsDown[controlName] == 1 or\\\
						(\\\
							self.controlsDown[controlName] >= (repeatTime * (1 / gameConfig.tickDelay)) and (\\\
								repeatDelay and ((self.controlsDown[controlName] * gameConfig.tickDelay) % repeatDelay == 0) or true\\\
							)\\\
						)\\\
			else\\\
				return self.controlsDown[controlName] == 1\\\
			end\\\
		end\\\
	else\\\
		return false\\\
	end\\\
	\\\
end\\\
\\\
return ControlAPI\\\
\",\
    [ \"sound/mino_L.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000Û]\\000\\000\\000\\000\\000\\000Q/¨vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000Û]\\000\\000\\000\\000\\000*5!Dÿÿÿÿÿÿÿÿÿÿÿÿvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000 \\\
ÆÐU\\000\\000\\000\\000BFÆP§GÄPóPjé xJaÉôkBß{Ï½÷Þ{ 4d\\000\\000\\000@bà1	B¡Å	Q)Ba9	r:	B÷ .çÞrî½÷\\rY\\000\\000\\0000!B!B\\\
)¥R)¦bÊ1ÇsÌ1È :è¤N2©¤2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊc1Æc1Æc1ÆBCV\\000 \\000\\000AdB!R)¦sÌ1ÇÐU\\000\\000 \\000\\000\\000\\000\\000GÉÉ$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û}ÛwuÙ·}ÙvuYeYwm[uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9#)¬\\000d\\000\\000\\000à(â8#9cI¤IåYåi&j¢¬\\000\\000\\000\\000\\000\\000\\000\\000 (â(#I¥iç©(¦ªª¢iªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i@hÈ*\\000@\\000@ÇqÇQÇqÉ$	\\rY\\000È\\000\\000\\000ÀPGË±$ÍÒ,Ïò4Ñ3=WMÝÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓÐU\\000\\000\\000\\000 B1 4d\\000\\000\\000¢1Ô)%Á¥`!Ä1Ô!ä<Z:RX2&=ÅÂ÷Þsï½÷\\rY\\000\\000\\000FxLB(FqBg\\\
BXN¥NÐ=!Ë¹·{ï½BCV\\000\\000\\000B!B!BJ)b)¦rÌ1Çs2È :é¤L*é¤£L2ê(µRK1Å[n1ÖZkÍ9÷2Æc1Æc1Æc1ÐU\\000\\000\\000\\000aABH!b)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I,É4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeÝÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäH¤\\000¡!«\\000\\000\\000\\000\\0008£8äHåX%ifygy§è¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(¢8ãHeiæyª'¢©ªªhªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i&²\\\
\\000\\000\\000ÐqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç<É³<Çs<É4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000 Ç´$	 äÄÄ¤ ä:%Åä!§ bä9ÉAäÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥9ç¤tR¡¥Rg©´ZbÌ(ÚR­\\rRH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,BCV\\000Q\\000\\0001H)¤b9ÈD1èd1!sNAÇT*uPRÃsA¨ T:GPRG\\000\\000\\000\\000\\000¡Ð@\\000A4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUÝvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×eÓumÙue[WeYø5UeÓumÙt]ÙveW·UYÖmÑu}]eá7eÙ÷e[×}Y·at]ÛWeY÷MY~ÙÝÕu_DQU=U]QU]×t][W]×¶5Õ]ÓumÙT]YVeY÷]WÖuMUeÙeÛ6]WUYöuWu[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}Uu_ÖuauÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_máXeÙøuá[×ßs]_WmÙVÙ6Ý÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^Ý6êÆO¸ß¨©ª¯®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VYÕaÖuaÙa©Úº2¼ºo¯­+ÃíßWªmË«ÛÂ0û¶ðÛÂo»±3\\000\\0008\\000\\000P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEUeÕeYu]]MÓEÕteÓT]Yu]WV]W%M3MÍóLSó<Ó4UÓMSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓMSeÓUmÙUeW]Ù¶MUeS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨²kªl«ªª»²kë¾,Ë¶,ªªë®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï¦,ª)Û¦ªÊ²,»¶mË²/¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À\\000@	e Ð\\000@\\000\\000`cAhrÎ9RÎ9!sB©dÎA¡¤Ì9¥¤9¡B¥¤ÔZ¡Z+\\000\\000 À\\000 ÀMÅ\\\
\\rY	\\000¤\\000GÓLÓueÙËEUeÛ6Å²DQUeÙ¶cEUeÛÖu4QTUY¶mÝWSUeÙ¶}]82UUm[×}#Um[×¡*Ë¶më¾QI¶m]7ã¨$Û¶îû¾q,ñ¡°,ð_8*\\000\\000ð\\000 VG8),4d%\\000\\000\\000¤QJ)£RJ)ÆR	\\000\\000p\\000\\0000¡²\\\"\\000\\000\\000sÎ9çsÎ9çsÎ9çsÎ9çc1Æc1Æc1Æc1Æc1Æc1Æ\\000ìD8\\000ìDX¬\\000Â\\000\\000R)¥9ç¤RJ)¥ÈA¥RJ)¥DÒI)¥RJ)¥qPJ)¥RJ)¡RJ)¥RJ	¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ\\000&\\000P	6Î°tV8\\\\hÈJ\\000 7\\000\\000P9Æ$JH%JåÎI	)µVB\\\
­\\\
:h£RK­JIB(¡RZ)%µR2¡PJ!¥RJ	¡ePB\\\
%RI-´TJÉ PZ	©ÔZ\\\
%A)©R*­µJJ­ÒR)­µÖJJ!R¥¤R)¥µJk­µNR)-¤ÖRk­VJ)¥JI­µZk)¥VB)­´ÒZ)%µÖRk-ÔZK­¥ÖRk­¥ÖJ)%¥Zk­µZ*)µB)¥Bj©¥ÖJ*-ÐRI¥VZk)¥J(%Z*©µRh¥ÒJI%¥J*)¥ÔR*¡R*¡ÔRk©¥J*-µÔR+©JJ©\\000\\000tà\\000\\000`D¥ØiÆGàB	(\\000\\000\\000@ \\000\\\
d\\000ÀB\\000PX`(]è\\\"HA\\\\8qãNèÐ\\000\\000¡\\\"$dÀEt\\000°¸À(]è\\\"HA\\\\8qãNèÐ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\ÆGÇH\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000OggS\\000¢%\\000\\000\\000\\000\\000\\000Û]\\000\\000\\000\\000\\000ìUØ`//.F;.07JbQ/14M6+-RcÅè¤j+±ã­¯\\\"~ªiÖßýüÊ¯úGF.ÑÀ¬ý[]Ñ]r.iXÂ[¥®}¯É¸ÚÄ¢UvüLI³ùasØ*½#öçÖH\\rLvo¤d¦¦ÜÐ	 ï2^0·d\\000\\000ß÷åóÏëG¼NpC\\000À@°K\\000ìro¨Ä¬©©Å§%wt¼ÿ¦oÐV\\000\\000Y\\000?àõ\\000¾à \\\
¸)vo¤$³¦¦¿=¹£¼ÿ¢[¹\\000CÄäY`pÿ§ \\000§\\000¼joÒ8`ÉI1,J°RE(]¡R¬ËRÏ³¤õÍ÷<rSÍoë1Ð\\\"áOHÖ5	ÀhÀ:à=<Ï$0@\\000^q<øÍël°²f5»»\\000TFDýIìði§\\000£èóYJú|è/`\\000 @ï ¸*\\000rq(´ýÑñúl(s°;\\000à¨3¾«`¾Ð÷ÀH\\000\\000{	À²\\000Ì\\000^mà:ðþD7ÄèKÒ`g\\000­fÝ¹'$p{\\000°Ä^\\000ì\\000Æ\\000l	\\000xL\\000&MÄ¹ªIî¸âc@][WË Hm:/¥ç\\rÀt7Ðg	À`Ø.Â{.pØ\\0000é\\000E·Æ¨ÕÞ[Ò\\0005oª¢,õËõøû6ËÙ+URL-bGü2XæÂé,YSh ÊF½1ûpö©{m.ëT]\\000El µ¡ú¬ð¢úýuñþÂª_]þæ©ÏtÝK[íç¿/þËi2Aãþ'?~ÏÔÿä§¸òT®Nv\\r?	Ì/6ªâÈ'»`Z·\\\\jm¡{D£6þ\\000Gyð¢RèMÜøÃoYm+ÓÎ-»úYùm·¨¹b1eôñ±0òf(9rà%*RâoSÃüf@Wx»­tz9[Jãð`b6\\000*KÐ0eòÀ47~¾k:Xd\\000àyþª\\000ú\\000 \\000àª\\000¾\\000°L\\000*IÐ*âT¦¹è»bÁ\\\\\\\
!ðÌ«ú\\000@ö!\\000O@\\\\Ðy\\000QÀ7Ðt\\000&IÐÄ0e<}Ú9ôJ@^2B½Çþyï@óy\\000J\\000ÀE=°\\000GÖøÖ\\\"~À3½Z4Kµé»mÝº5S;ILOvÐÏÐ4ÉSÜ]iiâQ:ÎxE)ø@×Ù8P: àÑK45KàñÄè»@Ù\\000@=M»Åyþ	:G\\000Çà@ÌP°(â\\\
)\\000EUýOC|ôJ ;\\000ç\\\\£í\\000{9à\\000¼\\000î \\000Ë o EiªÆ(û§!yÞ40&\\000035K÷\\000v×jñK\\000xÀ¯ÑI¿Ä\\000\\\" ®!\\000\\000À,µnÝÀºõq\",\
    [ \"sound/mino_I.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000/Y\\000\\000\\000\\000\\000\\0008ðvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000/Y\\000\\000\\000\\000\\000©úrDÿÿÿÿÿÿÿÿÿÿÿÿvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000 \\\
ÆÐU\\000\\000\\000\\000BFÆP§GÄPóPjé xJaÉôkBß{Ï½÷Þ{ 4d\\000\\000\\000@bà1	B¡Å	Q)Ba9	r:	B÷ .çÞrî½÷\\rY\\000\\000\\0000!B!B\\\
)¥R)¦bÊ1ÇsÌ1È :è¤N2©¤2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊc1Æc1Æc1ÆBCV\\000 \\000\\000AdB!R)¦sÌ1ÇÐU\\000\\000 \\000\\000\\000\\000\\000GÉÉ$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û}ÛwuÙ·}ÙvuYeYwm[uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9#)¬\\000d\\000\\000\\000à(â8#9cI¤IåYåi&j¢¬\\000\\000\\000\\000\\000\\000\\000\\000 (â(#I¥iç©(¦ªª¢iªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i@hÈ*\\000@\\000@ÇqÇQÇqÉ$	\\rY\\000È\\000\\000\\000ÀPGË±$ÍÒ,Ïò4Ñ3=WMÝÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓÐU\\000\\000\\000\\000 B1 4d\\000\\000\\000¢1Ô)%Á¥`!Ä1Ô!ä<Z:RX2&=ÅÂ÷Þsï½÷\\rY\\000\\000\\000FxLB(FqBg\\\
BXN¥NÐ=!Ë¹·{ï½BCV\\000\\000\\000B!B!BJ)b)¦rÌ1Çs2È :é¤L*é¤£L2ê(µRK1Å[n1ÖZkÍ9÷2Æc1Æc1Æc1ÐU\\000\\000\\000\\000aABH!b)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I,É4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeÝÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäH¤\\000¡!«\\000\\000\\000\\000\\0008£8äHåX%ifygy§è¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(¢8ãHeiæyª'¢©ªªhªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i&²\\\
\\000\\000\\000ÐqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç<É³<Çs<É4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000 Ç´$	 äÄÄ¤ ä:%Åä!§ bä9ÉAäÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥9ç¤tR¡¥Rg©´ZbÌ(ÚR­\\rRH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,BCV\\000Q\\000\\0001H)¤b9ÈD1èd1!sNAÇT*uPRÃsA¨ T:GPRG\\000\\000\\000\\000\\000¡Ð@\\000A4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUÝvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×eÓumÙue[WeYø5UeÓumÙt]ÙveW·UYÖmÑu}]eá7eÙ÷e[×}Y·at]ÛWeY÷MY~ÙÝÕu_DQU=U]QU]×t][W]×¶5Õ]ÓumÙT]YVeY÷]WÖuMUeÙeÛ6]WUYöuWu[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}Uu_ÖuauÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_máXeÙøuá[×ßs]_WmÙVÙ6Ý÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^Ý6êÆO¸ß¨©ª¯®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VYÕaÖuaÙa©Úº2¼ºo¯­+ÃíßWªmË«ÛÂ0û¶ðÛÂo»±3\\000\\0008\\000\\000P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEUeÕeYu]]MÓEÕteÓT]Yu]WV]W%M3MÍóLSó<Ó4UÓMSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓMSeÓUmÙUeW]Ù¶MUeS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨²kªl«ªª»²kë¾,Ë¶,ªªë®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï¦,ª)Û¦ªÊ²,»¶mË²/¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À\\000@	e Ð\\000@\\000\\000`cAhrÎ9RÎ9!sB©dÎA¡¤Ì9¥¤9¡B¥¤ÔZ¡Z+\\000\\000 À\\000 ÀMÅ\\\
\\rY	\\000¤\\000GÓLÓueÙËEUeÛ6Å²DQUeÙ¶cEUeÛÖu4QTUY¶mÝWSUeÙ¶}]82UUm[×}#Um[×¡*Ë¶më¾QI¶m]7ã¨$Û¶îû¾q,ñ¡°,ð_8*\\000\\000ð\\000 VG8),4d%\\000\\000\\000¤QJ)£RJ)ÆR	\\000\\000p\\000\\0000¡²\\\"\\000\\000\\000sÎ9çsÎ9çsÎ9çsÎ9çc1Æc1Æc1Æc1Æc1Æc1Æ\\000ìD8\\000ìDX¬\\000Â\\000\\000R)¥9ç¤RJ)¥ÈA¥RJ)¥DÒI)¥RJ)¥qPJ)¥RJ)¡RJ)¥RJ	¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ\\000&\\000P	6Î°tV8\\\\hÈJ\\000 7\\000\\000P9Æ$JH%JåÎI	)µVB\\\
­\\\
:h£RK­JIB(¡RZ)%µR2¡PJ!¥RJ	¡ePB\\\
%RI-´TJÉ PZ	©ÔZ\\\
%A)©R*­µJJ­ÒR)­µÖJJ!R¥¤R)¥µJk­µNR)-¤ÖRk­VJ)¥JI­µZk)¥VB)­´ÒZ)%µÖRk-ÔZK­¥ÖRk­¥ÖJ)%¥Zk­µZ*)µB)¥Bj©¥ÖJ*-ÐRI¥VZk)¥J(%Z*©µRh¥ÒJI%¥J*)¥ÔR*¡R*¡ÔRk©¥J*-µÔR+©JJ©\\000\\000tà\\000\\000`D¥ØiÆGàB	(\\000\\000\\000@ \\000\\\
d\\000ÀB\\000PX`(]è\\\"HA\\\\8qãNèÐ\\000\\000¡\\\"$dÀEt\\000°¸À(]è\\\"HA\\\\8qãNèÐ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\ÆGÇH\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000OggS\\000r\\\"\\000\\000\\000\\000\\000\\000/Y\\000\\000\\000\\000\\000¸v³}]R`^d]_Yb]O?BAC>88B«Vö²/O·ÝçóU\\000@	·ìâmÀ\\\\ÍÌLeÿLµ¦ÆÔÔQPjï<\\\"uÙ\\000°ãõãã÷î_l½t½^¯×ëUÀB\\000 a3¾Z±5É¦¦×Rd~¤ïw@Õ\\000\\000Pô5ÃÜÆH`]µ\\000<\\000Ï¬è½3×ç*oïäñoÜ_èç¬}V©\\000\\000ø§n3ê-\\000\\000Ø$\\000^©=Þºü|­Ù-½¦^5Ð\\000À	\\000Ñ1\\000«6e\\000ÑâÔÑ-Ï¾ÝÌÙ.í\\000\\000¦évx\\000>=Òý\\000ø¶ûÀU\\000\\000tìwÀ;@Î.	\\000ôË	¯\\000ÀNÞ\\\
\\000R©µtN·j_XîU\\000p| e\\000êÚk´Wz7ÚöÔ-5@QmÉÎY[H\\000.\\000t£Ø»Un\\000ó'? ¬ý1P«:w\\rYGâ\\000Z­¬ ó7æÔ®i=E/øÔ\\000 M\\000Û}\\000\\000°h «ÔÔÒg)öìØ*µWz#\\000\\000uOmË°º\\0002lÆÖÿ.ÉV'\\000ÀiZ_ðK7[\\r@Á\\000@c~f³\\\"^nr%înê-êo¾°~ü-\\000x  ò\\\"@¥¥«jÎX¥w?RÝì³N\\\"HJ30yB5M°,@Ó4Ä~ß\\000Çðº\\\
ÌUi²Ís\\000*+u%}ó`ñOb¡ãôºÚÖ^TôÆ=ó\\000ê¾Ùâ¢\\000\\000,@-hØ¢iNhS»6}Þ¼Ë[OV\\000\\000y Ò´y`P³Ë¡^ÝÃ°³WS\\000ìêç\\000Á¨ù\\000,ú_Ï\\0000¤ì\\000V­Á_ëß=vÿt.q ÓÎÑ \\0000è\\000sÓ¦3«<§3UÇp[y»\\000À\\000ÀÎäJÕd6t±\\000gÜV´©ú¯â\\\\ß²1\\000¶szH^«{.îzÄè¡ï§3Â}Ã	Ð\\000Ú6\\000K\\\\Ë¤l=¾vâhußUß'¨§àûöô¥Ëm6Y8H\\000nËô«¢a9¾ÜÃMe\\000°ô\\rh\\000ýÌ~\\000>RK¯\\000Z«=æ¯¥sZc>ÐP¢\\rÚ\\0004ÃªæGËòåËsöÞ¯aY\\000Þ0Ïsî ÿ2:áý\\\
p«b¿D\\000\\000à9é0?at\\000t]¯ÊV³:¤Lg±\\000Z±5o?XG«?ÂÓw@\\000	.\\000ð\\000\\000Ñ\\000kÌUhß,¾Í\\000PiP©LÛÃÅóL_ý:¸w\\000Ðã÷!\\000ìÎþÎ\\000\\000ÎÇZ¯õ\\\\ÚN<*ð¥o?\\000\\000#\\000t#H\\000JÛ ý0ÿ\\0000íq¿TÏ#à\\\"\\000ü¶r\\000x%Ñ:_¥}­«-î~\\000}Ù!bÇ\\000¼YEFóuïíKø\\000ÎÚûz¶(A¼«r\\000ï\\000f`°É«\\000jõVX½[uÕh2äíèV&Jí<ßoËNúlH\\000Ã*$\\000@'Le\\\\Áüær x\\000K\\r\\000·\\\
\\000ë¡-ßí['Ãå49asÄ\\\
ñL¤hý~ïõ»LÐôt\\0008¹\\\\\\000@\\000A\\000×2tÀæ0\\000Ý'{û].Â÷ÓúUrBÛbrÒbÙíçÿJu-§·\\000ßt]¯ñ\\000è\\rSBrTáÀluÒ¹\\000q/éÚçPüÆíÕko¡*`Ã~5vÚ)#`H/þ#\\000.A\\000@Ü~°®<7=|`(º\\000e©m¿<¾Óò9©Þµ\\r+4`Å/#<:yZ°#Í¿¼\\000$\\000æç;\\r\\000_[«Ýê\\000E\\000\\000\\000Xõ\\000\",\
    [ \"backup/lib/mino.lua\" ] = \"-- makes a Mino, a tetris piece that can be rendered on a Board\\r\\\
local Mino = {}\\r\\\
\\r\\\
local gameConfig = require \\\"lib.gameconfig\\\"\\r\\\
\\r\\\
local stringrep = string.rep\\r\\\
\\r\\\
function Mino:New(minoTable, minoID, board, xPos, yPos, oldeMino)\\r\\\
	local mino = setmetatable(oldeMino or {}, self)\\r\\\
    self.__index = self\\r\\\
	\\r\\\
	local minoTable = minoTable or gameConfig.minos\\r\\\
	if not minoTable[minoID] then\\r\\\
		error(\\\"tried to spawn mino with invalid ID '\\\" .. tostring(minoID) .. \\\"'\\\")\\r\\\
	else\\r\\\
		mino.shape = minoTable[minoID].shape\\r\\\
		mino.spinID = minoTable[minoID].spinID\\r\\\
		mino.kickID = minoTable[minoID].kickID\\r\\\
		mino.color = minoTable[minoID].color\\r\\\
		mino.name = minoTable[minoID].name\\r\\\
	end\\r\\\
\\r\\\
	mino.finished = false\\r\\\
	mino.active = true\\r\\\
	mino.spawnTimer = 0\\r\\\
	mino.visible = true\\r\\\
	mino.height = #mino.shape\\r\\\
	mino.width = #mino.shape[1]\\r\\\
	mino.board = board\\r\\\
	mino.minoID = minoID\\r\\\
	mino.x = xPos\\r\\\
	mino.y = yPos\\r\\\
	mino.xFloat = 0\\r\\\
	mino.yFloat = 0\\r\\\
	mino.board = board\\r\\\
	mino.rotation = 0\\r\\\
	mino.resting = false\\r\\\
	mino.lockTimer = 0\\r\\\
	mino.movesLeft = gameConfig.lock_move_limit\\r\\\
	mino.yHighest = mino.y\\r\\\
\\r\\\
	return mino\\r\\\
end\\r\\\
\\r\\\
function Mino:Serialize(doIncludeInit)\\r\\\
	return textutils.serialize({\\r\\\
		minoID = doIncludeInit and self.minoID or nil,\\r\\\
		rotation = self.rotation,\\r\\\
		x = x,\\r\\\
		y = y,\\r\\\
	})\\r\\\
end\\r\\\
\\r\\\
-- takes absolute position (x, y) on board, and returns true if it exists within the bounds of the board\\r\\\
function Mino:DoesSpotExist(x, y)\\r\\\
	return self.board and (\\r\\\
		x >= 1 and\\r\\\
		x <= self.board.width and\\r\\\
		y >= 1 and\\r\\\
		y <= self.board.height\\r\\\
	)\\r\\\
end\\r\\\
\\r\\\
-- checks if the mino is colliding with solid objects on its board, shifted by xMod and/or yMod (default 0)\\r\\\
-- if doNotCountBorder == true, the border of the board won't be considered as solid\\r\\\
-- returns true if it IS colliding, and false if it is not\\r\\\
function Mino:CheckCollision(xMod, yMod, doNotCountBorder, round)\\r\\\
	local cx, cy	-- represents position on board\\r\\\
	round = round or math.floor\\r\\\
	for y = 1, self.height do\\r\\\
		for x = 1, self.width do\\r\\\
\\r\\\
			cx = round(-1 + x + self.x + xMod)\\r\\\
			cy = round(-1 + y + self.y + yMod)\\r\\\
			\\r\\\
			if self:DoesSpotExist(cx, cy) then\\r\\\
				if self.board.contents[cy]:sub(cx, cx) ~= self.board.blankColor and self:CheckSolid(x, y) then\\r\\\
					return true\\r\\\
				end\\r\\\
				\\r\\\
			elseif (not doNotCountBorder) and self:CheckSolid(x, y) then\\r\\\
				return true\\r\\\
			end\\r\\\
\\r\\\
		end\\r\\\
	end\\r\\\
	return false\\r\\\
end\\r\\\
\\r\\\
-- checks whether or not the (x, y) position of the mino's shape is solid.\\r\\\
function Mino:CheckSolid(x, y, relativeToBoard)\\r\\\
	--print(x, y, relativeToBoard)\\r\\\
	if relativeToBoard then\\r\\\
		x = x - self.x + 1\\r\\\
		y = y - self.y + 1\\r\\\
	end\\r\\\
	x = math.floor(x)\\r\\\
	y = math.floor(y)\\r\\\
	if y >= 1 and y <= self.height and x >= 1 and x <= self.width then\\r\\\
		return self.shape[y]:sub(x, x) ~= \\\" \\\"\\r\\\
	else\\r\\\
		return false\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
-- direction = 1: clockwise\\r\\\
-- direction = -1: counter-clockwise\\r\\\
function Mino:Rotate(direction, expendLockMove)\\r\\\
	local oldShape = table.copy(self.shape)\\r\\\
	local kickTable = gameConfig.kickTables[gameConfig.currentKickTable]\\r\\\
	local output = {}\\r\\\
	local success = false\\r\\\
	local newRotation = ((self.rotation + direction + 1) % 4) - 1\\r\\\
	local kickRotTranslate = {\\r\\\
		[-1] = \\\"3\\\",\\r\\\
		[ 0] = \\\"0\\\",\\r\\\
		[ 1] = \\\"1\\\",\\r\\\
		[ 2] = \\\"2\\\",\\r\\\
	}\\r\\\
	if self.active then\\r\\\
		-- get the specific offset table for the type of rotation based on the mino type\\r\\\
		local kickX, kickY\\r\\\
		local kickRot = kickRotTranslate[self.rotation] .. kickRotTranslate[newRotation]\\r\\\
\\r\\\
		-- translate the mino piece\\r\\\
		for y = 1, self.width do\\r\\\
			output[y] = \\\"\\\"\\r\\\
			for x = 1, self.height do\\r\\\
				if direction == -1 then\\r\\\
					output[y] = output[y] .. oldShape[x]:sub(-y, -y)\\r\\\
				elseif direction == 1 then\\r\\\
					output[y] = oldShape[x]:sub(y, y) .. output[y]\\r\\\
				end\\r\\\
			end\\r\\\
		end\\r\\\
		self.width, self.height = self.height, self.width\\r\\\
		self.shape = output\\r\\\
		-- it's time to do some floor and wall kicking\\r\\\
		if self.board and self:CheckCollision(0, 0) then\\r\\\
			for i = 1, #kickTable[self.kickID][kickRot] do\\r\\\
				kickX = kickTable[self.kickID][kickRot][i][1]\\r\\\
				kickY = -kickTable[self.kickID][kickRot][i][2]\\r\\\
				if not self:Move(kickX, kickY, false) then\\r\\\
					success = true\\r\\\
					break\\r\\\
				end\\r\\\
			end\\r\\\
		else\\r\\\
			success = true\\r\\\
		end\\r\\\
		if success then\\r\\\
			self.rotation = newRotation\\r\\\
			self.height, self.width = self.width, self.height\\r\\\
		else\\r\\\
			self.shape = oldShape\\r\\\
		end\\r\\\
\\r\\\
		if expendLockMove then\\r\\\
			self.movesLeft = self.movesLeft - 2\\r\\\
			if self.movesLeft <= 0 then\\r\\\
				if self:CheckCollision(0, 1) then\\r\\\
					self.finished = 1\\r\\\
				end\\r\\\
			else\\r\\\
				self.lockTimer = gameConfig.lock_delay\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	return mino, success\\r\\\
end\\r\\\
\\r\\\
function Mino:Move(x, y, doSlam, expendLockMove)\\r\\\
	local didSlam\\r\\\
	local didCollide = false\\r\\\
	local didMoveX = true\\r\\\
	local didMoveY = true\\r\\\
	local step, round\\r\\\
\\r\\\
	if self.active then\\r\\\
	\\r\\\
		if doSlam then\\r\\\
\\r\\\
			self.xFloat = self.xFloat + x\\r\\\
			self.yFloat = self.yFloat + y\\r\\\
\\r\\\
			-- handle Y position\\r\\\
			if y ~= 0 then\\r\\\
				step = y / math.abs(y)\\r\\\
				round = self.yFloat > 0 and math.floor or math.ceil\\r\\\
				if self:CheckCollision(0, step) then\\r\\\
					self.yFloat = 0\\r\\\
					didMoveY = false\\r\\\
				else\\r\\\
					for iy = step, round(self.yFloat), step do\\r\\\
						if self:CheckCollision(0, step) then\\r\\\
							didCollide = true\\r\\\
							self.yFloat = 0\\r\\\
							break\\r\\\
						else\\r\\\
							didMoveY = true\\r\\\
							self.y = self.y + step\\r\\\
							self.yFloat = self.yFloat - step\\r\\\
						end\\r\\\
					end\\r\\\
				end\\r\\\
			else\\r\\\
				didMoveY = false\\r\\\
			end\\r\\\
\\r\\\
			-- handle x position\\r\\\
			if x ~= 0 then\\r\\\
				step = x / math.abs(x)\\r\\\
				round = self.xFloat > 0 and math.floor or math.ceil\\r\\\
				if self:CheckCollision(step, 0) then\\r\\\
					self.xFloat = 0\\r\\\
					didMoveX = false\\r\\\
				else\\r\\\
					for ix = step, round(self.xFloat), step do\\r\\\
						if self:CheckCollision(step, 0) then\\r\\\
							didCollide = true\\r\\\
							self.xFloat = 0\\r\\\
							break\\r\\\
						else\\r\\\
							didMoveX = true\\r\\\
							self.x = self.x + step\\r\\\
							self.xFloat = self.xFloat - step\\r\\\
						end\\r\\\
					end\\r\\\
				end\\r\\\
			else\\r\\\
				didMoveX = false\\r\\\
			end\\r\\\
			\\r\\\
		else\\r\\\
			if self:CheckCollision(x, y) then\\r\\\
				didCollide = true\\r\\\
				didMoveX = false\\r\\\
				didMoveY = false\\r\\\
			else\\r\\\
				self.x = self.x + x\\r\\\
				self.y = self.y + y\\r\\\
				didCollide = false\\r\\\
				didMoveX = true\\r\\\
				didMoveY = true\\r\\\
			end\\r\\\
		end\\r\\\
\\r\\\
		local yHighestDidChange = (self.y > self.yHighest)\\r\\\
		self.yHighest = math.max(self.yHighest, self.y)\\r\\\
\\r\\\
		if yHighestDidChange then\\r\\\
			self.movesLeft = gameConfig.lock_move_limit\\r\\\
		end\\r\\\
\\r\\\
		if expendLockMove then\\r\\\
			if didMoveX or didMoveY then\\r\\\
				self.movesLeft = self.movesLeft - 1\\r\\\
				if self.movesLeft <= 0 then\\r\\\
					if self:CheckCollision(0, 1) then\\r\\\
						self.finished = 1\\r\\\
					end\\r\\\
				else\\r\\\
					self.lockTimer = gameConfig.lock_delay\\r\\\
				end\\r\\\
			end\\r\\\
		end\\r\\\
	else\\r\\\
		didMoveX = false\\r\\\
		didMoveY = false\\r\\\
	end\\r\\\
\\r\\\
	return didCollide, didMoveX, didMoveY, yHighestDidChange\\r\\\
end\\r\\\
\\r\\\
-- writes the mino to the board\\r\\\
function Mino:Write()\\r\\\
	if self.active then\\r\\\
		for y = 1, self.height do\\r\\\
			for x = 1, self.width do\\r\\\
				if self:CheckSolid(x, y, false) then\\r\\\
					self.board:Write(x + self.x - 1, y + self.y - 1, self.color)\\r\\\
				end\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
return Mino\",\
    [ \"sound/mino_J.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000§g\\000\\000\\000\\000\\000\\000Ñ~ïvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000§g\\000\\000\\000\\000\\000e#CDÿÿÿÿÿÿÿÿÿÿÿÿvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000 \\\
ÆÐU\\000\\000\\000\\000BFÆP§GÄPóPjé xJaÉôkBß{Ï½÷Þ{ 4d\\000\\000\\000@bà1	B¡Å	Q)Ba9	r:	B÷ .çÞrî½÷\\rY\\000\\000\\0000!B!B\\\
)¥R)¦bÊ1ÇsÌ1È :è¤N2©¤2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊc1Æc1Æc1ÆBCV\\000 \\000\\000AdB!R)¦sÌ1ÇÐU\\000\\000 \\000\\000\\000\\000\\000GÉÉ$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û}ÛwuÙ·}ÙvuYeYwm[uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9#)¬\\000d\\000\\000\\000à(â8#9cI¤IåYåi&j¢¬\\000\\000\\000\\000\\000\\000\\000\\000 (â(#I¥iç©(¦ªª¢iªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i@hÈ*\\000@\\000@ÇqÇQÇqÉ$	\\rY\\000È\\000\\000\\000ÀPGË±$ÍÒ,Ïò4Ñ3=WMÝÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓÐU\\000\\000\\000\\000 B1 4d\\000\\000\\000¢1Ô)%Á¥`!Ä1Ô!ä<Z:RX2&=ÅÂ÷Þsï½÷\\rY\\000\\000\\000FxLB(FqBg\\\
BXN¥NÐ=!Ë¹·{ï½BCV\\000\\000\\000B!B!BJ)b)¦rÌ1Çs2È :é¤L*é¤£L2ê(µRK1Å[n1ÖZkÍ9÷2Æc1Æc1Æc1ÐU\\000\\000\\000\\000aABH!b)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I,É4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeÝÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäH¤\\000¡!«\\000\\000\\000\\000\\0008£8äHåX%ifygy§è¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(¢8ãHeiæyª'¢©ªªhªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i&²\\\
\\000\\000\\000ÐqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç<É³<Çs<É4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000 Ç´$	 äÄÄ¤ ä:%Åä!§ bä9ÉAäÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥9ç¤tR¡¥Rg©´ZbÌ(ÚR­\\rRH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,BCV\\000Q\\000\\0001H)¤b9ÈD1èd1!sNAÇT*uPRÃsA¨ T:GPRG\\000\\000\\000\\000\\000¡Ð@\\000A4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUÝvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×eÓumÙue[WeYø5UeÓumÙt]ÙveW·UYÖmÑu}]eá7eÙ÷e[×}Y·at]ÛWeY÷MY~ÙÝÕu_DQU=U]QU]×t][W]×¶5Õ]ÓumÙT]YVeY÷]WÖuMUeÙeÛ6]WUYöuWu[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}Uu_ÖuauÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_máXeÙøuá[×ßs]_WmÙVÙ6Ý÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^Ý6êÆO¸ß¨©ª¯®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VYÕaÖuaÙa©Úº2¼ºo¯­+ÃíßWªmË«ÛÂ0û¶ðÛÂo»±3\\000\\0008\\000\\000P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEUeÕeYu]]MÓEÕteÓT]Yu]WV]W%M3MÍóLSó<Ó4UÓMSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓMSeÓUmÙUeW]Ù¶MUeS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨²kªl«ªª»²kë¾,Ë¶,ªªë®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï¦,ª)Û¦ªÊ²,»¶mË²/¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À\\000@	e Ð\\000@\\000\\000`cAhrÎ9RÎ9!sB©dÎA¡¤Ì9¥¤9¡B¥¤ÔZ¡Z+\\000\\000 À\\000 ÀMÅ\\\
\\rY	\\000¤\\000GÓLÓueÙËEUeÛ6Å²DQUeÙ¶cEUeÛÖu4QTUY¶mÝWSUeÙ¶}]82UUm[×}#Um[×¡*Ë¶më¾QI¶m]7ã¨$Û¶îû¾q,ñ¡°,ð_8*\\000\\000ð\\000 VG8),4d%\\000\\000\\000¤QJ)£RJ)ÆR	\\000\\000p\\000\\0000¡²\\\"\\000\\000\\000sÎ9çsÎ9çsÎ9çsÎ9çc1Æc1Æc1Æc1Æc1Æc1Æ\\000ìD8\\000ìDX¬\\000Â\\000\\000R)¥9ç¤RJ)¥ÈA¥RJ)¥DÒI)¥RJ)¥qPJ)¥RJ)¡RJ)¥RJ	¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ\\000&\\000P	6Î°tV8\\\\hÈJ\\000 7\\000\\000P9Æ$JH%JåÎI	)µVB\\\
­\\\
:h£RK­JIB(¡RZ)%µR2¡PJ!¥RJ	¡ePB\\\
%RI-´TJÉ PZ	©ÔZ\\\
%A)©R*­µJJ­ÒR)­µÖJJ!R¥¤R)¥µJk­µNR)-¤ÖRk­VJ)¥JI­µZk)¥VB)­´ÒZ)%µÖRk-ÔZK­¥ÖRk­¥ÖJ)%¥Zk­µZ*)µB)¥Bj©¥ÖJ*-ÐRI¥VZk)¥J(%Z*©µRh¥ÒJI%¥J*)¥ÔR*¡R*¡ÔRk©¥J*-µÔR+©JJ©\\000\\000tà\\000\\000`D¥ØiÆGàB	(\\000\\000\\000@ \\000\\\
d\\000ÀB\\000PX`(]è\\\"HA\\\\8qãNèÐ\\000\\000¡\\\"$dÀEt\\000°¸À(]è\\\"HA\\\\8qãNèÐ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\ÆGÇH\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000OggS\\000PF\\000\\000\\000\\000\\000\\000§g\\000\\000\\000\\000\\0008%MBSGYMQXLbNRVPgfhaQTLfgRT`QAAOAD6D96BS[ØðF÷axëå¹PUÐjU\\000°?X`1À,Eº¿SóÝö[»´=¿\\000@|óDÓoÆÍ\\000d_/i\\000@ÿÊ\\000 ¬\\0000B\\000V[[Ø}o±O\\\
¾?Ï.%U@ð ÀHê°4f¿4Q¨\\000I´©\\000v4\\000h÷\\000\\000º_ð%pJ\\000Ne«l {¥~P?hêà-\\000Àv°î	À«Õºç©}5_ò¶]j.\\000¢iDÐ>ËwÛöBéú´j¾|VÏý@E\\000p=1\\000\\000°Vq+ÚèÊñ@yÐ§¾`RÜ\\000P°\\000¼ÂÐbòõ­³É(eº÷\\000ÔÉäTX\\000ÀÈ\\\
\\000ÜÊCI`esíyNy«)\\000(,ïF	$XÀª};úF<j}³µk³µùÒzö_/ºÑ¶O,Ì4`i)Ú±ö)\\000\\000£¯Rt\\000\\000ìc,$\\000RyJ.Ô³÷È¯çámN\\000ªz\\000À\\rA#5Ç·¾ÌÑ­Xë?9~\\000Pµ¶4gv -zø^|zX@ß\\000\\000G\\000Fg=ÿoÇ «ýs=(ªá@¶mhf©¦eÛû£O«Ox36µw±¨ëÐoBM!\\rG#¶y¨ëÚ¿)ls\\000\\000çG¡\\000VuÓÈ SãA« n\\000¨\\000°hÀ[¨b¥Ú:Ûåwî\\\"îÀÒ.¥É©0fO>\\000DZÚ³ÚÔ=¾æ¾+¹ýù½d/< \\000àXÿr¶\\000FÍ3@×\\\\\\r^^/ o\\000X@°ææ\\\"âa¤Å³~i¨w¨#K\\000øN³|±1°\\000ð\\000*\\000Þ¿Ç	&*\\000	Ø_z\\000F©U¸(É×¨_îëµÊ?<Á @$À¡2GÛ\\000ÐçDj5GmsmM>Un),¨'E:µ@¥ù\\000`­©%üô;ª&>;qvÜ`c¨§üö©\\\
ê8Ë\\000N©}Ë×vdÉÕt±ã¥°¢.\\000K\\000ÀÔsY\\000*GYÿÏ?O¿.ìHÔO@Õ0=Á>¥º~µ¬$$ðë0P\\000ÐÃèjÀ7R¡UdK#y=ëïã½¥à`à%m:\\000T°,]¶Ô¹öq,£UM¦Q)0 MT;Ã}\\000Õ2ÕHJÇ!`?$Pwãø9.#úìjBsõ*ü Ó3ÅôJÁ#hA³XIiªêjÓ´×^k´°UStêèïÓ%yüdøm##¢çJ@þI°Æ¡Ôñ7§\\000°Ì¯ð5Norû©Èúü| l×Ád<*Lû\\0008Âqió>Û+	\\000\\000\\\"¹VsSkNF¥w.&wc`Áï3?¯\\000\\000àR ÌVÆ\\000K\\000B§\\\"`SG³Å²-ÀLkQBo\\000ú'ÅrÛÚuO¿û;µkýXI÷ì¾b@Ó°^¼êêìèbôv3 Øùÿ¾	°âìö9\\000»¥\\000B2L§©_ÁÞX'K\\000ö¯\\000\\000B¡+Ò(Ë\\\\²imþ Ð·Gr¨x\\0008\\000\\000ºmÇ\\000°bì§TÝïYÚ_ÖDÇ-à\\000@sí¦þ·^Ò_3Å/l¨À¾.ÀfTÖñ(ÐÀ(1ê(q\\000måàl\\000R§URCäïèFy0Ì``ð=Þ\\000^¢ÊºÅR­÷ùï¿ýÂ¼É²dÌü³0U\\000ªAjëw\\000\\0000ïÎsÝâ\\000Q\\000Îî&Ájç7£` ò¦ðÍ\\000>­Y;{7.¶Eè¡øsîQ\\rÀ\\0008\\000\\000ºÄó\\000¬D4tÙ¬ÕMú?·9'[:\\000\\000Ô'r\\000ÿ/¬E_Èß92á¸Ørà>XêpV$ nã·yv~¹ê\\000\\000Oe\\000àÈã\\000N¿T&í%¶+®¿½Öz\\000N$\\000x\\000Ð\\000t*4d®ÚÚÝo¹M½#x$`*\\000 ?kÀ_ë\\000pS!\\000Í\\000é³\\000\\000@.·5w^\\\
*ü$[µòý\\\
 wê®Â+Ú>ãÉ¥ÙÞUÓ°OÕGOgÛy3}[Ð17Àµ¤\\000x ¾Ûü  !cøUA_éHS\\000àÕ¡ÎHFEå7µ©m#*ü`¿qÌ\\000\\000-À±LyûþåÒ\\000\\000®;\\000,YÂ½pJÌw²9½+`QªÆÝÎr\\000sp¡\\000\\000`Ë\\000:¡½ì¹DAhÈ÷ÀÚ\\000Ð:\\000\\000¶Gñ/\\000,Â½ëM5ßs_Ëu´íüÚTzçX´XvY4Ñ6©\\r 5rú^¡êáw\\000ÀÆgw´×£\\000\\000p»ö\\000é=\\\\ïÿz¶õF£Ù{zµ¡B¯ wD\\000<bßik\\000\\000Ú@ÕÑF	\\000Þ­A÷ÿß9Ù{oÖJ8>¿\\000H15ù~>\\r©»]YÛ68]¸¼Ü®pÐÉæ4ò\\000@oÅÑ}àü(\\000ìN©9Wç Ôl¸@ph\\000·\\000@Y\\0006 K\\000e\\000Pj÷j+÷¦+ú\\\
\\\"Ûh º\\000\\000G\\000ðÌà×eiÐg%ý[HàY\\000J©uLsÊ^TÕ]@O\\000Oà\\000@\\000\\000´kaýRÚg}â|Ïn#ÜêH&	\\000H)\\0000#K@RU¾$]A÷7#\\000\\000;\\000ùs[	\\000J£1ûÝ¸:}s]X-õÀ=ÀØiK\\0006 `ý_cÞçø¾K÷jÓô;$´ìXÅ·\\000f«Ïú0 lÙg\\000Àö½@\\000ö\\000,õÇ\\000±¾YLC\\000J§1w]}´öÒC~¦Þà²\\000 èÊ°ËRüYæ}@ä\\000æ_\\000¨RZ\\000&ËÏ\\\"_FtË¯á\\\"\\000~^2\\000\\000Û	§4¿ªèiÒ¶\\r@e5^qàGÙXÙþ:¬¥ÓxÐýËhI@Rø-EgÀpv1Pì\\000¨Zú¿«sò÷KÏ²ÀlÌffeisÇni\\0003Ü&èhÀÖ%3¸Äðî8\\0000Õ_ÍúÒ\\000<°:G!A¯êQ8õ|[þå¬ooÇé$ÌøqÓÔÇoçª`&Yå¹Ô¶VX9W]\\000À?Â'\\000è%$wüâþs`Ú¶^£6q,P¸ö}§Xr^y=8Ê(TIPô\\000èÇ!\\000\\000¼?\\000 \\000~]\\000¨ÀDH\\000ÔW_ºÒ¥½è,Á¬2 \\000X´ßÙ.Ë¢`¢R%\\000=\\000ý.ÒÐÿª ÷\\0005%àæ{\\000\\000\\000pìô3\\000:÷¼2q¹àà{o4£ôæÎàgý(8+*×àÞ\\000\\000N|\\000\\000`ã\\000,\\000ÒV('Õê1R Û¶GÀ\\\"À¬k*;Ä»|.fÇóeuFØ/70ºò\\000Ø\\000}%\\000`\\000ìs\\0002¶¿T¥ëóhÉB?ÀÁl\\r\\r£¢ÚJ¥Ö×\\000ðK Á6À«2\\000<¿\\000ÀtP¨æàèy!v]ñ·h«äF\\0008ýz½<ps7¢QÏ&¼_\\000\\rª\\000n\\\\è¹\\rwÍI¿$\\000\\000Ö\\000\",\
    [ \"sound/lineclear.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000µ}\\000\\000\\000\\000\\000\\000[yvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000µ}\\000\\000\\000\\000\\000}/èDÿÿÿÿÿÿÿÿÿÿÿÿvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000 \\\
ÆÐU\\000\\000\\000\\000BFÆP§GÄPóPjé xJaÉôkBß{Ï½÷Þ{ 4d\\000\\000\\000@bà1	B¡Å	Q)Ba9	r:	B÷ .çÞrî½÷\\rY\\000\\000\\0000!B!B\\\
)¥R)¦bÊ1ÇsÌ1È :è¤N2©¤2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊc1Æc1Æc1ÆBCV\\000 \\000\\000AdB!R)¦sÌ1ÇÐU\\000\\000 \\000\\000\\000\\000\\000GÉÉ$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û}ÛwuÙ·}ÙvuYeYwm[uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9#)¬\\000d\\000\\000\\000à(â8#9cI¤IåYåi&j¢¬\\000\\000\\000\\000\\000\\000\\000\\000 (â(#I¥iç©(¦ªª¢iªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i@hÈ*\\000@\\000@ÇqÇQÇqÉ$	\\rY\\000È\\000\\000\\000ÀPGË±$ÍÒ,Ïò4Ñ3=WMÝÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓÐU\\000\\000\\000\\000 B1 4d\\000\\000\\000¢1Ô)%Á¥`!Ä1Ô!ä<Z:RX2&=ÅÂ÷Þsï½÷\\rY\\000\\000\\000FxLB(FqBg\\\
BXN¥NÐ=!Ë¹·{ï½BCV\\000\\000\\000B!B!BJ)b)¦rÌ1Çs2È :é¤L*é¤£L2ê(µRK1Å[n1ÖZkÍ9÷2Æc1Æc1Æc1ÐU\\000\\000\\000\\000aABH!b)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I,É4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeÝÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäH¤\\000¡!«\\000\\000\\000\\000\\0008£8äHåX%ifygy§è¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(¢8ãHeiæyª'¢©ªªhªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i&²\\\
\\000\\000\\000ÐqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç<É³<Çs<É4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000 Ç´$	 äÄÄ¤ ä:%Åä!§ bä9ÉAäÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥9ç¤tR¡¥Rg©´ZbÌ(ÚR­\\rRH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,BCV\\000Q\\000\\0001H)¤b9ÈD1èd1!sNAÇT*uPRÃsA¨ T:GPRG\\000\\000\\000\\000\\000¡Ð@\\000A4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUÝvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×eÓumÙue[WeYø5UeÓumÙt]ÙveW·UYÖmÑu}]eá7eÙ÷e[×}Y·at]ÛWeY÷MY~ÙÝÕu_DQU=U]QU]×t][W]×¶5Õ]ÓumÙT]YVeY÷]WÖuMUeÙeÛ6]WUYöuWu[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}Uu_ÖuauÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_máXeÙøuá[×ßs]_WmÙVÙ6Ý÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^Ý6êÆO¸ß¨©ª¯®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VYÕaÖuaÙa©Úº2¼ºo¯­+ÃíßWªmË«ÛÂ0û¶ðÛÂo»±3\\000\\0008\\000\\000P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEUeÕeYu]]MÓEÕteÓT]Yu]WV]W%M3MÍóLSó<Ó4UÓMSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓMSeÓUmÙUeW]Ù¶MUeS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨²kªl«ªª»²kë¾,Ë¶,ªªë®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï¦,ª)Û¦ªÊ²,»¶mË²/¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À\\000@	e Ð\\000@\\000\\000`cAhrÎ9RÎ9!sB©dÎA¡¤Ì9¥¤9¡B¥¤ÔZ¡Z+\\000\\000 À\\000 ÀMÅ\\\
\\rY	\\000¤\\000GÓLÓueÙËEUeÛ6Å²DQUeÙ¶cEUeÛÖu4QTUY¶mÝWSUeÙ¶}]82UUm[×}#Um[×¡*Ë¶më¾QI¶m]7ã¨$Û¶îû¾q,ñ¡°,ð_8*\\000\\000ð\\000 VG8),4d%\\000\\000\\000¤QJ)£RJ)ÆR	\\000\\000p\\000\\0000¡²\\\"\\000\\000\\000sÎ9çsÎ9çsÎ9çsÎ9çc1Æc1Æc1Æc1Æc1Æc1Æ\\000ìD8\\000ìDX¬\\000Â\\000\\000R)¥9ç¤RJ)¥ÈA¥RJ)¥DÒI)¥RJ)¥qPJ)¥RJ)¡RJ)¥RJ	¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ\\000&\\000P	6Î°tV8\\\\hÈJ\\000 7\\000\\000P9Æ$JH%JåÎI	)µVB\\\
­\\\
:h£RK­JIB(¡RZ)%µR2¡PJ!¥RJ	¡ePB\\\
%RI-´TJÉ PZ	©ÔZ\\\
%A)©R*­µJJ­ÒR)­µÖJJ!R¥¤R)¥µJk­µNR)-¤ÖRk­VJ)¥JI­µZk)¥VB)­´ÒZ)%µÖRk-ÔZK­¥ÖRk­¥ÖJ)%¥Zk­µZ*)µB)¥Bj©¥ÖJ*-ÐRI¥VZk)¥J(%Z*©µRh¥ÒJI%¥J*)¥ÔR*¡R*¡ÔRk©¥J*-µÔR+©JJ©\\000\\000tà\\000\\000`D¥ØiÆGàB	(\\000\\000\\000@ \\000\\\
d\\000ÀB\\000PX`(]è\\\"HA\\\\8qãNèÐ\\000\\000¡\\\"$dÀEt\\000°¸À(]è\\\"HA\\\\8qãNèÐ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\ÆGÇH\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000OggS\\000â6\\000\\000\\000\\000\\000\\000µ}\\000\\000\\000\\000\\000Æ³btx{txuxlynzxwuqmjOYZQ`UWV\\\\YQF·SâMÐµLXõÄÍêRJÙ×õËkskV÷+ûºè¶CîÑç6M.4Ru]¯þcesnMjþ¿)âÊ¬|à¦Ååà¿eëtP&Sß)fì8ÈæÍÖ0|l|7\\\"BÜ Egb±ý @¬dYÕ©OïªnÇ\\\
\\000À¿.ÒýñËµýz>½|õ0låè±¬/ºé9ªaË¸4Eûê°ªe¡=ÞÆÞîj­pg®RÔTÞD¶³uÿF\\\
&ðÁÍÿ#ý3æ\\\\<g\\r\\\\]Æx¾\\000a?»ó¯©´9t¯t·8B7~£³\\000&Ç12	 :%K)¥»Sö¿ûÿâñWUþûtg¼²ä4ÿ{ñ_fî\\\\tåíiÊÚÜÇ:ÈSÉå3¿©P©W¿NTl!Á®I¾yx¥ÞÍö¹Å1IsIO©ØI	^®V½â@<PE^¥¥ÄJ)K­ó¿Ò¸51ý¼×õæñ<åN§±Å£yÇ[\\\"»GbãOn±ÒÁ	TK~,ñ#)EÌFszvO²Iµã¾êìÍä­Ð$5~Hh©ÍF¯ä¯UjÙÆe¨bH!¢RË:\\000ªÏf¥ÌJ±ÓÍë¯êWªL_uù²XSSrý*YõÓ|A¦+äyØW½£ÿi«È@W\\\"IJbì_¹Tö¢S_:1\\\"¿ûcª\\rGª,ùÓ³¶J$rûû£®¦ùÑ§G·*ªlj.Ô2¯Èa§´ÄJ¤ùË7Ç~ã×¯¿ïãU;ÄöuÄr{Ez!¢Kö.e!áYL¨Åï\\\"£T[³k¯Ål­Ãf[t&¥c®¥ïéå®ß»ºYÄ31çT®oµ*ñQ¡ýÐ»ÊÓþ¢Ö6Á[94-æP×	§´.eVxZRÅ··YÛ´íu?nBßóÃ5/_#ªqV<®@3DiVèÂ¶¢Áy6YÃC;UÅ$BÑÞLThé³Vc¾46³{°Ei¹R)Å²Æ¡é½v7®PTä¸±·b»=ë½\\000äP}F_Já{ñÈËªê¢xûRÔÏYI\\\\ö²&×ÆüüL8'Pú9ÐÑ<¢.QÛZné£¾dÝ]èzýÃÓÜ¼´NÀØÛ(Ý¶§4o{Hø5ü<}ÝË9ñ$=³\\rB.­ÛB\\000©Öb\\\"gô¼RHñ¼þÝ¿oË«wÌç©0æ+©î'îÝÃõUûz;¢PIWêÓ7½æ:ß51XúÙhÞx²47ceÄÌíîoìÒSYaÎ±ö?õï:3LáI|äÂ5\\\"»SåPá4«JÎJ)%×ííZïÙÿ¶OÇN¯¿\\\
SØØÉ_¾ÓÔ[ñÙç8ìÎY÷ê$¿y'¬öÌbÔÞ{þgLduøþP'Ù1¯¿[ÏJMuiwÑý= ?üê¥¾qÑèw­{y3û}¿-¤Wô³ì¯àw\\000RÂð$mKÉYf·ãéÓ¾Þ»ùy¢<,¸M2&o!¨$¶Ô±µÝóXyâÊCâ\\rjÒ#Â·g¾*#æ$ìY|{¯-Wi¢×{£3ûîòÊÑL%I±^3éÒ:Û&¯	ÕÀÃ³S=R >K)%Õï¿üï©þÇý[S3OU¿dßÈn7æã£GëSCö9Z0øOÂÊ½bÊÚÂ+Ê®×oÜÔLÊÿ}´IÿúeêÇ\\000ú³KÝÛA®XòéI`­7e\\\"ò¿·Ié?+L,C£³¤À!pùTRJâz:_uóÕX¿òÊü¥óüÖåÍû°^zêçsÓ¼)ÌóííñyÝ?¾Ü£rlpÍÔÖ:¸òyK\\r#õ þ[®;¢kÕz:g×QSÈSíN2tÛÏ¡SB!f¶à\\000ç\\000 ÂCbxvúRJ)³,ÿpÞ~ÑÄÝÒøl[¬õ¼Y(_îó×±¸Vs!¯7Cêírqª\\\"d)f¾`fc­³b¾}¸rø	èlUÝUH­íZà	»H\\\
t^»°¯ÓiUÒæ\\\\Tç4j.Ì¶tÈ\\r±«\\\\\\\
@Ç.yÔY]J))u_·IGÙoYú|7wë4S®>ñÓ1¦ÿÝGQëz½.® ¡(ñðº÷;ç®V1§Ï±ÑZÈÆñÑÍ:KÞúL}©Û:c[QC&Ó:öëoÑñËNèðKo:« P½ú¬%{+GÝùã¿Úõ^]àÎÿ?ù(uäë½Qßv~l2KÂþ¼þÒÀj«hòÎL/5Í{@Õ%²¾³\\\\X¤Î]­ Ç·ÃAO @d¯ë©9¶Ã®sµZ\\\\YT££ÛÆî\\000ð¨³ÏEåy¿¤7ÏóoÉ×ÝpüÚÙÈ°-ëËJ¬õNCÎ+ù¬bã5Ãê¯_Å	6[+·	|aÑÒ×4¯ØÆjæJ»§TRÂ818÷÷çðõ\\\\×2rÚP4«&z^ªz ê3^JÉ4]öQÙ¿åÝÂÙÅ½ì\\rá³Z«°ý«Ç<¯Eøçþÿ{?¸j\\\\d,ÅíZ¦ò.Ðß0Ð9O`:Fë~¢î²Á«g4¿½?Úê%üÇÚ³ïÔ´sy«@lj\\000³T6{÷\\\\þk5bîÊU«ï¾ÜíS G÷:ÒàLÒµÎ$qx(NwËÎÑõiKñnJ%=&zÎÃ­àSÕg)OÝ/ÔÃ#å¾-´Qñ©'ÑWäIÕ¬kÍfË<²ð¶ÏKPÀf\\rÿ-ûP¯Î¢7úØê1×=°ÍrÌ®Pù.,0øb¾¨ðG¦g<çFRMt¾åºÏÞõ'Êä:){Õç¯ªºº=;¥sÞÿ¢\\000\\r¹±h¼Y5Á67[ü°n*ïÌÂ(<¬«è6À}ð\\000øí4©*Û-»²4ÍòmMcçZ÷¬0rSHOó+òìl¯Aü¨»·HAký´]!AèPcÞ=\\\\az¡§ÿ¡_d\\r¨d!-¤¥Â{ðfªSYTs\\\\G¾.ý¼üQYÙª\\rT÷ÙjvbõuL\\r*ó¦¡¦ªÿ´­s\\\"L´wBÑº:\\000ù|©±RjæGÑ[n.ûÒY»}>ÙËº±fú3ð	g|âgªÎ,·<]ý±ÅçhV\\r!Ç\\\\Nû1X²ù]®®úZ}HObÕùÝîwm^DÀ\\\
Z¹9¶è^xÂ`M¿¢hpM\\\"\\00088£­1\\000}jÑÔ¤îmÿWÍQýÂtÉÓÊ¿ÖÉx/Ì\\\"æÀGDTz}»Ý yÜ7Ui[½gã2h5÷Fñ­(}4)ßLó*òöÁªð`<#Q=¹*ßq¦<¿&nñ[lÓ¢ëqÝBz³3.1ëÊ¨uM¦¶VâD,Å¤)è-MÉ²¡SmNI¼ä#Ï5gM§ÂôLúi\\000y\\000ÕÏ>Tu¹åÿ3]¾ækÓêù±?÷M(Ü^o®­N¡p£ºxÛP1µ'Fóâa6û|ñ¨K?À+\\\"µ3,AOl{¯`t5Ï¢ã:©b{c\\000öYryÊÇÝ³ç»Uy·ÏéTY®ºÉl1Yæ&xFîD½ÝÕöQ-¤l°©R\\0004{+pÆ	½wº3b#r+l½qÐäBã4MÀ¼#\\000ogYEkhhõYáÉØ)Îgçç×_1­5Ùº\\\\3XßMæjÞqE°HbÑ~ùÅT\\000ïÌ*0ÛI\\000¤= ³I³ÕÆ5h\\000\",\
    [ \"sound/lock.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000a|\\000\\000\\000\\000\\000\\000\\\
zvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000a|\\000\\000\\000\\000\\000´ùª-Dÿÿÿÿÿÿÿÿÿÿÿÿvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000 \\\
ÆÐU\\000\\000\\000\\000BFÆP§GÄPóPjé xJaÉôkBß{Ï½÷Þ{ 4d\\000\\000\\000@bà1	B¡Å	Q)Ba9	r:	B÷ .çÞrî½÷\\rY\\000\\000\\0000!B!B\\\
)¥R)¦bÊ1ÇsÌ1È :è¤N2©¤2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊc1Æc1Æc1ÆBCV\\000 \\000\\000AdB!R)¦sÌ1ÇÐU\\000\\000 \\000\\000\\000\\000\\000GÉÉ$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û}ÛwuÙ·}ÙvuYeYwm[uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9#)¬\\000d\\000\\000\\000à(â8#9cI¤IåYåi&j¢¬\\000\\000\\000\\000\\000\\000\\000\\000 (â(#I¥iç©(¦ªª¢iªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i@hÈ*\\000@\\000@ÇqÇQÇqÉ$	\\rY\\000È\\000\\000\\000ÀPGË±$ÍÒ,Ïò4Ñ3=WMÝÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓÐU\\000\\000\\000\\000 B1 4d\\000\\000\\000¢1Ô)%Á¥`!Ä1Ô!ä<Z:RX2&=ÅÂ÷Þsï½÷\\rY\\000\\000\\000FxLB(FqBg\\\
BXN¥NÐ=!Ë¹·{ï½BCV\\000\\000\\000B!B!BJ)b)¦rÌ1Çs2È :é¤L*é¤£L2ê(µRK1Å[n1ÖZkÍ9÷2Æc1Æc1Æc1ÐU\\000\\000\\000\\000aABH!b)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I,É4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeÝÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäH¤\\000¡!«\\000\\000\\000\\000\\0008£8äHåX%ifygy§è¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(¢8ãHeiæyª'¢©ªªhªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i&²\\\
\\000\\000\\000ÐqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç<É³<Çs<É4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000 Ç´$	 äÄÄ¤ ä:%Åä!§ bä9ÉAäÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥9ç¤tR¡¥Rg©´ZbÌ(ÚR­\\rRH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,BCV\\000Q\\000\\0001H)¤b9ÈD1èd1!sNAÇT*uPRÃsA¨ T:GPRG\\000\\000\\000\\000\\000¡Ð@\\000A4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUÝvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×eÓumÙue[WeYø5UeÓumÙt]ÙveW·UYÖmÑu}]eá7eÙ÷e[×}Y·at]ÛWeY÷MY~ÙÝÕu_DQU=U]QU]×t][W]×¶5Õ]ÓumÙT]YVeY÷]WÖuMUeÙeÛ6]WUYöuWu[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}Uu_ÖuauÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_máXeÙøuá[×ßs]_WmÙVÙ6Ý÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^Ý6êÆO¸ß¨©ª¯®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VYÕaÖuaÙa©Úº2¼ºo¯­+ÃíßWªmË«ÛÂ0û¶ðÛÂo»±3\\000\\0008\\000\\000P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEUeÕeYu]]MÓEÕteÓT]Yu]WV]W%M3MÍóLSó<Ó4UÓMSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓMSeÓUmÙUeW]Ù¶MUeS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨²kªl«ªª»²kë¾,Ë¶,ªªë®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï¦,ª)Û¦ªÊ²,»¶mË²/¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À\\000@	e Ð\\000@\\000\\000`cAhrÎ9RÎ9!sB©dÎA¡¤Ì9¥¤9¡B¥¤ÔZ¡Z+\\000\\000 À\\000 ÀMÅ\\\
\\rY	\\000¤\\000GÓLÓueÙËEUeÛ6Å²DQUeÙ¶cEUeÛÖu4QTUY¶mÝWSUeÙ¶}]82UUm[×}#Um[×¡*Ë¶më¾QI¶m]7ã¨$Û¶îû¾q,ñ¡°,ð_8*\\000\\000ð\\000 VG8),4d%\\000\\000\\000¤QJ)£RJ)ÆR	\\000\\000p\\000\\0000¡²\\\"\\000\\000\\000sÎ9çsÎ9çsÎ9çsÎ9çc1Æc1Æc1Æc1Æc1Æc1Æ\\000ìD8\\000ìDX¬\\000Â\\000\\000R)¥9ç¤RJ)¥ÈA¥RJ)¥DÒI)¥RJ)¥qPJ)¥RJ)¡RJ)¥RJ	¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ\\000&\\000P	6Î°tV8\\\\hÈJ\\000 7\\000\\000P9Æ$JH%JåÎI	)µVB\\\
­\\\
:h£RK­JIB(¡RZ)%µR2¡PJ!¥RJ	¡ePB\\\
%RI-´TJÉ PZ	©ÔZ\\\
%A)©R*­µJJ­ÒR)­µÖJJ!R¥¤R)¥µJk­µNR)-¤ÖRk­VJ)¥JI­µZk)¥VB)­´ÒZ)%µÖRk-ÔZK­¥ÖRk­¥ÖJ)%¥Zk­µZ*)µB)¥Bj©¥ÖJ*-ÐRI¥VZk)¥J(%Z*©µRh¥ÒJI%¥J*)¥ÔR*¡R*¡ÔRk©¥J*-µÔR+©JJ©\\000\\000tà\\000\\000`D¥ØiÆGàB	(\\000\\000\\000@ \\000\\\
d\\000ÀB\\000PX`(]è\\\"HA\\\\8qãNèÐ\\000\\000¡\\\"$dÀEt\\000°¸À(]è\\\"HA\\\\8qãNèÐ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\ÆGÇH\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000OggS\\000\\000\\000\\000\\000\\000\\000a|\\000\\000\\000\\000\\000iC-2	s}{a]_V\\\
.g[½(eºË	X\\000â'{_±Ö/ß¿]7ù=f?gMjîevé¸ÊNøçò`ü7®Ê°ò¹9[2÷¹sÿÈÀSu}îÜ¹Xý¢ð¿ÃÄF1å8ös+ÏSÂøÆRÊí6³÷`\\\
K»'\\000Æ/\\000RUså×ÛvñíG·üóXkÿºçaN=fÆ:F¤ÿLMQÍT;nr4úeæÑÌ$ùµ*tÝ-ãª¼tåuLA|é5â&)wóoF1&n+=¹ÿ^Ue´6®ïÓC,n¿\\000NÉAÒà WRú§ÔùÛª­oï¾~u«X(æhÙË?ÑëP\\\"5áþ^ûÌÈi/4 ýa\\\\J¢GC[ÞKÑä¢Zº.Q^3®ü|\\\\ÞP«oOÕp,-%»àøÀLþ×vyBºëÚuºáiKk	J»IÍÚ¤ì¢%ï¨5ªÓâS¡Ïúü·^o³ï¿g£Î¡s¦Ýðz\\\
ÄÞÄFW1ðím<;11¢J¯J±ÏÃt)p­mcÈûæ6¬Ýd¦axL6î­XÅUGzq]É&{jìeß²ÔnÀ~»¡Z\\\"¯éTÁAHf§´¶Ëò«+:¦±Wí½³Èº/coS#3fæf®¨Lã·X¯&Ýfì~4¤Ø[%¢#\\rÃ>ä­p8Ã|ï@úO0OE7°¼1ÕsVREé\\000é8`tçmÛ¶@ÉîÚbYã¸­Õ43ÝÇùÕ>néîxÝfÏÙÓÔ²r@×Ò*lcÆXmüÓhêx _ðEv´IÞtÑ@ÖX­\\000\\000mbÕ4¼s9ÀãÜìâ±5u¤S_[¨V±Êôåor.q\\\"ì\\\
ûIâø4v­,ì;Oæ:W/e¯2éÜ4¾²iÀ ÷æÊÐ½[)«·µo]v\\000×kÀ]N¨N)gVÏåIo}±êùÒ±óÃÆ\\\\UÃ?õ¤~T¤¼ö}sMÊL¿n2=]¤1Ø\\000¼{&lÖÜ¸\\000ð_@¢Àâ²ò<^¯ÁU\\000I¿$\\000\\000\\000\",\
    [ \"sound/fall.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000'~\\000\\000\\000\\000\\000\\000pÂóvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000'~\\000\\000\\000\\000\\000ÇÑ@[Dÿÿÿÿÿÿÿÿÿÿÿÿvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000 \\\
ÆÐU\\000\\000\\000\\000BFÆP§GÄPóPjé xJaÉôkBß{Ï½÷Þ{ 4d\\000\\000\\000@bà1	B¡Å	Q)Ba9	r:	B÷ .çÞrî½÷\\rY\\000\\000\\0000!B!B\\\
)¥R)¦bÊ1ÇsÌ1È :è¤N2©¤2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊc1Æc1Æc1ÆBCV\\000 \\000\\000AdB!R)¦sÌ1ÇÐU\\000\\000 \\000\\000\\000\\000\\000GÉÉ$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û}ÛwuÙ·}ÙvuYeYwm[uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9#)¬\\000d\\000\\000\\000à(â8#9cI¤IåYåi&j¢¬\\000\\000\\000\\000\\000\\000\\000\\000 (â(#I¥iç©(¦ªª¢iªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i@hÈ*\\000@\\000@ÇqÇQÇqÉ$	\\rY\\000È\\000\\000\\000ÀPGË±$ÍÒ,Ïò4Ñ3=WMÝÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓÐU\\000\\000\\000\\000 B1 4d\\000\\000\\000¢1Ô)%Á¥`!Ä1Ô!ä<Z:RX2&=ÅÂ÷Þsï½÷\\rY\\000\\000\\000FxLB(FqBg\\\
BXN¥NÐ=!Ë¹·{ï½BCV\\000\\000\\000B!B!BJ)b)¦rÌ1Çs2È :é¤L*é¤£L2ê(µRK1Å[n1ÖZkÍ9÷2Æc1Æc1Æc1ÐU\\000\\000\\000\\000aABH!b)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I,É4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeÝÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäH¤\\000¡!«\\000\\000\\000\\000\\0008£8äHåX%ifygy§è¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(¢8ãHeiæyª'¢©ªªhªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i&²\\\
\\000\\000\\000ÐqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç<É³<Çs<É4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000 Ç´$	 äÄÄ¤ ä:%Åä!§ bä9ÉAäÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥9ç¤tR¡¥Rg©´ZbÌ(ÚR­\\rRH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,BCV\\000Q\\000\\0001H)¤b9ÈD1èd1!sNAÇT*uPRÃsA¨ T:GPRG\\000\\000\\000\\000\\000¡Ð@\\000A4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUÝvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×eÓumÙue[WeYø5UeÓumÙt]ÙveW·UYÖmÑu}]eá7eÙ÷e[×}Y·at]ÛWeY÷MY~ÙÝÕu_DQU=U]QU]×t][W]×¶5Õ]ÓumÙT]YVeY÷]WÖuMUeÙeÛ6]WUYöuWu[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}Uu_ÖuauÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_máXeÙøuá[×ßs]_WmÙVÙ6Ý÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^Ý6êÆO¸ß¨©ª¯®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VYÕaÖuaÙa©Úº2¼ºo¯­+ÃíßWªmË«ÛÂ0û¶ðÛÂo»±3\\000\\0008\\000\\000P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEUeÕeYu]]MÓEÕteÓT]Yu]WV]W%M3MÍóLSó<Ó4UÓMSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓMSeÓUmÙUeW]Ù¶MUeS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨²kªl«ªª»²kë¾,Ë¶,ªªë®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï¦,ª)Û¦ªÊ²,»¶mË²/¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À\\000@	e Ð\\000@\\000\\000`cAhrÎ9RÎ9!sB©dÎA¡¤Ì9¥¤9¡B¥¤ÔZ¡Z+\\000\\000 À\\000 ÀMÅ\\\
\\rY	\\000¤\\000GÓLÓueÙËEUeÛ6Å²DQUeÙ¶cEUeÛÖu4QTUY¶mÝWSUeÙ¶}]82UUm[×}#Um[×¡*Ë¶më¾QI¶m]7ã¨$Û¶îû¾q,ñ¡°,ð_8*\\000\\000ð\\000 VG8),4d%\\000\\000\\000¤QJ)£RJ)ÆR	\\000\\000p\\000\\0000¡²\\\"\\000\\000\\000sÎ9çsÎ9çsÎ9çsÎ9çc1Æc1Æc1Æc1Æc1Æc1Æ\\000ìD8\\000ìDX¬\\000Â\\000\\000R)¥9ç¤RJ)¥ÈA¥RJ)¥DÒI)¥RJ)¥qPJ)¥RJ)¡RJ)¥RJ	¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ\\000&\\000P	6Î°tV8\\\\hÈJ\\000 7\\000\\000P9Æ$JH%JåÎI	)µVB\\\
­\\\
:h£RK­JIB(¡RZ)%µR2¡PJ!¥RJ	¡ePB\\\
%RI-´TJÉ PZ	©ÔZ\\\
%A)©R*­µJJ­ÒR)­µÖJJ!R¥¤R)¥µJk­µNR)-¤ÖRk­VJ)¥JI­µZk)¥VB)­´ÒZ)%µÖRk-ÔZK­¥ÖRk­¥ÖJ)%¥Zk­µZ*)µB)¥Bj©¥ÖJ*-ÐRI¥VZk)¥J(%Z*©µRh¥ÒJI%¥J*)¥ÔR*¡R*¡ÔRk©¥J*-µÔR+©JJ©\\000\\000tà\\000\\000`D¥ØiÆGàB	(\\000\\000\\000@ \\000\\\
d\\000ÀB\\000PX`(]è\\\"HA\\\\8qãNèÐ\\000\\000¡\\\"$dÀEt\\000°¸À(]è\\\"HA\\\\8qãNèÐ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\ÆGÇH\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000OggS\\0002\\000\\000\\000\\000\\000\\000'~\\000\\000\\000\\000\\000\\000ï¼®{ub\\\\^]XaUWRNOOQRPSJTQMKQONvL\\000à°*`¥ôô¥díg³}÷n='¶ÑðMp¾6ûG#¯týzÆ»>nÆ]<% ½ô¸þmi:M5&t¤¹äbJJ^\\\"nNó7¡TÉóïs·Ü[>eëø	ôOÞÚL|Ì±3øóÏMþ¨k\\000¡\\000ðÑRJzýiÞåøZYaòå>[b#T=ñNäÜÿ§l%pûãí#Kü*©O¾13BÕ®¼2²)¸ÃZÄæßT7¯ÀïÂÛÊª¬V\\\"Ä$RÏÉòLK­«X	¢Ä¥7\\000£\\\\ÅQ0âå®Ã¾ê\\\\-fÝ{«¦ù=ÑgÙÔR|Å¹Ð_Ü«ÒNÓ0^EDkª­j9iÅle³IÙo `²Ä+n	¤Y`æó()eïCô%Û\\\\È1lÓS}\\000¦­\\\
@<T[62¸R«Ü¹æú¯OÛ®·Òmê¡Ôã§áfÜ*dïÓÈÿ]Ñ¯!~C·¢ÞÏn,*Ê,Êl¼QU¡yèr:Ù­;êNóÒÖv\\000ª»\\\
@\\000û^×ÐÏõå#·ï×gnO§ëu[wa/¯¹°û=kTÈëöSsªíNÇnî1ì%ÙZ\\\\èR·Ü¬g³ßjsÉD,°\\000Íßo éc\\000¢½\\000\\000Àãäc»k¨eÊ£×UûOÝ÷òNY8ºØcÅñB½¹ï#6È§z¨¨|'\\\"`~¥Y\\\"vZ$©n(Hu¹²°(ÊÏ\\\
O½Á¢Ù-Ã¡=½¸,À³5\\000½\\\
D\\000\\000ª?\\000NAiòXuÙ!ôþêÚ¿~.¯W¼¢+\\\"¢AéÊcê!CýmL©	ÞêÖÒ]°¨ÖÏa{±ÞðAQ:ìþb1\\000\\000~¹T\\000x2sîÁvM©dÚìMÖoíý~ª¯ÂY*Ö±ÅO8s^¦µ9^Ø]÷åÀÒLïÔ=ª¯H$ä:\\000	´û`¨=ß&\\rmbXKn\\000³\\000S@úY\\\
xÈHJ\\r*IÇ/{ûõ¨©[óÛoßÙcsô|¶·³Þ¬Æi,¸lF[³&× Àek?¡/Th±ÖP»$æj\\000¡D\\000áDXSÞIq{á0î¼¯Gývìq|»Y¶è°.¾M}ûZþe¿|÷fGdh-àã/\\000=h,¿íyZdãèÞ¨\\\"öb\\000©H\\000W\\000°SjkÐôú:/½äý÷ªb/Öÿïhq«ãàpëM¬Â¤×+E±¼ä\\000|à\\\"FQ2L1sbDÖ¿5@\\000©F\\000\\000=¾rü<ÜöÇÇØ¹)ÓÝùæ6îã¬í©`´ÝJï©so|KkfA9é/\\000p­\\000¸0¡-Ó³¡@bóB\\000z±$	Øìñ\\rÉ÷Si|þ¸^®|õHqì·õ5ãùÖPleÌ=Ä§ôCË	vÌpÕÚÒ R&¬4.,õÈ¶ÙwL(àPìP\\000~³ÆáHwÒ¶¤Ï³ìx¾~½u÷>\\\"/Íêl'cnC¥\\\
~ü;YAaQ½hðI=SB~< =¯<#\\\
ìÖ©0¡C~\\000r­¤	Ø;¿ ­ÎDÉBTrÿßÖe}úlýmÙ³`wÞ²¬<Ç×;i¦°ÒQo`8~Ns¶68)\\\"ÈÍKZa$gæþ:iBÐæ£\\000b§¼lÎsBÖø¸[=Wþf)¯ßº¥<{} ¯h¿q«Å>R9V\\\
Nè&MW*0KnîØHRat/¬u´þ\\000 ôC\\000RÒI\\000àg4Ì½;Úñ¿÷Wäß2ßÞb\\\\(µym$³=ájãþ×©äP¶É©Ñ@ÜO.íl\\\\ädcðð¥OE÷Æ\\000b4ä\\000xóÒ*éÞÿýûÞ£Ö«nGçù±ÌbVYNÕ¸w® Þ}ß¡©7\\\\JMNçY'C62/.¬%ßB*\\rÀ£zûH\\000f(\\000ç\\0008s É$®ÊÄq?~Y6ýÛ4gõaÛéx´u]³ÂY'ÖÙdÒ÷Á,ô¾xvÛÚAÀ\\000úor%|õuqçLJéÑ~RØ\\000R5QRUÉy|ó4Ù³¼ëõs.õüte{è¡ÓGøÆ\\\
QúiÃ¶5Vfâ¡S¤Sú¢³cIÖB(4(TnC\\000NØ\\000\\\"çÇdxVõø©JüÍ~»tûÞýÞhË·I÷³ìø5V,>¦¶jMÒ»ut´xúÁöJ&\\\
 ðõfîLPàÐ¡r.c\\000B \\000À@à¹aj ùzxWÙ~öËí®Ñ¡xZ\\r'(´GbÈ.PòP¯:M=M¥ùpÀÅ­ýç4cÐy_\\0006ÔÐ.\\000Õ)Uüuùp¬ú£§ÒíÁMmé7â¨gu¾Å0ÙM©ÕÀKð×\\rR¥eì©×6c±\\\
»÷mêë8p:0Æt\\0006È\\000Ð1¤@i¡Ð@êzâ}Ó­É~Õo}§&\\\\ç®2õ;Ë3\\r¹¢Ò0Åó¢-8ö\\\
XtöOi«vÑ=Ô8` wì\\000oÔÂP3«S¢4QI4óu7iý¨®XäL(&[Õ[ÑwÚlÆúü;²LaO¢à¸ÛÑn^óÓ\\\"=ÇL1Æ&\\rç\\000MV\\000H´:=7åÄ0dg¿~õùwvËVík·wyÞÏ¼Z´xk;ön(®\\\
÷&E¦cÐÉ½³hÃP\\000\\000\",\
    [ \"ldris2.lua\" ] = \"--[[\\r\\\
\\r\\\
   ,--,\\r\\\
,---.'|\\r\\\
|   | :        ,---,     ,-.----.       ,---,   .--.--.          ,----,\\r\\\
:   : |      .'  .' `\\\\   \\\\    /  \\\\   ,`--.' |  /  /    '.      .'   .' \\\\\\r\\\
|   ' :    ,---.'     \\\\  ;   :    \\\\  |   :  : |  :  /`. /    ,----,'    |\\r\\\
;   ; '    |   |  .`\\\\  | |   | .\\\\ :  :   |  ' ;  |  |--`     |    :  .  ;\\r\\\
'   | |__  :   : |  '  | .   : |: |  |   :  | |  :  ;_       ;    |.'  /\\r\\\
|   | :.'| |   ' '  ;  : |   |  \\\\ :  '   '  ;  \\\\  \\\\    `.    `----'/  ;\\r\\\
'   :    ; '   | ;  .  | |   : .  /  |   |  |   `----.   \\\\     /  ;  /\\r\\\
|   |  ./  |   | :  |  ' ;   | |  \\\\  '   :  ;   __ \\\\  \\\\  |    ;  /  /-,\\r\\\
;   : ;    '   : | /  ;  |   | ;\\\\  \\\\ |   |  '  /  /`--'  /   /  /  /.`|\\r\\\
|   ,/     |   | '` ,/   :   ' | \\\\.' '   :  | '--'.     /  ./__;      :\\r\\\
'---'      ;   :  .'     :   : :-'   ;   |.'    `--'---'   |   :    .'\\r\\\
           |   ,.'       |   |.'     '---'                 ;   | .'\\r\\\
           '---'         `---'                             `---'\\r\\\
\\r\\\
LDRIS 2 (Work in Progress)\\r\\\
Last update: April 4th 2025\\r\\\
\\r\\\
Current features:\\r\\\
	+ Real SRS rotation and wall-kicking!\\r\\\
	+ 7bag randomization!\\r\\\
	+ Modern-feeling controls!\\r\\\
	+ Ghost piece!\\r\\\
	+ Piece holding!\\r\\\
	+ Sonic drop!\\r\\\
	+ Configurable SDF, DAS, ARR, ARE, lock delay, etc.!\\r\\\
	+ Piece queue! It's even animated!\\r\\\
\\r\\\
To-do:\\r\\\
	+ Turn the GameState into an object like Minos and Boards\\r\\\
	+ Add score, and let lineclears and piece dropping add to it\\r\\\
	+ Add an actual menu, and not that shit LDRIS 1 had\\r\\\
	+ Multiplayer, as well as an implementation of garbage\\r\\\
	+ Cheese race mode\\r\\\
	+ Define color palletes so that the ghost piece isn't the color of dirt\\r\\\
	+ Add in-game menu for changing controls (some people can actually tolerate guideline)\\r\\\
]]\\r\\\
\\r\\\
local scr_x, scr_y = term.getSize()\\r\\\
\\r\\\
local Board = require \\\"lib.board\\\"\\r\\\
local Mino = require \\\"lib.mino\\\"\\r\\\
local GameInstance = require \\\"lib.gameinstance\\\"\\r\\\
local Control = require \\\"lib.control\\\"\\r\\\
\\r\\\
-- client config can be changed however you please\\r\\\
local clientConfig = require \\\"lib.clientconfig\\\"\\r\\\
\\r\\\
-- ideally, only clients with IDENTICAL game configs should face one another\\r\\\
local gameConfig = require \\\"lib.gameconfig\\\"\\r\\\
\\r\\\
-- localize commonly used functions\\r\\\
local stringrep = string.rep\\r\\\
\\r\\\
local cospc_debuglog = require \\\"lib.debug\\\"\\r\\\
\\r\\\
-- recursively copies the contents of a table\\r\\\
table.copy = function(tbl)\\r\\\
	local output = {}\\r\\\
	for k,v in pairs(tbl) do\\r\\\
		output[k] = (type(v) == \\\"table\\\" and k ~= v) and table.copy(v) or v\\r\\\
	end\\r\\\
	return output\\r\\\
end\\r\\\
\\r\\\
local roundToPlaces = function(number, places)\\r\\\
	return math.floor(number * 10^places) / (10^places)\\r\\\
end\\r\\\
\\r\\\
-- current state of the game; can be used to perfectly recreate the current scene of a game\\r\\\
-- that includes board and mino objects, bitch\\r\\\
-- gameState = {}\\r\\\
\\r\\\
-- gameConfig.minos = require \\\"lib.minodata\\\"\\r\\\
gameConfig.kickTables = require \\\"lib.kicktables\\\"\\r\\\
\\r\\\
-- returns a number that's capped between 'min' and 'max', inclusively\\r\\\
local function between(number, min, max)\\r\\\
	return math.min(math.max(number, min), max)\\r\\\
end\\r\\\
\\r\\\
-- image-related functions (from NFTE)\\r\\\
local loadImageDataNFT = function(image, background) -- string image\\r\\\
	local output = {{},{},{}} -- char, text, back\\r\\\
	local y = 1\\r\\\
	background = (background or \\\"f\\\"):sub(1,1)\\r\\\
	local text, back = \\\"f\\\", background\\r\\\
	local doSkip, c1, c2 = false\\r\\\
	local tchar = string.char(31)	-- for text colors\\r\\\
	local bchar = string.char(30)	-- for background colors\\r\\\
	local maxX = 0\\r\\\
	local bx\\r\\\
	for i = 1, #image do\\r\\\
		if doSkip then\\r\\\
			doSkip = false\\r\\\
		else\\r\\\
			output[1][y] = output[1][y] or \\\"\\\"\\r\\\
			output[2][y] = output[2][y] or \\\"\\\"\\r\\\
			output[3][y] = output[3][y] or \\\"\\\"\\r\\\
			c1, c2 = image:sub(i,i), image:sub(i+1,i+1)\\r\\\
			if c1 == tchar then\\r\\\
				text = c2\\r\\\
				doSkip = true\\r\\\
			elseif c1 == bchar then\\r\\\
				back = c2\\r\\\
				doSkip = true\\r\\\
			elseif c1 == \\\"\\\\n\\\" then\\r\\\
				maxX = math.max(maxX, #output[1][y])\\r\\\
				y = y + 1\\r\\\
				text, back = \\\" \\\", background\\r\\\
			else\\r\\\
				output[1][y] = output[1][y]..c1\\r\\\
				output[2][y] = output[2][y]..text\\r\\\
				output[3][y] = output[3][y]..back\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
	for y = 1, #output[1] do\\r\\\
		output[1][y] = output[1][y] .. (\\\" \\\"):rep(maxX - #output[1][y])\\r\\\
		output[2][y] = output[2][y] .. (\\\" \\\"):rep(maxX - #output[2][y])\\r\\\
		output[3][y] = output[3][y] .. (background):rep(maxX - #output[3][y])\\r\\\
	end\\r\\\
	return output\\r\\\
end\\r\\\
\\r\\\
-- draws an image with the topleft corner at (x, y), with transparency\\r\\\
local drawImageTransparent = function(image, x, y, terminal)\\r\\\
	terminal = terminal or term.current()\\r\\\
	local cx, cy = terminal.getCursorPos()\\r\\\
	local c, t, b\\r\\\
	for iy = 1, #image[1] do\\r\\\
		for ix = 1, #image[1][iy] do\\r\\\
			c, t, b = image[1][iy]:sub(ix,ix), image[2][iy]:sub(ix,ix), image[3][iy]:sub(ix,ix)\\r\\\
			if b ~= \\\" \\\" or c ~= \\\" \\\" then\\r\\\
				terminal.setCursorPos(x + (ix - 1), y + (iy - 1))\\r\\\
				terminal.blit(c, t, b)\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
	terminal.setCursorPos(cx,cy)\\r\\\
end\\r\\\
\\r\\\
local GameInstance = require \\\"lib.gameinstance\\\"\\r\\\
\\r\\\
\\r\\\
local TitleScreen = function()\\r\\\
	local animation = function()\\r\\\
		local tsx = 8\\r\\\
		local tsy = 10\\r\\\
		--[[\\r\\\
		local title = {\\r\\\
			[1] = \\\"eeÂ\\\\neeÂ\\\\neeÂfÂfeÂ\\\",\\r\\\
			[2] = \\\"ddÂfÂdfÂfdÂ\\\\nddÂ   dfÂfdÂ\\\\nddÂfÂfdÂÂ\\\",\\r\\\
			[3] = \\\"11ÂfÂ1fÂf1Â\\\\n11ÂfÂÂf1Â\\\\n11Â   11ÂfÂ\\\",\\r\\\
			[4] = \\\"afÂfaÂ\\\\nafÂfaÂ\\\\nafÂÂ\\\",\\r\\\
			[5] = \\\"3fÂ3ÂfÂ3fÂ\\\\nfÂ3Â3fÂf3Â\\\\n3fÂÂÂf3Â\\\",\\r\\\
			[6] = \\\"4fÂf4ÂÂ4fÂ\\\\n   4fÂÂf4Â\\\\n4fÂ4ÂfÂÂ\\\"\\r\\\
		}\\r\\\
		--]]\\r\\\
		\\r\\\
		--[[\\r\\\
			1 = \\\"    \\\",\\r\\\
				\\\"@@@@\\\",\\r\\\
				\\\"    \\\",\\r\\\
				\\\"    \\\",\\r\\\
\\r\\\
			2 = \\\" @ \\\",\\r\\\
				\\\"@@@\\\",\\r\\\
				\\\"    \\\",\\r\\\
\\r\\\
			3 = \\\"  @\\\",\\r\\\
				\\\"@@@\\\",\\r\\\
				\\\"   \\\",\\r\\\
				\\r\\\
			4 = \\\"@  \\\",\\r\\\
				\\\"@@@\\\",\\r\\\
				\\\"   \\\",\\r\\\
\\r\\\
			5 = \\\"@@\\\",\\r\\\
				\\\"@@\\\",\\r\\\
\\r\\\
			6 = \\\" @@\\\",\\r\\\
				\\\"@@ \\\",\\r\\\
				\\\"   \\\",\\r\\\
\\r\\\
			7 = \\\"@@ \\\",\\r\\\
				\\\" @@\\\",\\r\\\
				\\\"   \\\",\\r\\\
		]]\\r\\\
\\r\\\
		local animBoard = Board:New(1, 1, scr_x, scr_y * 10/3, \\\"f\\\")\\r\\\
		animBoard.visibleHeight = animBoard.height / 2\\r\\\
\\r\\\
		local animMinos = {}\\r\\\
\\r\\\
		local iterate = 0\\r\\\
		local mTimer = 100000\\r\\\
		\\r\\\
		local titleMinos = {\\r\\\
			-- L\\r\\\
			Mino:New(nil, 4, animBoard, tsx + 1, tsy).Rotate(0),\\r\\\
			Mino:New(nil, 1, animBoard, tsx + 0, tsy).Rotate(3),\\r\\\
			\\r\\\
			-- D\\r\\\
			Mino:New(nil, 7, animBoard, tsx + 6, tsy).Rotate(3),\\r\\\
			Mino:New(nil, 3, animBoard, tsx + 4, tsy).Rotate(1),\\r\\\
			nil\\r\\\
		}\\r\\\
\\r\\\
		for i = 1, #titleMinos do\\r\\\
			if titleMinos[i] then\\r\\\
				table.insert(animMinos, titleMinos[i])\\r\\\
			end\\r\\\
		end\\r\\\
\\r\\\
		while true do\\r\\\
			iterate = (iterate + 10) % 360\\r\\\
\\r\\\
			if mTimer <= 0 then\\r\\\
				table.insert(animMinos, Mino:New(nil,\\r\\\
					math.random(1, 7),\\r\\\
					animBoard,\\r\\\
					math.random(1, animBoard.width - 4),\\r\\\
					animBoard.visibleHeight - 4\\r\\\
				))\\r\\\
				mTimer = 4\\r\\\
			else\\r\\\
				mTimer = mTimer - 1\\r\\\
			end\\r\\\
\\r\\\
			for i = 1, #animMinos do\\r\\\
				animMinos[i]:Move(0, 0.75, false)\\r\\\
				if animMinos[i].y > animBoard.height then\\r\\\
					table.remove(animMinos, i)\\r\\\
				end\\r\\\
			end\\r\\\
\\r\\\
			animBoard:Render(table.unpack(animMinos))\\r\\\
\\r\\\
			sleep(0.05)\\r\\\
		end\\r\\\
	end\\r\\\
	local menu = function()\\r\\\
		local options = {\\\"Singleplayer\\\", \\\"How to play\\\", \\\"Quit\\\"}\\r\\\
		\\r\\\
	end\\r\\\
	--animation()\\r\\\
	--StartGame(true, 0, 0)\\r\\\
	--[[\\r\\\
	parallel.waitForAny(function()\\r\\\
		cospc_debuglog(1, \\\"Starting game.\\\")\\r\\\
		StartGame(1, true, 0, 0)\\r\\\
		cospc_debuglog(1, \\\"Game concluded.\\\")\\r\\\
	end, function()\\r\\\
		while true do\\r\\\
			cospc_debuglog(2, \\\"Starting game.\\\")\\r\\\
			StartGame(2, false, 24, 0)\\r\\\
			cospc_debuglog(2, \\\"Game concluded.\\\")\\r\\\
		end\\r\\\
	end)\\r\\\
	--]]\\r\\\
	local tickTimer = os.startTimer(gameConfig.tickDelay)\\r\\\
	\\r\\\
	local GAMES = {\\r\\\
		GameInstance:New(1, Control:New(clientConfig, true),  0,  0, clientConfig):Initiate(),\\r\\\
		GameInstance:New(2, Control:New(clientConfig, false), 24, 0, clientConfig):Initiate()\\r\\\
	}\\r\\\
	\\r\\\
	local message, doTick\\r\\\
	local keysDown = {}\\r\\\
	\\r\\\
	cospc_debuglog(2, \\\"Starting game.\\\")\\r\\\
	\\r\\\
	while true do\\r\\\
		evt = {os.pullEvent()}\\r\\\
		\\r\\\
		if evt[1] == \\\"timer\\\" and evt[2] == tickTimer then\\r\\\
			doTick = true\\r\\\
			tickTimer = os.startTimer(gameConfig.tickDelay)\\r\\\
		else\\r\\\
			doTick = false\\r\\\
		end\\r\\\
		\\r\\\
		if evt[1] == \\\"key\\\" and evt[2] == keys.tab then\\r\\\
			-- swap playable game\\r\\\
			GAMES[1].control:Clear()\\r\\\
			GAMES[2].control:Clear()\\r\\\
			GAMES[1].control.native_control = not GAMES[1].control.native_control\\r\\\
			GAMES[2].control.native_control = not GAMES[2].control.native_control\\r\\\
		end\\r\\\
		\\r\\\
		-- run games\\r\\\
		for i, GAME in ipairs(GAMES) do\\r\\\
			message = GAME:Resume(evt, doTick) or {}\\r\\\
			\\r\\\
			-- end game\\r\\\
			if message.finished then\\r\\\
				cospc_debuglog(i, \\\"Game over!\\\")\\r\\\
				-- for demo purposes, just restart games that fail if they aren't the player\\r\\\
				if i ~= 1 then\\r\\\
					GAME:Initiate()\\r\\\
				else\\r\\\
					return\\r\\\
				end\\r\\\
			end\\r\\\
			\\r\\\
			-- deal garbage attacks to other game instances\\r\\\
			if message.attack then\\r\\\
				for _i, _GAME in ipairs(GAMES) do\\r\\\
					if _i ~= i then\\r\\\
						_GAME:ReceiveGarbage(message.attack)\\r\\\
					end\\r\\\
				end\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
term.clear()\\r\\\
\\r\\\
cospc_debuglog(nil, 0)\\r\\\
\\r\\\
cospc_debuglog(nil, \\\"Opened LDRIS2.\\\")\\r\\\
\\r\\\
TitleScreen()\\r\\\
\\r\\\
cospc_debuglog(nil, \\\"Closed LDRIS2.\\\")\\r\\\
\\r\\\
term.setCursorPos(1, scr_y - 1)\\r\\\
term.clearLine()\\r\\\
print(\\\"Thank you for playing!\\\")\\r\\\
term.setCursorPos(1, scr_y - 0)\\r\\\
term.clearLine()\\r\\\
\\r\\\
sleep(0.05)\\r\\\
\",\
    [ \"backup/lib/board.lua\" ] = \"-- generates a new board, on which polyominos can be placed and interact\\r\\\
local Board = {}\\r\\\
\\r\\\
local gameConfig = require \\\"lib.gameconfig\\\"\\r\\\
\\r\\\
local stringrep = string.rep\\r\\\
\\r\\\
function Board:New(x, y, width, height, blankColor)\\r\\\
	\\r\\\
	local board = setmetatable({}, self)\\r\\\
    self.__index = self\\r\\\
	\\r\\\
	board.contents = {}\\r\\\
	board.height = height or gameConfig.board_height\\r\\\
	board.width = width or gameConfig.board_width\\r\\\
	board.x, board.y = x, y\\r\\\
	board.blankColor = blankColor or \\\"7\\\"	-- color if no minos are in that spot\\r\\\
	board.transparentColor = \\\"f\\\"         -- color if the board tries to render where there is no board\\r\\\
	board.garbageColor = \\\"8\\\"\\r\\\
	board.visibleHeight = height and math.floor(board.height / 2) or gameConfig.board_height_visible\\r\\\
	board.alignFromBottom = false\\r\\\
\\r\\\
	for y = 1, board.height do\\r\\\
		board.contents[y] = stringrep(board.blankColor, board.width)\\r\\\
	end\\r\\\
	\\r\\\
	return board\\r\\\
end\\r\\\
\\r\\\
function Board:Write(x, y, color)\\r\\\
	x = math.floor(x)\\r\\\
	y = math.floor(y)\\r\\\
	if not self.contents[y] then\\r\\\
		error(\\\"tried to write outsite size of board!\\\")\\r\\\
	end\\r\\\
	self.contents[y] = self.contents[y]:sub(1, x - 1) .. color .. self.contents[y]:sub(x + 1)\\r\\\
end\\r\\\
\\r\\\
function Board:AddGarbage(amount)\\r\\\
	local changePercent = 00	-- higher the percent, the more likely it is that subsequent rows of garbage will have a different hole\\r\\\
	local holeX = math.random(1, self.width)\\r\\\
	for y = amount, self.height do\\r\\\
		self.contents[y - amount + 1] = self.contents[y]\\r\\\
	end\\r\\\
	for y = self.height, self.height - amount + 1, -1 do\\r\\\
		self.contents[y] = stringrep(self.garbageColor, holeX - 1) .. self.blankColor .. stringrep(self.garbageColor, self.width - holeX)\\r\\\
		if math.random(1, 100) <= changePercent then\\r\\\
			holeX = math.random(1, self.width)\\r\\\
		end\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
function Board:Clear(color)\\r\\\
	color = color or self.blankColor\\r\\\
	for y = 1, self.height do\\r\\\
		self.contents[y] = stringrep(color, self.width)\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
-- used for sending board data over the network\\r\\\
function Board:Serialize(doIncludeInit)\\r\\\
	return textutils.serialize({\\r\\\
		x             = doIncludeInit and self.x or nil,\\r\\\
		y             = doIncludeInit and self.y or nil,\\r\\\
		height        = doIncludeInit and self.height or nil,\\r\\\
		width         = doIncludeInit and self.width or nil,\\r\\\
		blankColor    = doIncludeInit and self.blankColor or nil,\\r\\\
		visibleHeight = self.visibleHeight or nil,\\r\\\
		contents      = self.contents\\r\\\
	})\\r\\\
end\\r\\\
\\r\\\
-- takes list of minos that it will render atop the board\\r\\\
function Board:Render(...)\\r\\\
	local charLine1 = stringrep(\\\"\\\\131\\\", self.width)\\r\\\
	local charLine2 = stringrep(\\\"\\\\143\\\", self.width)\\r\\\
	local transparentLine = stringrep(self.transparentColor, self.width)\\r\\\
	local colorLine1, colorLine2, colorLine3\\r\\\
	local minoColor1, minoColor2, minoColor3\\r\\\
	local minos = {...}\\r\\\
	local mino, tY\\r\\\
\\r\\\
	if self.alignFromBottom then\\r\\\
\\r\\\
		tY = self.y + math.floor((self.height - self.visibleHeight) * (2 / 3)) - 2\\r\\\
\\r\\\
		for y = self.height, 1 + (board.height - self.visibleHeight), -3 do\\r\\\
			colorLine1, colorLine2, colorLine3 = \\\"\\\", \\\"\\\", \\\"\\\"\\r\\\
			for x = 1, self.width do\\r\\\
\\r\\\
				minoColor1, minoColor2, minoColor3 = nil, nil, nil\\r\\\
				for i = 1, #minos do\\r\\\
					mino = minos[i]\\r\\\
					if mino.visible then\\r\\\
						if mino:CheckSolid(x, y - 0, true) then\\r\\\
							minoColor1 = mino.color\\r\\\
						end\\r\\\
						if mino:CheckSolid(x, y - 1, true) then\\r\\\
							minoColor2 = mino.color\\r\\\
						end\\r\\\
						if mino:CheckSolid(x, y - 2, true) then\\r\\\
							minoColor3 = mino.color\\r\\\
						end\\r\\\
					end\\r\\\
				end\\r\\\
\\r\\\
				colorLine1 = colorLine1 .. (minoColor1 or ((self.contents[y - 0] and self.contents[y - 0]:sub(x, x)) or self.blankColor))\\r\\\
				colorLine2 = colorLine2 .. (minoColor2 or ((self.contents[y - 1] and self.contents[y - 1]:sub(x, x)) or self.blankColor))\\r\\\
				colorLine3 = colorLine3 .. (minoColor3 or ((self.contents[y - 2] and self.contents[y - 2]:sub(x, x)) or self.blankColor))\\r\\\
\\r\\\
			end\\r\\\
\\r\\\
			if (y - 0) <= (self.height - self.visibleHeight) then\\r\\\
				colorLine1 = transparentLine\\r\\\
			end\\r\\\
			if (y - 1) <= (self.height - self.visibleHeight) then\\r\\\
				colorLine2 = transparentLine\\r\\\
			end\\r\\\
			if (y - 2) <= (self.height - self.visibleHeight) then\\r\\\
				colorLine3 = transparentLine\\r\\\
			end\\r\\\
\\r\\\
			term.setCursorPos(self.x, self.y + tY)\\r\\\
			term.blit(charLine1, colorLine2, colorLine1)\\r\\\
			tY = tY - 1\\r\\\
			term.setCursorPos(self.x, self.y + tY)\\r\\\
			term.blit(charLine2, colorLine3, colorLine2)\\r\\\
			tY = tY - 1\\r\\\
		end\\r\\\
	\\r\\\
	else\\r\\\
\\r\\\
		tY = self.y\\r\\\
\\r\\\
		for y = 1 + (self.height - self.visibleHeight), self.height, 3 do\\r\\\
			colorLine1, colorLine2, colorLine3 = \\\"\\\", \\\"\\\", \\\"\\\"\\r\\\
			for x = 1, self.width do\\r\\\
\\r\\\
				minoColor1, minoColor2, minoColor3 = nil, nil, nil\\r\\\
				for i = 1, #minos do\\r\\\
					mino = minos[i]\\r\\\
					if mino.visible then\\r\\\
						if mino:CheckSolid(x, y + 0, true) then\\r\\\
							minoColor1 = mino.color\\r\\\
						end\\r\\\
						if mino:CheckSolid(x, y + 1, true) then\\r\\\
							minoColor2 = mino.color\\r\\\
						end\\r\\\
						if mino:CheckSolid(x, y + 2, true) then\\r\\\
							minoColor3 = mino.color\\r\\\
						end\\r\\\
					end\\r\\\
				end\\r\\\
\\r\\\
				colorLine1 = colorLine1 .. (minoColor1 or ((self.contents[y + 0] and self.contents[y + 0]:sub(x, x)) or self.blankColor))\\r\\\
				colorLine2 = colorLine2 .. (minoColor2 or ((self.contents[y + 1] and self.contents[y + 1]:sub(x, x)) or self.blankColor))\\r\\\
				colorLine3 = colorLine3 .. (minoColor3 or ((self.contents[y + 2] and self.contents[y + 2]:sub(x, x)) or self.blankColor))\\r\\\
\\r\\\
			end\\r\\\
\\r\\\
			if (y + 0) > self.height or (y + 0) <= (self.height - self.visibleHeight) then\\r\\\
				colorLine1 = transparentLine\\r\\\
			end\\r\\\
			if (y + 1) > self.height or (y + 1) <= (self.height - self.visibleHeight) then\\r\\\
				colorLine2 = transparentLine\\r\\\
			end\\r\\\
			if (y + 2) > self.height or (y + 2) <= (self.height - self.visibleHeight) then\\r\\\
				colorLine3 = transparentLine\\r\\\
			end\\r\\\
\\r\\\
			term.setCursorPos(self.x, self.y + tY)\\r\\\
			term.blit(charLine2, colorLine1, colorLine2)\\r\\\
			tY = tY + 1\\r\\\
			term.setCursorPos(self.x, self.y + tY)\\r\\\
			term.blit(charLine1, colorLine2, colorLine3)\\r\\\
			tY = tY + 1\\r\\\
			\\r\\\
		end\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
return Board\",\
    [ \"sound/drop.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\0002\\\\\\000\\000\\000\\000\\000\\000°{Ovorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\0002\\\\\\000\\000\\000\\000\\000ROá!Dÿÿÿÿÿÿÿÿÿÿÿÿvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000 \\\
ÆÐU\\000\\000\\000\\000BFÆP§GÄPóPjé xJaÉôkBß{Ï½÷Þ{ 4d\\000\\000\\000@bà1	B¡Å	Q)Ba9	r:	B÷ .çÞrî½÷\\rY\\000\\000\\0000!B!B\\\
)¥R)¦bÊ1ÇsÌ1È :è¤N2©¤2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊc1Æc1Æc1ÆBCV\\000 \\000\\000AdB!R)¦sÌ1ÇÐU\\000\\000 \\000\\000\\000\\000\\000GÉÉ$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û}ÛwuÙ·}ÙvuYeYwm[uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9#)¬\\000d\\000\\000\\000à(â8#9cI¤IåYåi&j¢¬\\000\\000\\000\\000\\000\\000\\000\\000 (â(#I¥iç©(¦ªª¢iªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i@hÈ*\\000@\\000@ÇqÇQÇqÉ$	\\rY\\000È\\000\\000\\000ÀPGË±$ÍÒ,Ïò4Ñ3=WMÝÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓÐU\\000\\000\\000\\000 B1 4d\\000\\000\\000¢1Ô)%Á¥`!Ä1Ô!ä<Z:RX2&=ÅÂ÷Þsï½÷\\rY\\000\\000\\000FxLB(FqBg\\\
BXN¥NÐ=!Ë¹·{ï½BCV\\000\\000\\000B!B!BJ)b)¦rÌ1Çs2È :é¤L*é¤£L2ê(µRK1Å[n1ÖZkÍ9÷2Æc1Æc1Æc1ÐU\\000\\000\\000\\000aABH!b)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I,É4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeÝÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäH¤\\000¡!«\\000\\000\\000\\000\\0008£8äHåX%ifygy§è¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(¢8ãHeiæyª'¢©ªªhªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i&²\\\
\\000\\000\\000ÐqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç<É³<Çs<É4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000 Ç´$	 äÄÄ¤ ä:%Åä!§ bä9ÉAäÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥9ç¤tR¡¥Rg©´ZbÌ(ÚR­\\rRH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,BCV\\000Q\\000\\0001H)¤b9ÈD1èd1!sNAÇT*uPRÃsA¨ T:GPRG\\000\\000\\000\\000\\000¡Ð@\\000A4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUÝvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×eÓumÙue[WeYø5UeÓumÙt]ÙveW·UYÖmÑu}]eá7eÙ÷e[×}Y·at]ÛWeY÷MY~ÙÝÕu_DQU=U]QU]×t][W]×¶5Õ]ÓumÙT]YVeY÷]WÖuMUeÙeÛ6]WUYöuWu[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}Uu_ÖuauÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_máXeÙøuá[×ßs]_WmÙVÙ6Ý÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^Ý6êÆO¸ß¨©ª¯®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VYÕaÖuaÙa©Úº2¼ºo¯­+ÃíßWªmË«ÛÂ0û¶ðÛÂo»±3\\000\\0008\\000\\000P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEUeÕeYu]]MÓEÕteÓT]Yu]WV]W%M3MÍóLSó<Ó4UÓMSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓMSeÓUmÙUeW]Ù¶MUeS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨²kªl«ªª»²kë¾,Ë¶,ªªë®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï¦,ª)Û¦ªÊ²,»¶mË²/¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À\\000@	e Ð\\000@\\000\\000`cAhrÎ9RÎ9!sB©dÎA¡¤Ì9¥¤9¡B¥¤ÔZ¡Z+\\000\\000 À\\000 ÀMÅ\\\
\\rY	\\000¤\\000GÓLÓueÙËEUeÛ6Å²DQUeÙ¶cEUeÛÖu4QTUY¶mÝWSUeÙ¶}]82UUm[×}#Um[×¡*Ë¶më¾QI¶m]7ã¨$Û¶îû¾q,ñ¡°,ð_8*\\000\\000ð\\000 VG8),4d%\\000\\000\\000¤QJ)£RJ)ÆR	\\000\\000p\\000\\0000¡²\\\"\\000\\000\\000sÎ9çsÎ9çsÎ9çsÎ9çc1Æc1Æc1Æc1Æc1Æc1Æ\\000ìD8\\000ìDX¬\\000Â\\000\\000R)¥9ç¤RJ)¥ÈA¥RJ)¥DÒI)¥RJ)¥qPJ)¥RJ)¡RJ)¥RJ	¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ\\000&\\000P	6Î°tV8\\\\hÈJ\\000 7\\000\\000P9Æ$JH%JåÎI	)µVB\\\
­\\\
:h£RK­JIB(¡RZ)%µR2¡PJ!¥RJ	¡ePB\\\
%RI-´TJÉ PZ	©ÔZ\\\
%A)©R*­µJJ­ÒR)­µÖJJ!R¥¤R)¥µJk­µNR)-¤ÖRk­VJ)¥JI­µZk)¥VB)­´ÒZ)%µÖRk-ÔZK­¥ÖRk­¥ÖJ)%¥Zk­µZ*)µB)¥Bj©¥ÖJ*-ÐRI¥VZk)¥J(%Z*©µRh¥ÒJI%¥J*)¥ÔR*¡R*¡ÔRk©¥J*-µÔR+©JJ©\\000\\000tà\\000\\000`D¥ØiÆGàB	(\\000\\000\\000@ \\000\\\
d\\000ÀB\\000PX`(]è\\\"HA\\\\8qãNèÐ\\000\\000¡\\\"$dÀEt\\000°¸À(]è\\\"HA\\\\8qãNèÐ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\ÆGÇH\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000OggS\\000m\\000\\000\\000\\000\\000\\0002\\\\\\000\\000\\000\\000\\000Wy5éyfddhde\\\\XMTJµ÷ )]a¯¾\\\
·-¥¥RªÖü_~Ë¾^ýüïq¦zïÜëçyNê&o?hr»ûa&±$¡1m&?5õã3\\\
üÑSSÂ¿2ßú\\\"±¯ÉÏßOO­|NGùÿGî_+O¬ÿjÜ¬pp´4ÿË:\\000V±+Ô@§>wäAcNu)³|kwëR?Ë½O'|ÁP}Þ§¦Ëg	KM_f|ÕA,SÅ÷SÆ[³ò¥ØºÃÕæi£Î´OÞYX£s,¦xyÛÜV?c'iu¡¨h¬ß%BÊì\\\"ZI>ëk§,²Ù¶Z.\\\\ÿLûµè6[\\\
\\000~£²Q ÓÝg±TnaìóëùøØÓ«Æüø¶°óÍå5D=Ø2ÆG2ncu³akûù¸èËç¤é¢è¶´(ÎR8§´r3ß%Ï··­KÍ]k1¡mÏL²xãj\\000ØÚ%9t|?U<Z©zþß{tÇ¦Z{tUÖ¹Q5G$å/ª¼×Í¶Û$ÚöÝ×p¾¶)õ\\000\\\
ùíÓTþü\\000~ïº»=çøñ!Ú(×C·A\\000§¤2hÊèô¼ÌNEÛfä*[jnõDó>GíóN:*·9Ýe&SWüõsÏ¿7gç<-Ü&äF©­©×?)võôB¼[%o},£àFÇH\\\
$°®¶%¥Õ\\000£¤òÍxéÞýdT	b>9/éqmù²<É-¢¶ô}{v6µè±è!7ö`§²Éël¿NÔmÒa-YÛÆ/=!`Ü¬½\\\"ôbiÝ¯ ÆIÈßÚmXµ~n§\\0000ûæXJ,Iß»y¹.öm«ÒÁf>çZù>ï-®¦M±>ß7<ÏÅ±ÂXwmb¾ê:¾±Cê¬n¨HÔ«¹MQ¸Éic5¿=¶å`ÃUÖì×¼KQ@Zm87¨vIÏÝªâ.ÎÇd\\000ÆäEó§o¶ô^ë¬M{+öUs1vÍ¡-í+å=Uq¬¾_@¡#ï]éñmh<ëû¨ñ@Þ[L?ïÁA8nAzSt	\\000e»êe\\000rwTâ+Lº§òÄÀãskóÎz»=qû]Ûºeals¤Ú­k;OßFXæaZº.KÃúæ>¡ÐË,x{¬-5ó·\\\
>6f(\\000NyÂc\\\\`îj¿N~Àd5\\000@y3íõ·eYëÞûBêC*ùãøüùÙ Ã\\\\5Ð©áe\\rE7¡O»²sÉèÀ¼[È'fÁfj`\\\
\\000ZcsvÖhØl}{:ü=S×@ÒäÉÈÏÖ÷{óHýQÀW?ÕKäµµîÇ|tÀúLèôËãbkkÅÀ½clÞ=0Ud\\\\vI\\000\\0007kî·Ì\\\\GíÞW½&#ºª}éùëWóÅ)n¾ÚÈçªuÙêk]'Þ*ÊòÛÀGq\\\\5Zaæg¾$»8&»´¨È=`\\000\",\
    [ \"lib/mino.lua\" ] = \"-- makes a Mino, a tetris piece that can be rendered on a Board\\r\\\
local Mino = {}\\r\\\
\\r\\\
local gameConfig = require \\\"lib.gameconfig\\\"\\r\\\
--gameConfig.minos = require \\\"lib.minodata\\\"\\r\\\
\\r\\\
local stringrep = string.rep\\r\\\
\\r\\\
function Mino:New(minoTable, minoID, board, xPos, yPos, oldeMino)\\r\\\
	local mino = setmetatable(oldeMino or {}, self)\\r\\\
    self.__index = self\\r\\\
	\\r\\\
	local minoTable = minoTable or gameConfig.minos\\r\\\
	if not minoTable[minoID] then\\r\\\
		error(\\\"tried to spawn mino with invalid ID '\\\" .. tostring(minoID) .. \\\"'\\\")\\r\\\
	else\\r\\\
		mino.shape = minoTable[minoID].shape\\r\\\
		mino.spinID = minoTable[minoID].spinID\\r\\\
		mino.kickID = minoTable[minoID].kickID\\r\\\
		mino.color = minoTable[minoID].color\\r\\\
		mino.name = minoTable[minoID].name\\r\\\
	end\\r\\\
\\r\\\
	mino.finished = false\\r\\\
	mino.active = true\\r\\\
	mino.spawnTimer = 0\\r\\\
	mino.visible = true\\r\\\
	mino.height = #mino.shape\\r\\\
	mino.width = #mino.shape[1]\\r\\\
	mino.minoID = minoID\\r\\\
	mino.x = xPos\\r\\\
	mino.y = yPos\\r\\\
	mino.xFloat = 0\\r\\\
	mino.yFloat = 0\\r\\\
	mino.board = board\\r\\\
	mino.rotation = 0\\r\\\
	mino.resting = false\\r\\\
	mino.lockTimer = 0\\r\\\
	mino.movesLeft = gameConfig.lock_move_limit\\r\\\
	mino.yHighest = mino.y\\r\\\
\\r\\\
	return mino\\r\\\
end\\r\\\
\\r\\\
function Mino:Serialize(doIncludeInit)\\r\\\
	return textutils.serialize({\\r\\\
		minoID = doIncludeInit and self.minoID or nil,\\r\\\
		rotation = self.rotation,\\r\\\
		x = x,\\r\\\
		y = y,\\r\\\
	})\\r\\\
end\\r\\\
\\r\\\
-- takes absolute position (x, y) on board, and returns true if it exists within the bounds of the board\\r\\\
function Mino:DoesSpotExist(x, y)\\r\\\
	return self.board and (\\r\\\
		x >= 1 and\\r\\\
		x <= self.board.width and\\r\\\
		y >= 1 and\\r\\\
		y <= self.board.height\\r\\\
	)\\r\\\
end\\r\\\
\\r\\\
-- checks if the mino is colliding with solid objects on its board, shifted by xMod and/or yMod (default 0)\\r\\\
-- if doNotCountBorder == true, the border of the board won't be considered as solid\\r\\\
-- returns true if it IS colliding, and false if it is not\\r\\\
function Mino:CheckCollision(xMod, yMod, doNotCountBorder, round)\\r\\\
	local cx, cy	-- represents position on board\\r\\\
	round = round or math.floor\\r\\\
	for y = 1, self.height do\\r\\\
		for x = 1, self.width do\\r\\\
\\r\\\
			cx = round(-1 + x + self.x + xMod)\\r\\\
			cy = round(-1 + y + self.y + yMod)\\r\\\
			\\r\\\
			if self:DoesSpotExist(cx, cy) then\\r\\\
				if (\\r\\\
					self.board.contents[cy]:sub(cx, cx)	~= self.board.blankColor and\\r\\\
					self:CheckSolid(x, y)\\r\\\
				) then\\r\\\
					return true\\r\\\
				end\\r\\\
				\\r\\\
			elseif (not doNotCountBorder) and self:CheckSolid(x, y) then\\r\\\
				return true\\r\\\
			end\\r\\\
\\r\\\
		end\\r\\\
	end\\r\\\
	return false\\r\\\
end\\r\\\
\\r\\\
-- checks whether or not the (x, y) position of the mino's shape is solid.\\r\\\
function Mino:CheckSolid(x, y, relativeToBoard)\\r\\\
	--print(x, y, relativeToBoard)\\r\\\
	if relativeToBoard then\\r\\\
		x = x - self.x + 1\\r\\\
		y = y - self.y + 1\\r\\\
	end\\r\\\
	x = math.floor(x)\\r\\\
	y = math.floor(y)\\r\\\
	if y >= 1 and y <= self.height and x >= 1 and x <= self.width then\\r\\\
		return self.shape[y]:sub(x, x) ~= \\\" \\\"\\r\\\
	else\\r\\\
		return false\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
-- direction = 1: clockwise\\r\\\
-- direction = -1: counter-clockwise\\r\\\
function Mino:Rotate(direction, expendLockMove)\\r\\\
	local oldShape = table.copy(self.shape)\\r\\\
	local kickTable = gameConfig.kickTables[gameConfig.currentKickTable]\\r\\\
	local output = {}\\r\\\
	local success = false\\r\\\
	local newRotation = ((self.rotation + direction + 1) % 4) - 1\\r\\\
	local kickRotTranslate = {\\r\\\
		[-1] = \\\"3\\\",\\r\\\
		[ 0] = \\\"0\\\",\\r\\\
		[ 1] = \\\"1\\\",\\r\\\
		[ 2] = \\\"2\\\",\\r\\\
	}\\r\\\
	if self.active then\\r\\\
		-- get the specific offset table for the type of rotation based on the mino type\\r\\\
		local kickX, kickY\\r\\\
		local kickRot = kickRotTranslate[self.rotation] .. kickRotTranslate[newRotation]\\r\\\
\\r\\\
		-- translate the mino piece\\r\\\
		for y = 1, self.width do\\r\\\
			output[y] = \\\"\\\"\\r\\\
			for x = 1, self.height do\\r\\\
				if direction == -1 then\\r\\\
					output[y] = output[y] .. oldShape[x]:sub(-y, -y)\\r\\\
				elseif direction == 1 then\\r\\\
					output[y] = oldShape[x]:sub(y, y) .. output[y]\\r\\\
				end\\r\\\
			end\\r\\\
		end\\r\\\
		self.width, self.height = self.height, self.width\\r\\\
		self.shape = output\\r\\\
		-- it's time to do some floor and wall kicking\\r\\\
		if self.board and self:CheckCollision(0, 0) then\\r\\\
			for i = 1, #kickTable[self.kickID][kickRot] do\\r\\\
				kickX = kickTable[self.kickID][kickRot][i][1]\\r\\\
				kickY = -kickTable[self.kickID][kickRot][i][2]\\r\\\
				if not self:Move(kickX, kickY, false) then\\r\\\
					success = true\\r\\\
					break\\r\\\
				end\\r\\\
			end\\r\\\
		else\\r\\\
			success = true\\r\\\
		end\\r\\\
		if success then\\r\\\
			self.rotation = newRotation\\r\\\
			self.height, self.width = self.width, self.height\\r\\\
		else\\r\\\
			self.shape = oldShape\\r\\\
		end\\r\\\
\\r\\\
		if expendLockMove and not gameConfig.minos[self.minoID].noDelayLock then\\r\\\
			self.movesLeft = self.movesLeft - 1\\r\\\
			if self.movesLeft <= 0 then\\r\\\
				if self:CheckCollision(0, 1) then\\r\\\
					self.finished = 1\\r\\\
				end\\r\\\
			else\\r\\\
				self.lockTimer = gameConfig.lock_delay\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	return self, success\\r\\\
end\\r\\\
\\r\\\
function Mino:Move(x, y, doSlam, expendLockMove)\\r\\\
	local didSlam\\r\\\
	local didCollide = false\\r\\\
	local didMoveX = true\\r\\\
	local didMoveY = true\\r\\\
	local step, round\\r\\\
\\r\\\
	if self.active then\\r\\\
	\\r\\\
		if doSlam then\\r\\\
\\r\\\
			self.xFloat = self.xFloat + x\\r\\\
			self.yFloat = self.yFloat + y\\r\\\
\\r\\\
			-- handle Y position\\r\\\
			if y ~= 0 then\\r\\\
				step = y / math.abs(y)\\r\\\
				round = self.yFloat > 0 and math.floor or math.ceil\\r\\\
				if self:CheckCollision(0, step) then\\r\\\
					self.yFloat = 0\\r\\\
					didMoveY = false\\r\\\
				else\\r\\\
					for iy = step, round(self.yFloat), step do\\r\\\
						if self:CheckCollision(0, step) then\\r\\\
							didCollide = true\\r\\\
							self.yFloat = 0\\r\\\
							break\\r\\\
						else\\r\\\
							didMoveY = true\\r\\\
							self.y = self.y + step\\r\\\
							self.yFloat = self.yFloat - step\\r\\\
						end\\r\\\
					end\\r\\\
				end\\r\\\
			else\\r\\\
				didMoveY = false\\r\\\
			end\\r\\\
\\r\\\
			-- handle x position\\r\\\
			if x ~= 0 then\\r\\\
				step = x / math.abs(x)\\r\\\
				round = self.xFloat > 0 and math.floor or math.ceil\\r\\\
				if self:CheckCollision(step, 0) then\\r\\\
					self.xFloat = 0\\r\\\
					didMoveX = false\\r\\\
				else\\r\\\
					for ix = step, round(self.xFloat), step do\\r\\\
						if self:CheckCollision(step, 0) then\\r\\\
							didCollide = true\\r\\\
							self.xFloat = 0\\r\\\
							break\\r\\\
						else\\r\\\
							didMoveX = true\\r\\\
							self.x = self.x + step\\r\\\
							self.xFloat = self.xFloat - step\\r\\\
						end\\r\\\
					end\\r\\\
				end\\r\\\
			else\\r\\\
				didMoveX = false\\r\\\
			end\\r\\\
			\\r\\\
		else\\r\\\
			if self:CheckCollision(x, y) then\\r\\\
				didCollide = true\\r\\\
				didMoveX = false\\r\\\
				didMoveY = false\\r\\\
			else\\r\\\
				self.x = self.x + x\\r\\\
				self.y = self.y + y\\r\\\
				didCollide = false\\r\\\
				didMoveX = true\\r\\\
				didMoveY = true\\r\\\
			end\\r\\\
		end\\r\\\
\\r\\\
		local yHighestDidChange = (self.y > self.yHighest)\\r\\\
		self.yHighest = math.max(self.yHighest, self.y)\\r\\\
\\r\\\
		if yHighestDidChange then\\r\\\
			self.movesLeft = gameConfig.lock_move_limit\\r\\\
		end\\r\\\
\\r\\\
		if expendLockMove then\\r\\\
			if didMoveX or didMoveY then\\r\\\
				self.movesLeft = self.movesLeft - 1\\r\\\
				if self.movesLeft <= 0 then\\r\\\
					if self:CheckCollision(0, 1) then\\r\\\
						self.finished = 1\\r\\\
					end\\r\\\
				else\\r\\\
					self.lockTimer = gameConfig.lock_delay\\r\\\
				end\\r\\\
			end\\r\\\
		end\\r\\\
	else\\r\\\
		didMoveX = false\\r\\\
		didMoveY = false\\r\\\
	end\\r\\\
\\r\\\
	return didCollide, didMoveX, didMoveY, yHighestDidChange\\r\\\
end\\r\\\
\\r\\\
-- writes the mino to the board\\r\\\
function Mino:Write()\\r\\\
	if self.active then\\r\\\
		for y = 1, self.height do\\r\\\
			for x = 1, self.width do\\r\\\
				if self:CheckSolid(x, y, false) then\\r\\\
					if self.board then\\r\\\
						self.board:Write(x + self.x - 1, y + self.y - 1, self.color)\\r\\\
					end\\r\\\
				end\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
return Mino\",\
    [ \"lib/clientconfig.lua\" ] = \"return {\\r\\\
	controls = {\\r\\\
		rotate_ccw = keys.z,\\r\\\
		rotate_cw = keys.x,\\r\\\
		move_left = keys.left,\\r\\\
		move_right = keys.right,\\r\\\
		soft_drop = keys.down,\\r\\\
		hard_drop = keys.up,\\r\\\
		sonic_drop = keys.space,	-- drop mino to bottom, but don't lock\\r\\\
		hold = keys.leftShift,\\r\\\
		pause = keys.p,\\r\\\
		restart = keys.r,\\r\\\
		open_chat = keys.t,\\r\\\
		quit = keys.q,\\r\\\
	},\\r\\\
	-- (SDF) the factor in which soft dropping effects the gravity\\r\\\
	soft_drop_multiplier = 4.0,\\r\\\
	\\r\\\
	-- (DAS) amount of time you must be holding the movement keys for it to start repeatedly moving (seconds)\\r\\\
	move_repeat_delay = 0.25,\\r\\\
	\\r\\\
	-- (ARR) speed at which the pieces move when holding the movement keys (seconds per tick)\\r\\\
	move_repeat_interval = 0.05,\\r\\\
	\\r\\\
	-- (ARE) amount of seconds it will take for the next piece to arrive after the current one locks into place\\r\\\
	-- settings this to something above 0 will let you preload a rotation (IRS) or hold (IHS) (unimplemented)\\r\\\
	appearance_delay = 0,\\r\\\
	\\r\\\
	-- alternate appearance delay for when a line is cleared\\r\\\
	line_clear_delay = 0.3,\\r\\\
	\\r\\\
	-- amount of pieces visible in the queue (limited by size of UI)\\r\\\
	queue_length = 5,\\r\\\
}\",\
    [ \"backup/ldris2.lua\" ] = \"--[[\\r\\\
\\r\\\
   ,--,\\r\\\
,---.'|\\r\\\
|   | :        ,---,     ,-.----.       ,---,   .--.--.          ,----,\\r\\\
:   : |      .'  .' `\\\\   \\\\    /  \\\\   ,`--.' |  /  /    '.      .'   .' \\\\\\r\\\
|   ' :    ,---.'     \\\\  ;   :    \\\\  |   :  : |  :  /`. /    ,----,'    |\\r\\\
;   ; '    |   |  .`\\\\  | |   | .\\\\ :  :   |  ' ;  |  |--`     |    :  .  ;\\r\\\
'   | |__  :   : |  '  | .   : |: |  |   :  | |  :  ;_       ;    |.'  /\\r\\\
|   | :.'| |   ' '  ;  : |   |  \\\\ :  '   '  ;  \\\\  \\\\    `.    `----'/  ;\\r\\\
'   :    ; '   | ;  .  | |   : .  /  |   |  |   `----.   \\\\     /  ;  /\\r\\\
|   |  ./  |   | :  |  ' ;   | |  \\\\  '   :  ;   __ \\\\  \\\\  |    ;  /  /-,\\r\\\
;   : ;    '   : | /  ;  |   | ;\\\\  \\\\ |   |  '  /  /`--'  /   /  /  /.`|\\r\\\
|   ,/     |   | '` ,/   :   ' | \\\\.' '   :  | '--'.     /  ./__;      :\\r\\\
'---'      ;   :  .'     :   : :-'   ;   |.'    `--'---'   |   :    .'\\r\\\
           |   ,.'       |   |.'     '---'                 ;   | .'\\r\\\
           '---'         `---'                             `---'\\r\\\
\\r\\\
LDRIS 2 (Work in Progress)\\r\\\
Last update: April 1st 2025\\r\\\
\\r\\\
Current features:\\r\\\
	+ Real SRS rotation and wall-kicking!\\r\\\
	+ 7bag randomization!\\r\\\
	+ Modern-feeling controls!\\r\\\
	+ Ghost piece!\\r\\\
	+ Piece holding!\\r\\\
	+ Sonic drop!\\r\\\
	+ Configurable SDF, DAS, ARR, ARE, lock delay, etc.!\\r\\\
	+ Piece queue! It's even animated!\\r\\\
\\r\\\
To-do:\\r\\\
	+ Turn the GameState into an object like Minos and Boards\\r\\\
	+ Add score, and let lineclears and piece dropping add to it\\r\\\
	+ Add an actual menu, and not that shit LDRIS 1 had\\r\\\
	+ Multiplayer, as well as an implementation of garbage\\r\\\
	+ Cheese race mode\\r\\\
	+ Define color palletes so that the ghost piece isn't the color of dirt\\r\\\
	+ Add in-game menu for changing controls (some people can actually tolerate guideline)\\r\\\
]]\\r\\\
\\r\\\
_WRITE_TO_DEBUG_MONITOR = false\\r\\\
\\r\\\
local scr_x, scr_y = term.getSize()\\r\\\
\\r\\\
local Board = require \\\"lib.board\\\"\\r\\\
local Mino = require \\\"lib.mino\\\"\\r\\\
local GameInstance = require \\\"lib.gameinstance\\\"\\r\\\
\\r\\\
-- client config can be changed however you please\\r\\\
local clientConfig = {\\r\\\
	controls = {\\r\\\
		rotate_ccw = keys.z,\\r\\\
		rotate_cw = keys.x,\\r\\\
		move_left = keys.left,\\r\\\
		move_right = keys.right,\\r\\\
		soft_drop = keys.down,\\r\\\
		hard_drop = keys.up,\\r\\\
		sonic_drop = keys.space,	-- drop mino to bottom, but don't lock\\r\\\
		hold = keys.leftShift,\\r\\\
		pause = keys.p,\\r\\\
		restart = keys.r,\\r\\\
		open_chat = keys.t,\\r\\\
		quit = keys.q,\\r\\\
	},\\r\\\
	-- (SDF) the factor in which soft dropping effects the gravity\\r\\\
	soft_drop_multiplier = 4.0,\\r\\\
	\\r\\\
	-- (DAS) amount of time you must be holding the movement keys for it to start repeatedly moving (seconds)\\r\\\
	move_repeat_delay = 0.25,\\r\\\
	\\r\\\
	-- (ARR) speed at which the pieces move when holding the movement keys (seconds per tick)\\r\\\
	move_repeat_interval = 0.05,\\r\\\
	\\r\\\
	-- (ARE) amount of seconds it will take for the next piece to arrive after the current one locks into place\\r\\\
	appearance_delay = 0,\\r\\\
	\\r\\\
	-- amount of pieces visible in the queue (limited by size of UI)\\r\\\
	queue_length = 5,\\r\\\
}\\r\\\
\\r\\\
-- ideally, only clients with IDENTICAL game configs should face one another\\r\\\
local gameConfig = require \\\"lib.gameconfig\\\"\\r\\\
\\r\\\
-- localize commonly used functions\\r\\\
local stringrep = string.rep\\r\\\
\\r\\\
local cospc_debuglog = function(header, text)\\r\\\
	if _WRITE_TO_DEBUG_MONITOR then\\r\\\
		if ccemux then\\r\\\
			if not peripheral.find(\\\"monitor\\\") then\\r\\\
				ccemux.attach(\\\"right\\\", \\\"monitor\\\")\\r\\\
			end\\r\\\
			local t = term.redirect(peripheral.wrap(\\\"right\\\"))\\r\\\
			if text == 0 then\\r\\\
				term.clear()\\r\\\
				term.setCursorPos(1, 1)\\r\\\
			else\\r\\\
				term.setTextColor(colors.yellow)\\r\\\
				term.write(header or \\\"SYS\\\")\\r\\\
				term.setTextColor(colors.white)\\r\\\
				print(\\\": \\\" .. text)\\r\\\
			end\\r\\\
			term.redirect(t)\\r\\\
		end\\r\\\
	end	\\r\\\
end\\r\\\
\\r\\\
-- recursively copies the contents of a table\\r\\\
table.copy = function(tbl)\\r\\\
	local output = {}\\r\\\
	for k,v in pairs(tbl) do\\r\\\
		output[k] = (type(v) == \\\"table\\\" and k ~= v) and table.copy(v) or v\\r\\\
	end\\r\\\
	return output\\r\\\
end\\r\\\
\\r\\\
-- emulation of switch case in Lua\\r\\\
local switch = function(check)\\r\\\
    return function(cases)\\r\\\
        if type(cases[check]) == \\\"function\\\" then\\r\\\
            return cases[check]()\\r\\\
        elseif type(cases[\\\"default\\\"] == \\\"function\\\") then\\r\\\
            return cases[\\\"default\\\"]()\\r\\\
        end\\r\\\
    end\\r\\\
end\\r\\\
\\r\\\
local roundToPlaces = function(number, places)\\r\\\
	return math.floor(number * 10^places) / (10^places)\\r\\\
end\\r\\\
\\r\\\
-- current state of the game; can be used to perfectly recreate the current scene of a game\\r\\\
-- that includes board and mino objects, bitch\\r\\\
-- gameState = {}\\r\\\
\\r\\\
--[[\\r\\\
	(later, I'll probably store mino data in a separate file)\\r\\\
	spinID:	1 = considered a \\\"T\\\" piece, can be spun\\r\\\
			2 = considered a \\\"J\\\" or \\\"L\\\" piece, can be spun if that's allowed\\r\\\
			3 = considered every other piece, can be spun if STUPID mode is on\\r\\\
]]\\r\\\
\\r\\\
gameConfig.minos = require \\\"lib.minodata\\\"\\r\\\
gameConfig.kickTables = require \\\"lib.kicktables\\\"\\r\\\
\\r\\\
-- returns a number that's capped between 'min' and 'max', inclusively\\r\\\
local function between(number, min, max)\\r\\\
	return math.min(math.max(number, min), max)\\r\\\
end\\r\\\
\\r\\\
-- image-related functions (from NFTE)\\r\\\
local loadImageDataNFT = function(image, background) -- string image\\r\\\
	local output = {{},{},{}} -- char, text, back\\r\\\
	local y = 1\\r\\\
	background = (background or \\\"f\\\"):sub(1,1)\\r\\\
	local text, back = \\\"f\\\", background\\r\\\
	local doSkip, c1, c2 = false\\r\\\
	local tchar = string.char(31)	-- for text colors\\r\\\
	local bchar = string.char(30)	-- for background colors\\r\\\
	local maxX = 0\\r\\\
	local bx\\r\\\
	for i = 1, #image do\\r\\\
		if doSkip then\\r\\\
			doSkip = false\\r\\\
		else\\r\\\
			output[1][y] = output[1][y] or \\\"\\\"\\r\\\
			output[2][y] = output[2][y] or \\\"\\\"\\r\\\
			output[3][y] = output[3][y] or \\\"\\\"\\r\\\
			c1, c2 = image:sub(i,i), image:sub(i+1,i+1)\\r\\\
			if c1 == tchar then\\r\\\
				text = c2\\r\\\
				doSkip = true\\r\\\
			elseif c1 == bchar then\\r\\\
				back = c2\\r\\\
				doSkip = true\\r\\\
			elseif c1 == \\\"\\\\n\\\" then\\r\\\
				maxX = math.max(maxX, #output[1][y])\\r\\\
				y = y + 1\\r\\\
				text, back = \\\" \\\", background\\r\\\
			else\\r\\\
				output[1][y] = output[1][y]..c1\\r\\\
				output[2][y] = output[2][y]..text\\r\\\
				output[3][y] = output[3][y]..back\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
	for y = 1, #output[1] do\\r\\\
		output[1][y] = output[1][y] .. (\\\" \\\"):rep(maxX - #output[1][y])\\r\\\
		output[2][y] = output[2][y] .. (\\\" \\\"):rep(maxX - #output[2][y])\\r\\\
		output[3][y] = output[3][y] .. (background):rep(maxX - #output[3][y])\\r\\\
	end\\r\\\
	return output\\r\\\
end\\r\\\
\\r\\\
-- draws an image with the topleft corner at (x, y), with transparency\\r\\\
local drawImageTransparent = function(image, x, y, terminal)\\r\\\
	terminal = terminal or term.current()\\r\\\
	local cx, cy = terminal.getCursorPos()\\r\\\
	local c, t, b\\r\\\
	for iy = 1, #image[1] do\\r\\\
		for ix = 1, #image[1][iy] do\\r\\\
			c, t, b = image[1][iy]:sub(ix,ix), image[2][iy]:sub(ix,ix), image[3][iy]:sub(ix,ix)\\r\\\
			if b ~= \\\" \\\" or c ~= \\\" \\\" then\\r\\\
				terminal.setCursorPos(x + (ix - 1), y + (iy - 1))\\r\\\
				terminal.blit(c, t, b)\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
	terminal.setCursorPos(cx,cy)\\r\\\
end\\r\\\
\\r\\\
local pseudoRandom = function(gameState)\\r\\\
	return switch(gameConfig.randomBag) {\\r\\\
		[\\\"random\\\"] = function()\\r\\\
			return math.random(1, #gameConfig.minos)\\r\\\
		end,\\r\\\
		[\\\"singlebag\\\"] = function()\\r\\\
			if #gameState.random_bag == 0 then\\r\\\
				-- repopulate random bag\\r\\\
				for i = 1, #gameConfig.minos do\\r\\\
					if math.random(0, 1) == 0 then\\r\\\
						gameState.random_bag[#gameState.random_bag + 1] = i\\r\\\
					else\\r\\\
						table.insert(gameState.random_bag, 1, i)\\r\\\
					end\\r\\\
				end\\r\\\
			end\\r\\\
			local pick = math.random(1, #gameState.random_bag)\\r\\\
			local output = gameState.random_bag[pick]\\r\\\
			table.remove(gameState.random_bag, pick)\\r\\\
			return output\\r\\\
		end,\\r\\\
		[\\\"doublebag\\\"] = function()\\r\\\
			if #gameState.random_bag == 0 then\\r\\\
				for r = 1, 2 do\\r\\\
					-- repopulate random bag\\r\\\
					for i = 1, #gameConfig.minos do\\r\\\
						if math.random(0, 1) == 0 then\\r\\\
							gameState.random_bag[#gameState.random_bag + 1] = i\\r\\\
						else\\r\\\
							table.insert(gameState.random_bag, 1, i)\\r\\\
						end\\r\\\
					end\\r\\\
				end\\r\\\
			end\\r\\\
			local pick = math.random(1, #gameState.random_bag)\\r\\\
			local output = gameState.random_bag[pick]\\r\\\
			table.remove(gameState.random_bag, pick)\\r\\\
			return output\\r\\\
		end\\r\\\
	}\\r\\\
end\\r\\\
\\r\\\
local handleLineClears = function(gameState)\\r\\\
	local mino, board = gameState.mino, gameState.board\\r\\\
\\r\\\
	-- get list of full lines\\r\\\
	local clearedLines = {lookup = {}}\\r\\\
	for y = 1, board.height do\\r\\\
		if not board.contents[y]:find(board.blankColor) then\\r\\\
			clearedLines[#clearedLines + 1] = y\\r\\\
			clearedLines.lookup[y] = true\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	-- clear the lines, baby\\r\\\
	if #clearedLines > 0 then\\r\\\
		local newContents = {}\\r\\\
		local i = board.height\\r\\\
		for y = board.height, 1, -1 do\\r\\\
			if not clearedLines.lookup[y] then\\r\\\
				newContents[i] = board.contents[y]\\r\\\
				i = i - 1\\r\\\
			end\\r\\\
		end\\r\\\
		for y = 1, #clearedLines do\\r\\\
			newContents[y] = stringrep(board.blankColor, board.width)\\r\\\
		end\\r\\\
		gameState.board.contents = newContents\\r\\\
	end\\r\\\
\\r\\\
	gameState.linesCleared = gameState.linesCleared + #clearedLines\\r\\\
\\r\\\
	return clearedLines\\r\\\
\\r\\\
end\\r\\\
\\r\\\
local StartGame = function(player_number, native_control, board_xmod, board_ymod)\\r\\\
	board_xmod = board_xmod or 0\\r\\\
	board_ymod = board_ymod or 0\\r\\\
	local gameState = {\\r\\\
		gravity = gameConfig.startingGravity,\\r\\\
		pNum = player_number,\\r\\\
		targetPlayer = 0,\\r\\\
		score = 0,\\r\\\
		antiControlRepeat = {},\\r\\\
		topOut = false,\\r\\\
		canHold = true,\\r\\\
		didHold = false,\\r\\\
		heldPiece = false,\\r\\\
		paused = false,\\r\\\
		queue = {},\\r\\\
		queueMinos = {},\\r\\\
		linesCleared = 0,\\r\\\
		random_bag = {},\\r\\\
		gameTickCount = 0,\\r\\\
		controlTickCount = 0,\\r\\\
		animFrame = 0,\\r\\\
		state = \\\"halt\\\",\\r\\\
		controlsDown = {},		-- \\r\\\
		incomingGarbage = 0,	-- amount of garbage that will be added to board after non-line-clearing mino placement\\r\\\
		combo = 0,				-- amount of successive line clears\\r\\\
		backToBack = 0,			-- amount of tetris/t-spins comboed\\r\\\
		spinLevel = 0,			-- 0 = no special spin\\r\\\
								-- 1 = mini spin\\r\\\
								-- 2 = Z/S/J/L spin\\r\\\
								-- 3 = T spin\\r\\\
	}\\r\\\
	\\r\\\
	-- create boards\\r\\\
	-- main gameplay board\\r\\\
	gameState.board = Board:New(\\r\\\
		7 + board_xmod,\\r\\\
		1 + board_ymod,\\r\\\
		gameConfig.board_width,\\r\\\
		gameConfig.board_height\\r\\\
	)\\r\\\
\\r\\\
	-- queue of upcoming minos\\r\\\
	gameState.queueBoard = Board:New(\\r\\\
		gameState.board.x + gameState.board.width + 1,\\r\\\
		gameState.board.y,\\r\\\
		4,\\r\\\
		28\\r\\\
		--gameState.board.height - 12\\r\\\
	)\\r\\\
\\r\\\
	-- display of currently held mino\\r\\\
	gameState.holdBoard = Board:New(\\r\\\
		--gameState.board.x + gameState.board.width + 1,\\r\\\
		2 + board_xmod,\\r\\\
		--gameState.board.y + gameState.board.visibleHeight * (1/3),\\r\\\
		1 + board_ymod,\\r\\\
		gameState.queueBoard.width,\\r\\\
		4\\r\\\
	)\\r\\\
	gameState.holdBoard.visibleHeight = 4\\r\\\
	\\r\\\
	\\r\\\
	-- indicator of incoming garbage\\r\\\
	gameState.garbageBoard = Board:New(\\r\\\
		gameState.board.x - 1,\\r\\\
		gameState.board.y,\\r\\\
		1,\\r\\\
		gameState.board.visibleHeight,\\r\\\
		\\\"f\\\"\\r\\\
	)\\r\\\
	gameState.garbageBoard.visibleHeight = gameState.garbageBoard.height\\r\\\
\\r\\\
	-- populate the queue\\r\\\
	for i = 1, clientConfig.queue_length + 1 do\\r\\\
		gameState.queue[i] = pseudoRandom(gameState)\\r\\\
	end\\r\\\
	for i = 1, clientConfig.queue_length do\\r\\\
		gameState.queueMinos[i] = Mino:New(nil,\\r\\\
			gameState.queue[i + 1],\\r\\\
			gameState.queueBoard,\\r\\\
			1,\\r\\\
			i * 3 + 12\\r\\\
		)\\r\\\
	end\\r\\\
	gameState.queue.cyclePiece = function()\\r\\\
		local output = gameState.queue[1]\\r\\\
		table.remove(gameState.queue, 1)\\r\\\
		gameState.queue[#gameState.queue + 1] = pseudoRandom(gameState)\\r\\\
		return output\\r\\\
	end\\r\\\
	gameState.mino = {}\\r\\\
\\r\\\
	local qmAnim = 0\\r\\\
\\r\\\
	local makeDefaultMino = function(gameState)\\r\\\
		local nextPiece\\r\\\
		if gameState.didHold then\\r\\\
			if gameState.heldPiece then\\r\\\
				nextPiece, gameState.heldPiece = gameState.heldPiece, gameState.mino.minoID\\r\\\
			else\\r\\\
				nextPiece, gameState.heldPiece = gameState.queue.cyclePiece(), gameState.mino.minoID\\r\\\
			end\\r\\\
		else\\r\\\
			nextPiece = gameState.queue.cyclePiece()\\r\\\
		end\\r\\\
		return Mino:New(nil,\\r\\\
			nextPiece,\\r\\\
			gameState.board,\\r\\\
			math.floor(gameState.board.width / 2 - 1) + (gameConfig.minos[nextPiece].spawnOffsetX or 0),\\r\\\
			math.floor(gameConfig.board_height_visible + 1) + (gameConfig.minos[nextPiece].spawnOffsetY or 0),\\r\\\
			gameState.mino\\r\\\
		)\\r\\\
	end\\r\\\
\\r\\\
	local calculateGarbage = function(gameState, linesCleared)\\r\\\
		local output = 0\\r\\\
		local lncleartbl = {\\r\\\
			[0] = 0,\\r\\\
			[1] = 0,\\r\\\
			[2] = 1,\\r\\\
			[3] = 2,\\r\\\
			[4] = 4,\\r\\\
			[5] = 5,\\r\\\
			[6] = 6,\\r\\\
			[7] = 7,\\r\\\
			[8] = 8\\r\\\
		}\\r\\\
\\r\\\
		if (gameState.spinLevel == 3) or (gameState.spinLevel == 2 and gameConfig.spin_mode >= 2) then\\r\\\
			output = output + linesCleared * 2\\r\\\
		else\\r\\\
			output = output + (lncleartbl[linesCleared] or 0)\\r\\\
		end\\r\\\
\\r\\\
		-- add combo bonus\\r\\\
		output = output + math.max(0, math.floor(-1 + gameState.combo / 2))\\r\\\
\\r\\\
		return output\\r\\\
	end\\r\\\
\\r\\\
	local sendGameEvent = function(eventName, ...)\\r\\\
		if native_control then\\r\\\
			os.queueEvent(eventName, ...)\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	gameState.mino = makeDefaultMino(gameState)\\r\\\
\\r\\\
	local mino, board = gameState.mino, gameState.board\\r\\\
	local holdBoard, queueBoard, garbageBoard = gameState.holdBoard, gameState.queueBoard, gameState.garbageBoard\\r\\\
	local ghostMino = Mino:New(nil, mino.minoID, gameState.board, mino.x, mino.y, {})\\r\\\
\\r\\\
	local garbageMinoShape = {}\\r\\\
	for i = 1, garbageBoard.height do\\r\\\
		garbageMinoShape[i] = \\\"@\\\"\\r\\\
	end\\r\\\
\\r\\\
	local garbageMino = Mino:New({\\r\\\
		[1] = {\\r\\\
			shape = garbageMinoShape,\\r\\\
			color = \\\"e\\\"\\r\\\
		}\\r\\\
	}, 1, garbageBoard, 1, garbageBoard.height + 1)\\r\\\
	\\r\\\
	local keysDown = {}\\r\\\
	local tickDelay = 0.05\\r\\\
\\r\\\
	local render = function(drawOtherBoards)\\r\\\
		board:Render(ghostMino, mino)\\r\\\
		if drawOtherBoards then\\r\\\
			holdBoard:Render()\\r\\\
			queueBoard:Render(table.unpack(gameState.queueMinos))\\r\\\
			garbageBoard:Render(garbageMino)\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	local tick = function(gameState)\\r\\\
		local didCollide, didMoveX, didMoveY, yHighestDidChange = mino:Move(0, gameState.gravity, true)\\r\\\
		local doCheckStuff = false\\r\\\
		local doAnimateQueue = false\\r\\\
		local doMakeNewMino = false\\r\\\
\\r\\\
		qmAnim = math.max(0, qmAnim - 0.8)\\r\\\
\\r\\\
		-- position queue minos properly\\r\\\
		for i = 1, #gameState.queueMinos do\\r\\\
			gameState.queueMinos[i].y = (i * 3 + 12) + math.floor(qmAnim)\\r\\\
		end\\r\\\
\\r\\\
		if not mino.finished then\\r\\\
			mino.resting = (not didMoveY) and mino:CheckCollision(0, 1)\\r\\\
\\r\\\
			if yHighestDidChange then\\r\\\
				mino.movesLeft = gameConfig.lock_move_limit\\r\\\
			end\\r\\\
\\r\\\
			if mino.resting then\\r\\\
				mino.lockTimer = mino.lockTimer - tickDelay\\r\\\
				if mino.lockTimer <= 0 then\\r\\\
					mino.finished = 1\\r\\\
				end\\r\\\
			else\\r\\\
				mino.lockTimer = gameConfig.lock_delay\\r\\\
			end\\r\\\
		end\\r\\\
\\r\\\
		gameState.mino.spawnTimer = math.max(0, gameState.mino.spawnTimer - tickDelay)\\r\\\
		if gameState.mino.spawnTimer == 0 then\\r\\\
			gameState.mino.active = true\\r\\\
			gameState.mino.visible = true\\r\\\
			ghostMino.active = true\\r\\\
			ghostMino.visible = true\\r\\\
		end\\r\\\
\\r\\\
		if mino.finished then\\r\\\
			if mino.finished == 1 then -- piece will lock\\r\\\
				gameState.didHold = false\\r\\\
				gameState.canHold = true\\r\\\
				-- check for top-out due to placing a piece outside the visible area of its board\\r\\\
				if false then	-- I'm doing that later\\r\\\
					\\r\\\
				else\\r\\\
					doAnimateQueue = true\\r\\\
					mino:Write()\\r\\\
					doMakeNewMino = true\\r\\\
					doCheckStuff = true\\r\\\
				end\\r\\\
			elseif mino.finished == 2 then -- piece will attempt hold\\r\\\
				if gameState.canHold then\\r\\\
					gameState.didHold = true\\r\\\
					gameState.canHold = false\\r\\\
					-- I would have used a ternary statement, but didn't\\r\\\
					if gameState.heldPiece then\\r\\\
						doAnimateQueue = false\\r\\\
					else\\r\\\
						doAnimateQueue = true\\r\\\
					end\\r\\\
					-- draw held piece\\r\\\
					gameState.holdBoard:Clear()\\r\\\
					Mino:New(nil,\\r\\\
						gameState.mino.minoID,\\r\\\
						gameState.holdBoard,\\r\\\
						1, 2, {}\\r\\\
					):Write()\\r\\\
\\r\\\
					doMakeNewMino = true\\r\\\
					doCheckStuff = true\\r\\\
				else\\r\\\
					mino.finished = false\\r\\\
				end\\r\\\
			else\\r\\\
				error(\\\"I don't know how, but that polyomino's finished!\\\")\\r\\\
			end\\r\\\
\\r\\\
			if doMakeNewMino then\\r\\\
				gameState.mino = makeDefaultMino(gameState)\\r\\\
				ghostMino = Mino:New(nil, mino.minoID, gameState.board, mino.x, mino.y, {})\\r\\\
				if (not gameState.didHold) and (clientConfig.appearance_delay > 0) then\\r\\\
					gameState.mino.spawnTimer = clientConfig.appearance_delay\\r\\\
					gameState.mino.active = false\\r\\\
					gameState.mino.visible = false\\r\\\
					ghostMino.active = false\\r\\\
					ghostMino.visible = false\\r\\\
				end\\r\\\
			end\\r\\\
\\r\\\
			if doAnimateQueue then\\r\\\
				table.remove(gameState.queueMinos, 1)\\r\\\
				gameState.queueMinos[#gameState.queueMinos + 1] = Mino:New(nil,\\r\\\
					gameState.queue[clientConfig.queue_length],\\r\\\
					gameState.queueBoard,\\r\\\
					1,\\r\\\
					(clientConfig.queue_length + 1) * 3 + 12\\r\\\
				)\\r\\\
				qmAnim = 3\\r\\\
			end\\r\\\
\\r\\\
			-- if the hold attempt fails (say, you already held a piece), it wouldn't do to check for a top-out or line clears\\r\\\
			if doCheckStuff then\\r\\\
				-- check for top-out due to obstructed mino upon entry\\r\\\
				-- attempt to move mino at most 2 spaces upwards before considering it fully topped out\\r\\\
				gameState.topOut = true\\r\\\
				for i = 0, 2 do\\r\\\
					if mino:CheckCollision(0, 1) then\\r\\\
						mino.y = mino.y - 1\\r\\\
					else\\r\\\
						gameState.topOut = false\\r\\\
						break\\r\\\
					end\\r\\\
				end\\r\\\
				\\r\\\
				local linesCleared = handleLineClears(gameState)\\r\\\
				if #linesCleared == 0 then\\r\\\
					gameState.combo = 0\\r\\\
					gameState.backToBack = 0\\r\\\
				else\\r\\\
					gameState.combo = gameState.combo + 1\\r\\\
					if #linesCleared == 4 or gameState.spinLevel >= 1 then\\r\\\
						gameState.backToBack = gameState.backToBack + 1\\r\\\
					else\\r\\\
						gameState.backToBack = 0\\r\\\
					end\\r\\\
				end\\r\\\
				-- calculate garbage to be sent\\r\\\
				local garbage = calculateGarbage(gameState, #linesCleared)\\r\\\
				if garbage > 0 then\\r\\\
					cospc_debuglog(gameState.pNum, \\\"Doled out \\\" .. garbage .. \\\" lines\\\")\\r\\\
				end\\r\\\
				\\r\\\
				-- send garbage to enemy player\\r\\\
				sendGameEvent(\\\"attack\\\", gameState.targetPlayer, garbage)\\r\\\
\\r\\\
				if doMakeNewMino then\\r\\\
					gameState.spinLevel = 0\\r\\\
				end\\r\\\
\\r\\\
			end\\r\\\
		end\\r\\\
\\r\\\
		-- debug info\\r\\\
		if native_control then\\r\\\
			term.setCursorPos(2, scr_y - 2)\\r\\\
			term.write(\\\"Lines: \\\" .. gameState.linesCleared .. \\\"      \\\")\\r\\\
\\r\\\
			term.setCursorPos(2, scr_y - 1)\\r\\\
			term.write(\\\"M=\\\" .. mino.movesLeft .. \\\", TTL=\\\" .. tostring(mino.lockTimer):sub(1, 4) .. \\\"      \\\")\\r\\\
\\r\\\
			term.setCursorPos(2, scr_y - 0)\\r\\\
			term.write(\\\"POS=(\\\" .. mino.x .. \\\":\\\" .. tostring(mino.xFloat):sub(1, 5) .. \\\", \\\" .. mino.y .. \\\":\\\" .. tostring(mino.yFloat):sub(1, 5) .. \\\")      \\\")\\r\\\
		end\\r\\\
		\\r\\\
	end\\r\\\
\\r\\\
	local checkControl = function(controlName, repeatTime, repeatDelay)\\r\\\
		repeatDelay = repeatDelay or 1\\r\\\
		if native_control then\\r\\\
			if keysDown[clientConfig.controls[controlName]] then\\r\\\
				if not gameState.antiControlRepeat[controlName] then\\r\\\
					if repeatTime then\\r\\\
						return 	keysDown[clientConfig.controls[controlName]] == 1 or\\r\\\
								(\\r\\\
									keysDown[clientConfig.controls[controlName]] >= (repeatTime * (1 / tickDelay)) and (\\r\\\
										repeatDelay and ((keysDown[clientConfig.controls[controlName]] * tickDelay) % repeatDelay == 0) or true\\r\\\
									)\\r\\\
								)\\r\\\
					else\\r\\\
						return keysDown[clientConfig.controls[controlName]] == 1\\r\\\
					end\\r\\\
				end\\r\\\
			else\\r\\\
				return false\\r\\\
			end\\r\\\
		else\\r\\\
			if gameState.controlsDown[controlName] then\\r\\\
				if not gameState.antiControlRepeat[controlName] then\\r\\\
					if repeatTime then\\r\\\
						return 	gameState.controlsDown[controlName] == 1 or\\r\\\
								(\\r\\\
									gameState.controlsDown[controlName] >= (repeatTime * (1 / tickDelay)) and (\\r\\\
										repeatDelay and ((gameState.controlsDown[controlName] * tickDelay) % repeatDelay == 0) or true\\r\\\
									)\\r\\\
								)\\r\\\
					else\\r\\\
						return gameState.controlsDown[controlName] == 1\\r\\\
					end\\r\\\
				end\\r\\\
			else\\r\\\
				return false\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	local controlTick = function(gameState, onlyFastActions)\\r\\\
		local dc, dmx, dmy	-- did collide, did move X, did move Y\\r\\\
		local didSlowAction = false\\r\\\
		if (not gameState.paused) and gameState.mino.active then\\r\\\
			if not onlyFastActions then\\r\\\
				if checkControl(\\\"move_left\\\", clientConfig.move_repeat_delay, clientConfig.move_repeat_interval) then\\r\\\
					if not mino.finished then\\r\\\
						mino:Move(-1, 0, true, true)\\r\\\
						didSlowAction = true\\r\\\
						gameState.antiControlRepeat[\\\"move_left\\\"] = true\\r\\\
					end\\r\\\
				end\\r\\\
				if checkControl(\\\"move_right\\\", clientConfig.move_repeat_delay, clientConfig.move_repeat_interval) then\\r\\\
					if not mino.finished then\\r\\\
						mino:Move(1, 0, true, true)\\r\\\
						didSlowAction = true\\r\\\
						gameState.antiControlRepeat[\\\"move_right\\\"] = true\\r\\\
					end\\r\\\
				end\\r\\\
				if checkControl(\\\"soft_drop\\\", 0) then\\r\\\
					mino:Move(0, gameState.gravity * clientConfig.soft_drop_multiplier, true, false)\\r\\\
					didSlowAction = true\\r\\\
					gameState.antiControlRepeat[\\\"soft_drop\\\"] = true\\r\\\
				end\\r\\\
				if checkControl(\\\"hard_drop\\\", false) then\\r\\\
					mino:Move(0, board.height, true, false)\\r\\\
					mino.finished = 1\\r\\\
					didSlowAction = true\\r\\\
					gameState.antiControlRepeat[\\\"hard_drop\\\"] = true\\r\\\
				end\\r\\\
				if checkControl(\\\"sonic_drop\\\", false) then\\r\\\
					mino:Move(0, board.height, true, true)\\r\\\
					didSlowAction = true\\r\\\
					gameState.antiControlRepeat[\\\"sonic_drop\\\"] = true\\r\\\
				end\\r\\\
				if checkControl(\\\"hold\\\", false) then\\r\\\
					if not mino.finished then\\r\\\
						mino.finished = 2\\r\\\
						gameState.antiControlRepeat[\\\"hold\\\"] = true\\r\\\
						didSlowAction = true\\r\\\
					end\\r\\\
				end\\r\\\
				if checkControl(\\\"quit\\\", false) then\\r\\\
					gameState.topOut = true\\r\\\
					gameState.antiControlRepeat[\\\"quit\\\"] = true\\r\\\
					didSlowAction = true\\r\\\
				end\\r\\\
			end\\r\\\
			if checkControl(\\\"rotate_ccw\\\", false) then\\r\\\
				mino:Rotate(-1, true)\\r\\\
				if mino.spinID <= gameConfig.spin_mode then\\r\\\
					if (\\r\\\
						mino:CheckCollision(1, 0) and\\r\\\
						mino:CheckCollision(-1, 0) and\\r\\\
						mino:CheckCollision(0, -1)\\r\\\
					) then\\r\\\
						gameState.spinLevel = 3\\r\\\
					else\\r\\\
						gameState.spinLevel = 0\\r\\\
					end\\r\\\
				end\\r\\\
				gameState.antiControlRepeat[\\\"rotate_ccw\\\"] = true\\r\\\
			end\\r\\\
			if checkControl(\\\"rotate_cw\\\", false) then\\r\\\
				mino:Rotate(1, true)\\r\\\
				if mino.spinID <= gameConfig.spin_mode then\\r\\\
					if (\\r\\\
						mino:CheckCollision(1, 0) and\\r\\\
						mino:CheckCollision(-1, 0) and\\r\\\
						mino:CheckCollision(0, -1)\\r\\\
					) then\\r\\\
						gameState.spinLevel = 3\\r\\\
					else\\r\\\
						gameState.spinLevel = 0\\r\\\
					end\\r\\\
				end\\r\\\
				gameState.antiControlRepeat[\\\"rotate_cw\\\"] = true\\r\\\
			end\\r\\\
		end\\r\\\
		if checkControl(\\\"pause\\\", false) then\\r\\\
			gameState.paused = not gameState.paused\\r\\\
			gameState.antiControlRepeat[\\\"pause\\\"] = true\\r\\\
		end\\r\\\
		return didSlowAction\\r\\\
	end\\r\\\
\\r\\\
	local tickTimer = os.startTimer(tickDelay)\\r\\\
	local evt\\r\\\
	local didControlTick = false\\r\\\
	\\r\\\
	-- TODO: make each instance of the game into an object\\r\\\
\\r\\\
	while true do\\r\\\
\\r\\\
		-- handle ghost piece\\r\\\
		ghostMino.color = \\\"c\\\"\\r\\\
		ghostMino.shape = mino.shape\\r\\\
		ghostMino.x = mino.x\\r\\\
		ghostMino.y = mino.y\\r\\\
		ghostMino:Move(0, board.height, true)\\r\\\
\\r\\\
		garbageMino.y = 1 + garbageBoard.height - gameState.incomingGarbage\\r\\\
\\r\\\
		-- render board\\r\\\
		render(true)\\r\\\
\\r\\\
		evt = {os.pullEvent()}\\r\\\
\\r\\\
		if evt[1] == \\\"key\\\" and not evt[3] then\\r\\\
			keysDown[evt[2]] = 1\\r\\\
			didControlTick = controlTick(gameState, false)\\r\\\
			gameState.controlTickCount = gameState.controlTickCount + 1\\r\\\
			\\r\\\
		elseif evt[1] == \\\"key_up\\\" then\\r\\\
			keysDown[evt[2]] = nil\\r\\\
		end\\r\\\
\\r\\\
		if evt[1] == \\\"timer\\\" then\\r\\\
			if evt[2] == tickTimer then\\r\\\
				tickTimer = os.startTimer(0.05)\\r\\\
				for k,v in pairs(keysDown) do\\r\\\
					keysDown[k] = 1 + v\\r\\\
				end\\r\\\
				controlTick(gameState, didControlTick)\\r\\\
				gameState.controlTickCount = gameState.controlTickCount + 1\\r\\\
				if not gameState.paused then\\r\\\
					tick(gameState)\\r\\\
					gameState.gameTickCount = gameState.gameTickCount + 1\\r\\\
				end\\r\\\
				didControlTick = false\\r\\\
				gameState.antiControlRepeat = {}\\r\\\
			end\\r\\\
		end\\r\\\
		\\r\\\
		if evt[1] == \\\"attack\\\" and evt[2] == player_number then\\r\\\
			gameState.incomingGarbage = evt[3]\\r\\\
		end\\r\\\
\\r\\\
		if gameState.topOut then\\r\\\
			-- this will have a more elaborate game over sequence later\\r\\\
			return\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
end\\r\\\
\\r\\\
local TitleScreen = function()\\r\\\
	local animation = function()\\r\\\
		local tsx = 8\\r\\\
		local tsy = 10\\r\\\
		--[[\\r\\\
		local title = {\\r\\\
			[1] = \\\"eeÂ\\\\neeÂ\\\\neeÂfÂfeÂ\\\",\\r\\\
			[2] = \\\"ddÂfÂdfÂfdÂ\\\\nddÂ   dfÂfdÂ\\\\nddÂfÂfdÂÂ\\\",\\r\\\
			[3] = \\\"11ÂfÂ1fÂf1Â\\\\n11ÂfÂÂf1Â\\\\n11Â   11ÂfÂ\\\",\\r\\\
			[4] = \\\"afÂfaÂ\\\\nafÂfaÂ\\\\nafÂÂ\\\",\\r\\\
			[5] = \\\"3fÂ3ÂfÂ3fÂ\\\\nfÂ3Â3fÂf3Â\\\\n3fÂÂÂf3Â\\\",\\r\\\
			[6] = \\\"4fÂf4ÂÂ4fÂ\\\\n   4fÂÂf4Â\\\\n4fÂ4ÂfÂÂ\\\"\\r\\\
		}\\r\\\
		--]]\\r\\\
		\\r\\\
		--[[\\r\\\
			1 = \\\"    \\\",\\r\\\
				\\\"@@@@\\\",\\r\\\
				\\\"    \\\",\\r\\\
				\\\"    \\\",\\r\\\
\\r\\\
			2 = \\\" @ \\\",\\r\\\
				\\\"@@@\\\",\\r\\\
				\\\"    \\\",\\r\\\
\\r\\\
			3 = \\\"  @\\\",\\r\\\
				\\\"@@@\\\",\\r\\\
				\\\"   \\\",\\r\\\
				\\r\\\
			4 = \\\"@  \\\",\\r\\\
				\\\"@@@\\\",\\r\\\
				\\\"   \\\",\\r\\\
\\r\\\
			5 = \\\"@@\\\",\\r\\\
				\\\"@@\\\",\\r\\\
\\r\\\
			6 = \\\" @@\\\",\\r\\\
				\\\"@@ \\\",\\r\\\
				\\\"   \\\",\\r\\\
\\r\\\
			7 = \\\"@@ \\\",\\r\\\
				\\\" @@\\\",\\r\\\
				\\\"   \\\",\\r\\\
		]]\\r\\\
\\r\\\
		local animBoard = Board:New(1, 1, scr_x, scr_y * 10/3, \\\"f\\\")\\r\\\
		animBoard.visibleHeight = animBoard.height / 2\\r\\\
\\r\\\
		local animMinos = {}\\r\\\
\\r\\\
		local iterate = 0\\r\\\
		local mTimer = 100000\\r\\\
		\\r\\\
		local titleMinos = {\\r\\\
			-- L\\r\\\
			Mino:New(nil, 4, animBoard, tsx + 1, tsy).Rotate(0),\\r\\\
			Mino:New(nil, 1, animBoard, tsx + 0, tsy).Rotate(3),\\r\\\
			\\r\\\
			-- D\\r\\\
			Mino:New(nil, 7, animBoard, tsx + 6, tsy).Rotate(3),\\r\\\
			Mino:New(nil, 3, animBoard, tsx + 4, tsy).Rotate(1),\\r\\\
			nil\\r\\\
		}\\r\\\
\\r\\\
		for i = 1, #titleMinos do\\r\\\
			if titleMinos[i] then\\r\\\
				table.insert(animMinos, titleMinos[i])\\r\\\
			end\\r\\\
		end\\r\\\
\\r\\\
		while true do\\r\\\
			iterate = (iterate + 10) % 360\\r\\\
\\r\\\
			if mTimer <= 0 then\\r\\\
				table.insert(animMinos, Mino:New(nil,\\r\\\
					math.random(1, 7),\\r\\\
					animBoard,\\r\\\
					math.random(1, animBoard.width - 4),\\r\\\
					animBoard.visibleHeight - 4\\r\\\
				))\\r\\\
				mTimer = 4\\r\\\
			else\\r\\\
				mTimer = mTimer - 1\\r\\\
			end\\r\\\
\\r\\\
			for i = 1, #animMinos do\\r\\\
				animMinos[i]:Move(0, 0.75, false)\\r\\\
				if animMinos[i].y > animBoard.height then\\r\\\
					table.remove(animMinos, i)\\r\\\
				end\\r\\\
			end\\r\\\
\\r\\\
			animBoard:Render(table.unpack(animMinos))\\r\\\
\\r\\\
			sleep(0.05)\\r\\\
		end\\r\\\
	end\\r\\\
	local menu = function()\\r\\\
		local options = {\\\"Singleplayer\\\", \\\"How to play\\\", \\\"Quit\\\"}\\r\\\
		\\r\\\
	end\\r\\\
	--animation()\\r\\\
	--StartGame(true, 0, 0)\\r\\\
	parallel.waitForAny(function()\\r\\\
		cospc_debuglog(1, \\\"Starting game.\\\")\\r\\\
		StartGame(1, true, 0, 0)\\r\\\
		cospc_debuglog(1, \\\"Game concluded.\\\")\\r\\\
	end, function()\\r\\\
		while true do\\r\\\
			cospc_debuglog(2, \\\"Starting game.\\\")\\r\\\
			StartGame(2, false, 24, 0)\\r\\\
			cospc_debuglog(2, \\\"Game concluded.\\\")\\r\\\
		end\\r\\\
	end)\\r\\\
end\\r\\\
\\r\\\
term.clear()\\r\\\
\\r\\\
cospc_debuglog(nil, 0)\\r\\\
\\r\\\
cospc_debuglog(nil, \\\"Opened LDRIS2.\\\")\\r\\\
\\r\\\
TitleScreen()\\r\\\
\\r\\\
cospc_debuglog(nil, \\\"Closed LDRIS2.\\\")\\r\\\
\\r\\\
term.setCursorPos(1, scr_y - 1)\\r\\\
term.clearLine()\\r\\\
print(\\\"Thank you for playing!\\\")\\r\\\
term.setCursorPos(1, scr_y - 0)\\r\\\
term.clearLine()\\r\\\
\\r\\\
sleep(0.05)\\r\\\
\",\
    [ \"sound/mino_O.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000ý^\\000\\000\\000\\000\\000\\000svorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000ý^\\000\\000\\000\\000\\000d,Dÿÿÿÿÿÿÿÿÿÿÿÿvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000 \\\
ÆÐU\\000\\000\\000\\000BFÆP§GÄPóPjé xJaÉôkBß{Ï½÷Þ{ 4d\\000\\000\\000@bà1	B¡Å	Q)Ba9	r:	B÷ .çÞrî½÷\\rY\\000\\000\\0000!B!B\\\
)¥R)¦bÊ1ÇsÌ1È :è¤N2©¤2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊc1Æc1Æc1ÆBCV\\000 \\000\\000AdB!R)¦sÌ1ÇÐU\\000\\000 \\000\\000\\000\\000\\000GÉÉ$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û}ÛwuÙ·}ÙvuYeYwm[uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9#)¬\\000d\\000\\000\\000à(â8#9cI¤IåYåi&j¢¬\\000\\000\\000\\000\\000\\000\\000\\000 (â(#I¥iç©(¦ªª¢iªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i@hÈ*\\000@\\000@ÇqÇQÇqÉ$	\\rY\\000È\\000\\000\\000ÀPGË±$ÍÒ,Ïò4Ñ3=WMÝÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓÐU\\000\\000\\000\\000 B1 4d\\000\\000\\000¢1Ô)%Á¥`!Ä1Ô!ä<Z:RX2&=ÅÂ÷Þsï½÷\\rY\\000\\000\\000FxLB(FqBg\\\
BXN¥NÐ=!Ë¹·{ï½BCV\\000\\000\\000B!B!BJ)b)¦rÌ1Çs2È :é¤L*é¤£L2ê(µRK1Å[n1ÖZkÍ9÷2Æc1Æc1Æc1ÐU\\000\\000\\000\\000aABH!b)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I,É4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeÝÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäH¤\\000¡!«\\000\\000\\000\\000\\0008£8äHåX%ifygy§è¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(¢8ãHeiæyª'¢©ªªhªªª¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i¦i&²\\\
\\000\\000\\000ÐqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç<É³<Çs<É4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000 Ç´$	 äÄÄ¤ ä:%Åä!§ bä9ÉAäÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥9ç¤tR¡¥Rg©´ZbÌ(ÚR­\\rRH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,BCV\\000Q\\000\\0001H)¤b9ÈD1èd1!sNAÇT*uPRÃsA¨ T:GPRG\\000\\000\\000\\000\\000¡Ð@\\000A4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUÝvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×eÓumÙue[WeYø5UeÓumÙt]ÙveW·UYÖmÑu}]eá7eÙ÷e[×}Y·at]ÛWeY÷MY~ÙÝÕu_DQU=U]QU]×t][W]×¶5Õ]ÓumÙT]YVeY÷]WÖuMUeÙeÛ6]WUYöuWu[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}Uu_ÖuauÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_máXeÙøuá[×ßs]_WmÙVÙ6Ý÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^Ý6êÆO¸ß¨©ª¯®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VYÕaÖuaÙa©Úº2¼ºo¯­+ÃíßWªmË«ÛÂ0û¶ðÛÂo»±3\\000\\0008\\000\\000P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEUeÕeYu]]MÓEÕteÓT]Yu]WV]W%M3MÍóLSó<Ó4UÓMSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓMSeÓUmÙUeW]Ù¶MUeS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨²kªl«ªª»²kë¾,Ë¶,ªªë®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï¦,ª)Û¦ªÊ²,»¶mË²/¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À\\000@	e Ð\\000@\\000\\000`cAhrÎ9RÎ9!sB©dÎA¡¤Ì9¥¤9¡B¥¤ÔZ¡Z+\\000\\000 À\\000 ÀMÅ\\\
\\rY	\\000¤\\000GÓLÓueÙËEUeÛ6Å²DQUeÙ¶cEUeÛÖu4QTUY¶mÝWSUeÙ¶}]82UUm[×}#Um[×¡*Ë¶më¾QI¶m]7ã¨$Û¶îû¾q,ñ¡°,ð_8*\\000\\000ð\\000 VG8),4d%\\000\\000\\000¤QJ)£RJ)ÆR	\\000\\000p\\000\\0000¡²\\\"\\000\\000\\000sÎ9çsÎ9çsÎ9çsÎ9çc1Æc1Æc1Æc1Æc1Æc1Æ\\000ìD8\\000ìDX¬\\000Â\\000\\000R)¥9ç¤RJ)¥ÈA¥RJ)¥DÒI)¥RJ)¥qPJ)¥RJ)¡RJ)¥RJ	¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ)¥RJ\\000&\\000P	6Î°tV8\\\\hÈJ\\000 7\\000\\000P9Æ$JH%JåÎI	)µVB\\\
­\\\
:h£RK­JIB(¡RZ)%µR2¡PJ!¥RJ	¡ePB\\\
%RI-´TJÉ PZ	©ÔZ\\\
%A)©R*­µJJ­ÒR)­µÖJJ!R¥¤R)¥µJk­µNR)-¤ÖRk­VJ)¥JI­µZk)¥VB)­´ÒZ)%µÖRk-ÔZK­¥ÖRk­¥ÖJ)%¥Zk­µZ*)µB)¥Bj©¥ÖJ*-ÐRI¥VZk)¥J(%Z*©µRh¥ÒJI%¥J*)¥ÔR*¡R*¡ÔRk©¥J*-µÔR+©JJ©\\000\\000tà\\000\\000`D¥ØiÆGàB	(\\000\\000\\000@ \\000\\\
d\\000ÀB\\000PX`(]è\\\"HA\\\\8qãNèÐ\\000\\000¡\\\"$dÀEt\\000°¸À(]è\\\"HA\\\\8qãNèÐ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\ÆGÇH\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000OggS\\000Ú\\\"\\000\\000\\000\\000\\000\\000ý^\\000\\000\\000\\000\\000%[ñVHLW_LbfDD><BBOME?3V«¦3d÷¶µMö#\\000Ð¦=¡B ¦¶e¡¾T¬¾sîöøöÅõDÆüta`O\\000\\000ñåÐàO÷G\\000ð3Ë_\\000ÌC	`]Z\\rU¾o(C\\000n¯Õ{]6ñµCð\\0008\\000iP{Èn¿¦iÜ\\000s¾¸Äç×y\\\\¹wæVÈ\\000¸%z¤VøÀ~R¯à Ù\\000f«+âxÜ\\000ö§\\000ÀÒ>z¨è\\000³ì}ð®\\000ÀÙg\\000ýu%\\000°Çà9ÛZ§7øÀØÕQVðnÓ«»AÖ0\\\\\\000Z«rÒZ@ýÙæ`\\000@¸\\000 lc©Ðöíù?ïù»ç\\000¨«ZÇ\\000KÁ¤påÀG¹ï¬¬£ø9i@¯[f@0|0cf±\\000b8ï¾-<¦¹ØEªªD\\000¨¤\\000\\000ìcd}{ÿ{4m»ç4S¨WÑDÀ·Sàvø*æÄGÂ,Æ8å¬Þ¢Àèqu_³¨\\000ËüØV^«ÔZ/ßÄiº meIz\\000Lcë÷ÿÖ5­ÝmÏ\\000 y#2nïÌÉYi\\\
\\000¿§¾e\\000ÜxH\\000¥èè6µpu@ÐZ¡dkpS¸\\0004å½\\0008<ZöÁ3yí]_Úêü*ÁDÏ\\000WµYþ#\\000.ÖnÀÆaBÓ10fPÐô5öJìDÀó¦½ÃºY³XìE»=ðÄè'\\000R+vg(um<¢¾KÞO³Åé1ÿ&´×vo+qüíµ\\\"+ôí)Æª öWÁÍ!ô¥\\\\À»0°[-°ü|iEºÌI¸pÔ1¨1~~2P¯8ãÓ\\\
cvu?\\000^¥}&7òä<þöáK\\\\\\000Z`h3\\000\\0000\\000æê»\\000îà`XI<H@	ÃØ0ëÀ%¾@@C?t\\000:+|/TC1TVPÓP{\\\
v8»é+;°Öðï÷ß<Þ#vK5ì`ØÖ]à0{Ûà'½8Ù¡Ô}NjËXzHÃõ¸8r»óÜu-<u\\rýª\\000¬Ñ(@1`:\\000·gÀ-¥¹íS8þih ¡@´:Ø9Í\\rÓp:\\000gÁÀÖ<HPÙà\\\"°eüHÂËjÁ(´\\000}³E-)°oÚ*BÞ<î2ÚStzHèsô!íà%æ_zÀö\\\\Bc¸¤Ó\\000\\000u8Õ]8~«×À	\\000PnSbÖtvÏ.¸Î5 cßV9ËÂQÐÃ«Ñ±Kø<0¤X\\000³~5`\\000wêW\\000·V	\\000(=\\000¶1f&·YÕº}	ª\\000]Ò`[Á+¯Y¨â7åaFuÁ ~UU¼½+àr=\\000yÒ\\000ø}Íà¤¬ÑAáY¢Zó®ËÃðãòy%ð¡ÏðyÌL²ØÝ\\000l±?\\\\ãòÁ¶>àÒÀÉÆá[eauæÞ-y\\000o°UÍÚ¬ç^í^mÂ1Àvè2¨C¨dá``Pª }Úy*¨|VÐÎÎ\\000g¹5~PÐ­Jª2\\000k{ô	ìi^`;Öi°-_bÐpYCF¬\\\
v¨XÃ:±+øÃ\\000?W¨ð1\\000êÞ4M;ö<²!';Ég1@¯CU±îø@ Ó\\000\",\
    [ \"backup/lib/kicktables.lua\" ] = \"local kicktables = {}\\r\\\
\\r\\\
kicktables[\\\"SRS\\\"] = {\\r\\\
	[1] = { -- used on J, L, S, T, Z tetraminos\\r\\\
		[\\\"01\\\"] = {{ 0, 0}, {-1, 0}, {-1, 1}, { 0,-2}, {-1,-2}},\\r\\\
		[\\\"10\\\"] = {{ 0, 0}, { 1, 0}, { 1,-1}, { 0, 2}, { 1, 2}},\\r\\\
		[\\\"12\\\"] = {{ 0, 0}, { 1, 0}, { 1,-1}, { 0, 2}, { 1, 2}},\\r\\\
		[\\\"21\\\"] = {{ 0, 0}, {-1, 0}, {-1, 1}, { 0,-2}, {-1,-2}},\\r\\\
		[\\\"23\\\"] = {{ 0, 0}, { 1, 0}, { 1, 1}, { 0,-2}, { 1,-2}},\\r\\\
		[\\\"32\\\"] = {{ 0, 0}, {-1, 0}, {-1,-1}, { 0, 2}, {-1, 2}},\\r\\\
		[\\\"30\\\"] = {{ 0, 0}, {-1, 0}, {-1,-1}, { 0, 2}, {-1, 2}},\\r\\\
		[\\\"03\\\"] = {{ 0, 0}, { 1, 0}, { 1, 1}, { 0,-2}, { 1,-2}},\\r\\\
		[\\\"02\\\"] = {{ 0, 0}, { 0, 1}, { 1, 1}, {-1, 1}, { 1, 0}, {-1, 0}},\\r\\\
		[\\\"13\\\"] = {{ 0, 0}, { 1, 0}, { 1, 2}, { 1, 1}, { 0, 2}, { 0, 1}},\\r\\\
		[\\\"20\\\"] = {{ 0, 0}, { 0,-1}, {-1,-1}, { 1,-1}, {-1, 0}, { 1, 0}},\\r\\\
		[\\\"31\\\"] = {{ 0, 0}, {-1, 0}, {-1, 2}, {-1, 1}, { 0, 2}, { 0, 1}}\\r\\\
	},\\r\\\
	\\r\\\
	[2] = {	-- used on I tetraminos\\r\\\
		[\\\"01\\\"] = {{ 0, 0}, {-2, 0}, { 1, 0}, {-2,-1}, { 1, 2}},\\r\\\
		[\\\"10\\\"] = {{ 0, 0}, { 2, 0}, {-1, 0}, { 2, 1}, {-1,-2}},\\r\\\
		[\\\"12\\\"] = {{ 0, 0}, {-1, 0}, { 2, 0}, {-1, 2}, { 2,-1}},\\r\\\
		[\\\"21\\\"] = {{ 0, 0}, { 1, 0}, {-2, 0}, { 1,-2}, {-2, 1}},\\r\\\
		[\\\"23\\\"] = {{ 0, 0}, { 2, 0}, {-1, 0}, { 2, 1}, {-1,-2}},\\r\\\
		[\\\"32\\\"] = {{ 0, 0}, {-2, 0}, { 1, 0}, {-2,-1}, { 1, 2}},\\r\\\
		[\\\"30\\\"] = {{ 0, 0}, { 1, 0}, {-2, 0}, { 1,-2}, {-2, 1}},\\r\\\
		[\\\"03\\\"] = {{ 0, 0}, {-1, 0}, { 2, 0}, {-1, 2}, { 2,-1}},\\r\\\
		[\\\"02\\\"] = {{ 0, 0}},\\r\\\
		[\\\"13\\\"] = {{ 0, 0}},\\r\\\
		[\\\"20\\\"] = {{ 0, 0}},\\r\\\
		[\\\"31\\\"] = {{ 0, 0}}\\r\\\
	}\\r\\\
}\\r\\\
\\r\\\
return kicktables\",\
    [ \"lib/board.lua\" ] = \"-- generates a new board, on which polyominos can be placed and interact\\r\\\
local Board = {}\\r\\\
\\r\\\
local gameConfig = require \\\"lib.gameconfig\\\"\\r\\\
\\r\\\
local stringrep = string.rep\\r\\\
\\r\\\
function Board:New(x, y, width, height, blankColor)\\r\\\
	\\r\\\
	local board = setmetatable({}, self)\\r\\\
    self.__index = self\\r\\\
	\\r\\\
	board.contents = {}\\r\\\
	board.height = height or gameConfig.board_height\\r\\\
	board.width = width or gameConfig.board_width\\r\\\
	board.x, board.y = x, y\\r\\\
	board.blankColor = blankColor or \\\"7\\\"	-- color if no minos are in that spot\\r\\\
	board.transparentColor = \\\"f\\\"         -- color if the board tries to render where there is no board\\r\\\
	board.garbageColor = \\\"8\\\"\\r\\\
	board.visibleHeight = height and math.floor(board.height / 2) or gameConfig.board_height_visible\\r\\\
	board.alignFromBottom = false\\r\\\
\\r\\\
	for y = 1, board.height do\\r\\\
		board.contents[y] = stringrep(board.blankColor, board.width)\\r\\\
	end\\r\\\
	\\r\\\
	return board\\r\\\
end\\r\\\
\\r\\\
function Board:Write(x, y, color)\\r\\\
	x = math.floor(x)\\r\\\
	y = math.floor(y)\\r\\\
	if not self.contents[y] then\\r\\\
		error(\\\"tried to write outsite size of board!\\\")\\r\\\
	end\\r\\\
	self.contents[y] = self.contents[y]:sub(1, x - 1) .. color .. self.contents[y]:sub(x + 1)\\r\\\
end\\r\\\
\\r\\\
function Board:AddGarbage(amount)\\r\\\
	if amount < 1 then return end\\r\\\
	\\r\\\
	local changePercent = 00	-- higher the percent, the more likely it is that subsequent rows of garbage will have a different hole\\r\\\
	local holeX = math.random(1, self.width)\\r\\\
	\\r\\\
	-- move board contents up\\r\\\
	for y = amount, self.height do\\r\\\
		self.contents[y - amount + 1] = self.contents[y]\\r\\\
	end\\r\\\
	\\r\\\
	-- populate 'amount' bottom rows with fucking bullshit\\r\\\
	for y = self.height, self.height - amount + 1, -1 do\\r\\\
		self.contents[y] = stringrep(self.garbageColor, holeX - 1) .. self.blankColor .. stringrep(self.garbageColor, self.width - holeX)\\r\\\
		if math.random(1, 100) <= changePercent then\\r\\\
			holeX = math.random(1, self.width)\\r\\\
		end\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
function Board:Clear(color)\\r\\\
	color = color or self.blankColor\\r\\\
	for y = 1, self.height do\\r\\\
		self.contents[y] = stringrep(color, self.width)\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
-- used for sending board data over the network\\r\\\
function Board:Serialize(doIncludeInit)\\r\\\
	return textutils.serialize({\\r\\\
		x             = doIncludeInit and self.x or nil,\\r\\\
		y             = doIncludeInit and self.y or nil,\\r\\\
		height        = doIncludeInit and self.height or nil,\\r\\\
		width         = doIncludeInit and self.width or nil,\\r\\\
		blankColor    = doIncludeInit and self.blankColor or nil,\\r\\\
		visibleHeight = self.visibleHeight or nil,\\r\\\
		contents      = self.contents\\r\\\
	})\\r\\\
end\\r\\\
\\r\\\
-- takes list of minos that it will render atop the board\\r\\\
function Board:Render(...)\\r\\\
	local charLine1 = stringrep(\\\"\\\\131\\\", self.width)\\r\\\
	local charLine2 = stringrep(\\\"\\\\143\\\", self.width)\\r\\\
	local transparentLine = stringrep(self.transparentColor, self.width)\\r\\\
	local colorLine1, colorLine2, colorLine3\\r\\\
	local minoColor1, minoColor2, minoColor3\\r\\\
	local minos = {...}\\r\\\
	local mino, tY\\r\\\
\\r\\\
	if self.alignFromBottom then\\r\\\
\\r\\\
		tY = self.y + math.floor((self.height - self.visibleHeight) * (2 / 3)) - 2\\r\\\
\\r\\\
		for y = self.height, 1 + (self.height - self.visibleHeight), -3 do\\r\\\
			colorLine1, colorLine2, colorLine3 = \\\"\\\", \\\"\\\", \\\"\\\"\\r\\\
			for x = 1, self.width do\\r\\\
\\r\\\
				minoColor1, minoColor2, minoColor3 = nil, nil, nil\\r\\\
				for i = 1, #minos do\\r\\\
					mino = minos[i]\\r\\\
					if mino.visible then\\r\\\
						if mino:CheckSolid(x, y - 0, true) then\\r\\\
							minoColor1 = mino.color\\r\\\
						end\\r\\\
						if mino:CheckSolid(x, y - 1, true) then\\r\\\
							minoColor2 = mino.color\\r\\\
						end\\r\\\
						if mino:CheckSolid(x, y - 2, true) then\\r\\\
							minoColor3 = mino.color\\r\\\
						end\\r\\\
					end\\r\\\
				end\\r\\\
\\r\\\
				colorLine1 = colorLine1 .. (minoColor1 or ((self.contents[y - 0] and self.contents[y - 0]:sub(x, x)) or self.blankColor))\\r\\\
				colorLine2 = colorLine2 .. (minoColor2 or ((self.contents[y - 1] and self.contents[y - 1]:sub(x, x)) or self.blankColor))\\r\\\
				colorLine3 = colorLine3 .. (minoColor3 or ((self.contents[y - 2] and self.contents[y - 2]:sub(x, x)) or self.blankColor))\\r\\\
\\r\\\
			end\\r\\\
\\r\\\
			if (y - 0) <= (self.height - self.visibleHeight) then\\r\\\
				colorLine1 = transparentLine\\r\\\
			end\\r\\\
			if (y - 1) <= (self.height - self.visibleHeight) then\\r\\\
				colorLine2 = transparentLine\\r\\\
			end\\r\\\
			if (y - 2) <= (self.height - self.visibleHeight) then\\r\\\
				colorLine3 = transparentLine\\r\\\
			end\\r\\\
\\r\\\
			term.setCursorPos(self.x, self.y + tY)\\r\\\
			term.blit(charLine1, colorLine2, colorLine1)\\r\\\
			tY = tY - 1\\r\\\
			term.setCursorPos(self.x, self.y + tY)\\r\\\
			term.blit(charLine2, colorLine3, colorLine2)\\r\\\
			tY = tY - 1\\r\\\
		end\\r\\\
	\\r\\\
	else\\r\\\
\\r\\\
		tY = self.y\\r\\\
\\r\\\
		for y = 1 + (self.height - self.visibleHeight), self.height, 3 do\\r\\\
			colorLine1, colorLine2, colorLine3 = \\\"\\\", \\\"\\\", \\\"\\\"\\r\\\
			for x = 1, self.width do\\r\\\
\\r\\\
				minoColor1, minoColor2, minoColor3 = nil, nil, nil\\r\\\
				for i = 1, #minos do\\r\\\
					mino = minos[i]\\r\\\
					if mino.visible then\\r\\\
						if mino:CheckSolid(x, y + 0, true) then\\r\\\
							minoColor1 = mino.color\\r\\\
						end\\r\\\
						if mino:CheckSolid(x, y + 1, true) then\\r\\\
							minoColor2 = mino.color\\r\\\
						end\\r\\\
						if mino:CheckSolid(x, y + 2, true) then\\r\\\
							minoColor3 = mino.color\\r\\\
						end\\r\\\
					end\\r\\\
				end\\r\\\
\\r\\\
				colorLine1 = colorLine1 .. (minoColor1 or ((self.contents[y + 0] and self.contents[y + 0]:sub(x, x)) or self.blankColor))\\r\\\
				colorLine2 = colorLine2 .. (minoColor2 or ((self.contents[y + 1] and self.contents[y + 1]:sub(x, x)) or self.blankColor))\\r\\\
				colorLine3 = colorLine3 .. (minoColor3 or ((self.contents[y + 2] and self.contents[y + 2]:sub(x, x)) or self.blankColor))\\r\\\
\\r\\\
			end\\r\\\
\\r\\\
			if (y + 0) > self.height or (y + 0) <= (self.height - self.visibleHeight) then\\r\\\
				colorLine1 = transparentLine\\r\\\
			end\\r\\\
			if (y + 1) > self.height or (y + 1) <= (self.height - self.visibleHeight) then\\r\\\
				colorLine2 = transparentLine\\r\\\
			end\\r\\\
			if (y + 2) > self.height or (y + 2) <= (self.height - self.visibleHeight) then\\r\\\
				colorLine3 = transparentLine\\r\\\
			end\\r\\\
\\r\\\
			term.setCursorPos(self.x, self.y + tY)\\r\\\
			term.blit(charLine2, colorLine1, colorLine2)\\r\\\
			tY = tY + 1\\r\\\
			term.setCursorPos(self.x, self.y + tY)\\r\\\
			term.blit(charLine1, colorLine2, colorLine3)\\r\\\
			tY = tY + 1\\r\\\
			\\r\\\
		end\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
return Board\",\
  },\
}")
if fs.isReadOnly(outputPath) then
	error("Output path is read-only. Abort.")
elseif fs.getFreeSpace(outputPath) <= #archive then
	error("Insufficient space. Abort.")
end

if fs.exists(outputPath) and fs.combine("", outputPath) ~= "" then
	print("File/folder already exists! Overwrite?")
	stc(colors.lightGray)
	print("(Use -o when making the extractor to always overwrite.)")
	stc(colors.white)
	if choice() ~= 1 then
		error("Chose not to overwrite. Abort.")
	else
		fs.delete(outputPath)
	end
end
if selfDelete or (fs.combine("", outputPath) == shell.getRunningProgram()) then
	fs.delete(shell.getRunningProgram())
end
for name, contents in pairs(archive.data) do
	stc(colors.lightGray)
	write("'" .. name .. "'...")
	if contents == true then -- indicates empty directory
		fs.makeDir(fs.combine(outputPath, name))
	else
		file = fs.open(fs.combine(outputPath, name), "w")
		if file then
			file.write(contents)
			file.close()
		end
	end
	if file then
		stc(colors.green)
		print("good")
	else
		stc(colors.red)
		print("fail")
	end
end
stc(colors.white)
write("Unpacked to '")
stc(colors.yellow)
write(outputPath .. "/")
stc(colors.white)
print("'.")
