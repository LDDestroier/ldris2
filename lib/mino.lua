-- makes a Mino, a tetris piece that can be writted to and rendered on a Board
-- TODO: precalculate all rotated minos so that I don't have to recalculate their rotated state every time
local Mino = {}

local gameConfig = require "config.gameconfig"

-- recursively copies the contents of a table
table.copy = function(tbl)
	local output = {}
	for k, v in pairs(tbl) do
		output[k] = (type(v) == "table" and k ~= v) and table.copy(v) or v
	end
	return output
end

local mathfloor = math.floor

function Mino:New(mino_table, minoID, board, xPos, yPos, oldeMino)
	local mino = setmetatable(oldeMino or {}, self)
	self.__index = self

	mino_table = mino_table or gameConfig.minos
	if not mino_table[minoID] then
		error("tried to spawn mino with invalid ID '" .. tostring(minoID) .. "'")
	else
		mino.shape = mino_table[minoID].shape
		mino.spinID = mino_table[minoID].spinID
		mino.kickID = mino_table[minoID].kickID
		mino.color = mino_table[minoID].color
		mino.name = mino_table[minoID].name
	end

	mino.mino_table = mino_table
	mino.finished = false
	mino.active = true
	mino.spawnTimer = 0
	mino.visible = true
	mino.height = #mino.shape
	mino.width = #mino.shape[1]
	mino.minoID = minoID
	mino.x = xPos
	mino.y = yPos
	mino.xFloat = 0
	mino.yFloat = 0
	mino.board = board
	mino.rotation = 0
	mino.resting = false
	mino.lockTimer = gameConfig.lock_delay
	mino.movesLeft = gameConfig.lock_move_limit
	mino.yHighest = mino.y
	mino.doWriteColor = false

	return mino
end

function Mino:Serialize(doIncludeInit)
	return textutils.serialize({
		minoID = doIncludeInit and self.minoID or nil,
		rotation = self.rotation,
		x = x,
		y = y,
	})
end

-- takes absolute position (x, y) on board, and returns true if it exists within the bounds of the board
function Mino:DoesSpotExist(x, y)
	return self.board and (
		x >= 1 and
		x <= self.board.width and
		y >= 1 and
		y <= self.board.height
	)
end

-- checks if the mino is colliding with solid objects on its board, shifted by xMod and/or yMod (default 0)
-- if doNotCountBorder == true, the border of the board won't be considered as solid
-- returns true if it IS colliding, and false if it is not
function Mino:CheckCollision(xMod, yMod, doNotCountBorder, round)
	local cx, cy -- represents position on board
	round = round or mathfloor
	for y = 1, self.height do
		for x = 1, self.width do
			cx = round(-1 + x + self.x + xMod)
			cy = round(-1 + y + self.y + yMod)

			if self:DoesSpotExist(cx, cy) then
				if (
					self.board:IsSolid(cx, cy) and
					self:CheckSolid(x, y)
				) then
					return true
				end

			elseif (not doNotCountBorder) and self:CheckSolid(x, y) then
				return true
			end
		end
	end
	return false
end

-- checks whether or not the (x, y) position of the mino's shape is solid
-- returns success, and optionally a hex color
function Mino:CheckSolid(x, y, relativeToBoard)
	--print(x, y, relativeToBoard)
	if relativeToBoard then
		x = x - self.x + 1
		y = y - self.y + 1
	end
	x = mathfloor(x)
	y = mathfloor(y)
	if y >= 1 and y <= #self.shape then
		if x >= 1 and x <= #self.shape[y] then
			return (self.shape[y] or ""):sub(x, x) ~= " ",
			self.doWriteColor and self.color or self.shape[y]:sub(x, x)
		end
	end
	
	return false
end

