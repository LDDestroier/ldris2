local Menu = {}


function Menu:New(x, y)
	local menu = setmetatable({}, self)
	self.__index = self

	menu.x = x or 1
	menu.y = y or 1
	menu.selected = 1
	menu.title = {"", 1}
	menu.options = {}
	menu.cursor = {">"}
	menu.cursor_blink = 0.5
	menu.cursor_index = 1
	menu.color_title = colors.yellow
	menu.color_selected = colors.yellow
	menu.color_unselected = colors.lightGray

	return menu
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

function Menu:CycleCursor()
	self.cursor_index = (self.cursor_index % #self.cursor) + 1
end

function Menu:Move(x, y)
	self.x = tonumber(x) or self.x
	self.y = tonumber(y) or self.y
end

-- takes absolute mouse X and Y, optionally returns menu index
function Menu:MouseSelect(x, y)
	local sel
	local mx = (x - self.x) + 1
	local my = (y - self.y) + 1
	for i, option in ipairs(self.options) do
		if my == option[3] then
			if mx >= option[2] and mx < (option[2] + #option[1]) then
				return i
			end
		end
	end
end

function Menu:AddOption(name, sID, rx, ry)
	assert(type(sID) == "string", "menu options must have string ID")
	name = name or ""
	rx = rx or 1
	ry = ry or 1

	table.insert(self.options, {name, rx, ry, sID})
end

function Menu:AddOptions(tOptions)
	for i, option in ipairs(tOptions) do
		self:AddOption(table.unpack(option))
	end
end

function Menu:GetSelected()
	return self.options[self.selected][4]
end

function Menu:SetTitle(title, ry)
	assert(type(title) == "string", "asshole")
	self.title[1] = title
	self.title[2] = ry or self.title[2]
end

function Menu:MoveSelect(delta)
	local new_selection = ((self.selected + delta - 1) % #self.options) + 1
	if self.options[new_selection] then
		self.selected = new_selection
	end
end

function Menu:Render(show_no_selected)
	local cursor_index = (math.floor(os.clock() / self.cursor_blink) % #self.cursor) + 1
--	term.setCursorPos(self.x + self.title[2] - 1, self.y + self.title[3] - 1)
--	term.setTextColor(self.color_title)
--	term.write(self.title[1])
	cwrite(self.title[1], self.y + self.title[2] - 1, self.color_title)

	term.setTextColor(self.color_unselected)
	for i, option in ipairs(self.options) do
		if show_no_selected or (i ~= self.selected) then
			term.setCursorPos(self.x + option[2] - 1, self.y + option[3] - 1)
			term.write(option[1] .. "  ")
		end
	end

	if not show_no_selected then
		term.setTextColor(self.color_selected)
		term.setCursorPos(self.x + self.options[self.selected][2] - 1, self.y + self.options[self.selected][3] - 1)
		term.write(self.cursor[cursor_index])
		term.write(self.options[self.selected][1] .. "  ")
	end
end

return Menu
