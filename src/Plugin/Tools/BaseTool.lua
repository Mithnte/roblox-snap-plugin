local BaseTool = {}
BaseTool.__index = BaseTool

function BaseTool.new(ctx)
	return setmetatable({ ctx = ctx, active = false }, BaseTool)
end

function BaseTool:Activate()
	self.active = true
end

function BaseTool:Deactivate()
	self.active = false
end

return BaseTool
