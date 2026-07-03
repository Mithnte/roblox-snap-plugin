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
                if not self._drag then return end
                self._drag = false
                local a = self._startHit
                local b = self._mouse.Hit
                if not a or not b then return end
                -- MVP: project AABB on XZ plane between a and b
                local minX = math.min(a.X, b.X)
                local maxX = math.max(a.X, b.X)
                local minZ = math.min(a.Z, b.Z)
                local maxZ = math.max(a.Z, b.Z)
                local region = Region3.new(Vector3.new(minX, -1e6, minZ), Vector3.new(maxX, 1e6, maxZ))
                -- ExpandToGrid returns a new Region3, it does not mutate in place.
                region = region:ExpandToGrid(4)
                local parts = Workspace:FindPartsInRegion3(region, nil, math.huge)
                local out = {}
                for _, p in ipairs(parts) do
                        local top = p:FindFirstAncestorOfClass("Model") or p
                        if top and top.Parent ~= nil then
                                out[top] = true
                        end
                end
                local unique = {}
                for inst in pairs(out) do table.insert(unique, inst) end
                Selection:Set(unique)
        end)
end

function BoxSelectTool:Deactivate()
        BaseTool.Deactivate(self)
        if self._down then self._down:Disconnect() end
        if self._up then self._up:Disconnect() end
        self._down = nil
        self._up = nil
        self._mouse = nil
end

function BoxSelectTool:OnKeyDown(input)
        if input.KeyCode == Enum.KeyCode.B then
                self.ctx.toolController:SetActive("boxselect")
        end
end

return BoxSelectTool
