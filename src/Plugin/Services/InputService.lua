local UserInputService = game:GetService("UserInputService")

local InputService = {}
InputService.__index = InputService

function InputService.new(plugin, keyState)
	local self = setmetatable({}, InputService)
	self._plugin = plugin
	self._cons = {}
	self._activeTool = nil
	self._keyState = keyState
	-- Global shortcuts run regardless of which tool is active (tool switching,
	-- snap toggles, command palette, etc.). Each is a function(input) that
	-- returns true if it handled the key, in which case the active tool does
	-- not also receive it.
	self._shortcuts = {}
	return self
end

function InputService:SetActiveTool(tool)
	self._activeTool = tool
end

-- Registers a global shortcut handler. `fn(input)` should return true when it
-- consumes the key, so it isn't also forwarded to the active tool.
function InputService:RegisterShortcut(fn)
	table.insert(self._shortcuts, fn)
end

function InputService:Bind()
	table.insert(
		self._cons,
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
				self._keyState.shift = true
			end

			for _, fn in ipairs(self._shortcuts) do
				if fn(input) then
					return
				end
			end

			local tool = self._activeTool
			if tool and tool.OnKeyDown then
				tool:OnKeyDown(input)
			end
		end)
	)

	table.insert(
		self._cons,
		UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
				self._keyState.shift = false
			end

			local tool = self._activeTool
			if tool and tool.OnKeyUp then
				tool:OnKeyUp(input)
			end
		end)
	)
end

function InputService:Unbind()
	for _, c in ipairs(self._cons) do
		c:Disconnect()
	end
	self._cons = {}
end

return InputService
