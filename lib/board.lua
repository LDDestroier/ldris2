-- generates a new board, on which polyominos can be placed and interact
local Board = {}

local gameConfig = require "config.gameconfig"

local stringrep = string.rep
local mathfloor = math.floor
local tableconcat = table.concat

-- {match pattern, character, color invert?}
local tele_lookup_rev = {}
local tele_lookup_nor = {
	["      "] = "\128",
	["O     "] = "\129",
	[" O    "] = "\130",
	["OO    "] = "\131",
	["  O   "] = "\132",
	["O O   "] = "\133",
	[" OO   "] = "\134",
	["OOO   "] = "\135",
	["   O  "] = "\136",
	["O  O  "] = "\137",
	[" O O  "] = "\138",
	["OO O  "] = "\139",
	["  OO  "] = "\140",
	["O OO  "] = "\141",
	[" OOO  "] = "\142",
	["OOOO  "] = "\143",
	["    O "] = "\144",
	["O   O "] = "\145",
	[" O  O "] = "\146",
	["OO  O "] = "\147",
	["  O O "] = "\148",
	["O O O "] = "\149",
	[" OO O "] = "\150",
	["OOO O "] = "\151",
	["   OO "] = "\152",
	["O  OO "] = "\153",
	[" O OO "] = "\154",
	["OO OO "] = "\155",
	["  OOO "] = "\156",
	["O OOO "] = "\157",
	[" OOOO "] = "\158",
	["OOOOO "] = "\159"
}

for k,v in pairs(tele_lookup_nor) do
	if type(k) == "string" then
		tele_lookup_rev[ k:gsub( ".", function(c) return c == " " and "O" or " " end ) ] = v
	end
end

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
	board.last_frame = {}

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

function Board:AddGarbage(amount, no_hole, color)
    --if amount < 1 then return end

    local changePercent = 00 -- higher the percent, the more likely it is that subsequent rows of garbage will have a different hole
    local holeX = math.random(1, self.width)

    -- move board contents up
    for y = amount, self.height do
        self.contents[y - amount] = self.contents[y]
    end

    -- populate 'amount' bottom rows with fucking bullshit
    for y = self.height, self.height - amount + 1, -1 do
		if no_hole then
			self.contents[y] = stringrep(color or self.garbageColor, self.width)
		else
			self.contents[y] = stringrep(color or self.garbageColor, holeX - 1) .. " " .. stringrep(color or self.garbageColor, self.width - holeX)
			if math.random(1, 100) <= changePercent then
				holeX = math.random(1, self.width)
			end
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

function Board:SerializeContents()
	return tableconcat(self.contents)
end

-- takes list of minos that it will render atop the board
function Board:Render(tOpts, ...)
	tOpts = tOpts or {}
	local xmod = tOpts[1] or 0
	local ymod = tOpts[2] or 0
	local char_sub = tOpts.char_sub or {}
	local text_sub = tOpts.text_sub or {}
	local back_sub = tOpts.back_sub or {}
	local ignore_dirty = tOpts.ignore_dirty
	
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
	local topbound = self.height - (self.visibleHeight + self.overtopHeight)
	local visibound = topbound + self.overtopHeight
	local mino
	local dirty = {}

	for y = 1 + topbound, self.height, 3 do
--		colorLine1, colorLine2, colorLine3 = {}, {}, {}
        for x = 1, self.width do
            minoColor1, minoColor2, minoColor3 = nil, nil, nil
            --for i, mino in ipairs(minos) do
			for i = 1, #minos, 1 do
				mino = minos[i]
                if mino.visible then

                    is_solid, mino_color = mino:CheckSolid(x, y + 0, true)
                    if is_solid then
                        minoColor1 = mino_color
						dirty[tY] = true
                    end

                    is_solid, mino_color = mino:CheckSolid(x, y + 1, true)
                    if is_solid then
                        minoColor2 = mino_color
						dirty[tY] = true
						dirty[tY + 1] = true
                    end

                    is_solid, mino_color = mino:CheckSolid(x, y + 2, true)
                    if is_solid then
                        minoColor3 = mino_color
						dirty[tY + 1] = true
                    end

                end
            end

            colorLine1[x] = (minoColor1 or ((self.contents[y    ] and self.contents[y    ]:sub(x, x)) or " "))
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
		
		local _cl1, _cl2, _cl3 = tableconcat(colorLine1), tableconcat(colorLine2), tableconcat(colorLine3)
		
		if ignore_dirty or (self.last_frame[tY] ~= (_cl1 .. _cl2)) then
			term.setCursorPos(self.x + xmod, self.y + tY + ymod)
			term.blit(charLine2, tableconcat(colorLine1), tableconcat(colorLine2))
		end
		if ignore_dirty or (self.last_frame[tY + 1] ~= (_cl2 .. _cl3)) then
			term.setCursorPos(self.x + xmod, self.y + tY + ymod + 1)
			term.blit(charLine1, tableconcat(colorLine2), tableconcat(colorLine3))
		end
		
		self.last_frame[tY]     = _cl1 .. _cl2
		self.last_frame[tY + 1] = _cl2 .. _cl3
		
		tY = tY + 2
    end
end

-- draws the board using smaller, black and white characters
function Board:RenderTiny(tOpts, ...)
	tOpts = tOpts or {}
	local xmod = tOpts[1] or 0
	local ymod = tOpts[2] or 0
	local char_sub = tOpts.char_sub or {}
	local text_sub = tOpts.text_sub or {}
	local back_sub = tOpts.back_sub or {}
	
	local charLine = {}
	local textLine = {}
	local backLine = {}
	local pixel = ""
	local minos = { ... }
	
	local is_solid
	
	local topbound = self.height - (self.visibleHeight + self.overtopHeight)
	local visibound = topbound + self.overtopHeight
	local tY = self.y - math.ceil(self.overtopHeight * 0.333)
	local ix = 0
	
	for y = 1 + topbound, self.height, 3 do
		charLine = {}
		textLine = {}
		backLine = {}
		ix = 0 -- char/text/backLine iterator
		for x = 1, self.width, 2 do
			ix = ix + 1
			pixel = ""
			for my = 0, 2 do
				for mx = 0, 1 do
					is_solid = false
					if (not self.contents[y + my]) then
						pixel = pixel .. " "
					elseif self.contents[y + my]:sub(x + mx, x + mx) == "" then
						pixel = pixel .. " "
					elseif self.contents[y + my]:sub(x + mx, x + mx) ~= " " then
						pixel = pixel .. "O"
					else
						for i, mino in ipairs(minos) do
							if mino.visible then
								is_solid = is_solid or mino:CheckSolid(x + mx, y + my, true)
								if is_solid then break end
							end
						end
						pixel = pixel .. (is_solid and "O" or " ")
					end
				end
			end
			-- match "pixel"
			if tele_lookup_nor[pixel] then
				charLine[ix] = tele_lookup_nor[pixel]
				textLine[ix] = "0"
				backLine[ix] = "f"
			elseif tele_lookup_rev[pixel] then
				charLine[ix] = tele_lookup_rev[pixel]
				textLine[ix] = "f"
				backLine[ix] = "0"
			else
				charLine[ix] = "?"
				textLine[ix] = "8"
				backLine[ix] = "c"
			end
		end
		term.setCursorPos(self.x + xmod, tY + ymod)
		term.blit(tableconcat(charLine), tableconcat(textLine), tableconcat(backLine))
		tY = tY + 1
	end
	
end

return Board
