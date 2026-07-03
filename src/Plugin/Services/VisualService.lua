local Workspace = game:GetService("Workspace")

local VisualService = {}
VisualService.__index = VisualService

function VisualService.new()
	local self = setmetatable({}, VisualService)
	self._selectionBoxes = {}
	return self
end

function VisualService:Clear()
	for _, sb in pairs(self._selectionBoxes) do
		if sb then
			sb:Destroy()
		end
	end
	self._selectionBoxes = {}
end

function VisualService:ShowSelection(selection, ok)
	local color = ok and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
	for _, inst in ipairs(selection) do
		local target = nil
		if inst:IsA("Model") then
			target = inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart")
		else
			target = inst
		end
		if target and target:IsA("BasePart") then
			local sb = self._selectionBoxes[inst]
			if not sb then
				sb = Instance.new("SelectionBox")
				sb.LineThickness = 0.05
				sb.Adornee = inst
				sb.Parent = Workspace
				self._selectionBoxes[inst] = sb
			end
			sb.Color3 = color
			sb.Visible = true
		end
	end
end

return VisualService
