local SnapService = {}
SnapService.__index = SnapService

function SnapService.new(settingsStore)
	return setmetatable({ settings = settingsStore }, SnapService)
end

local function roundToStep(x, step)
	return math.floor((x / step) + 0.5) * step
end

function SnapService:SnapPosition(v3)
	if not self.settings.gridSnapEnabled then
		return v3
	end
	local s = self.settings.gridStep
	return Vector3.new(roundToStep(v3.X, s), roundToStep(v3.Y, s), roundToStep(v3.Z, s))
end

function SnapService:ProjectAxis(delta, axisLock)
	if not axisLock then return delta end
	if axisLock == "X" then return Vector3.new(delta.X, 0, 0) end
	if axisLock == "Y" then return Vector3.new(0, delta.Y, 0) end
	if axisLock == "Z" then return Vector3.new(0, 0, delta.Z) end
	return delta
end

function SnapService:SnapAngleRad(angleRad)
	if not self.settings.rotateSnapEnabled then
		return angleRad
	end
	local stepRad = math.rad(self.settings.rotateStepDeg)
	return roundToStep(angleRad, stepRad)
end

return SnapService
