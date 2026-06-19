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

return TransformService
