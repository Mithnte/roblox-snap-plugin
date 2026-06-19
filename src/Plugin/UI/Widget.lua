local Widget = {}
Widget.__index = Widget

function Widget.new(plugin, stores, onAction)
	local self = setmetatable({}, Widget)

	local info = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Left,
		true,  -- initialEnabled
		false, -- overrideEnabledRestore
		320,   -- defaultWidth
		420,   -- defaultHeight
		260,   -- minWidth
		300    -- minHeight
	)

	self.gui = plugin:CreateDockWidgetPluginGui("BuilderToolkitWidget", info)
	self.gui.Title = "Builder Toolkit"

	local root = Instance.new("Frame")
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundTransparency = 1
	root.Parent = self.gui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -16, 0, 24)
	label.Position = UDim2.new(0, 8, 0, 8)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = "Snap Settings (skeleton)"
	label.Parent = root

	-- TODO: build toggles + dropdowns
	-- onAction({ type = "setGridSnapEnabled", value = true })

	return self
end

function Widget:SetEnabled(enabled)
	self.gui.Enabled = enabled
end

return Widget
