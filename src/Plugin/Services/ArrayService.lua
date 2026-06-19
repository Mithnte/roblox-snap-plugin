local ArrayService = {}
ArrayService.__index = ArrayService

function ArrayService.new(ctx)
	local self = setmetatable({}, ArrayService)
	self._ctx = ctx
	return self
end

-- Linear array: n copies with spacing (Vector3) relative to selection average
function ArrayService:Linear(selection, n, spacing)
	if #selection == 0 or n < 1 then return end
	self._ctx.history:Waypoint("Builder: Array Linear (start)")
	local clones = {}
	for i = 1, n do
		for _, inst in ipairs(selection) do
			local c = inst:Clone()
			c.Parent = inst.Parent
			table.insert(clones, c)
		end
		self._ctx.transform:Translate(clones, spacing)
	end
	self._ctx.history:Waypoint("Builder: Array Linear (end)")
	return clones
end

-- Radial array: n copies around center with radius on XZ and step angle
function ArrayService:Radial(selection, n, radius, stepDeg)
	if #selection == 0 or n < 1 then return end
	self._ctx.history:Waypoint("Builder: Array Radial (start)")
	local clones = {}
	local pivot = nil
	local sum = Vector3.zero; local k = 0
	for _, inst in ipairs(selection) do
		local ok, cf = pcall(function()
			return inst:IsA("Model") and inst:GetPivot() or (inst:IsA("BasePart") and inst.CFrame)
		end)
		if ok and cf then sum += cf.Position; k += 1 end
	end
	if k > 0 then pivot = sum / k else return end
	for i = 1, n do
		local angle = math.rad(stepDeg * i)
		local offset = Vector3.new(math.cos(angle)*radius, 0, math.sin(angle)*radius)
		for _, inst in ipairs(selection) do
			local c = inst:Clone(); c.Parent = inst.Parent; table.insert(clones, c)
			self._ctx.transform:Translate({c}, offset)
		end
	end
	self._ctx.history:Waypoint("Builder: Array Radial (end)")
	return clones
end

-- Grid array: rows x cols with spacingX/Z
function ArrayService:Grid(selection, rows, cols, spacingX, spacingZ)
	if #selection == 0 or rows < 1 or cols < 1 then return end
	self._ctx.history:Waypoint("Builder: Array Grid (start)")
	local clones = {}
	for r = 1, rows do
		for c = 1, cols do
			local offset = Vector3.new((c-1)*spacingX, 0, (r-1)*spacingZ)
			for _, inst in ipairs(selection) do
				local copy = inst:Clone(); copy.Parent = inst.Parent; table.insert(clones, copy)
				self._ctx.transform:Translate({copy}, offset)
			end
		end
	end
	self._ctx.history:Waypoint("Builder: Array Grid (end)")
	return clones
end

return ArrayService
