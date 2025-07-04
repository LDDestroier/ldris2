local _WRITE_TO_DEBUG_MONITOR = true

local GameDebug = {}

local to_colors = {}
local to_blit = {}
local i = 0
for col in ("0123456789abcdef"):gmatch(".") do
	to_colors[col] = 2 ^ i
	i = i + 1
end
for k,v in pairs(to_colors) do
	to_blit[v] = k
end

local write_rich, process_rich, tsv

function GameDebug:New(debug_term, is_active)
	local gamedebug = setmetatable({}, self)
	self.__index = self
	
	gamedebug.window = debug_term
	gamedebug.scroll_y = 0
	gamedebug.scroll_x = 0
	gamedebug.log = {}
	gamedebug.header = {}
	gamedebug.active = is_active and true or false
	gamedebug.tallest_header = 0
	
	gamedebug.header_bgcol = colors.gray
	gamedebug.log_bgcol = colors.black
	
	return gamedebug
end

function GameDebug.FindMonitor()
	local mon = peripheral.find("monitor")
	if not mon then
		if periphemu then
			-- CraftOS-PC with the default "periphemu" library
			if periphemu.create("right", "monitor") then
				mon = peripheral.wrap("right")
			end
		
		elseif ccemux then
			-- CCEmuX itself doesn't have virtual monitor support
			if not _HOST:match("CCEmuX") then
				-- CraftOS-PC with ccemux module
				ccemux.attach("right", "monitor")
				mon = peripheral.wrap("right")
			end
		end
	end
	
	return mon
end

function GameDebug.Profile(func, ...)
	local time_start = os.epoch("utc")
	local output = {func(...)}
	local time_total = os.epoch("utc") - time_start
	return time_total, table.unpack(output)
end

function GameDebug:ProfileHeader(name, func, ...)
	local output = {GameDebug.Profile(func, ...)}
	self:LogHeader(name, output[1] .. "ms", 0, true)
	return table.unpack(output, 2)
end

function GameDebug:ProfileHeaderInline(name, func, ...)
	local output = {GameDebug.Profile(func, ...)}
	self:LogHeader(name, output[1] .. "ms", 0, false)
	return table.unpack(output, 2)
end

function GameDebug:SetActive(active)
	self.active = active and true or false
end

function GameDebug:Render(do_flush)
	if not self.active then return end
	if not self.window then return end
	local t = term.redirect(self.window)
	tsv(false)
	
	local scr_x, scr_y = term.getSize()
	term.setBackgroundColor(self.header_bgcol)

	local x, y = 1, 1
	local line
	local do_clear = true
	
	local blank_line = string.rep(" ", scr_x)
	
	-- sort fields by whether they force a line break
	local fields = {}
	for i = 1, #self.header do
		if not self.header[i][4] then
			table.insert(fields, self.header[i])
		end
	end
	for i = 1, #self.header do
		if self.header[i][4] then
			table.insert(fields, self.header[i])
		end
	end
	
	
	-- render header
	for i, field in ipairs(fields) do
		line = process_rich(field[1] .. "&r&4" .. tostring(field[2]), "0", to_blit[self.header_bgcol])
		if (x + #line[1] >= scr_x) or field[4] then
			x = 1
			y = y + 1
			do_clear = true
		end
		term.setCursorPos(x, y)
		self.tallest_header = math.max(self.tallest_header, y)
		if do_clear then
			term.clearLine()
			do_clear = false
		end
		term.blit(table.unpack(line))
		x = x + math.max(field[3] + #field[1], #line[1]) + 2
	end
	for iy = y + 1, self.tallest_header do
		term.setCursorPos(1, iy)
		term.clearLine()
	end
	
	-- render log
	term.setBackgroundColor(self.log_bgcol)
	local index = 1 - self.scroll_y
	for y = self.tallest_header + 1, scr_y do
		index = index + 1
		term.setCursorPos(1 - self.scroll_x, y)
		if self.log[index] then
			write_rich("~" .. to_blit[self.log_bgcol] .. self.log[index] .. blank_line)
		else
			term.clearLine()
		end
	end
	tsv(true)
	term.redirect(t)
	
	if do_flush then
		self.header = {}
	end
end


function GameDebug:LogHeader(field, value, minimum_size, do_newline)
	table.insert(self.header, {field, value, minimum_size or 0, do_newline})
end

function GameDebug:Log(text)
	self.log[#self.log + 1] = text
	self:Render()
end

function process_rich(str, default_txcol, default_bgcol)

	default_txcol = default_txcol or "0"
	default_bgcol = default_bgcol or "f"

	local text_match = "&"
	local back_match = "~"
	local text_col = default_txcol
	local back_col = default_bgcol
	local line = {"", "", ""}
	local c
	local do_continue = false
	
	for i = 1, #str do
		if do_continue then
			do_continue = false
		else
			c = str:sub(i, i)
			if c == text_match then
				i = i + 1
				if str:sub(i, i) == "r" then
					text_col = default_txcol
				else
					text_col = str:sub(i, i)
					assert(to_colors[back_col], "invalid TXT color'" .. text_col .. "'")
				end
				do_continue = true
				
			elseif c == back_match then
				i = i + 1
				if str:sub(i, i) == "r" then
					back_col = default_bgcol
				else
					back_col = str:sub(i, i)
					assert(to_colors[back_col], "invalid BG color'" .. back_col .. "'")
				end
				do_continue = true
				
			else
				line[1] = line[1] .. c
				line[2] = line[2] .. text_col
				line[3] = line[3] .. back_col
			end
		end
	end
	return line
end

function write_rich(str)
	term.blit(table.unpack(process_rich(str)))
end

function tsv(visible)
	if term.current().setVisible then
		term.current().setVisible(visible)
	end
end

return GameDebug
