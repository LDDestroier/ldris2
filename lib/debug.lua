local _WRITE_TO_DEBUG_MONITOR = false

local cospc_debuglog = function(header, text)
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

return cospc_debuglog
