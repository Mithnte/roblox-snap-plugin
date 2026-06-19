local BaseTool = require(script.Parent.BaseTool)
local Selection = game:GetService("Selection")

local SelectTool = setmetatable({}, BaseTool)
SelectTool.__index = SelectTool

local function getTopSelectable(inst)
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
	if input.KeyCode == Enum.KeyCode.One then
		self.ctx.toolController:SetActive("select")
	elseif input.KeyCode == Enum.KeyCode.Two then
		self.ctx.toolController:SetActive("move")
	elseif input.KeyCode == Enum.KeyCode.Three then
		self.ctx.toolController:SetActive("rotate")
	elseif input.KeyCode == Enum.KeyCode.G then
		self.ctx.settingsStore:Set({ gridSnapEnabled = not self.ctx.settingsStore.gridSnapEnabled })
	elseif input.KeyCode == Enum.KeyCode.F then
		self.ctx.settingsStore:Set({ rotateSnapEnabled = not self.ctx.settingsStore.rotateSnapEnabled })
	elseif input.KeyCode == Enum.KeyCode.LeftBracket or input.KeyCode == Enum.KeyCode.RightBracket then
		-- cycle grid steps
		local steps = {0.25, 0.5, 1}
		local cur = self.ctx.settingsStore.gridStep
		local idx = 1
		for i, v in ipairs(steps) do
			if v == cur then idx = i break end
		end
		if input.KeyCode == Enum.KeyCode.LeftBracket then
			idx -= 1
			if idx < 1 then idx = #steps end
		else
			idx += 1
			if idx > #steps then idx = 1 end
		end
		self.ctx.settingsStore:Set({ gridStep = steps[idx] })
	end
end

return SelectTool
