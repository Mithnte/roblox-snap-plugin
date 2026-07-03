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
local CommandPalette = require(script.Services.CommandPalette)
local BlueprintService = require(script.Services.BlueprintService)
local Icons = require(script.Config.Icons)

local SelectTool = require(script.Tools.SelectTool)
local MoveTool = require(script.Tools.MoveTool)
local RotateTool = require(script.Tools.RotateTool)
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
        palette = nil,
        _keyState = keyState,
}

ctx.ray = RaycastService.new(ctx)
ctx.align = AlignService.new(ctx)
ctx.visual = VisualService.new()
ctx.array = ArrayService.new(ctx)
ctx.palette = CommandPalette.new(ctx)
ctx.blueprint = BlueprintService.new(ctx)

ctx.input = InputService.new(plugin, keyState)
ctx.input:Bind()

ctx.toolController = ToolController.new(ctx)
ctx.toolController:RegisterTool("select", SelectTool.new(ctx))
ctx.toolController:RegisterTool("boxselect", BoxSelectTool.new(ctx))
ctx.toolController:RegisterTool("move", MoveTool.new(ctx))
ctx.toolController:RegisterTool("rotate", RotateTool.new(ctx))
ctx.toolController:RegisterTool("align", AlignTool.new(ctx))
ctx.toolController:SetActive("select")

local toolbar = plugin:CreateToolbar("Builder Toolkit")
local toggleButton = toolbar:CreateButton("Toggle","Toggle Builder Toolkit",Icons.toggle); toggleButton.ClickableWhenViewportHidden = true
local selectBtn = toolbar:CreateButton("Select","Select tool",Icons.select)
local boxBtn = toolbar:CreateButton("Box","Box select",Icons.box)
local moveBtn = toolbar:CreateButton("Move","Move tool",Icons.move)
local rotateBtn = toolbar:CreateButton("Rotate","Rotate tool",Icons.rotate)
local alignBtn = toolbar:CreateButton("Align","Align tool (J/L/I/K/U/O/C/T/S)",Icons.align)
local paletteBtn = toolbar:CreateButton("Palette","Command palette (Ctrl+P)",Icons.palette)

selectBtn.Click:Connect(function() ctx.toolController:SetActive("select") end)
boxBtn.Click:Connect(function() ctx.toolController:SetActive("boxselect") end)
moveBtn.Click:Connect(function() ctx.toolController:SetActive("move") end)
rotateBtn.Click:Connect(function() ctx.toolController:SetActive("rotate") end)
alignBtn.Click:Connect(function() ctx.toolController:SetActive("align") end)
paletteBtn.Click:Connect(function() ctx.palette:Open() end)

local widget = Widget.new(plugin, { settingsStore = settingsStore, selectionStore = selectionStore }, function(action)
        if action.type == "set" then
                settingsStore:Set({ [action.key] = action.value })
        elseif action.type == "quick" and action.op == "toggle_anchor" then
                local sel = selectionStore:Get()
                for _, inst in ipairs(sel) do
                        if inst:IsA("BasePart") then
                                inst.Anchored = not inst.Anchored
                        elseif inst:IsA("Model") then
                                for _, d in ipairs(inst:GetDescendants()) do
                                        if d:IsA("BasePart") then d.Anchored = not d.Anchored end
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
                if #sel < 2 then return end
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
                if #sel == 0 then return end
                if action.op == "linear" then
                        ctx.array:Linear(sel, math.max(1, math.floor(action.count or 1)), Vector3.new(action.spacing or 0, 0, 0))
                elseif action.op == "radial" then
                        ctx.array:Radial(sel, math.max(1, math.floor(action.count or 1)), action.radius or 0, action.stepDeg or 0)
                elseif action.op == "grid" then
                        ctx.array:Grid(sel, math.max(1, math.floor(action.rows or 1)), math.max(1, math.floor(action.cols or 1)), action.spacingX or 0, action.spacingZ or 0)
                end
        elseif action.type == "blueprint" then
                if action.op == "save" then
                        ctx.blueprint:SaveSelectedAs(action.name, selectionStore:Get())
                elseif action.op == "spawn" then
                        local mouse = plugin:GetMouse()
                        local at = (mouse and mouse.Hit and mouse.Hit.Position) or Vector3.new(0, 5, 0)
                        local spawned = ctx.blueprint:Spawn(action.name, at)
                        if spawned then
                                local Selection = game:GetService("Selection")
                                Selection:Set(spawned)
                        end
                elseif action.op == "delete" then
                        ctx.blueprint:Delete(action.name)
                end
        elseif action.type == "hotkey" then
                settingsStore:SetBinding(action.action, action.keyCode)
        end
end)

widget:SetEnabled(false)

toggleButton.Click:Connect(function()
        if widget and widget.gui then
                widget:SetEnabled(not widget.gui.Enabled)
        end
end)
