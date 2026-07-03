local Signal = require(script.Parent.Parent.Core.Signal)

local ToolController = {}
ToolController.__index = ToolController

function ToolController.new(ctx)
	local self = setmetatable({}, ToolController)
	self.ctx = ctx
	self.tools = {}
	self.active = nil
	self.activeId = nil
	-- Fires with the newly activated tool id (e.g. "move") so UI can reflect
	-- which tool is current without polling.
	self.changed = Signal.new()
	return self
end

function ToolController:RegisterTool(id, tool)
	self.tools[id] = tool
end

function ToolController:SetActive(id)
	if self.activeId == id then
		return
	end
	if self.active then
		self.active:Deactivate()
	end
	self.active = assert(self.tools[id], "Unknown tool: " .. tostring(id))
	self.activeId = id
	self.active:Activate()
	if self.ctx.input then
		self.ctx.input:SetActiveTool(self.active)
	end
	self.changed:Fire(id)
end

return ToolController
