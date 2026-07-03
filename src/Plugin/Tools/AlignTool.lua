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
	if side then
		local sel = self.ctx.selectionStore:Get()
		if #sel < 2 then
			return
		end
		self.ctx.history:Waypoint("Builder: Align " .. side .. " (start)")
		self.ctx.align:AlignToFirst(sel, side)
		self.ctx.history:Waypoint("Builder: Align " .. side .. " (end)")
		return
	end
	if input.KeyCode == Enum.KeyCode.C then
		local sel = self.ctx.selectionStore:Get()
		if #sel < 2 then
			return
		end
		self.ctx.history:Waypoint("Builder: Align Center (start)")
		self.ctx.align:CenterToFirst(sel)
		self.ctx.history:Waypoint("Builder: Align Center (end)")
	elseif input.KeyCode == Enum.KeyCode.T then
		local sel = self.ctx.selectionStore:Get()
		if #sel < 2 then
			return
		end
		self.ctx.history:Waypoint("Builder: Match Rotation (start)")
		self.ctx.align:MatchRotation(sel)
		self.ctx.history:Waypoint("Builder: Match Rotation (end)")
	elseif input.KeyCode == Enum.KeyCode.S then
		local sel = self.ctx.selectionStore:Get()
		if #sel < 2 then
			return
		end
		self.ctx.history:Waypoint("Builder: Match Size (start)")
		self.ctx.align:MatchSize(sel)
		self.ctx.history:Waypoint("Builder: Match Size (end)")
	end
end

return AlignTool
