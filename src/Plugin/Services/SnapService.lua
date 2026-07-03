local SnapService = {}
SnapService.__index = SnapService

function SnapService.new(settingsStore)
	return setmetatable({ settings = settingsStore }, SnapService)
end

local function roundToStep(x, step)
	return math.floor((x / step) + 0.5) * step
end

local function axisStep(settings, axis)
	if axis == "X" and settings.gridStepX then
		return settings.gridStepX
	end
	if axis == "Y" and settings.gridStepY then
		return settings.gridStepY
	end
	if axis == "Z" and settings.gridStepZ then
		return settings.gridStepZ
	end
	return settings.gridStep
end

function SnapService:SnapPosition(v3)
	if not self.settings.gridSnapEnabled then
		return v3
	end
	local sx = axisStep(self.settings, "X")
	local sy = axisStep(self.settings, "Y")
	local sz = axisStep(self.settings, "Z")
	return Vector3.new(roundToStep(v3.X, sx), roundToStep(v3.Y, sy), roundToStep(v3.Z, sz))
end

function SnapService:ProjectAxis(delta, axisLock)
	if not axisLock then
		return delta
	end
	if axisLock == "X" then
		return Vector3.new(delta.X, 0, 0)
	end
	if axisLock == "Y" then
		return Vector3.new(0, delta.Y, 0)
	end
	if axisLock == "Z" then
		return Vector3.new(0, 0, delta.Z)
	end
	return delta
end

local function closestPointOnSegment(p, a, b)
	local ab = b - a
	local lenSq = ab:Dot(ab)
	if lenSq < 1e-8 then
		return a
	end
	local t = math.clamp((p - a):Dot(ab) / lenSq, 0, 1)
	return a + ab * t
end

-- Tries to snap `desiredPos` onto a nearby vertex first, then a nearby edge,
-- within the configured thresholds. Returns the snapped position, or nil if
-- nothing was close enough (caller should fall back to grid snap).
function SnapService:SnapToGeometry(desiredPos, targets)
	if not self.settings.vertexSnapEnabled then
		return nil
	end
	if not targets then
		return nil
	end

	local vertexThreshold = self.settings.vertexSnapThreshold or 1.5
	local bestVertex, bestVertexDist = nil, math.huge
	for _, v in ipairs(targets.vertices or {}) do
		local d = (v - desiredPos).Magnitude
		if d < bestVertexDist then
			bestVertex, bestVertexDist = v, d
		end
	end
	if bestVertex and bestVertexDist <= vertexThreshold then
		return bestVertex
	end

	local edgeThreshold = self.settings.edgeSnapThreshold or 1
	local bestEdgePoint, bestEdgeDist = nil, math.huge
	for _, e in ipairs(targets.edges or {}) do
		local p = closestPointOnSegment(desiredPos, e.a, e.b)
		local d = (p - desiredPos).Magnitude
		if d < bestEdgeDist then
			bestEdgePoint, bestEdgeDist = p, d
		end
	end
	if bestEdgePoint and bestEdgeDist <= edgeThreshold then
		return bestEdgePoint
	end

	return nil
end

function SnapService:SnapAngleRad(angleRad)
	if not self.settings.rotateSnapEnabled then
		return angleRad
	end
	local stepRad = math.rad(self.settings.rotateStepDeg)
	return roundToStep(angleRad, stepRad)
end

return SnapService
