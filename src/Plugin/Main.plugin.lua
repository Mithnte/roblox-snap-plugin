local Selection = game:GetService("Selection")

local SettingsStore = require(script.State.SettingsStore)
local SelectionStore = require(script.State.SelectionStore)

local HistoryService = require(script.Services.HistoryService)
local SnapService = require(script.Services.SnapService)
local TransformService = require(script.Services.TransformService)
local RaycastService = require(script.Services.RaycastService)
local VisualService = require(script.Services.VisualService)
local InputService = require(script.Services.InputService)
local ToolController = require(script.Services.ToolController)
local AlignService = require(script.Services.AlignService)
local ArrayService = require(script.Services.ArrayService)
local PaintService = require(script.Services.PaintService)
local CommandPalette = require(script.Services.CommandPalette)
local BlueprintService = require(script.Services.BlueprintService)
local Icons = require(script.Config.Icons)
local Defaults = require(script.Config.Defaults)

local SelectTool = require(script.Tools.SelectTool)
local MoveTool = require(script.Tools.MoveTool)
local RotateTool = require(script.Tools.RotateTool)
local ScaleTool = require(script.Tools.ScaleTool)
local BoxSelectTool = require(script.Tools.BoxSelectTool)
local AlignTool = require(script.Tools.AlignTool)

local Widget = require(script.UI.Widget)

local settingsStore = SettingsStore.new(plugin)
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
	ray = nil,
	align = nil,
	visual = nil,
	array = nil,
	paint = nil,
	palette = nil,
	_keyState = keyState,
	_lastMoveOffset = nil, -- net offset of the last Move drag; used by Smart Duplicate
}

ctx.ray = RaycastService.new(ctx)
ctx.align = AlignService.new(ctx)
ctx.visual = VisualService.new()
ctx.array = ArrayService.new(ctx)
ctx.paint = PaintService.new(ctx)
ctx.palette = CommandPalette.new(ctx)
ctx.blueprint = BlueprintService.new(ctx)

ctx.input = InputService.new(plugin, keyState)
ctx.input:Bind()

ctx.toolController = ToolController.new(ctx)
ctx.toolController:RegisterTool("select", SelectTool.new(ctx))
ctx.toolController:RegisterTool("boxselect", BoxSelectTool.new(ctx))
ctx.toolController:RegisterTool("move", MoveTool.new(ctx))
ctx.toolController:RegisterTool("rotate", RotateTool.new(ctx))
ctx.toolController:RegisterTool("scale", ScaleTool.new(ctx))
ctx.toolController:RegisterTool("align", AlignTool.new(ctx))
ctx.toolController:SetActive("select")

-- Duplicates the selection using the last Move drag's offset (or one grid step
-- along X if nothing has been moved yet), then selects the copies so repeated
-- presses lay down an evenly spaced row.
local function smartDuplicate()
	local sel = selectionStore:Get()
	if #sel == 0 then
		return
	end
	local offset = ctx._lastMoveOffset
	if not offset or offset.Magnitude < 1e-4 then
		offset = Vector3.new(settingsStore.gridStep or 1, 0, 0)
	end
	history:Waypoint("Builder: Smart Duplicate (start)")
	local newSel = {}
	for _, inst in ipairs(sel) do
		local clone = inst:Clone()
		clone.Parent = inst.Parent
		table.insert(newSel, clone)
	end
	transform:Translate(newSel, offset)
	history:Waypoint("Builder: Smart Duplicate (end)")
	Selection:Set(newSel)
end

