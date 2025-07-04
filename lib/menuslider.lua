local MenuSlider = {}

function MenuSlider:New(x, y, min, max, interval, width)
	local slider = setmetatable({}, self)
	self.__index = self

	slider.x = x or 1
	slider.y = y or 1
	
	slider.is_slider = true -- just making sure

	slider.color_cap = colors.yellow
	slider.color_handle = colors.yellow
	slider.color_bar = colors.lightGray
	slider.color_text = colors.white
	
	slider.max = max or 10
	slider.min = min or 0
	slider.interval = interval or 1
	slider.width = width or 8 -- length of bar, not including cap characters
	slider.char_cap = { "[", "]" }
	slider.char_bar = { "\128", "\132", "\140" }
	
	return slider
end

function MenuSlider:Render()

	
	
end

return MenuSlider