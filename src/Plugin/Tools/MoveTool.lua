local BaseTool = require(script.Parent.BaseTool)

local MoveTool = setmetatable({}, BaseTool)
MoveTool.__index = MoveTool

function MoveTool.new(ctx)
	local self = BaseTool.new(ctx)
	return setmetatable(self, MoveTool)
end

function MoveTool:Activate()
	BaseTool.Activate(self)
	-- TODO: Hook mouse drag events via ctx.input
end

function MoveTool:OnDrag(deltaWorld)
	local selection = self.ctx.selectionStore:Get()
	if #selection == 0 then return end

	-- TODO: set waypoint once at drag start, and once at drag end
	self.ctx.transform:Translate(selection, deltaWorld)
end

return MoveTool
