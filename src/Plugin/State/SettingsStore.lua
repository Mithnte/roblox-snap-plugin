local Signal = require(script.Parent.Parent.Core.Signal)
local Defaults = require(script.Parent.Parent.Config.Defaults)

local SettingsStore = {}
SettingsStore.__index = SettingsStore

function SettingsStore.new()
	local self = setmetatable({}, SettingsStore)
	self.changed = Signal.new()

	self.gridSnapEnabled = Defaults.gridSnapEnabled
	self.rotateSnapEnabled = Defaults.rotateSnapEnabled
	self.gridStep = Defaults.defaultGridStep
	self.rotateStepDeg = Defaults.defaultRotateStepDeg
	self.pivotMode = Defaults.pivotMode

	self.surfaceSnapEnabled = false
	self.alignToNormalEnabled = false

	-- Per-axis grid (optional override). If nil, fall back to gridStep
	self.gridStepX = nil
	self.gridStepY = nil
	self.gridStepZ = nil

	return self
end

function SettingsStore:Set(patch)
	for k, v in pairs(patch) do
		if self[k] ~= v then
			self[k] = v
		end
	end
	self.changed:Fire(self)
end

return SettingsStore
