local BaseTool = require(script.Parent.BaseTool)

local MoveTool = setmetatable({}, BaseTool)
MoveTool.__index = MoveTool

local function averagePosition(instances)
        local sum = Vector3.zero
        local n = 0
        for _, inst in ipairs(instances) do
                local ok, cf = pcall(function()
                        if inst:IsA("Model") then return inst:GetPivot() elseif inst:IsA("BasePart") then return inst.CFrame end
                end)
                if ok and cf then sum += cf.Position; n += 1 end
        end
        if n == 0 then return nil end
        return sum / n
end

local function anyCollision(selection)
        -- naive overlap check: if any selected part intersects with non-selected parts using GetTouchingParts
        local selectedSet = {}
        for _, s in ipairs(selection) do selectedSet[s] = true end
        for _, inst in ipairs(selection) do
                if inst:IsA("Model") then
                        for _, d in ipairs(inst:GetDescendants()) do
                                if d:IsA("BasePart") then
                                        for _, tp in ipairs(d:GetTouchingParts()) do
                                                if not selectedSet[tp] and not tp:IsDescendantOf(inst) then return true end
                                        end
                                end
                        end
                elseif inst:IsA("BasePart") then
                        for _, tp in ipairs(inst:GetTouchingParts()) do
                                if not selectedSet[tp] then return true end
                        end
                end
        end
        return false
end

function MoveTool.new(ctx)
        local self = BaseTool.new(ctx)
        return setmetatable(self, MoveTool)
end

function MoveTool:Activate()
        BaseTool.Activate(self)
        self._mouse = self.ctx.plugin:GetMouse()
        self._dragging = false
        self._dragStartPoint = nil
        self._dragStartAvg = nil
        self._lastAppliedAvg = nil
        self._axisLock = nil -- "X"|"Y"|"Z" or nil

        self._downConn = self._mouse.Button1Down:Connect(function()
                local selection = self.ctx.selectionStore:Get()
                if #selection == 0 then return end
                self._dragging = true
                self._dragStartPoint = self._mouse.Hit.Position
                self._dragStartAvg = averagePosition(selection)
                self._lastAppliedAvg = self._dragStartAvg
                self.ctx.history:Waypoint("Builder: Move (start)")
        end)

        self._upConn = self._mouse.Button1Up:Connect(function()
                if not self._dragging then return end
                self._dragging = false
                self._dragStartPoint = nil
                self._dragStartAvg = nil
                self._lastAppliedAvg = nil
                self._axisLock = nil
                self.ctx.visual:Clear()
                self.ctx.history:Waypoint("Builder: Move (end)")
        end)

        self._moveConn = self._mouse.Move:Connect(function()
                if not self._dragging then return end
                local selection = self.ctx.selectionStore:Get()
                if #selection == 0 or not self._dragStartAvg then return end

                local currentPoint = self._mouse.Hit.Position
                local delta = currentPoint - self._dragStartPoint
                delta = self.ctx.snap:ProjectAxis(delta, self._axisLock)

                local desiredAvg = self._dragStartAvg + delta

                -- surface snap (replace desired Y/point with raycast result)
                if self.ctx.settingsStore.surfaceSnapEnabled then
                        local hit = self.ctx.ray:RaycastFromScreen(self._mouse)
                        if hit and hit.Position then
                                desiredAvg = Vector3.new(desiredAvg.X, hit.Position.Y, desiredAvg.Z)
                                if self.ctx.settingsStore.alignToNormalEnabled then
                                        -- Align selection to hit.Normal. RotateAroundPivot is additive, so we must
                                        -- measure the *current* up vector of the lead instance each frame (not a
                                        -- fixed world up) or the rotation would keep compounding and spin forever.
                                        local leadCF = self.ctx.transform:GetPivot(selection[1])
                                        if leadCF then
                                                local up = leadCF.UpVector
                                                local axis = up:Cross(hit.Normal)
                                                local angle = math.acos(math.clamp(up:Dot(hit.Normal), -1, 1))
                                                if axis.Magnitude > 1e-3 and angle > 1e-3 then
                                                        local rot = CFrame.fromAxisAngle(axis.Unit, angle)
                                                        local pivot = CFrame.new(self._lastAppliedAvg or self._dragStartAvg)
                                                        self.ctx.transform:RotateAroundPivot(selection, pivot, rot)
                                                end
                                        end
                                end
                        end
                end

                local snappedAvg = self.ctx.snap:SnapPosition(desiredAvg)
                local appliedDelta = snappedAvg - (self._lastAppliedAvg or self._dragStartAvg)
                if appliedDelta.Magnitude > 0 then
                        self.ctx.transform:Translate(selection, appliedDelta)
                        self._lastAppliedAvg = (self._lastAppliedAvg or self._dragStartAvg) + appliedDelta
                        -- collision preview
                        local bad = anyCollision(selection)
                        self.ctx.visual:ShowSelection(selection, not bad)
                end
        end)
end

function MoveTool:Deactivate()
        BaseTool.Deactivate(self)
        if self._downConn then self._downConn:Disconnect() end
        if self._upConn then self._upConn:Disconnect() end
        if self._moveConn then self._moveConn:Disconnect() end
        self._downConn = nil; self._upConn = nil; self._moveConn = nil
        self._mouse = nil; self._dragging = false
        self._axisLock = nil
        if self.ctx.visual then self.ctx.visual:Clear() end
end

function MoveTool:OnKeyDown(input)
        if input.KeyCode == Enum.KeyCode.M then self.ctx.toolController:SetActive("move"); return end
        if input.KeyCode == Enum.KeyCode.X then self._axisLock = "X" end
        if input.KeyCode == Enum.KeyCode.Y then self._axisLock = "Y" end
        if input.KeyCode == Enum.KeyCode.Z then self._axisLock = "Z" end
        -- Smart duplicate (Ctrl+Shift+D) using last move delta
        if input.KeyCode == Enum.KeyCode.D and (input:IsModifierKeyDown(Enum.ModifierKey.Ctrl) or input:IsModifierKeyDown(Enum.ModifierKey.Meta)) and input:IsModifierKeyDown(Enum.ModifierKey.Shift) then
                local sel = self.ctx.selectionStore:Get()
                if #sel == 0 or not self._lastAppliedAvg or not self._dragStartAvg then return end
                local offset = self._lastAppliedAvg - self._dragStartAvg
                self.ctx.history:Waypoint("Builder: Smart Duplicate (start)")
                local newSel = {}
                for _, inst in ipairs(sel) do
                        local clone = inst:Clone()
                        clone.Parent = inst.Parent
                        table.insert(newSel, clone)
                end
                self.ctx.transform:Translate(newSel, offset)
                self.ctx.history:Waypoint("Builder: Smart Duplicate (end)")
        end
end

function MoveTool:OnKeyUp(input)
        if input.KeyCode == Enum.KeyCode.X or input.KeyCode == Enum.KeyCode.Y or input.KeyCode == Enum.KeyCode.Z then
                self._axisLock = nil
        end
end

return MoveTool
