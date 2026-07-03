local Widget = {}
Widget.__index = Widget

local function makeToggle(parent, labelText, onChanged)
        local row = Instance.new("Frame"); row.Size = UDim2.new(1, -16, 0, 28); row.BackgroundTransparency = 1; row.Parent = parent
        local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, -60, 1, 0); label.BackgroundTransparency = 1; label.TextXAlignment = Enum.TextXAlignment.Left; label.Text = labelText; label.Parent = row
        local button = Instance.new("TextButton"); button.Size = UDim2.new(0, 48, 0, 22); button.Position = UDim2.new(1, -48, 0.5, -11); button.Text = "ON"; button.Parent = row
        local state = true
        button.MouseButton1Click:Connect(function() state = not state; button.Text = state and "ON" or "OFF"; onChanged(state) end)
        return function(setTo) state = setTo; button.Text = state and "ON" or "OFF" end
end

local function makeDropdown(parent, labelText, options, onChanged)
        local row = Instance.new("Frame"); row.Size = UDim2.new(1, -16, 0, 28); row.BackgroundTransparency = 1; row.Parent = parent
        local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, -160, 1, 0); label.BackgroundTransparency = 1; label.TextXAlignment = Enum.TextXAlignment.Left; label.Text = labelText; label.Parent = row
        local button = Instance.new("TextButton"); button.Size = UDim2.new(0, 140, 0, 22); button.Position = UDim2.new(1, -140, 0.5, -11); button.Parent = row
        local idx = 1; button.Text = tostring(options[idx])
        button.MouseButton1Click:Connect(function() idx += 1; if idx > #options then idx = 1 end; button.Text = tostring(options[idx]); onChanged(options[idx]) end)
        return function(setTo) for i, v in ipairs(options) do if v == setTo then idx = i break end end; button.Text = tostring(options[idx]) end
end

local function makeNumberField(parent, labelText, defaultValue)
        local row = Instance.new("Frame"); row.Size = UDim2.new(1, -16, 0, 28); row.BackgroundTransparency = 1; row.Parent = parent
        local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, -70, 1, 0); label.BackgroundTransparency = 1; label.TextXAlignment = Enum.TextXAlignment.Left; label.Text = labelText; label.Parent = row
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0, 60, 0, 22)
        box.Position = UDim2.new(1, -60, 0.5, -11)
        box.Text = tostring(defaultValue)
        box.ClearTextOnFocus = false
        box.Parent = row
        return function()
                return tonumber(box.Text) or defaultValue
        end
end

local function makeActionButton(parent, text, onClick)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 26)
        btn.Text = text
        btn.Parent = parent
        btn.MouseButton1Click:Connect(onClick)
        return btn
end

