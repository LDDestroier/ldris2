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
Last update: April 9th 2025

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
+ Figure out why game randomly lags out on CraftOS-PC
+ Refactor all code to look prettier
+ Add score, and let lineclears and piece dropping add to it
+ Implement initial hold and initial rotation
+ Add an actual menu, and not that shit LDRIS 1 had
+ Implement proper Multiplayer (modem-only for now)
+ Cheese race mode
+ Add in-game menu for changing controls (some people can actually tolerate guideline)
]]

local scr_x, scr_y = term.getSize()

local Board = require "lib.board"
local Mino = require "lib.mino"
local GameInstance = require "lib.gameinstance"
local Control = require "lib.control"
local cospc_debuglog = require "lib.debug"
local clientConfig = require "lib.clientconfig" -- client config can be changed however you please
local gameConfig = require "lib.gameconfig"     -- ideally, only clients with IDENTICAL game configs should face one another
gameConfig.kickTables = require "lib.kicktables"

local resume_count = 0

local speaker = peripheral.find("speaker")
if (not speaker) and periphemu then
		periphemu.create("speaker", "speaker")
		speaker = peripheral.wrap("speaker")
end

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
				speaker.playNote("guitar", 2, note)
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
				speaker.playLocalMusic(fs.combine(shell.dir(), "sound/" .. name .. ".ogg"))
		end
end

local function write_debug_stuff(game)
	if game.control.native_control then
		local mino = game.state.mino
		term.setCursorPos(2, scr_y - 2)
		term.write("Lines: " .. game.state.linesCleared .. "   ")
		
		term.setCursorPos(14, scr_y - 2)
		term.write("Combo: " .. game.state.combo .. "      ")

		term.setCursorPos(2, scr_y - 1)
		term.write("M=" .. mino.movesLeft .. ", TtL=" .. tostring(mino.lockTimer):sub(1, 4) .. "      ")

		term.setCursorPos(2, scr_y - 0)
		term.write("POS=(" ..
		mino.x ..
		":" ..
		tostring(mino.xFloat):sub(1, 5) .. ", " .. mino.y .. ":" .. tostring(mino.yFloat):sub(1, 5) .. ")      ")
	end
end

local function main()

		cospc_debuglog(2, "Starting game.")

		local player_number = 1
		local tickTimer = os.startTimer(gameConfig.tickDelay)
		local message, doTick, doResume
		
		local frame_time
		local last_epoch = os.epoch()

		local GAMES = {
				GameInstance:New(Control:New(clientConfig, false),  0, 0, clientConfig):Initiate(),
				GameInstance:New(Control:New(clientConfig, false), 0, 0, clientConfig):Initiate()
		}
	

		-- center boards on screen
		local game_size = { GAMES[1].width + 2, GAMES[1].height }
		for i = 1, #GAMES do
				GAMES[i]:Move(
						(scr_x / 2) - ((#GAMES * game_size[1]) / 2) + (game_size[1] * (i - 1)),
						(scr_y / 4) - ((game_size[2] - 5) / 2)
				)
		end
		
		for i, _GAME in ipairs(GAMES) do
			_GAME.control:Clear()
			_GAME.control.native_control = (i == player_number)
		end
		
		while true do
				doResume = true
				evt = { os.pullEvent() }
				
				term.setCursorPos(1, 1)
				term.write("t=" .. tostring(resume_count) .. "  ")
				
				write_debug_stuff(GAMES[player_number])
				
				last_epoch = os.epoch("utc")

				if evt[1] == "timer" and evt[2] == tickTimer then
						doTick = true
						tickTimer = os.startTimer(gameConfig.tickDelay)
				else
						doTick = false
				end

				if evt[1] == "key" and evt[2] == keys.tab then
						player_number = (player_number % #GAMES) + 1
						for i, _GAME in ipairs(GAMES) do
							_GAME.control:Clear()
							_GAME.control.native_control = (i == player_number)
						end
				end

				if (evt[1] == "timer" and sound_timers[evt[2]]) then
						doResume = false
						playNote(sound_timers[evt[2]])
						sound_timers[evt[2]] = nil
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

								-- end game
								if message.finished then
										cospc_debuglog(i, "Game over!")
										-- for demo purposes, just restart games that fail if they aren't the player
										if i ~= player_number then
												GAME:Initiate()
										else
												return
										end
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
						end
						
						frame_time = os.epoch("utc") - last_epoch
						term.setCursorPos(10, 1)
						term.write("ft=" .. tostring(frame_time) .. "   ")
						
				end
		end
end

term.clear()

cospc_debuglog(nil, 0)
cospc_debuglog(nil, "Opened LDRIS2.")


local original_palette = {}
for i = 0, 15 do
		original_palette[i + 1] = { term.getPaletteColor(2 ^ i) }
end
term.setPaletteColor(colors.gray, 0.15, 0.15, 0.15)
term.setPaletteColor(colors.brown, 0.25, 0.25, 0.25)

local success, err_message = pcall(main)

for i = 1, 16 do
		term.setPaletteColor(2 ^ (i - 1), table.unpack(original_palette[i]))
end

if not success then
		error(err_message)
end

cospc_debuglog(nil, "Closed LDRIS2.")

term.setCursorPos(1, scr_y - 1)
term.clearLine()
print("Thank you for playing!")
term.setCursorPos(1, scr_y - 0)
term.clearLine()

sleep(0.05)
