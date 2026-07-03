local BaseTool = require(script.Parent.BaseTool)

local ScaleTool = setmetatable({}, BaseTool)
ScaleTool.__index = ScaleTool

function ScaleTool.new(ctx)
	local self = BaseTool.new(ctx)
	return setmetatable(self, ScaleTool)
end

function ScaleTool:Activate()
	BaseTool.Activate(self)
	-- Keyboard-driven resize (mirrors the Rotate tool's Q/E model):
	--   =  or  Num+  grows the selection by one grid step
	--   -  or  Num-  shrinks it by one grid step
	-- Hold X / Y / Z first to constrain resizing to that axis (BaseParts only).
	self._axisLock = nil
end

function ScaleTool:OnKeyDown(input)
	local kc = input.KeyCode
	if kc == Enum.KeyCode.X then
		self._axisLock = "X"
		return
	elseif kc == Enum.KeyCode.Y then
		self._axisLock = "Y"
		return
	elseif kc == Enum.KeyCode.Z then
		self._axisLock = "Z"
		return
	end

	local dir = 0
	if kc == Enum.KeyCode.Equals or kc == Enum.KeyCode.KeypadPlus then
		dir = 1
	elseif kc == Enum.KeyCode.Minus or kc == Enum.KeyCode.KeypadMinus then
		dir = -1
	end
	if dir == 0 then
		return
	end

	local selection = self.ctx.selectionStore:Get()
	if #selection == 0 then
		return
	end

	local step = self.ctx.settingsStore.gridStep or 1
	self.ctx.history:Waypoint("Builder: Scale (start)")
	self.ctx.transform:Resize(selection, dir * step, self._axisLock)
	self.ctx.history:Waypoint("Builder: Scale (end)")
end

function ScaleTool:OnKeyUp(input)
	if input.KeyCode == Enum.KeyCode.X or input.KeyCode == Enum.KeyCode.Y or input.KeyCode == Enum.KeyCode.Z then
		self._axisLock = nil
	end
end

return ScaleTool
