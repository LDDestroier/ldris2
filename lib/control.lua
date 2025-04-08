local ControlAPI = {}

local gameConfig = require "lib.gameconfig"

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
	
	if self.native_control then
		-- populate self.controlsDown based on self.keysDown
		for name, _key in pairs(clientConfig.controls) do
			self.controlsDown[name] = self.keysDown[_key]
		end
	end
	
	if self.controlsDown[controlName] then
		if not self.antiControlRepeat[controlName] then
			if repeatTime then
				return self.controlsDown[controlName] == 1 or
						(
							self.controlsDown[controlName] >= (repeatTime * (1 / gameConfig.tickDelay)) and (
								repeatDelay and ((self.controlsDown[controlName] * gameConfig.tickDelay) % repeatDelay == 0) or true
							)
						)
			else
				return self.controlsDown[controlName] == 1
			end
		end
	else
		return false
	end
	
end

return ControlAPI
