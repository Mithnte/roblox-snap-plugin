local UserInputService = game:GetService("UserInputService")

local InputService = {}
InputService.__index = InputService

function InputService.new(plugin, keyState)
	local self = setmetatable({}, InputService)
	self._plugin = plugin
	self._cons = {}
	self._activeTool = nil
	self._keyState = keyState
	return self
end

function InputService:SetActiveTool(tool)
	self._activeTool = tool
end

function InputService:Bind()
	table.insert(self._cons, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			self._keyState.shift = true
		end

		local tool = self._activeTool
		if tool and tool.OnKeyDown then
			tool:OnKeyDown(input)
		end
	end))

	table.insert(self._cons, UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			self._keyState.shift = false
		end

		local tool = self._activeTool
		if tool and tool.OnKeyUp then
			tool:OnKeyUp(input)
		end
	end))
end

function InputService:Unbind()
	for _, c in ipairs(self._cons) do
		c:Disconnect()
	end
	self._cons = {}
end

return InputService
