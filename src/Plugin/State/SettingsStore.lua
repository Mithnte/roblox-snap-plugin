local Signal = require(script.Parent.Parent.Core.Signal)
local Defaults = require(script.Parent.Parent.Config.Defaults)

local SettingsStore = {}
SettingsStore.__index = SettingsStore

-- Persisted locally per-user via plugin:SetSetting/GetSetting (Roblox Studio's
-- built-in key/value storage for plugins). Not a network database: it lives on
-- the user's machine and survives closing/reopening Studio.
local SETTINGS_KEY = "BuilderToolkit_Settings_v1"

local PERSISTED_KEYS = {
	"gridSnapEnabled",
	"rotateSnapEnabled",
	"gridStep",
	"rotateStepDeg",
	"pivotMode",
	"surfaceSnapEnabled",
	"alignToNormalEnabled",
	"gridStepX",
	"gridStepY",
	"gridStepZ",
	"vertexSnapEnabled",
	"vertexSnapThreshold",
	"edgeSnapThreshold",
	"keymap",
	"blueprints",
	"hasSeenOnboarding",
}

function SettingsStore.new(plugin)
	local self = setmetatable({}, SettingsStore)
	self.changed = Signal.new()
	self._plugin = plugin

	local saved = nil
	if plugin then
		local ok, result = pcall(function()
			return plugin:GetSetting(SETTINGS_KEY)
		end)
		if ok and type(result) == "table" then
			saved = result
		end
	end
	saved = saved or {}

	self.gridSnapEnabled = saved.gridSnapEnabled
	if self.gridSnapEnabled == nil then
		self.gridSnapEnabled = Defaults.gridSnapEnabled
	end

	self.rotateSnapEnabled = saved.rotateSnapEnabled
	if self.rotateSnapEnabled == nil then
		self.rotateSnapEnabled = Defaults.rotateSnapEnabled
	end

	self.gridStep = saved.gridStep or Defaults.defaultGridStep
	self.rotateStepDeg = saved.rotateStepDeg or Defaults.defaultRotateStepDeg
	self.pivotMode = saved.pivotMode or Defaults.pivotMode

	self.surfaceSnapEnabled = saved.surfaceSnapEnabled
	if self.surfaceSnapEnabled == nil then
		self.surfaceSnapEnabled = false
	end

	self.alignToNormalEnabled = saved.alignToNormalEnabled
	if self.alignToNormalEnabled == nil then
		self.alignToNormalEnabled = false
	end

	-- Per-axis grid (optional override). If nil, fall back to gridStep
	self.gridStepX = saved.gridStepX
	self.gridStepY = saved.gridStepY
	self.gridStepZ = saved.gridStepZ

	self.vertexSnapEnabled = saved.vertexSnapEnabled
	if self.vertexSnapEnabled == nil then
		self.vertexSnapEnabled = Defaults.vertexSnapEnabled
	end
	self.vertexSnapThreshold = saved.vertexSnapThreshold or Defaults.vertexSnapThreshold
	self.edgeSnapThreshold = saved.edgeSnapThreshold or Defaults.edgeSnapThreshold

	self.keymap = {}
	for action, keyName in pairs(Defaults.keymap) do
		self.keymap[action] = keyName
	end
	if type(saved.keymap) == "table" then
		for action, keyName in pairs(saved.keymap) do
			self.keymap[action] = keyName
		end
	end

	self.blueprints = type(saved.blueprints) == "table" and saved.blueprints or {}
	self.hasSeenOnboarding = saved.hasSeenOnboarding == true

	return self
end

-- Resolves a rebindable action name to its live Enum.KeyCode, falling back to
-- the shipped default if the saved keymap has a stale/unknown entry.
function SettingsStore:GetKey(action)
	local name = self.keymap and self.keymap[action] or Defaults.keymap[action]
	local keyCode = name and Enum.KeyCode[name]
	return keyCode or Enum.KeyCode[Defaults.keymap[action]]
end

function SettingsStore:SetBinding(action, keyCodeName)
	if not Defaults.keymap[action] then
		return
	end
	self.keymap[action] = keyCodeName
	self:_Save()
	self.changed:Fire(self)
end

function SettingsStore:SaveBlueprint(name, data)
	self.blueprints[name] = data
	self:_Save()
	self.changed:Fire(self)
end

function SettingsStore:DeleteBlueprint(name)
	self.blueprints[name] = nil
	self:_Save()
	self.changed:Fire(self)
end

function SettingsStore:_Save()
	if not self._plugin then
		return
	end
	local snapshot = {}
	for _, k in ipairs(PERSISTED_KEYS) do
		snapshot[k] = self[k]
	end
	pcall(function()
		self._plugin:SetSetting(SETTINGS_KEY, snapshot)
	end)
end

function SettingsStore:Set(patch)
	for k, v in pairs(patch) do
		if self[k] ~= v then
			self[k] = v
		end
	end
	self:_Save()
	self.changed:Fire(self)
end

-- Restores every tunable back to the shipped defaults. Saved blueprints and the
-- onboarding flag are intentionally preserved so a "reset" never destroys the
-- user's saved presets.
function SettingsStore:ResetToDefaults()
	self.gridSnapEnabled = Defaults.gridSnapEnabled
	self.rotateSnapEnabled = Defaults.rotateSnapEnabled
	self.gridStep = Defaults.defaultGridStep
	self.rotateStepDeg = Defaults.defaultRotateStepDeg
	self.pivotMode = Defaults.pivotMode
	self.surfaceSnapEnabled = false
	self.alignToNormalEnabled = false
	self.gridStepX = nil
	self.gridStepY = nil
	self.gridStepZ = nil
	self.vertexSnapEnabled = Defaults.vertexSnapEnabled
	self.vertexSnapThreshold = Defaults.vertexSnapThreshold
	self.edgeSnapThreshold = Defaults.edgeSnapThreshold
	self.keymap = {}
	for action, keyName in pairs(Defaults.keymap) do
		self.keymap[action] = keyName
	end
	self:_Save()
	self.changed:Fire(self)
end

return SettingsStore
