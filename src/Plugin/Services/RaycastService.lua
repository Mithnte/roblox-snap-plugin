local Workspace = game:GetService("Workspace")

local RaycastService = {}
RaycastService.__index = RaycastService

function RaycastService.new(ctx)
	local self = setmetatable({}, RaycastService)
	self._ctx = ctx
	return self
end

function RaycastService:RaycastFromScreen(mouse)
	local origin = mouse.Origin.Position
	local dir = (mouse.Hit.Position - origin).Unit * 10000
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	-- ignore current selection to avoid snapping to itself
	params.FilterDescendantsInstances = self._ctx.selectionStore:Get()
	return Workspace:Raycast(origin, dir, params)
end

local function isExcluded(part, excludeSet)
	if excludeSet[part] then
		return true
	end
	for inst in pairs(excludeSet) do
		if inst:IsA("Model") and part:IsDescendantOf(inst) then
			return true
		end
	end
	return false
end

local function corners(cf, size)
	local hx, hy, hz = size.X / 2, size.Y / 2, size.Z / 2
	return {
		(cf * CFrame.new(hx, hy, hz)).Position,
		(cf * CFrame.new(-hx, hy, hz)).Position,
		(cf * CFrame.new(hx, -hy, hz)).Position,
		(cf * CFrame.new(-hx, -hy, hz)).Position,
		(cf * CFrame.new(hx, hy, -hz)).Position,
		(cf * CFrame.new(-hx, hy, -hz)).Position,
		(cf * CFrame.new(hx, -hy, -hz)).Position,
		(cf * CFrame.new(-hx, -hy, -hz)).Position,
	}
end

-- The 12 edges of a box, expressed as pairs of corner indices (see `corners`).
local EDGE_PAIRS = {
	{ 1, 2 },
	{ 3, 4 },
	{ 5, 6 },
	{ 7, 8 }, -- along X
	{ 1, 3 },
	{ 2, 4 },
	{ 5, 7 },
	{ 6, 8 }, -- along Y
	{ 1, 5 },
	{ 2, 6 },
	{ 3, 7 },
	{ 4, 8 }, -- along Z
}

-- Gathers vertex + edge snap candidates from BaseParts near `position`,
-- excluding the current selection (so an object never snaps to itself).
function RaycastService:GetNearbySnapTargets(position, radius, excludeInstances)
	local excludeSet = {}
	for _, inst in ipairs(excludeInstances or {}) do
		excludeSet[inst] = true
	end

	local parts = Workspace:GetPartBoundsInRadius(position, radius)
	local vertices = {}
	local edges = {}
	for _, part in ipairs(parts) do
		if not isExcluded(part, excludeSet) then
			local pts = corners(part.CFrame, part.Size)
			for _, p in ipairs(pts) do
				table.insert(vertices, p)
			end
			for _, pair in ipairs(EDGE_PAIRS) do
				table.insert(edges, { a = pts[pair[1]], b = pts[pair[2]] })
			end
		end
	end
	return { vertices = vertices, edges = edges }
end

return RaycastService
