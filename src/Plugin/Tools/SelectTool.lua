local BaseTool = require(script.Parent.BaseTool)
local Selection = game:GetService("Selection")

local SelectTool = setmetatable({}, BaseTool)
SelectTool.__index = SelectTool

local function getTopSelectable(inst)
	-- Prefer Model parent if present
	if not inst then return nil end
	local m = inst:FindFirstAncestorOfClass("Model")
	if m and m.Parent ~= nil then
		return m
	end
	return inst
end

function SelectTool.new(ctx)
	local self = BaseTool.new(ctx)
	return setmetatable(self, SelectTool)
end

function SelectTool:Activate()
	BaseTool.Activate(self)
	self._mouse = self.ctx.plugin:GetMouse()
	self._downConn = self._mouse.Button1Down:Connect(function()
		local target = getTopSelectable(self._mouse.Target)
		if not target then return end

		local isShift = self.ctx._keyState and self.ctx._keyState.shift
		local current = Selection:Get()

		if not isShift then
			Selection:Set({ target })
			return
		end

		-- shift toggle
		local out = {}
		local found = false
		for _, it in ipairs(current) do
			if it == target then
				found = true
			else
				table.insert(out, it)
			end
		end
		if not found then
			table.insert(out, target)
		end
		Selection:Set(out)
	end)
end

function SelectTool:Deactivate()
	BaseTool.Deactivate(self)
	if self._downConn then
		self._downConn:Disconnect()
		self._downConn = nil
	end
	self._mouse = nil
end

function SelectTool:OnKeyDown(input)
	-- Track shift for multi-select toggle
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		self.ctx._keyState.shift = true
	end
end

return SelectTool
