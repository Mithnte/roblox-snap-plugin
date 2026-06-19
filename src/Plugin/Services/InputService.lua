local UserInputService = game:GetService("UserInputService")

local InputService = {}
InputService.__index = InputService

function InputService.new(plugin)
	local self = setmetatable({}, InputService)
	self._plugin = plugin
	self._cons = {}
	self._activeTool = nil
	return self
end

function InputService:SetActiveTool(tool)
	self._activeTool = tool
end

function InputService:Bind()
	-- Keyboard shortcuts (best-effort; Studio may intercept some)
	table.insert(self._cons, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		local tool = self._activeTool
		if tool and tool.OnKeyDown then
			tool:OnKeyDown(input)
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