local function cycleGridStep(dir)
	local steps = Defaults.gridSteps
	local cur = settingsStore.gridStep
	local idx = 1
	for i, v in ipairs(steps) do
		if v == cur then
			idx = i
			break
		end
	end
	idx = ((idx - 1 + dir) % #steps) + 1
	settingsStore:Set({ gridStep = steps[idx] })
end

local function hasCtrlOrCmd(input)
	return input:IsModifierKeyDown(Enum.ModifierKey.Ctrl) or input:IsModifierKeyDown(Enum.ModifierKey.Meta)
end

-- Global keyboard shortcuts, active regardless of the current tool. Each returns
-- true when it handles the key so the active tool doesn't also react to it.
ctx.input:RegisterShortcut(function(input)
	local kc = input.KeyCode
	local s = settingsStore

	if kc == Enum.KeyCode.P and hasCtrlOrCmd(input) then
		ctx.palette:Open()
		return true
	end
	if kc == Enum.KeyCode.D and hasCtrlOrCmd(input) and input:IsModifierKeyDown(Enum.ModifierKey.Shift) then
		smartDuplicate()
		return true
	end

	if kc == s:GetKey("switch_select") then
		ctx.toolController:SetActive("select")
		return true
	end
	if kc == s:GetKey("switch_move") then
		ctx.toolController:SetActive("move")
		return true
	end
	if kc == s:GetKey("switch_rotate") then
		ctx.toolController:SetActive("rotate")
		return true
	end
	if kc == s:GetKey("switch_scale") then
		ctx.toolController:SetActive("scale")
		return true
	end
	if kc == s:GetKey("switch_box") then
		ctx.toolController:SetActive("boxselect")
		return true
	end

	if kc == s:GetKey("toggle_grid_snap") then
		s:Set({ gridSnapEnabled = not s.gridSnapEnabled })
		return true
	end
	if kc == s:GetKey("toggle_rotate_snap") then
		s:Set({ rotateSnapEnabled = not s.rotateSnapEnabled })
		return true
	end
	if kc == s:GetKey("toggle_vertex_snap") then
		s:Set({ vertexSnapEnabled = not s.vertexSnapEnabled })
		return true
	end

	if kc == Enum.KeyCode.LeftBracket then
		cycleGridStep(-1)
		return true
	end
	if kc == Enum.KeyCode.RightBracket then
		cycleGridStep(1)
		return true
	end

	return false
end)

local toolbar = plugin:CreateToolbar("Builder Toolkit")
local toggleButton = toolbar:CreateButton("Toggle", "Toggle Builder Toolkit", Icons.toggle)
toggleButton.ClickableWhenViewportHidden = true
local selectBtn = toolbar:CreateButton("Select", "Select tool", Icons.select)
local boxBtn = toolbar:CreateButton("Box", "Box select", Icons.box)
local moveBtn = toolbar:CreateButton("Move", "Move tool", Icons.move)
local rotateBtn = toolbar:CreateButton("Rotate", "Rotate tool", Icons.rotate)
local scaleBtn = toolbar:CreateButton("Scale", "Scale tool (=/-, X/Y/Z to constrain)", Icons.scale)
local alignBtn = toolbar:CreateButton("Align", "Align tool (J/L/I/K/U/O/C/T/S)", Icons.align)
local paletteBtn = toolbar:CreateButton("Palette", "Command palette (Ctrl+P)", Icons.palette)

selectBtn.Click:Connect(function()
	ctx.toolController:SetActive("select")
end)
boxBtn.Click:Connect(function()
	ctx.toolController:SetActive("boxselect")
end)
moveBtn.Click:Connect(function()
	ctx.toolController:SetActive("move")
end)
rotateBtn.Click:Connect(function()
	ctx.toolController:SetActive("rotate")
end)
scaleBtn.Click:Connect(function()
	ctx.toolController:SetActive("scale")
end)
alignBtn.Click:Connect(function()
	ctx.toolController:SetActive("align")
end)
paletteBtn.Click:Connect(function()
	ctx.palette:Open()
end)

local widget = Widget.new(
	plugin,
	{ settingsStore = settingsStore, selectionStore = selectionStore, toolController = ctx.toolController },
	function(action)
		if action.type == "set" then
			settingsStore:Set({ [action.key] = action.value })
		elseif action.type == "quick" and action.op == "toggle_anchor" then
			local sel = selectionStore:Get()
			for _, inst in ipairs(sel) do
				if inst:IsA("BasePart") then
					inst.Anchored = not inst.Anchored
				elseif inst:IsA("Model") then
					for _, d in ipairs(inst:GetDescendants()) do
						if d:IsA("BasePart") then
							d.Anchored = not d.Anchored
						end
					end
				end
			end
		elseif action.type == "history" then
			if action.op == "undo" then
				history:Undo()
			elseif action.op == "redo" then
				history:Redo()
			end
		elseif action.type == "align" then
			local sel = selectionStore:Get()
			if #sel < 2 then
				return
			end
			history:Waypoint("Builder: Align (start)")
			if action.op == "center" then
				ctx.align:CenterToFirst(sel)
			elseif action.op == "match_rotation" then
				ctx.align:MatchRotation(sel)
			elseif action.op == "match_size" then
				ctx.align:MatchSize(sel)
			end
			history:Waypoint("Builder: Align (end)")
		elseif action.type == "array" then
			local sel = selectionStore:Get()
			if #sel == 0 then
				return
			end
			if action.op == "linear" then
				ctx.array:Linear(
					sel,
					math.max(1, math.floor(action.count or 1)),
					Vector3.new(action.spacing or 0, 0, 0)
				)
			elseif action.op == "radial" then
				ctx.array:Radial(
					sel,
					math.max(1, math.floor(action.count or 1)),
					action.radius or 0,
					action.stepDeg or 0
				)
			elseif action.op == "grid" then
				ctx.array:Grid(
					sel,
					math.max(1, math.floor(action.rows or 1)),
					math.max(1, math.floor(action.cols or 1)),
					action.spacingX or 0,
					action.spacingZ or 0
				)
			end
		elseif action.type == "paint" then
			local sel = selectionStore:Get()
			if action.op == "color" then
				ctx.paint:SetColor(sel, Color3.fromRGB(action.r or 255, action.g or 255, action.b or 255))
			elseif action.op == "material" then
				ctx.paint:SetMaterial(sel, action.material)
			elseif action.op == "match" then
				ctx.paint:MatchAppearanceToFirst(sel)
			end
		elseif action.type == "blueprint" then
			if action.op == "save" then
				ctx.blueprint:SaveSelectedAs(action.name, selectionStore:Get())
			elseif action.op == "spawn" then
				local mouse = plugin:GetMouse()
				local at = (mouse and mouse.Hit and mouse.Hit.Position) or Vector3.new(0, 5, 0)
				local spawned = ctx.blueprint:Spawn(action.name, at)
				if spawned then
					Selection:Set(spawned)
				end
			elseif action.op == "delete" then
				ctx.blueprint:Delete(action.name)
			end
		elseif action.type == "hotkey" then
			settingsStore:SetBinding(action.action, action.keyCode)
		elseif action.type == "settings" and action.op == "reset" then
			settingsStore:ResetToDefaults()
		end
	end
)

widget:SetEnabled(false)

toggleButton.Click:Connect(function()
	if widget and widget.gui then
		widget:SetEnabled(not widget.gui.Enabled)
	end
end)
