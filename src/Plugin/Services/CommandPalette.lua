local CommandPalette = {}
CommandPalette.__index = CommandPalette

function CommandPalette.new(ctx)
	local self = setmetatable({}, CommandPalette)
	self._ctx = ctx
	self._commands = {
		{ id = "toggle_grid", label = "Toggle Grid Snap", run = function() ctx.settingsStore:Set({ gridSnapEnabled = not ctx.settingsStore.gridSnapEnabled }) end },
		{ id = "toggle_rotate", label = "Toggle Rotate Snap", run = function() ctx.settingsStore:Set({ rotateSnapEnabled = not ctx.settingsStore.rotateSnapEnabled }) end },
		{ id = "align_center", label = "Align Center to First", run = function() ctx.align:CenterToFirst(ctx.selectionStore:Get()) end },
		{ id = "array_linear", label = "Array Linear (5, step=grid)", run = function() local s=ctx.selectionStore:Get(); if #s>0 then ctx.array:Linear(s,5,Vector3.new(ctx.settingsStore.gridStep,0,0)) end end },
	}
	return self
end

function CommandPalette:Open()
	-- skeleton: run first command for now
	if #self._commands > 0 then self._commands[1].run() end
end

return CommandPalette
