local ControlAPI = {}

local gameConfig = require "config.gameconfig"

function ControlAPI:New(clientConfig, native_control)
	local control = setmetatable({}, self)
	self.__index = self

	control.keysDown = {}
	control.controlsDown = {}
	control.antiControlRepeat = {}
	control.clientConfig = clientConfig
	control.native_control = native_control

	return control
end

function ControlAPI:Clear()
	self.keysDown = {}
	self.controlsDown = {}
end

function ControlAPI:CheckControl(controlName, repeatTime, repeatDelay)
	repeatDelay = repeatDelay or 1

	local clientConfig = self.clientConfig
	
	local processed_controls = {}

	if self.native_control then
		-- populate self.controlsDown based on self.keysDown
		for name, _key in pairs(clientConfig.controls) do
			self.controlsDown[name] = self.keysDown[_key]
		end
	end
	
	for k,v in pairs(self.controlsDown) do
		processed_controls[k] = v
	end
	
	-- disallow simultaneous move left + move right inputs
	if self.controlsDown["move_left"] and self.controlsDown["move_right"] then
		if self.controlsDown["move_left"] > self.controlsDown["move_right"] then
			processed_controls["move_left"] = nil
		else
			processed_controls["move_right"] = nil
		end
	end

	if processed_controls[controlName] then
		if not self.antiControlRepeat[controlName] then
			if repeatTime then
				return processed_controls[controlName] == 1 or
				(
					processed_controls[controlName] >= (repeatTime * (1 / gameConfig.tickDelay)) and (
						repeatDelay and ((processed_controls[controlName] * gameConfig.tickDelay) % repeatDelay == 0) or true
					)
				)
			else
				return processed_controls[controlName] == 1
			end
		end
	else
		return false
	end

end

return ControlAPI