function Widget.new(plugin, stores, onAction)
        local self = setmetatable({}, Widget)
        local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, true, false, 360, 520, 280, 340)
        self.gui = plugin:CreateDockWidgetPluginGui("BuilderToolkitWidget", info)
        self.gui.Title = "Builder Toolkit"
        local root = Instance.new("Frame"); root.Size = UDim2.fromScale(1,1); root.BackgroundTransparency = 1; root.Parent = self.gui
        local pad = Instance.new("Frame"); pad.Size = UDim2.new(1, -16, 1, -16); pad.Position = UDim2.new(0,8,0,8); pad.BackgroundTransparency = 1; pad.Parent = root
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)
        layout.Parent = pad

        local title1 = Instance.new("TextLabel"); title1.Size = UDim2.new(1,0,0,24); title1.BackgroundTransparency = 1; title1.TextXAlignment = Enum.TextXAlignment.Left; title1.Text = "Snapping"; title1.Parent = pad
        local gridToggleSetter = makeToggle(pad, "Grid Snap", function(v) onAction({ type = "set", key = "gridSnapEnabled", value = v }) end)
        local gridStepSetter = makeDropdown(pad, "Grid Step (All)", {0.25, 0.5, 1}, function(v) onAction({ type = "set", key = "gridStep", value = v }) end)
        local gridStepXSetter = makeDropdown(pad, "Grid Step X", {"(inherit)",0.25,0.5,1,2}, function(v) onAction({ type = "set", key = "gridStepX", value = v=="(inherit)" and nil or v }) end)
        local gridStepYSetter = makeDropdown(pad, "Grid Step Y", {"(inherit)",0.25,0.5,1,2}, function(v) onAction({ type = "set", key = "gridStepY", value = v=="(inherit)" and nil or v }) end)
        local gridStepZSetter = makeDropdown(pad, "Grid Step Z", {"(inherit)",0.25,0.5,1,2}, function(v) onAction({ type = "set", key = "gridStepZ", value = v=="(inherit)" and nil or v }) end)

        local rotateToggleSetter = makeToggle(pad, "Rotate Snap", function(v) onAction({ type = "set", key = "rotateSnapEnabled", value = v }) end)
        local rotateStepSetter = makeDropdown(pad, "Rotate Step", {15, 45}, function(v) onAction({ type = "set", key = "rotateStepDeg", value = v }) end)

        local title2 = Instance.new("TextLabel"); title2.Size = UDim2.new(1,0,0,24); title2.BackgroundTransparency = 1; title2.TextXAlignment = Enum.TextXAlignment.Left; title2.Text = "Placement"; title2.Parent = pad
        local surfaceSnapSetter = makeToggle(pad, "Surface Snap", function(v) onAction({ type = "set", key = "surfaceSnapEnabled", value = v }) end)
        local alignNormalSetter = makeToggle(pad, "Align to Normal", function(v) onAction({ type = "set", key = "alignToNormalEnabled", value = v }) end)

        local title3 = Instance.new("TextLabel"); title3.Size = UDim2.new(1,0,0,24); title3.BackgroundTransparency = 1; title3.TextXAlignment = Enum.TextXAlignment.Left; title3.Text = "Quick Actions"; title3.Parent = pad
        makeActionButton(pad, "Toggle Anchor (Selection)", function() onAction({ type = "quick", op = "toggle_anchor" }) end)
        makeActionButton(pad, "Undo", function() onAction({ type = "history", op = "undo" }) end)
        makeActionButton(pad, "Redo", function() onAction({ type = "history", op = "redo" }) end)

        local title4 = Instance.new("TextLabel"); title4.Size = UDim2.new(1,0,0,24); title4.BackgroundTransparency = 1; title4.TextXAlignment = Enum.TextXAlignment.Left; title4.Text = "Align (needs 2+ selected)"; title4.Parent = pad
        makeActionButton(pad, "Center to First", function() onAction({ type = "align", op = "center" }) end)
        makeActionButton(pad, "Match Rotation to First", function() onAction({ type = "align", op = "match_rotation" }) end)
        makeActionButton(pad, "Match Size to First", function() onAction({ type = "align", op = "match_size" }) end)

        local title5 = Instance.new("TextLabel"); title5.Size = UDim2.new(1,0,0,24); title5.BackgroundTransparency = 1; title5.TextXAlignment = Enum.TextXAlignment.Left; title5.Text = "Array Tools (uses selection)"; title5.Parent = pad

        local arrayCountGet = makeNumberField(pad, "Count", 5)
        local arraySpacingGet = makeNumberField(pad, "Linear Spacing X", 4)
        makeActionButton(pad, "Array Linear", function()
                onAction({ type = "array", op = "linear", count = arrayCountGet(), spacing = arraySpacingGet() })
        end)

        local arrayRadiusGet = makeNumberField(pad, "Radial Radius", 6)
        local arrayStepDegGet = makeNumberField(pad, "Radial Step (deg)", 30)
        makeActionButton(pad, "Array Radial", function()
                onAction({ type = "array", op = "radial", count = arrayCountGet(), radius = arrayRadiusGet(), stepDeg = arrayStepDegGet() })
        end)

        local arrayRowsGet = makeNumberField(pad, "Grid Rows", 2)
        local arrayColsGet = makeNumberField(pad, "Grid Cols", 2)
        local arraySpacingXGet = makeNumberField(pad, "Grid Spacing X", 4)
        local arraySpacingZGet = makeNumberField(pad, "Grid Spacing Z", 4)
        makeActionButton(pad, "Array Grid", function()
                onAction({ type = "array", op = "grid", rows = arrayRowsGet(), cols = arrayColsGet(), spacingX = arraySpacingXGet(), spacingZ = arraySpacingZGet() })
        end)

        stores.settingsStore.changed:Connect(function(s)
                gridToggleSetter(s.gridSnapEnabled)
                gridStepSetter(s.gridStep)
                gridStepXSetter(s.gridStepX or "(inherit)")
                gridStepYSetter(s.gridStepY or "(inherit)")
                gridStepZSetter(s.gridStepZ or "(inherit)")
                rotateToggleSetter(s.rotateSnapEnabled)
                rotateStepSetter(s.rotateStepDeg)
                surfaceSnapSetter(s.surfaceSnapEnabled)
                alignNormalSetter(s.alignToNormalEnabled)
        end)

        gridToggleSetter(stores.settingsStore.gridSnapEnabled)
        gridStepSetter(stores.settingsStore.gridStep)
        gridStepXSetter(stores.settingsStore.gridStepX or "(inherit)")
        gridStepYSetter(stores.settingsStore.gridStepY or "(inherit)")
        gridStepZSetter(stores.settingsStore.gridStepZ or "(inherit)")
        rotateToggleSetter(stores.settingsStore.rotateSnapEnabled)
        rotateStepSetter(stores.settingsStore.rotateStepDeg)
        surfaceSnapSetter(stores.settingsStore.surfaceSnapEnabled)
        alignNormalSetter(stores.settingsStore.alignToNormalEnabled)

        return self
end

function Widget:SetEnabled(enabled)
        self.gui.Enabled = enabled
end

return Widget
