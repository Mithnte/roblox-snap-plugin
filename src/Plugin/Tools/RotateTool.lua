local BaseTool = require(script.Parent.BaseTool)

local RotateTool = setmetatable({}, BaseTool)
RotateTool.__index = RotateTool

function RotateTool.new(ctx)
	local self = BaseTool.new(ctx)
	return setmetatable(self, RotateTool)
end

function RotateTool:Activate()
	BaseTool.Activate(self)
	-- Q/E rotate the selection around its pivot. By default this is the Y
	-- (yaw) axis; hold X or Z first to rotate about that world axis instead.
	self._axisLock = nil
end

local function axisVector(axisLock)
	if axisLock == "X" then
		return Vector3.xAxis
	end
	if axisLock == "Z" then
		return Vector3.zAxis
	end
	return Vector3.yAxis
end

function RotateTool:OnKeyDown(input)
	local kc = input.KeyCode
	if kc == Enum.KeyCode.X then
		self._axisLock = "X"
		return
	end
	if kc == Enum.KeyCode.Y then
		self._axisLock = "Y"
		return
	end
	if kc == Enum.KeyCode.Z then
		self._axisLock = "Z"
		return
	end

	local selection = self.ctx.selectionStore:Get()
	if #selection == 0 then
		return
	end

	local stepDeg = self.ctx.settingsStore.rotateStepDeg
	local step = math.rad(stepDeg)

	local dir = 0
	if kc == Enum.KeyCode.Q then
		dir = -1
	end
	if kc == Enum.KeyCode.E then
		dir = 1
	end
	if dir == 0 then
		return
	end

	if self.ctx.settingsStore.rotateSnapEnabled == false then
		step = math.rad(5)
	end

	self.ctx.history:Waypoint("Builder: Rotate (start)")
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
	if n == 0 then
		return
	end
	local pivot = CFrame.new(sum / n)

	local rot = CFrame.fromAxisAngle(axisVector(self._axisLock), dir * step)
	self.ctx.transform:RotateAroundPivot(selection, pivot, rot)
	self.ctx.history:Waypoint("Builder: Rotate (end)")
end

function RotateTool:OnKeyUp(input)
	if input.KeyCode == Enum.KeyCode.X or input.KeyCode == Enum.KeyCode.Y or input.KeyCode == Enum.KeyCode.Z then
		self._axisLock = nil
	end
end

return RotateTool
