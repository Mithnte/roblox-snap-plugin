local CommandPalette = {}
CommandPalette.__index = CommandPalette

function CommandPalette.new(ctx)
        local self = setmetatable({}, CommandPalette)
        self._ctx = ctx
        self._gui = nil
        self._search = nil
        self._list = nil
        self._commands = self:_BuildCommands()
        return self
end

function CommandPalette:_BuildCommands()
        local ctx = self._ctx

        local function toggleAnchor()
                for _, inst in ipairs(ctx.selectionStore:Get()) do
                        if inst:IsA("BasePart") then
                                inst.Anchored = not inst.Anchored
                        elseif inst:IsA("Model") then
                                for _, d in ipairs(inst:GetDescendants()) do
                                        if d:IsA("BasePart") then d.Anchored = not d.Anchored end
                                end
                        end
                end
        end

        return {
                { label = "Tool: Select", run = function() ctx.toolController:SetActive("select") end },
                { label = "Tool: Box Select", run = function() ctx.toolController:SetActive("boxselect") end },
                { label = "Tool: Move", run = function() ctx.toolController:SetActive("move") end },
                { label = "Tool: Rotate", run = function() ctx.toolController:SetActive("rotate") end },
                { label = "Tool: Align", run = function() ctx.toolController:SetActive("align") end },

                { label = "Toggle Grid Snap", run = function() ctx.settingsStore:Set({ gridSnapEnabled = not ctx.settingsStore.gridSnapEnabled }) end },
                { label = "Toggle Rotate Snap", run = function() ctx.settingsStore:Set({ rotateSnapEnabled = not ctx.settingsStore.rotateSnapEnabled }) end },
                { label = "Toggle Surface Snap", run = function() ctx.settingsStore:Set({ surfaceSnapEnabled = not ctx.settingsStore.surfaceSnapEnabled }) end },
                { label = "Toggle Align to Normal", run = function() ctx.settingsStore:Set({ alignToNormalEnabled = not ctx.settingsStore.alignToNormalEnabled }) end },

                { label = "Align: Center to First", run = function() ctx.align:CenterToFirst(ctx.selectionStore:Get()) end },
                { label = "Align: Match Rotation to First", run = function() ctx.align:MatchRotation(ctx.selectionStore:Get()) end },
                { label = "Align: Match Size to First", run = function() ctx.align:MatchSize(ctx.selectionStore:Get()) end },

                { label = "Array: Linear x5", run = function()
                        local s = ctx.selectionStore:Get()
                        if #s > 0 then ctx.array:Linear(s, 5, Vector3.new(ctx.settingsStore.gridStep, 0, 0)) end
                end },
                { label = "Array: Radial x8", run = function()
                        local s = ctx.selectionStore:Get()
                        if #s > 0 then ctx.array:Radial(s, 8, 6, 45) end
                end },
                { label = "Array: Grid 2x2", run = function()
                        local s = ctx.selectionStore:Get()
                        if #s > 0 then ctx.array:Grid(s, 2, 2, ctx.settingsStore.gridStep, ctx.settingsStore.gridStep) end
                end },

                { label = "Toggle Anchor (Selection)", run = toggleAnchor },
                { label = "Undo", run = function() ctx.history:Undo() end },
                { label = "Redo", run = function() ctx.history:Redo() end },
        }
end

function CommandPalette:_EnsureGui()
        if self._gui then return end
        local plugin = self._ctx.plugin
        local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, true, 320, 380, 260, 220)
        local gui = plugin:CreateDockWidgetPluginGui("BuilderToolkitPalette", info)
        gui.Title = "Command Palette"
        self._gui = gui

        local root = Instance.new("Frame"); root.Size = UDim2.fromScale(1, 1); root.BackgroundTransparency = 1; root.Parent = gui
        local pad = Instance.new("Frame"); pad.Size = UDim2.new(1, -16, 1, -16); pad.Position = UDim2.new(0, 8, 0, 8); pad.BackgroundTransparency = 1; pad.Parent = root
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)
        layout.Parent = pad

        local search = Instance.new("TextBox")
        search.Size = UDim2.new(1, 0, 0, 30)
        search.PlaceholderText = "Type a command..."
        search.Text = ""
        search.ClearTextOnFocus = false
        search.Parent = pad
        self._search = search

        local list = Instance.new("ScrollingFrame")
        list.Size = UDim2.new(1, 0, 1, -40)
        list.BackgroundTransparency = 1
        list.CanvasSize = UDim2.new(0, 0, 0, 0)
        list.AutomaticCanvasSize = Enum.AutomaticSize.Y
        list.ScrollBarThickness = 6
        list.Parent = pad
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = list
        self._list = list

        search:GetPropertyChangedSignal("Text"):Connect(function()
                self:_Refresh()
        end)

        search.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                        self:_RunFirstMatch()
                end
        end)
end

function CommandPalette:_Refresh()
        for _, child in ipairs(self._list:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
        end
        local query = string.lower(self._search.Text or "")
        for _, cmd in ipairs(self._commands) do
                if query == "" or string.find(string.lower(cmd.label), query, 1, true) then
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(1, 0, 0, 26)
                        btn.Text = cmd.label
                        btn.Parent = self._list
                        btn.MouseButton1Click:Connect(function()
                                cmd.run()
                                self:Close()
                        end)
                end
        end
end

function CommandPalette:_RunFirstMatch()
        local query = string.lower(self._search.Text or "")
        for _, cmd in ipairs(self._commands) do
                if query == "" or string.find(string.lower(cmd.label), query, 1, true) then
                        cmd.run()
                        self:Close()
                        return
                end
        end
end

function CommandPalette:Open()
        self:_EnsureGui()
        self._search.Text = ""
        self:_Refresh()
        self._gui.Enabled = true
        self._search:CaptureFocus()
end

function CommandPalette:Close()
        if self._gui then self._gui.Enabled = false end
end

return CommandPalette
