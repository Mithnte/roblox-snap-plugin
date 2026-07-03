local TransformService = {}
TransformService.__index = TransformService

function TransformService.new()
	return setmetatable({}, TransformService)
end

local function isModel(inst)
	return inst and inst:IsA("Model")
end

local function isBasePart(inst)
	return inst and inst:IsA("BasePart")
end

local function getPivotCFrame(inst)
	if isModel(inst) then
		return inst:GetPivot()
	elseif isBasePart(inst) then
		return inst.CFrame
	end
	return nil
end

local function setPivotCFrame(inst, cf)
	if isModel(inst) then
		inst:PivotTo(cf)
	elseif isBasePart(inst) then
		inst.CFrame = cf
	end
end

function TransformService:GetPivot(inst)
	return getPivotCFrame(inst)
end

function TransformService:Translate(instances, deltaWorld)
	for _, inst in ipairs(instances) do
		local pivot = getPivotCFrame(inst)
		if pivot then
			setPivotCFrame(inst, pivot + deltaWorld)
		end
	end
end

function TransformService:RotateAroundPivot(instances, pivotCFrame, rotCFrame)
	local pivotInv = pivotCFrame:Inverse()
	local newPivot = pivotCFrame * rotCFrame

	for _, inst in ipairs(instances) do
		local obj = getPivotCFrame(inst)
		if obj then
			local rel = pivotInv * obj
			local newObj = newPivot * rel
			setPivotCFrame(inst, newObj)
		end
	end
end

local MIN_PART_SIZE = 0.05

-- Grows/shrinks a selection by `step` studs (signed). BaseParts change Size on
-- the requested axes (all three when axisLock is nil), keeping their centre
-- fixed and never dropping below Roblox's minimum part size. Models can't be
-- resized per-axis, so they scale uniformly about their pivot instead — a
-- positive step grows, a negative step shrinks.
function TransformService:Resize(instances, step, axisLock)
	local dx = (not axisLock or axisLock == "X") and step or 0
	local dy = (not axisLock or axisLock == "Y") and step or 0
	local dz = (not axisLock or axisLock == "Z") and step or 0

	for _, inst in ipairs(instances) do
		if isBasePart(inst) then
			local s = inst.Size
			inst.Size = Vector3.new(
				math.max(MIN_PART_SIZE, s.X + dx),
				math.max(MIN_PART_SIZE, s.Y + dy),
				math.max(MIN_PART_SIZE, s.Z + dz)
			)
		elseif isModel(inst) then
			local ok, scale = pcall(function()
				return inst:GetScale()
			end)
			if ok and scale then
				local factor = step > 0 and 1.1 or (1 / 1.1)
				pcall(function()
					inst:ScaleTo(scale * factor)
				end)
			end
		end
	end
end

return TransformService
