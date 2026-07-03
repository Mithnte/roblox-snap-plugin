-- Applies visual appearance (colour, material) to the current selection, and
-- can copy the appearance of the first selected part onto the rest. Works on
-- BaseParts directly and on every BasePart descendant of selected Models, all
-- wrapped in ChangeHistoryService waypoints so it's a single undo step.
local PaintService = {}
PaintService.__index = PaintService

function PaintService.new(ctx)
	local self = setmetatable({}, PaintService)
	self._ctx = ctx
	return self
end

local function eachPart(selection, fn)
	for _, inst in ipairs(selection) do
		if inst:IsA("BasePart") then
			fn(inst)
		elseif inst:IsA("Model") then
			for _, d in ipairs(inst:GetDescendants()) do
				if d:IsA("BasePart") then
					fn(d)
				end
			end
		end
	end
end

local function firstPart(selection)
	local found = nil
	eachPart({ selection[1] }, function(p)
		found = found or p
	end)
	return found
end

function PaintService:SetColor(selection, color)
	if #selection == 0 or not color then
		return
	end
	self._ctx.history:Waypoint("Builder: Paint Colour (start)")
	eachPart(selection, function(p)
		p.Color = color
	end)
	self._ctx.history:Waypoint("Builder: Paint Colour (end)")
end

function PaintService:SetMaterial(selection, materialName)
	local material = materialName and Enum.Material[materialName]
	if #selection == 0 or not material then
		return
	end
	self._ctx.history:Waypoint("Builder: Paint Material (start)")
	eachPart(selection, function(p)
		p.Material = material
	end)
	self._ctx.history:Waypoint("Builder: Paint Material (end)")
end

-- Copies Color, Material, Transparency and Reflectance from the first selected
-- part onto every other selected part (needs 2+ in the selection).
function PaintService:MatchAppearanceToFirst(selection)
	if #selection < 2 then
		return
	end
	local lead = firstPart(selection)
	if not lead then
		return
	end
	local color, material = lead.Color, lead.Material
	local transparency, reflectance = lead.Transparency, lead.Reflectance
	self._ctx.history:Waypoint("Builder: Match Appearance (start)")
	for i = 2, #selection do
		eachPart({ selection[i] }, function(p)
			p.Color = color
			p.Material = material
			p.Transparency = transparency
			p.Reflectance = reflectance
		end)
	end
	self._ctx.history:Waypoint("Builder: Match Appearance (end)")
end

return PaintService
