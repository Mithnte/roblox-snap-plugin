local BaseTool = require(script.Parent.BaseTool)

local AlignTool = setmetatable({}, BaseTool)
AlignTool.__index = AlignTool

function AlignTool.new(ctx)
	local self = BaseTool.new(ctx)
	return setmetatable(self, AlignTool)
end

function AlignTool:Activate()
	BaseTool.Activate(self)
end

function AlignTool:OnKeyDown(input)
	local map = {
		[Enum.KeyCode.J] = "Left",
		[Enum.KeyCode.L] = "Right",
		[Enum.KeyCode.I] = "Top",
		[Enum.KeyCode.K] = "Bottom",
		[Enum.KeyCode.U] = "Back",
		[Enum.KeyCode.O] = "Front",
	}
	local side = map[input.KeyCode]
	if not side then return end
	local sel = self.ctx.selectionStore:Get()
	if #sel < 2 then return end
	self.ctx.history:Waypoint("Builder: Align " .. side .. " (start)")
	self.ctx.align:AlignToFirst(sel, side)
	self.ctx.history:Waypoint("Builder: Align " .. side .. " (end)")
end

return AlignTool
