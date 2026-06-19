local ToolController = {}
ToolController.__index = ToolController

function ToolController.new(ctx)
	local self = setmetatable({}, ToolController)
	self.ctx = ctx
	self.tools = {}
	self.active = nil
	return self
end

function ToolController:RegisterTool(id, tool)
	self.tools[id] = tool
end

function ToolController:SetActive(id)
	if self.active then
		self.active:Deactivate()
	end
	self.active = assert(self.tools[id], "Unknown tool: " .. tostring(id))
	self.active:Activate()
	if self.ctx.input then
		self.ctx.input:SetActiveTool(self.active)
	end
end

return ToolController
