local BaseTool = require(script.Parent.BaseTool)

local RotateTool = setmetatable({}, BaseTool)
RotateTool.__index = RotateTool

function RotateTool.new(ctx)
	local self = BaseTool.new(ctx)
	return setmetatable(self, RotateTool)
end

function RotateTool:Activate()
	BaseTool.Activate(self)
	-- MVP rotate: hotkeys Q/E rotate around Y axis
end

function RotateTool:OnKeyDown(input)
	if input.KeyCode == Enum.KeyCode.R then
		self.ctx.toolController:SetActive("rotate")
		return
	end

	local selection = self.ctx.selectionStore:Get()
	if #selection == 0 then return end

	local stepDeg = self.ctx.settingsStore.rotateStepDeg
	local step = math.rad(stepDeg)

	local dir = 0
	if input.KeyCode == Enum.KeyCode.Q then dir = -1 end
	if input.KeyCode == Enum.KeyCode.E then dir = 1 end
	if dir == 0 then return end

	if self.ctx.settingsStore.rotateSnapEnabled == false then
		step = math.rad(5)
	end

	self.ctx.history:Waypoint("Builder: Rotate (start)")
	local pivot = nil
	-- rotate around selection average pivot
	local sum = Vector3.zero
	local n = 0
	for _, inst in ipairs(selection) do
		local ok, cf = pcall(function()
			if inst:IsA("Model") then
				return inst:GetPivot()
			elseif inst:IsA("BasePart") then
				return inst.CFrame
			end
		end)
		if ok and cf then
			sum += cf.Position
			n += 1
		end
	end
	if n > 0 then
		pivot = CFrame.new(sum / n)
	end
	if not pivot then return end

	local rot = CFrame.Angles(0, dir * step, 0)
	self.ctx.transform:RotateAroundPivot(selection, pivot, rot)
	self.ctx.history:Waypoint("Builder: Rotate (end)")
end

return RotateTool
