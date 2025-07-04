local _AMOUNT_OF_GAMES = 1
local _PRINT_DEBUG_INFO = true
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
Last update: April 22nd 2025

Current features:
+ Basic modem multiplayer! (barely functional)
+ SRS wall kicks! 180-spins!
+ 7bag randomization!
+ Modern-feeling controls!
+ Garbage attack!
+ Ghost piece, piece holding, sonic drop!
+ Configurable SDF, DAS, ARR, ARE, lock delay, etc.!
+ Animated piece queue!
+ Included sound effects!

To-do:
+ Fix multiplayer
+ Try to further mitigate any garbage collector-related slowdown in CraftOS-PC
+ Polish the menu
+ Add proper game over screen
+ Implement DFPWM audio so that real sound effects work in CC:Tweaked
+ Refactor code to look prettier
+ Add score, and let line clears and piece dropping add to it
+ Implement initial hold and initial rotation
+ Implement arcade features (proper kiosk mode, krist integration)
+ Add touchscreen-friendly controls for CraftOS-PC Mobile
+ Cheese race mode
+ 40-line Sprint mode
+ Add in-game menu for changing controls (some people can actually tolerate keyboard guideline)
--]]

-- if my indenting is fucked, I blame zed (neovim for life)

local scr_x, scr_y = term.getSize()

local Board = require "lib.board"
local Mino = require "lib.mino"
local GameInstance = require "lib.gameinstance"
local Control = require "lib.control"
local GameDebug = require "lib.gamedebug"
local Menu = require "lib.menu"

local DEBUG = GameDebug:New( _PRINT_DEBUG_INFO and GameDebug.FindMonitor(), _PRINT_DEBUG_INFO)

local clientConfig = require "config.clientconfig" -- client config can be changed however you please
local gameConfig = require "config.gameconfig"     -- ideally, only clients with IDENTICAL game configs should face one another
gameConfig.kickTables = require "lib.kicktables"

local modem = peripheral.find("modem")
if (not modem) then
	if ccemux then -- CCEmuX
		ccemux.attach("top", "wireless_modem")
		modem = peripheral.wrap("top")
	elseif periphemu then -- CraftOS-PC
		periphemu.create("top", "modem")
		modem = peripheral.wrap("top")
	end
end

if modem then
	modem.open(100)
