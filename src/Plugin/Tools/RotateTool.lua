local BaseTool = require(script.Parent.BaseTool)

local RotateTool = setmetatable({}, BaseTool)
RotateTool.__index = RotateTool

function RotateTool.new(ctx)
	local self = BaseTool.new(ctx)
	return setmetatable(self, RotateTool)
end

function RotateTool:Activate()
	BaseTool.Activate(self)
	-- TODO: Hook rotate drag input
end

return RotateTool
