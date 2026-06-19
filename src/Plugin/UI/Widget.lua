local Widget = {}
Widget.__index = Widget

local function makeToggle(parent, labelText, onChanged)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -16, 0, 28)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -60, 1, 0)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = labelText
	label.Parent = row

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 48, 0, 22)
	button.Position = UDim2.new(1, -48, 0.5, -11)
	button.Text = "ON"
	button.Parent = row

	local state = true
	button.MouseButton1Click:Connect(function()
		state = not state
		button.Text = state and "ON" or "OFF"
		onChanged(state)
	end)

	return function(setTo)
		state = setTo
		button.Text = state and "ON" or "OFF"
	end
end

local function makeDropdown(parent, labelText, options, onChanged)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -16, 0, 28)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -120, 1, 0)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = labelText
	label.Parent = row

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 96, 0, 22)
	button.Position = UDim2.new(1, -96, 0.5, -11)
	button.Parent = row

	local idx = 1
	button.Text = tostring(options[idx])
	button.MouseButton1Click:Connect(function()
		idx += 1
		if idx > #options then idx = 1 end
		button.Text = tostring(options[idx])
		onChanged(options[idx])
	end)

	return function(setTo)
		for i, v in ipairs(options) do
			if v == setTo then
				idx = i
				break
			end
		end
		button.Text = tostring(options[idx])
	end
end

function Widget.new(plugin, stores, onAction)
	local self = setmetatable({}, Widget)

	local info = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Left,
		true,
		false,
		320,
		420,
		260,
		300
	)

	self.gui = plugin:CreateDockWidgetPluginGui("BuilderToolkitWidget", info)
	self.gui.Title = "Builder Toolkit"

	local root = Instance.new("Frame")
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundTransparency = 1
	root.Parent = self.gui

	local pad = Instance.new("Frame")
	pad.Size = UDim2.new(1, -16, 1, -16)
	pad.Position = UDim2.new(0, 8, 0, 8)
	pad.BackgroundTransparency = 1
	pad.Parent = root

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 24)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Snapping"
	title.Parent = pad

	local gridToggleSetter = makeToggle(pad, "Grid Snap", function(v)
		onAction({ type = "set", key = "gridSnapEnabled", value = v })
	end)
	local gridStepSetter = makeDropdown(pad, "Grid Step", {0.25, 0.5, 1}, function(v)
		onAction({ type = "set", key = "gridStep", value = v })
	end)

	local rotateToggleSetter = makeToggle(pad, "Rotate Snap", function(v)
		onAction({ type = "set", key = "rotateSnapEnabled", value = v })
	end)
	local rotateStepSetter = makeDropdown(pad, "Rotate Step", {15, 45}, function(v)
		onAction({ type = "set", key = "rotateStepDeg", value = v })
	end)

	-- Sync UI from store changes
	stores.settingsStore.changed:Connect(function(s)
		gridToggleSetter(s.gridSnapEnabled)
		gridStepSetter(s.gridStep)
		rotateToggleSetter(s.rotateSnapEnabled)
		rotateStepSetter(s.rotateStepDeg)
	end)

	-- initial
	gridToggleSetter(stores.settingsStore.gridSnapEnabled)
	gridStepSetter(stores.settingsStore.gridStep)
	rotateToggleSetter(stores.settingsStore.rotateSnapEnabled)
	rotateStepSetter(stores.settingsStore.rotateStepDeg)

	return self
end

function Widget:SetEnabled(enabled)
	self.gui.Enabled = enabled
end

return Widget