function Mino:Shade(sMatch, sRepl)
	assert(#sMatch == #sRepl, "both arguments must be same length")
	for i, line in ipairs(self.shape) do
		self.shape[i] = line:gsub(sMatch, sRepl)
	end
	return self
end

-- direction = 1: clockwise
-- direction = -1: counter-clockwise
-- mino.rotation ranges from 0-3
function Mino:Rotate(direction, expendLockMove)
	local oldShape = table.copy(self.shape)
	local kickTable = gameConfig.kickTables[gameConfig.currentKickTable]
	local output = {}
	local success = false
	local kick_count = 0
	local newRotation = (self.rotation + direction) % 4

	if self.active then
		-- get the specific offset table for the type of rotation based on the mino type
		local kickX, kickY
		local kickRot = self.rotation .. newRotation

		-- translate the mino piece
		for y = 1, self.width do
			output[y] = ""
			for x = 1, self.height do
				if direction == -1 then
					output[y] = output[y] .. oldShape[x]:sub(-y, -y)
				elseif direction == 1 then
					output[y] = oldShape[x]:sub(y, y) .. output[y]
				elseif direction == 2 then
					output[y] = oldShape[self.height - y + 1]:sub(x, x) .. output[y]
				end
			end
		end
		
		if direction % 2 == 1 then
			self.width, self.height = self.height, self.width
		end
		self.shape = output
		-- it's time to do some floor and wall kicking
		if self.board and self:CheckCollision(0, 0) then
			for i = 1, #kickTable[self.kickID][kickRot] do
				kickX = kickTable[self.kickID][kickRot][i][1]
				kickY = -kickTable[self.kickID][kickRot][i][2]
				if not self:Move(kickX, kickY, false) then
					success = true
					kick_count = i
					break
				end
			end
		else
			success = true
		end
		
		if success then
			self.rotation = newRotation
		else
			self.shape = oldShape
			if direction % 2 == 1 then
				self.width, self.height = self.height, self.width
			end
		end

		if expendLockMove and not self.mino_table[self.minoID].noDelayLock then
			self.movesLeft = self.movesLeft - 1
			if self.movesLeft <= 0 then
				if self:CheckCollision(0, 1) then
					self.finished = 1
				end
			else
				self.lockTimer = gameConfig.lock_delay
			end
		end
	end

	-- round xFloat/yFloat values
	self.xFloat = math.floor(self.xFloat * 100) * 0.01
	self.yFloat = math.floor(self.yFloat * 100) * 0.01

	return self, success, kick_count
end

-- same as Mino:Rotate, but uses lookup tables to be faster
function Mino:RotateLookup(direction, expendLockMove, mino_rotable)
	local kickTable = gameConfig.kickTables[gameConfig.currentKickTable]
	local success = false
	local kick_count = 0
	local old_rotation = self.rotation
	local newRotation = (self.rotation + direction) % 4
	local kickRot = self.rotation .. newRotation
	
	self.shape = mino_rotable[self.minoID][newRotation + 1]
	if direction % 2 == 1 then
		self.width, self.height = self.height, self.width
	end
	
	-- it's time to do some floor and wall kicking
	if self.board and self:CheckCollision(0, 0) then
		for i = 1, #kickTable[self.kickID][kickRot] do
			kickX = kickTable[self.kickID][kickRot][i][1]
			kickY = -kickTable[self.kickID][kickRot][i][2]
			if not self:Move(kickX, kickY, false) then
				success = true
				kick_count = i
				break
			end
		end
	else
		success = true
	end
	
	if success then
		self.rotation = newRotation
	else
		self.shape = mino_rotable[self.minoID][old_rotation + 1]
		if direction % 2 == 1 then
			self.width, self.height = self.height, self.width
		end
	end
	
	if expendLockMove and not self.mino_table[self.minoID].noDelayLock then
		self.movesLeft = self.movesLeft - 1
		if self.movesLeft <= 0 then
			if self:CheckCollision(0, 1) then
				self.finished = 1
			end
		else
			self.lockTimer = gameConfig.lock_delay
		end
	end
end

-- rotates via lookup table without considering wall kicks or position
-- this is used in network mode where the position and rotation of a mino is already "validated"
-- direction is absolute, not relative
function Mino:ForceRotateLookup(abs_direction, mino_rotable)
	self.shape = mino_rotable[self.minoID][1 + (abs_direction % 4)]
	if (self.rotation - abs_direction) % 2 == 1 then
		self.width, self.height = self.height, self.width
	end
	self.rotation = abs_direction
end

-- if doSlam == true, moves as far as it can before terminating
function Mino:Move(x, y, doSlam, expendLockMove)
	local didSlam
	local didCollide = false
	local didMoveX = true
	local didMoveY = true
	local step, round

	if self.active then
		if doSlam then
			self.xFloat = self.xFloat + x
			self.yFloat = self.yFloat + y

			-- handle Y position
			if y ~= 0 then
				step = y / math.abs(y)
				round = self.yFloat > 0 and mathfloor or math.ceil
				if self:CheckCollision(0, step) then
					self.yFloat = 0
					didMoveY = false
				else
					for iy = step, round(self.yFloat), step do
						if self:CheckCollision(0, step) then
							didCollide = true
							self.yFloat = 0
							break
						else
							didMoveY = true
							self.y = self.y + step
							self.yFloat = self.yFloat - step
						end
					end
				end
			else
				didMoveY = false
			end

			-- handle x position
			if x ~= 0 then
				step = x / math.abs(x)
				round = self.xFloat > 0 and mathfloor or math.ceil
				if self:CheckCollision(step, 0) then
					self.xFloat = 0
					didMoveX = false
				else
					for ix = step, round(self.xFloat), step do
						if self:CheckCollision(step, 0) then
							didCollide = true
							self.xFloat = 0
							break
						else
							didMoveX = true
							self.x = self.x + step
							self.xFloat = self.xFloat - step
						end
					end
				end
			else
				didMoveX = false
			end
		else
			if self:CheckCollision(x, y) then
				didCollide = true
				didMoveX = false
				didMoveY = false
			else
				self.x = self.x + x
				self.y = self.y + y
				didCollide = false
				didMoveX = true
				didMoveY = true
			end
		end

		local yHighestDidChange = (self.y > self.yHighest)
		self.yHighest = math.max(self.yHighest, self.y)

		if yHighestDidChange then
			self.movesLeft = gameConfig.lock_move_limit
		end

		if expendLockMove then
			if didMoveX or didMoveY then
				self.movesLeft = self.movesLeft - 1
				if self.movesLeft <= 0 then
					if self:CheckCollision(0, 1) then
						self.finished = 1
					end
				else
					self.lockTimer = gameConfig.lock_delay
				end
			end
		end
	else
		didMoveX = false
		didMoveY = false
	end

	return didCollide, didMoveX, didMoveY, yHighestDidChange
end

-- writes the mino to the board
function Mino:Write()
	local is_solid, mino_color
	if self.active and self.board then
		for y = 1, self.height do
			for x = 1, self.width do
				is_solid, mino_color = self:CheckSolid(x, y, false)
				if is_solid then
					self.board:Write(x + self.x - 1, y + self.y - 1, self.doWriteColor and self.color or mino_color)
				end
			end
		end
	end
end

return Mino
