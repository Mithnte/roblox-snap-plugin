local SnapService = {}
SnapService.__index = SnapService

function SnapService.new(settingsStore)
	return setmetatable({ settings = settingsStore }, SnapService)
end

local function roundToStep(x, step)
	return math.floor((x / step) + 0.5) * step
end

local function axisStep(settings, axis)
	if axis == "X" and settings.gridStepX then return settings.gridStepX end
	if axis == "Y" and settings.gridStepY then return settings.gridStepY end
	if axis == "Z" and settings.gridStepZ then return settings.gridStepZ end
	return settings.gridStep
end

function SnapService:SnapPosition(v3)
	if not self.settings.gridSnapEnabled then return v3 end
	local sx = axisStep(self.settings, "X")
	local sy = axisStep(self.settings, "Y")
	local sz = axisStep(self.settings, "Z")
	return Vector3.new(roundToStep(v3.X, sx), roundToStep(v3.Y, sy), roundToStep(v3.Z, sz))
end

function SnapService:ProjectAxis(delta, axisLock)
	if not axisLock then return delta end
	if axisLock == "X" then return Vector3.new(delta.X, 0, 0) end
	if axisLock == "Y" then return Vector3.new(0, delta.Y, 0) end
	if axisLock == "Z" then return Vector3.new(0, 0, delta.Z) end
	return delta
end

function SnapService:SnapAngleRad(angleRad)
	if not self.settings.rotateSnapEnabled then return angleRad end
	local stepRad = math.rad(self.settings.rotateStepDeg)
	return roundToStep(angleRad, stepRad)
end

return SnapService
