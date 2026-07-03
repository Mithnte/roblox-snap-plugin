local BaseTool = require(script.Parent.BaseTool)
local Selection = game:GetService("Selection")
local Workspace = game:GetService("Workspace")

local BoxSelectTool = setmetatable({}, BaseTool)
BoxSelectTool.__index = BoxSelectTool

function BoxSelectTool.new(ctx)
	local self = BaseTool.new(ctx)
	return setmetatable(self, BoxSelectTool)
end

function BoxSelectTool:Activate()
	BaseTool.Activate(self)
	self._mouse = self.ctx.plugin:GetMouse()
	self._drag = false
	self._startHit = nil

	self._down = self._mouse.Button1Down:Connect(function()
		self._drag = true
		self._startHit = self._mouse.Hit
	end)
	self._up = self._mouse.Button1Up:Connect(function()
		if not self._drag then
			return
		end
		self._drag = false
		local a = self._startHit
		local b = self._mouse.Hit
		if not a or not b then
			return
		end

		-- Build a tall box spanning the dragged rectangle on the XZ plane, then
		-- collect any part whose bounds overlap it. GetPartBoundsInBox is the
		-- modern replacement for the deprecated Region3 + FindPartsInRegion3.
		local aPos, bPos = a.Position, b.Position
		local minX, maxX = math.min(aPos.X, bPos.X), math.max(aPos.X, bPos.X)
		local minZ, maxZ = math.min(aPos.Z, bPos.Z), math.max(aPos.Z, bPos.Z)
		local center = Vector3.new((minX + maxX) / 2, 0, (minZ + maxZ) / 2)
		local size = Vector3.new(math.max(maxX - minX, 0.05), 1e6, math.max(maxZ - minZ, 0.05))

		local params = OverlapParams.new()
		params.MaxParts = 0 -- 0 = unlimited
		local parts = Workspace:GetPartBoundsInBox(CFrame.new(center), size, params)

		local out = {}
		for _, p in ipairs(parts) do
			local top = p:FindFirstAncestorOfClass("Model") or p
			if top and top.Parent ~= nil then
				out[top] = true
			end
		end
		local unique = {}
		for inst in pairs(out) do
			table.insert(unique, inst)
		end
		Selection:Set(unique)
	end)
end

function BoxSelectTool:Deactivate()
	BaseTool.Deactivate(self)
	if self._down then
		self._down:Disconnect()
	end
	if self._up then
		self._up:Disconnect()
	end
	self._down = nil
	self._up = nil
	self._mouse = nil
end

return BoxSelectTool
