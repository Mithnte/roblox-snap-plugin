local AlignService = {}
AlignService.__index = AlignService

local function getBBox(inst)
	if inst:IsA("Model") then
		local cf, size = inst:GetBoundingBox()
		return cf, size
	elseif inst:IsA("BasePart") then
		return inst.CFrame, inst.Size
	end
end

local function getMinMax(cf, size)
	local corners = {
		cf * CFrame.new(size.X / 2, size.Y / 2, size.Z / 2),
		cf * CFrame.new(-size.X / 2, size.Y / 2, size.Z / 2),
		cf * CFrame.new(size.X / 2, -size.Y / 2, size.Z / 2),
		cf * CFrame.new(-size.X / 2, -size.Y / 2, size.Z / 2),
		cf * CFrame.new(size.X / 2, size.Y / 2, -size.Z / 2),
		cf * CFrame.new(-size.X / 2, size.Y / 2, -size.Z / 2),
		cf * CFrame.new(size.X / 2, -size.Y / 2, -size.Z / 2),
		cf * CFrame.new(-size.X / 2, -size.Y / 2, -size.Z / 2),
	}
	local minV = Vector3.new(math.huge, math.huge, math.huge)
	local maxV = Vector3.new(-math.huge, -math.huge, -math.huge)
	for _, c in ipairs(corners) do
		local p = c.Position
		minV = Vector3.new(math.min(minV.X, p.X), math.min(minV.Y, p.Y), math.min(minV.Z, p.Z))
		maxV = Vector3.new(math.max(maxV.X, p.X), math.max(maxV.Y, p.Y), math.max(maxV.Z, p.Z))
	end
	return minV, maxV
end

function AlignService.new(ctx)
	local self = setmetatable({}, AlignService)
	self._ctx = ctx
	return self
end

function AlignService:AlignToFirst(selection, side)
	if #selection < 2 then
		return
	end
	local first = selection[1]
	local fcf, fsize = getBBox(first)
	if not fcf then
		return
	end
	local fmin, fmax = getMinMax(fcf, fsize)
	for i = 2, #selection do
		local inst = selection[i]
		local icf, isize = getBBox(inst)
		if icf then
			local imin, imax = getMinMax(icf, isize)
			local delta = Vector3.zero
			if side == "Left" then
				delta = Vector3.new(fmin.X - imin.X, 0, 0)
			end
			if side == "Right" then
				delta = Vector3.new(fmax.X - imax.X, 0, 0)
			end
			if side == "Front" then
				delta = Vector3.new(0, 0, fmax.Z - imax.Z)
			end
			if side == "Back" then
				delta = Vector3.new(0, 0, fmin.Z - imin.Z)
			end
			if side == "Top" then
				delta = Vector3.new(0, fmax.Y - imax.Y, 0)
			end
			if side == "Bottom" then
				delta = Vector3.new(0, fmin.Y - imin.Y, 0)
			end
			self._ctx.transform:Translate({ inst }, delta)
		end
	end
end

function AlignService:CenterToFirst(selection)
	if #selection < 2 then
		return
	end
	local first = selection[1]
	local fcf, fsize = getBBox(first)
	if not fcf then
		return
	end
	local fmin, fmax = getMinMax(fcf, fsize)
	local fcenter = (fmin + fmax) / 2
	for i = 2, #selection do
		local inst = selection[i]
		local icf, isize = getBBox(inst)
		if icf and isize then
			local imin, imax = getMinMax(icf, isize)
			local icenter = (imin + imax) / 2
			self._ctx.transform:Translate({ inst }, fcenter - icenter)
		end
	end
end

function AlignService:MatchRotation(selection)
	if #selection < 2 then
		return
	end
	local first = selection[1]
	local fcf = first:IsA("Model") and first:GetPivot() or (first:IsA("BasePart") and first.CFrame)
	if not fcf then
		return
	end
	for i = 2, #selection do
		local inst = selection[i]
		local icf = inst:IsA("Model") and inst:GetPivot() or (inst:IsA("BasePart") and inst.CFrame)
		if icf then
			local new = CFrame.new(icf.Position) * (fcf - fcf.Position)
			if inst:IsA("Model") then
				inst:PivotTo(new)
			else
				inst.CFrame = new
			end
		end
	end
end

function AlignService:MatchSize(selection)
	if #selection < 2 then
		return
	end
	local first = selection[1]
	local fcf, fsize = getBBox(first)
	if not fcf then
		return
	end
	for i = 2, #selection do
		local inst = selection[i]
		if inst:IsA("BasePart") then
			inst.Size = fsize
		end
		-- For Model: complex; skip in MVP
	end
end

return AlignService