else
	--error("no modem???")
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
	if game.control.native_control then
		local mino = game.state.mino
		DEBUG:LogHeader("Combo=", game.state.combo, 2)
		DEBUG:LogHeader("TimeToLock=", tostring(mino.lockTimer):sub(1, 4), 5)
		DEBUG:LogHeader("MovesLeft=", mino.movesLeft, 3)
		DEBUG:LogHeader("Pos=", "(" .. mino.x .. ":" .. tostring(mino.xFloat):sub(1, 5) .. ", " .. mino.y .. ":" .. tostring(mino.yFloat):sub(1, 5) .. ")", 16)
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
	term.setCursorPos(math.ceil(sx / 2 - #text / 2), y or (sy / 2))
	term.write(text)
	term.setTextColor(color)
end

local function WIPscreen(...)
	local evt = {}
	local messages = {...}
	term.clear()
	for i = 1, #messages do
		cwrite(messages[i], 2 + i, colors.white)
		sleep(0.1)
	end
	sleep(0.15)
	cwrite("Press any key to continue", 5 + #messages, colors.lightGray)
	repeat
		evt = {os.pullEvent()}
	until evt[1] == "key" or evt[1] == "mouse_click"
	sleep(0.1)
	term.clear()
end

local function startGame(mode_name, is_networked)

	DEBUG:Log("Starting game \"" .. mode_name .. "\", is_networked = " .. tostring(is_networked))
	term.clear()

	local tickTimer = os.startTimer(gameConfig.tickDelay)
	local message, doTick, doResume

	local frame_time
	local last_epoch = os.epoch()

	local GAMES = {}
	for i = 1, _AMOUNT_OF_GAMES do
		table.insert(GAMES, GameInstance:New(Control:New(clientConfig, false), 0, 0, clientConfig):Initiate(gameConfig.minos, last_epoch))
		GAMES[i]:AttachDebug(DEBUG)
		if i > 1 then
			GAMES[i].networked = true
			GAMES[i].do_render_tiny = true
			GAMES[i].do_compact_view = true
			GAMES[i].visible = false
		end
		if mode_name == "marathon_tiny" then
			GAMES[i].do_render_tiny = true
		end
	end
	local player_number = math.max(1, math.floor(#GAMES / 2))


	-- center boards on screen
	move_games(GAMES)

	for i, _GAME in ipairs(GAMES) do
		_GAME.control:Clear()
		_GAME.control.native_control = (i == player_number)
	end
	
	local is_game_running = true

	while is_game_running do
		doResume = true
		evt = { os.pullEvent() }

		if evt[1] == "modem_message" and is_networked then
			if type(evt[5]) == "string" then
				if evt[5]:sub(1, 6) == "ldris2" then
					evt = {"network_moment", evt[5]}
				end
			end
		end

		DEBUG:LogHeader("t=", resume_count, 6)
		DEBUG:LogHeader("evt[1]=", evt[1], 20, true)
		DEBUG:LogHeader("evt[2]=", evt[2], 20, true)
		write_debug_stuff(GAMES[player_number])

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
				message = GAME:Resume(evt, doTick) or {}

				-- restart game after topout
				if message.gameover then
					GAME:Initiate(nil, last_epoch)
				end

				-- quit game
				if message.quit then
					is_game_running = false
				end


				-- queue timers for speaker notes
				if message.sound then
					queueSound(message.sound)
				end

				-- deal garbage attacks to other game instances
				if message.attack then
					for _i, _GAME in ipairs(GAMES) do
						if _i ~= i then _GAME:ReceiveGarbage(message.attack) end
					end
				end

				-- send network packets
				if message.packet and modem and is_networked then
					for ii, packet in ipairs(message.packet) do
						modem.transmit(100, 100, packet)
					end
				end
			end

			frame_time = os.epoch("utc") - last_epoch
			DEBUG:LogHeader("ft=", tostring(frame_time) .. "ms")
			
		end

		if frame_time > 100 and collectgarbage then
			collectgarbage("collect")
		end
		
		DEBUG:Render(true)
	end
	
	DEBUG:Log("Game stopped.")
end

local function titleScreen()
	term.clear()
	local control = Control:New(clientConfig, true)

	local mainmenu = Menu:New(2, 2)
	mainmenu:SetTitle("LDRIS 2", 1)
	mainmenu:AddOptions({
		{"Marathon", "marathon", 1, 3},
		{"Marathon (Tiny)", "marathon_tiny", 1, 4},
		{"Multiplayer (Modem)", "mp_modem", 1, 5},
		{"Modes", "mode_menu", 1, 6},
		{"Options", "options_menu", 1, 7},
		{"Quit", "quit_game", 1, 9}
	})
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
	
	local optionmenu = Menu:New(2, 2)
	optionmenu:SetTitle("Options")
	optionmenu:AddOptions({
		{"", "", 1, 3}
	})
	
	-- size consideration for pocket computers
	if scr_x < 45 then
		modemenu:Move(2, 11)
		modemenu:SetTitle("MODES:", 1)
	end

	local evt
	local tickTimer = os.startTimer(mainmenu.cursor_blink)
	local doRenderMenu = true
	local sel

	local MENU = mainmenu
	local force_select = false
	local force_return = false

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
			
		elseif evt[1] == "term_resize" then
			term.setCursorPos(MENU.x, MENU.y)
			term.clearLine()
			doRenderMenu = true
			
		elseif evt[1] == "mouse_click" and evt[2] < 3 then
			local sel_try = MENU:MouseSelect(evt[3], evt[4])
			if sel_try then
				if sel_try == MENU.selected or evt[2] == 2 then
					force_select = true
				end
			elseif evt[2] == 2 then
				force_return = true
			end
			MENU.selected = sel_try or MENU.selected
			doRenderMenu = true
		end

		if control:CheckControl("menu_up") then
			MENU:MoveSelect(-1)
			doRenderMenu = true

		elseif control:CheckControl("menu_down") then
			MENU:MoveSelect(1)
			doRenderMenu = true

		elseif control:CheckControl("menu_select") or force_select or force_return then
			sel = force_return and "" or MENU:GetSelected()
			do
				if sel == "marathon" then
					_AMOUNT_OF_GAMES = 1
					startGame(sel, false)
					term.clear()
				
				elseif sel == "marathon_tiny" then
					_AMOUNT_OF_GAMES = 1
					startGame(sel, false)
					term.clear()

				elseif sel == "mp_modem" then
					_AMOUNT_OF_GAMES = 2
					--WIPscreen("Multiplayer will be", "implemented later!")
					startGame(sel, true)
					term.clear()

				elseif sel == "mode_menu" then
					MENU:Render(true)
					MENU = modemenu
					MENU.selected = 1

				elseif sel == "main_menu" or force_return then
					MENU = mainmenu
					term.clear()

				elseif sel == "options_menu" then
					WIPscreen("Options will be", "added later!","","","...Really!")

				elseif sel == "quit_game" then
					return
				end
			end

			do
				if sel == "cheese_race" then
					WIPscreen("Cheese race will be", "added later!")
					mainmenu:Render(true)

				elseif sel == "sprint" then
					WIPscreen("Sprint mode will be", "added later!")
					mainmenu:Render(true)

				elseif sel == "othershit" then
					WIPscreen("Other modes will be", "added later!")
					mainmenu:Render(true)
				end
			end

			tickTimer = os.startTimer(MENU.cursor_blink)
			doRenderMenu = true

		elseif control:CheckControl("quit") then
			return
		end
		
		force_select = false
		force_return = false
	end
end

term.clear()

DEBUG:Log("Opened LDRIS2.")


local original_palette = {}
local original_randomseed = {math.randomseed()}
for i = 0, 15 do
	original_palette[i + 1] = { term.getPaletteColor(2 ^ i) }
end
term.setPaletteColor(colors.gray, 0.15, 0.15, 0.15)
term.setPaletteColor(colors.brown, 0.25, 0.25, 0.25)

local runtime, success, err_message
while true do
	runtime, success, err_message = GameDebug.Profile(pcall, titleScreen)
	if success then
		break
	else
		printError(err_message)
		term.setCursorPos(1, scr_y)
		term.setBackgroundColor(colors.black)
		term.setTextColor(colors.white)
		print("Failed in " .. tostring(runtime) .. "ms")
		
		-- justification: if it fails instantly, re-running again will lock the system and be bad
		-- but if it fails due to some user action, restarting lets us look at the log in the GUI
		if runtime < 1000 then
			print("Failed within one second! Aborting.")
		else
			write("Restarting in ")
			for i = 5, 1, -1 do
				write(i .. (i == 1 and "..." or ", "))
				sleep(1)
			end
		end
	end
end

for i = 1, 16 do
	term.setPaletteColor(2 ^ (i - 1), table.unpack(original_palette[i]))
end
math.randomseed(table.unpack(original_randomseed))


DEBUG:Log("Closed LDRIS2.")

term.setCursorPos(1, scr_y - 1)
term.clearLine()
term.setTextColor(colors.yellow)
print("Thank you for playing!")
term.setCursorPos(1, scr_y - 0)
term.clearLine()
term.setTextColor(colors.white)

sleep(0.05)
