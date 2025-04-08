--[[

   ,--,
,---.'|
|   | :        ,---,     ,-.----.       ,---,   .--.--.          ,----,
:   : |      .'  .' `\   \    /  \   ,`--.' |  /  /    '.      .'   .' \
|   ' :    ,---.'     \  ;   :    \  |   :  : |  :  /`. /    ,----,'    |
;   ; '    |   |  .`\  | |   | .\ :  :   |  ' ;  |  |--`     |    :  .  ;
'   | |__  :   : |  '  | .   : |: |  |   :  | |  :  ;_       ;    |.'  /
|   | :.'| |   ' '  ;  : |   |  \ :  '   '  ;  \  \    `.    `----'/  ;
'   :    ; '   | ;  .  | |   : .  /  |   |  |   `----.   \     /  ;  /
|   |  ./  |   | :  |  ' ;   | |  \  '   :  ;   __ \  \  |    ;  /  /-,
;   : ;    '   : | /  ;  |   | ;\  \ |   |  '  /  /`--'  /   /  /  /.`|
|   ,/     |   | '` ,/   :   ' | \.' '   :  | '--'.     /  ./__;      :
'---'      ;   :  .'     :   : :-'   ;   |.'    `--'---'   |   :    .'
           |   ,.'       |   |.'     '---'                 ;   | .'
           '---'         `---'                             `---'

LDRIS 2 (Work in Progress)
Last update: April 8th 2025

Current features:
	+ Real SRS rotation and wall-kicking!
	+ 7bag randomization!
	+ Modern-feeling controls!
	+ Ghost piece!
	+ Piece holding!
	+ Sonic drop!
	+ Configurable SDF, DAS, ARR, ARE, lock delay, etc.!
	+ Piece queue! It's even animated!

To-do:
	+ Refactor all code to look prettier
	+ Add score, and let lineclears and piece dropping add to it
	+ Fix garbage calculation when considering combos (currently doesn't factor in combos)
	+ Implement initial hold and initial rotation
	+ Check for perfect clears and react accordingly (send 10 lines of garbage)
	+ Add an actual menu, and not that shit LDRIS 1 had
	+ Implement proper Multiplayer (modem-only for now)
	+ Cheese race mode
	+ Define color palletes so that the ghost piece isn't the color of dirt
	+ Add in-game menu for changing controls (some people can actually tolerate guideline)
]]

local scr_x, scr_y = term.getSize()

local Board = require "lib.board"
local Mino = require "lib.mino"
local GameInstance = require "lib.gameinstance"
local Control = require "lib.control"
local cospc_debuglog = require "lib.debug"
local clientConfig = require "lib.clientconfig" -- client config can be changed however you please
local gameConfig = require "lib.gameconfig" -- ideally, only clients with IDENTICAL game configs should face one another
gameConfig.kickTables = require "lib.kicktables"

-- returns a number that's capped between 'min' and 'max', inclusively
local function between(number, min, max)
	return math.min(math.max(number, min), max)
end

-- image-related functions (from NFTE)
local loadImageDataNFT = function(image, background) -- string image
	local output = {{},{},{}} -- char, text, back
	local y = 1
	background = (background or "f"):sub(1,1)
	local text, back = "f", background
	local doSkip, c1, c2 = false
	local tchar = string.char(31)	-- for text colors
	local bchar = string.char(30)	-- for background colors
	local maxX = 0
	local bx
	for i = 1, #image do
		if doSkip then
			doSkip = false
		else
			output[1][y] = output[1][y] or ""
			output[2][y] = output[2][y] or ""
			output[3][y] = output[3][y] or ""
			c1, c2 = image:sub(i,i), image:sub(i+1,i+1)
			if c1 == tchar then
				text = c2
				doSkip = true
			elseif c1 == bchar then
				back = c2
				doSkip = true
			elseif c1 == "\n" then
				maxX = math.max(maxX, #output[1][y])
				y = y + 1
				text, back = " ", background
			else
				output[1][y] = output[1][y]..c1
				output[2][y] = output[2][y]..text
				output[3][y] = output[3][y]..back
			end
		end
	end
	for y = 1, #output[1] do
		output[1][y] = output[1][y] .. (" "):rep(maxX - #output[1][y])
		output[2][y] = output[2][y] .. (" "):rep(maxX - #output[2][y])
		output[3][y] = output[3][y] .. (background):rep(maxX - #output[3][y])
	end
	return output
end

-- draws an image with the topleft corner at (x, y), with transparency
local drawImageTransparent = function(image, x, y, terminal)
	terminal = terminal or term.current()
	local cx, cy = terminal.getCursorPos()
	local c, t, b
	for iy = 1, #image[1] do
		for ix = 1, #image[1][iy] do
			c, t, b = image[1][iy]:sub(ix,ix), image[2][iy]:sub(ix,ix), image[3][iy]:sub(ix,ix)
			if b ~= " " or c ~= " " then
				terminal.setCursorPos(x + (ix - 1), y + (iy - 1))
				terminal.blit(c, t, b)
			end
		end
	end
	terminal.setCursorPos(cx,cy)
end

local GameInstance = require "lib.gameinstance"


local TitleScreen = function()
	local animation = function()
		local tsx = 8
		local tsy = 10
		--[[
		local title = {
			[1] = "ee\nee\neeffe",
			[2] = "ddfdffd\ndd   dffd\nddffd",
			[3] = "11f1ff1\n11ff1\n11   11f",
			[4] = "affa\naffa\naf",
			[5] = "3f3f3f\nf33ff3\n3ff3",
			[6] = "4ff44f\n   4ff4\n4f4f"
		}
		--]]
		
		--[[
			1 = "    ",
				"@@@@",
				"    ",
				"    ",

			2 = " @ ",
				"@@@",
				"    ",

			3 = "  @",
				"@@@",
				"   ",
				
			4 = "@  ",
				"@@@",
				"   ",

			5 = "@@",
				"@@",

			6 = " @@",
				"@@ ",
				"   ",

			7 = "@@ ",
				" @@",
				"   ",
		]]

		local animBoard = Board:New(1, 1, scr_x, scr_y * 10/3, "f")
		animBoard.visibleHeight = animBoard.height / 2

		local animMinos = {}

		local iterate = 0
		local mTimer = 100000
		
		local titleMinos = {
			-- L
			Mino:New(nil, 4, animBoard, tsx + 1, tsy).Rotate(0),
			Mino:New(nil, 1, animBoard, tsx + 0, tsy).Rotate(3),
			
			-- D
			Mino:New(nil, 7, animBoard, tsx + 6, tsy).Rotate(3),
			Mino:New(nil, 3, animBoard, tsx + 4, tsy).Rotate(1),
			nil
		}

		for i = 1, #titleMinos do
			if titleMinos[i] then
				table.insert(animMinos, titleMinos[i])
			end
		end

		while true do
			iterate = (iterate + 10) % 360

			if mTimer <= 0 then
				table.insert(animMinos, Mino:New(nil,
					math.random(1, 7),
					animBoard,
					math.random(1, animBoard.width - 4),
					animBoard.visibleHeight - 4
				))
				mTimer = 4
			else
				mTimer = mTimer - 1
			end

			for i = 1, #animMinos do
				animMinos[i]:Move(0, 0.75, false)
				if animMinos[i].y > animBoard.height then
					table.remove(animMinos, i)
				end
			end

			animBoard:Render(table.unpack(animMinos))

			sleep(0.05)
		end
	end
	local menu = function()
		local options = {"Singleplayer", "How to play", "Quit"}
		
	end
	--animation()
	--StartGame(true, 0, 0)
	--[[
	parallel.waitForAny(function()
		cospc_debuglog(1, "Starting game.")
		StartGame(1, true, 0, 0)
		cospc_debuglog(1, "Game concluded.")
	end, function()
		while true do
			cospc_debuglog(2, "Starting game.")
			StartGame(2, false, 24, 0)
			cospc_debuglog(2, "Game concluded.")
		end
	end)
	--]]
	local tickTimer = os.startTimer(gameConfig.tickDelay)
	
	local GAMES = {
		GameInstance:New(1, Control:New(clientConfig, true),  0,  0, clientConfig):Initiate(),
		--GameInstance:New(2, Control:New(clientConfig, false), 24, 0, clientConfig):Initiate()
	}
	
	local message, doTick
	local keysDown = {}
	
	cospc_debuglog(2, "Starting game.")
	
	while true do
		evt = {os.pullEvent()}
		
		if evt[1] == "timer" and evt[2] == tickTimer then
			doTick = true
			tickTimer = os.startTimer(gameConfig.tickDelay)
		else
			doTick = false
		end
		
		if evt[1] == "key" and evt[2] == keys.tab then
			-- swap playable game
			GAMES[1].control:Clear()
			GAMES[2].control:Clear()
			GAMES[1].control.native_control = not GAMES[1].control.native_control
			GAMES[2].control.native_control = not GAMES[2].control.native_control
		end
		
		-- run games
		if not (evt[1] == "key" and evt[3]) then -- do not resume on key repeat events!
			for i, GAME in ipairs(GAMES) do
				message = GAME:Resume(evt, doTick) or {}
				
				-- end game
				if message.finished then
					cospc_debuglog(i, "Game over!")
					-- for demo purposes, just restart games that fail if they aren't the player
					if i ~= 1 then
						GAME:Initiate()
					else
						return
					end
				end
				
				-- deal garbage attacks to other game instances
				if message.attack then
					for _i, _GAME in ipairs(GAMES) do
						if _i ~= i then
							_GAME:ReceiveGarbage(message.attack)
						end
					end
				end
			end
		end
	end
end

term.clear()

cospc_debuglog(nil, 0)

cospc_debuglog(nil, "Opened LDRIS2.")

TitleScreen()

cospc_debuglog(nil, "Closed LDRIS2.")

term.setCursorPos(1, scr_y - 1)
term.clearLine()
print("Thank you for playing!")
term.setCursorPos(1, scr_y - 0)
term.clearLine()

sleep(0.05)
