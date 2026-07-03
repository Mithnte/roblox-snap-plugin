-- Saves the currently selected BaseParts as a named, reusable "blueprint"
-- (positions relative to the selection's average pivot + key visual/physics
-- properties), persisted via SettingsStore so it survives Studio restarts.
-- This intentionally supports BaseParts only (not Models/MeshParts/etc) to
-- keep the saved data small and reliably reconstructible.
local BlueprintService = {}
BlueprintService.__index = BlueprintService

function BlueprintService.new(ctx)
        local self = setmetatable({}, BlueprintService)
        self._ctx = ctx
        return self
end

local function averagePivot(selection)
        local sum = Vector3.zero
        local n = 0
        for _, inst in ipairs(selection) do
                if inst:IsA("BasePart") then
                        sum += inst.Position
                        n += 1
                end
        end
        if n == 0 then return nil end
        return sum / n
end

function BlueprintService:SaveSelectedAs(name, selection)
        if not name or name == "" then return false, "Name required" end
        local parts = {}
        for _, inst in ipairs(selection) do
                if inst:IsA("BasePart") then table.insert(parts, inst) end
        end
        if #parts == 0 then return false, "Select at least one Part" end

        local pivot = averagePivot(parts)
        local items = {}
        for _, part in ipairs(parts) do
                table.insert(items, {
                        offset = { part.Position.X - pivot.X, part.Position.Y - pivot.Y, part.Position.Z - pivot.Z },
                        rotation = { part.Orientation.X, part.Orientation.Y, part.Orientation.Z },
                        size = { part.Size.X, part.Size.Y, part.Size.Z },
                        shape = part:IsA("Part") and part.Shape.Name or nil,
                        color = { part.Color.R, part.Color.G, part.Color.B },
                        material = part.Material.Name,
                        transparency = part.Transparency,
                        canCollide = part.CanCollide,
                        anchored = part.Anchored,
                })
        end

        self._ctx.settingsStore:SaveBlueprint(name, { items = items, count = #items })
        return true
end

function BlueprintService:List()
        local names = {}
        for name in pairs(self._ctx.settingsStore.blueprints) do
                table.insert(names, name)
        end
        table.sort(names)
        return names
end

function BlueprintService:Delete(name)
        self._ctx.settingsStore:DeleteBlueprint(name)
end

function BlueprintService:Spawn(name, atPosition)
        local data = self._ctx.settingsStore.blueprints[name]
        if not data then return nil, "Unknown blueprint: " .. tostring(name) end

        self._ctx.history:Waypoint("Builder: Spawn Blueprint (start)")
        local spawned = {}
        for _, item in ipairs(data.items) do
                local part = Instance.new("Part")
                part.Size = Vector3.new(item.size[1], item.size[2], item.size[3])
                part.Position = atPosition + Vector3.new(item.offset[1], item.offset[2], item.offset[3])
                part.Orientation = Vector3.new(item.rotation[1], item.rotation[2], item.rotation[3])
                if item.shape then part.Shape = Enum.PartType[item.shape] end
                part.Color = Color3.new(item.color[1], item.color[2], item.color[3])
                part.Material = Enum.Material[item.material] or Enum.Material.Plastic
                part.Transparency = item.transparency or 0
                part.CanCollide = item.canCollide ~= false
                part.Anchored = item.anchored ~= false
                part.Parent = workspace
                table.insert(spawned, part)
        end
        self._ctx.history:Waypoint("Builder: Spawn Blueprint (end)")
        return spawned
end

return BlueprintService
