local _AMOUNT_OF_GAMES = 2
local _PRINT_DEBUG_INFO = false
--[[
   ,--,
,---.'|
|   | :       ,---,    ,-.----.     ,---,  .--.--.        ,----,
:   : |     .'  .' `\  \    /  \ ,`--.' | /  /    '.    .'   .' \
|   ' :   ,---.'     \ ;   :    \|   :  :|  :  /`. /  ,----,'    |
;   ; '   |   |  .`\  ||   | .\ ::   |  ';  |  |--`   |    :  .  ;
'   | |__ :   : |  '  |.   : |: ||   :  ||  :  ;_     ;    |.'  /
|   | :.'||   ' '  ;  :|   |  \ :'   '  ; \  \    `.  `----'/  ;
'   :    ;'   | ;  .  ||   : .  /|   |  |  `----.   \   /  ;  /
|   |  ./ |   | :  |  ';   | |  \'   :  ;  __ \  \  |  ;  /  /-,
;   : ;   '   : | /  ; |   | ;\  \   |  ' /  /`--'  / /  /  /.`|
|   ,/    |   | '` ,/  :   ' | \.'   :  |'--'.     /./__;      :
'---'     ;   :  .'    :   : :-' ;   |.'   `--'---' |   :    .'
          |   ,.'      |   |.'   '---'              ;   | .'
          '---'        `---'                        `---'

LDRIS 2 (Work in Progress)
Last update: April 18th 2025

Current features:
+ SRS wall kicks! 180-spins!
+ 7bag randomization!
+ Modern-feeling controls!
+ Garbage attack!
+ Ghost piece, piece holding, sonic drop!
+ Configurable SDF, DAS, ARR, ARE, lock delay, etc.!
+ Animated piece queue!
+ Included sound effects!

To-do:
+ Implement DFPWM audio so that real sound effects work in CC:Tweaked
+ Try to further mitigate any garbage collector-related slowdown in CraftOS-PC
+ Refactor code to look prettier
+ Add score, and let line clears and piece dropping add to it
+ Implement initial hold and initial rotation
+ Improve menu drastically
+ Implement proper Multiplayer (aiming for modem-only for now)
+ Implement arcade features (proper kiosk mode, krist integration)
+ Add touchscreen-friendly controls for CraftOS-PC Mobile
+ Cheese race mode
+ 40-line Sprint mode
+ Add in-game menu for changing controls (some people can actually tolerate guideline)
]]

-- if my indenting is fucked, I blame zed's default settings'

local scr_x, scr_y = term.getSize()

local Board = require "lib.board"
local Mino = require "lib.mino"
local GameInstance = require "lib.gameinstance"
local Control = require "lib.control"
local GameDebug = require "lib.gamedebug"
local Menu = require "lib.menu"
local cospc_debuglog = GameDebug.cospc_debuglog
local clientConfig = require "config.clientconfig" -- client config can be changed however you please
local gameConfig = require "config.gameconfig"     -- ideally, only clients with IDENTICAL game configs should face one another
gameConfig.kickTables = require "lib.kicktables"

local modem = peripheral.find("modem")
if (not modem) and ccemux then
	ccemux.attach("top", "wireless_modem")
	modem = peripheral.wrap("top")
end

if modem then
	modem.open(100)
end

--local dfpwm = require "cc.audio.dfpwm"

local resume_count = 0

local speaker = peripheral.find("speaker")
if (not speaker) and periphemu then
	periphemu.create("speaker", "speaker")
	speaker = peripheral.wrap("speaker")
end

-- note block pitches for playing bad sound effects
-- index 1 is delay duration, the rest represent pitch
local sound_timers = {}
local sound_data = {
	mino_Z = { 0.1, 15, 6, 9 },
	mino_T = { 0.1, 8, 10, 12 },
	mino_S = { 0.05, 17, 12, 15, 10, 12, 19 },
	mino_O = { 0.05, 17, 12, 10, 9, 5, 3 },
	mino_L = { 0.1, 7, 5 },
	mino_J = { 0.05, 5, 7, 11, 10, 13, 12, 13, 13, 15, 19 },
	mino_I = { 0.05, 19, 14, 11, 7, 9, 11, 14, 19 },
	lineclear = { 0.05, 24, 19, 16, 12, 12, 16, 19, 24 }
}

local function playNote(note)
	if speaker then
		speaker.playNote("guitar", 1, note)
	end
end

local function queueSound(name)
	if not gameConfig.enable_sound then
		return
	end

	if gameConfig.enable_noteblocksound then
		if sound_data[name] then
			for i = 2, #sound_data[name] do
				sound_timers[os.startTimer((i - 2) * sound_data[name][1])] = sound_data[name][i]
			end
		end

	elseif speaker then
		speaker.playLocalMusic(fs.combine(shell.dir(), "sound/" .. name .. ".ogg"), 0.15)
	end
end

