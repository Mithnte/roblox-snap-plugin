local SettingsStore = require(script.State.SettingsStore)
local SelectionStore = require(script.State.SelectionStore)

local HistoryService = require(script.Services.HistoryService)
local SnapService = require(script.Services.SnapService)
local TransformService = require(script.Services.TransformService)
local InputService = require(script.Services.InputService)
local ToolController = require(script.Services.ToolController)

local SelectTool = require(script.Tools.SelectTool)
local MoveTool = require(script.Tools.MoveTool)
local RotateTool = require(script.Tools.RotateTool)

local Widget = require(script.UI.Widget)

local settingsStore = SettingsStore.new()
local selectionStore = SelectionStore.new()

local history = HistoryService.new()
local transform = TransformService.new()
local snap = SnapService.new(settingsStore)

local keyState = { shift = false }

local ctx = {
	plugin = plugin,
	settingsStore = settingsStore,
	selectionStore = selectionStore,
	history = history,
	transform = transform,
	snap = snap,
	_keyState = keyState,
}

ctx.input = InputService.new(plugin)
ctx.input:Bind()

ctx.toolController = ToolController.new(ctx)
ctx.toolController:RegisterTool("select", SelectTool.new(ctx))
ctx.toolController:RegisterTool("move", MoveTool.new(ctx))
ctx.toolController:RegisterTool("rotate", RotateTool.new(ctx))
ctx.toolController:SetActive("select")

local toolbar = plugin:CreateToolbar("Builder Toolkit")
local toggleButton = toolbar:CreateButton(
	"Toggle",
	"Toggle Builder Toolkit",
	"rbxassetid://0"
)
	toggleButton.ClickableWhenViewportHidden = true

local widget = Widget.new(plugin, { settingsStore = settingsStore, selectionStore = selectionStore }, function(action)
	if action.type == "set" then
		settingsStore:Set({ [action.key] = action.value })
	end
end)

widget:SetEnabled(false)

toggleButton.Click:Connect(function()
	widget:SetEnabled(not widget.gui.Enabled)
end)
