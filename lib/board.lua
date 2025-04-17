-- generates a new board, on which polyominos can be placed and interact
local Board = {}

local gameConfig = require "config.gameconfig"

local stringrep = string.rep
local mathfloor = math.floor

function Board:New(x, y, width, height, blankColor)
    local board = setmetatable({}, self)
    self.__index = self

    board.contents = {}
    board.height = height or gameConfig.board_height
    board.width = width or gameConfig.board_width
    board.x, board.y = x, y
    board.blankColor = blankColor or "7" -- color if no minos are in that spot
    board.transparentColor = "f"         -- color if the board tries to render where there is no board
    board.garbageColor = "8"
    board.visibleHeight = height and mathfloor(board.height / 2) or gameConfig.board_height_visible
    board.charHeight = math.ceil(board.visibleHeight * (2 / 3))
    board.overtopHeight = 0

    for y = 1, board.height do
        board.contents[y] = stringrep(" ", board.width)
    end

    return board
end

function Board:Write(x, y, color)
    x = mathfloor(x)
    y = mathfloor(y)
    if not self.contents[y] then
        error("tried to write outsite size of board!")
    end
    self.contents[y] = self.contents[y]:sub(1, x - 1) .. color .. self.contents[y]:sub(x + 1)
end

function Board:IsSolid(x, y)
	x = mathfloor(x)
	y = mathfloor(y)
	if self.contents[y] then
		if x >= 1 and x <= self.width then
			return (self.contents[y]:sub(x, x) ~= " "), self.contents[y]:sub(x, x)
		end
	end

	return true, " "
end

function Board:AddGarbage(amount)
    if amount < 1 then return end

    local changePercent = 00 -- higher the percent, the more likely it is that subsequent rows of garbage will have a different hole
    local holeX = math.random(1, self.width)

    -- move board contents up
    for y = amount, self.height do
        self.contents[y - amount + 1] = self.contents[y]
    end

    -- populate 'amount' bottom rows with fucking bullshit
    for y = self.height, self.height - amount + 1, -1 do
        self.contents[y] = stringrep(self.garbageColor, holeX - 1) .. " " .. stringrep(self.garbageColor, self.width - holeX)
        if math.random(1, 100) <= changePercent then
            holeX = math.random(1, self.width)
        end
    end
end

function Board:CheckPerfectClear()
    -- checks only the bottom 2 rows, since is is impossible to have blocks floating above two empty rows
    -- ... i think
    for y = self.height - 1, self.height do
        if self.contents[y] ~= (" "):rep(self.width) then
            return false
        end
    end

    return true
end

function Board:Clear(color)
    color = color or " "
    for y = 1, self.height do
        self.contents[y] = stringrep(color, self.width)
    end
    return self
end

-- used for sending board data over the network
function Board:Serialize(doIncludeInit)
    return textutils.serialize({
        x             = doIncludeInit and self.x or nil,
        y             = doIncludeInit and self.y or nil,
        height        = doIncludeInit and self.height or nil,
        width         = doIncludeInit and self.width or nil,
        blankColor    = doIncludeInit and self.blankColor or nil,
        visibleHeight = self.visibleHeight or nil,
        contents      = self.contents
    })
end

-- takes list of minos that it will render atop the board
function Board:Render(...)
    local charLine1 = stringrep("\131", self.width)
    local charLine2 = stringrep("\143", self.width)
    local transparentLine, blankLine = {}, {}
    for x = 1, self.width do
        transparentLine[x] = self.transparentColor
        blankLine[x] = " "
    end
    local colorLine1, colorLine2, colorLine3 = {}, {}, {}
    local minoColor1, minoColor2, minoColor3
    local minos = { ... }
    local is_solid, mino_color, mino

	local tY = self.y - math.ceil(self.overtopHeight * 0.666)
	local topbound = (self.height - (self.visibleHeight + self.overtopHeight))
	local visibound = topbound + self.overtopHeight

	for y = 1 + topbound, self.height, 3 do
--		colorLine1, colorLine2, colorLine3 = {}, {}, {}
        for x = 1, self.width do
            minoColor1, minoColor2, minoColor3 = nil, nil, nil
            for i = #minos, 1, -1 do
				mino = minos[i]
                if mino.visible then

                    is_solid, mino_color = mino:CheckSolid(x, y + 0, true)
                    if is_solid then
                        minoColor1 = mino_color
                    end

                    is_solid, mino_color = mino:CheckSolid(x, y + 1, true)
                    if is_solid then
                        minoColor2 = mino_color
                    end

                    is_solid, mino_color = mino:CheckSolid(x, y + 2, true)
                    if is_solid then
                        minoColor3 = mino_color
                    end

                end
				
				if minoColor1 or minoColor2 or minoColor3 then
					break
				end
            end

            colorLine1[x] = (minoColor1 or ((self.contents[y]     and self.contents[y]    :sub(x, x)) or " "))
            colorLine2[x] = (minoColor2 or ((self.contents[y + 1] and self.contents[y + 1]:sub(x, x)) or " "))
            colorLine3[x] = (minoColor3 or ((self.contents[y + 2] and self.contents[y + 2]:sub(x, x)) or " "))

            if colorLine1[x] == " " then colorLine1[x] = (y     > (visibound) and self.blankColor or self.transparentColor) end
            if colorLine2[x] == " " then colorLine2[x] = (y + 1 > (visibound) and self.blankColor or self.transparentColor) end
            if colorLine3[x] == " " then colorLine3[x] = (y + 2 > (visibound) and self.blankColor or self.transparentColor) end

        end

        if (y + 0) > self.height or (y + 0) <= topbound then
            colorLine1 = transparentLine
        end
        if (y + 1) > self.height or (y + 1) <= topbound then
            colorLine2 = transparentLine
        end
        if (y + 2) > self.height or (y + 2) <= topbound then
            colorLine3 = transparentLine
        end

        term.setCursorPos(self.x, self.y + tY)
        term.blit(charLine2, table.concat(colorLine1), table.concat(colorLine2))
        term.setCursorPos(self.x, self.y + tY + 1)
        term.blit(charLine1, table.concat(colorLine2), table.concat(colorLine3))

		tY = tY + 2
    end
end

return Board