local function write_debug_stuff(game)
	if game.control.native_control and _PRINT_DEBUG_INFO then
		local mino = game.state.mino

		term.setCursorPos(18, scr_y - 1)
		term.write("Combo: " .. game.state.combo .. "      ")

		term.setCursorPos(2, scr_y - 1)
		term.write("M=" .. mino.movesLeft .. ", TtL=" .. tostring(mino.lockTimer):sub(1, 4) .. "  ")

		term.setCursorPos(2, scr_y - 0)
		term.write("POS=(" .. mino.x .. ":" .. tostring(mino.xFloat):sub(1, 5) .. ", " .. mino.y .. ":" .. tostring(mino.yFloat):sub(1, 5) .. ")      ")
	end
end

local function move_games(GAMES)
	local game_size = { GAMES[1].width + 2, GAMES[1].height }
	for i = 1, #GAMES do
		GAMES[i]:Move(
			(scr_x / 2) - ((#GAMES * game_size[1]) / 2) + (game_size[1] * (i - 1)),
			(scr_y / 4) - ((game_size[2] - 5) / 2) + 1
		)
	end
end

local function cwrite(text, y, color)
	local cx, cy = term.getCursorPos()
	local sx, sy = term.getSize()
	local og_color = term.getTextColor()
	if color then
		term.setTextColor(color)
	end
	term.setCursorPos(sx / 2 - #text / 2, y or (sy / 2))
	term.write(text)
	term.setTextColor(color)
end

local function WIPscreen(message)
	term.clear()
	cwrite(message, 3, colors.white)
	sleep(0.25)
	cwrite("Press any key to continue", 6, colors.lightGray)
	os.pullEvent("key")
	sleep(0.1)
	term.clear()
end

local function startGame()

	cospc_debuglog(2, "Starting game.")
	term.clear()

	local tickTimer = os.startTimer(gameConfig.tickDelay)
	local message, doTick, doResume

	local frame_time
	local last_epoch = os.epoch()

	local GAMES = {}
	for i = 1, _AMOUNT_OF_GAMES do
		table.insert(GAMES, GameInstance:New(Control:New(clientConfig, false), 0, 0, clientConfig):Initiate(gameConfig.minos, last_epoch))
		if i > 1 then
			GAMES[i].networked = true
		end
	end
	local player_number = math.max(1, math.floor(#GAMES / 2))


	-- center boards on screen
	move_games(GAMES)

	for i, _GAME in ipairs(GAMES) do
		_GAME.control:Clear()
		_GAME.control.native_control = (i == player_number)
	end

	while true do
		doResume = true
		evt = { os.pullEvent() }

		if evt[1] == "modem_message" then
			error("ass")
			if type(evt[5]) == "string" then
				if evt[5]:sub(1, 6) == "ldris2" then
					evt = {"network_moment", evt[5]}
				end
			end
		end

		if _PRINT_DEBUG_INFO then
			term.setCursorPos(1, 1)
			term.write("t=" .. tostring(resume_count) .. "  ")

			term.setCursorPos(20, 1)
			term.write("evt=" .. tostring(evt[1]) .. "   ")
			term.setCursorPos(32, 1)
			term.write(tostring(evt[2]) .. "                    ")

			write_debug_stuff(GAMES[player_number])
		end

		last_epoch = os.epoch("utc")

		if evt[1] == "term_resize" then
			scr_x, scr_y = term.getSize()
			term.clear()
			move_games(GAMES)
		end

		if evt[1] == "timer" then
			if evt[2] == tickTimer then
				doTick = true
				tickTimer = os.startTimer(gameConfig.tickDelay)
			else
				doTick = false

				if sound_timers[evt[2]] then
					doResume = false
					playNote(sound_timers[evt[2]])
					sound_timers[evt[2]] = nil
				end
			end

		end

		if evt[1] == "key" and evt[2] == keys.tab then
			--[[
			player_number = (player_number % #GAMES) + 1
			for i, _GAME in ipairs(GAMES) do
				_GAME.control:Clear()
				_GAME.control.native_control = (i == player_number)
			end
			--]]
		end

		-- it's wasteful to resume during key repeat events
		if (evt[1] == "key" and evt[3]) then
			doResume = false
		end

		-- run games
		if doResume then -- do not resume on key repeat events!
			resume_count = resume_count + 1
			for i, GAME in ipairs(GAMES) do
				--				message = GameDebug.profile("Game " .. i, i + 1, function() return (GAME:Resume(evt, doTick) or {}) end)
				message = GAME:Resume(evt, doTick) or {}

				-- restart game after topout
				if message.gameover then
					cospc_debuglog(i, "Game over!")
					GAME:Initiate(nil, last_epoch)
				end

				-- quit game
				if message.quit then
					return
				end


				-- queue timers for speaker notes
				if message.sound then
					queueSound(message.sound)
				end

				-- deal garbage attacks to other game instances
				if message.attack then
					for _i, _GAME in ipairs(GAMES) do
						if _i ~= i then
							_GAME:ReceiveGarbage(message.attack)
						end
					end
				end

				-- send network packets
				if message.packet and modem then
					for ii, packet in ipairs(message.packet) do
						modem.transmit(100, 100, packet)
					end
				end
			end

			frame_time = os.epoch("utc") - last_epoch
			if _PRINT_DEBUG_INFO or (frame_time > 200) then
				term.setCursorPos(10, 1)
				term.write("ft=" .. tostring(frame_time) .. "ms  ")
			end
		end
	end
end

local function titleScreen()
	term.clear()
	local control = Control:New(clientConfig, true)

	local mainmenu = Menu:New(2, 2)
	mainmenu:SetTitle("LDRIS 2", 1)
	mainmenu:AddOption("Marathon", "marathon", 1, 3)
	mainmenu:AddOption("Multiplayer (Modem)", "mp_modem", 1, 4)
	mainmenu:AddOption("Modes", "mode_menu", 1, 5)
	mainmenu:AddOption("Options", "options_menu", 1, 6)
	mainmenu:AddOption("Quit", "quit_game", 1, 8)
	mainmenu.selected = 1
	mainmenu.cursor = {"O ", "@ "}
	mainmenu.cursor_blink = 0.05

	local modemenu = Menu:New(24, 2)
	modemenu:SetTitle("", 1)
	modemenu:AddOption("Cheese Race", "cheese_race", 1, 3)	-- infinite garbage of a particular height
	modemenu:AddOption("40-line Sprint", "sprint", 1, 4)
	modemenu:AddOption("Some other shit idk", "othershit", 1, 5)
	modemenu:AddOption("Return", "main_menu", 1, 7)
	modemenu.cursor = {"O ", "@ "}
	modemenu.cursor_blink = 0.05

	local evt
	local tickTimer = os.startTimer(mainmenu.cursor_blink)
	local doRenderMenu = true
	local sel

	local MENU = mainmenu

	while true do
		if doRenderMenu then
			MENU:Render()
			doRenderMenu = false
		end
		for k, v in pairs(control.keysDown) do
			control.keysDown[k] = 1 + v
		end
		evt = {os.pullEvent()}
		control:Resume(evt)

		if evt[1] == "timer" and evt[2] == tickTimer then
			tickTimer = os.startTimer(MENU.cursor_blink)
			MENU:CycleCursor()
			doRenderMenu = true
		end

		if control:CheckControl("menu_up") then
			MENU:MoveSelect(-1)
			doRenderMenu = true

		elseif control:CheckControl("menu_down") then
			MENU:MoveSelect(1)
			doRenderMenu = true

		elseif control:CheckControl("menu_select") then
			sel = MENU:GetSelected()
			do
				if sel == "marathon" then
					startGame()
					term.clear()

				elseif sel == "mp_modem" then
					WIPscreen("Multiplayer will be implemented later!")

				elseif sel == "mode_menu" then
					MENU:Render(true)
					MENU = modemenu
					MENU.selected = 1

				elseif sel == "main_menu" then
					MENU = mainmenu
					term.clear()

				elseif sel == "options_menu" then
					WIPscreen("Options will be added later! Really!")

				elseif sel == "quit_game" then
					return
				end
			end

			do
				if sel == "cheese_race" then
					WIPscreen("Cheese race will be added later!")
					mainmenu:Render(true)

				elseif sel == "sprint" then
					WIPscreen("Sprint mode will be added later!")
					mainmenu:Render(true)

				elseif sel == "othershit" then
					WIPscreen("Other modes will be added later!")
					mainmenu:Render(true)
				end
			end

			tickTimer = os.startTimer(MENU.cursor_blink)
			doRenderMenu = true

		elseif control:CheckControl("quit") then
			return
		end
	end
end

term.clear()

cospc_debuglog(nil, 0)
cospc_debuglog(nil, "Opened LDRIS2.")


local original_palette = {}
local original_randomseed = {math.randomseed()}
for i = 0, 15 do
	original_palette[i + 1] = { term.getPaletteColor(2 ^ i) }
end
term.setPaletteColor(colors.gray, 0.15, 0.15, 0.15)
term.setPaletteColor(colors.brown, 0.25, 0.25, 0.25)

local success, err_message = pcall(titleScreen)

for i = 1, 16 do
	term.setPaletteColor(2 ^ (i - 1), table.unpack(original_palette[i]))
end
math.randomseed(table.unpack(original_randomseed))

if not success then
	error(err_message)
end

cospc_debuglog(nil, "Closed LDRIS2.")

term.setCursorPos(1, scr_y - 1)
term.clearLine()
term.setTextColor(colors.yellow)
print("Thank you for playing!")
term.setCursorPos(1, scr_y - 0)
term.clearLine()
term.setTextColor(colors.white)

sleep(0.05)
