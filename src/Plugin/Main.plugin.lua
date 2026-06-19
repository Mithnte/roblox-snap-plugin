local SettingsStore = require(script.State.SettingsStore)
local SelectionStore = require(script.State.SelectionStore)

local HistoryService = require(script.Services.HistoryService)
local SnapService = require(script.Services.SnapService)
local TransformService = require(script.Services.TransformService)

local Widget = require(script.UI.Widget)

local settingsStore = SettingsStore.new()
local selectionStore = SelectionStore.new()

local history = HistoryService.new()
local transform = TransformService.new()
local snap = SnapService.new(settingsStore)

local ctx = {
	settingsStore = settingsStore,
	selectionStore = selectionStore,
	history = history,
	transform = transform,
	snap = snap,
	-- input service + tool controller (next)
}

local toolbar = plugin:CreateToolbar("Builder Toolkit")
local toggleButton = toolbar:CreateButton(
	"Toggle",
	"Toggle Builder Toolkit",
	"rbxassetid://0"
)
	toggleButton.ClickableWhenViewportHidden = true

local widget = Widget.new(plugin, { settingsStore = settingsStore, selectionStore = selectionStore }, function(action)
	-- TODO: handle UI actions -> settingsStore:Set({...})
end)

widget:SetEnabled(false)

toggleButton.Click:Connect(function()
	widget:SetEnabled(not widget.gui.Enabled)
end)
