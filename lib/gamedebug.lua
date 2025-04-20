local GameDebug = {}

local _WRITE_TO_DEBUG_MONITOR = false

function GameDebug.cospc_debuglog(header, text)
	-- ccemux itself doesn't have virtual monitor support
	if _HOST:find("CCEmuX") then
		return
	end

	if _WRITE_TO_DEBUG_MONITOR then
		if ccemux then
			if not peripheral.find("monitor") then
				ccemux.attach("right", "monitor")
			end
			local t = term.redirect(peripheral.wrap("right"))
			if text == 0 then
				term.clear()
				term.setCursorPos(1, 1)
			else
				term.setTextColor(colors.yellow)
				term.write(header or "SYS")
				term.setTextColor(colors.white)
				print(": " .. text)
			end
			term.redirect(t)
		end
	end
end


local modem = peripheral.find("modem")
if (not modem) and (ccemux) then
	ccemux.attach("top", "wireless_modem")
	modem = peripheral.wrap("top")
end
modem.open(100)

function GameDebug.broadcast(message)
	if modem then
		modem.transmit(100, 100, message)
	end
end

function GameDebug.profile(fName, y, func, ...)
	local time_start = os.epoch("utc")
	term.setCursorPos(1, y)
	term.write(fName .. ": " .. "load          ")
	local output = func(...)
	local time_total = os.epoch("utc") - time_start
	term.setCursorPos(1, y)
	term.write(fName .. ": " .. tostring(time_total) .. "    ")
	return output
end

return GameDebug
