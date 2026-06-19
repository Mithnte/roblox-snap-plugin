local Selection = game:GetService("Selection")
local Signal = require(script.Parent.Parent.Core.Signal)

local SelectionStore = {}
SelectionStore.__index = SelectionStore

local function copySelection()
	return Selection:Get()
end

function SelectionStore.new()
	local self = setmetatable({}, SelectionStore)
	self.changed = Signal.new()
	self.items = copySelection()

	Selection.SelectionChanged:Connect(function()
		self.items = copySelection()
		self.changed:Fire(self.items)
	end)

	return self
end

function SelectionStore:Get()
	return self.items
end

return SelectionStore
