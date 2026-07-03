local Signal = require(script.Parent.Parent.Core.Signal)
local Defaults = require(script.Parent.Parent.Config.Defaults)

local SettingsStore = {}
SettingsStore.__index = SettingsStore

-- Persisted locally per-user via plugin:SetSetting/GetSetting (Roblox Studio's
-- built-in key/value storage for plugins). Not a network database: it lives on
-- the user's machine and survives closing/reopening Studio.
local SETTINGS_KEY = "BuilderToolkit_Settings_v1"

local PERSISTED_KEYS = {
        "gridSnapEnabled", "rotateSnapEnabled", "gridStep", "rotateStepDeg", "pivotMode",
        "surfaceSnapEnabled", "alignToNormalEnabled", "gridStepX", "gridStepY", "gridStepZ",
}

function SettingsStore.new(plugin)
        local self = setmetatable({}, SettingsStore)
        self.changed = Signal.new()
        self._plugin = plugin

        local saved = nil
        if plugin then
                local ok, result = pcall(function() return plugin:GetSetting(SETTINGS_KEY) end)
                if ok and type(result) == "table" then saved = result end
        end
        saved = saved or {}

        self.gridSnapEnabled = saved.gridSnapEnabled
        if self.gridSnapEnabled == nil then self.gridSnapEnabled = Defaults.gridSnapEnabled end

        self.rotateSnapEnabled = saved.rotateSnapEnabled
        if self.rotateSnapEnabled == nil then self.rotateSnapEnabled = Defaults.rotateSnapEnabled end

        self.gridStep = saved.gridStep or Defaults.defaultGridStep
        self.rotateStepDeg = saved.rotateStepDeg or Defaults.defaultRotateStepDeg
        self.pivotMode = saved.pivotMode or Defaults.pivotMode

        self.surfaceSnapEnabled = saved.surfaceSnapEnabled
        if self.surfaceSnapEnabled == nil then self.surfaceSnapEnabled = false end

        self.alignToNormalEnabled = saved.alignToNormalEnabled
        if self.alignToNormalEnabled == nil then self.alignToNormalEnabled = false end

        -- Per-axis grid (optional override). If nil, fall back to gridStep
        self.gridStepX = saved.gridStepX
        self.gridStepY = saved.gridStepY
        self.gridStepZ = saved.gridStepZ

        return self
end

function SettingsStore:_Save()
        if not self._plugin then return end
        local snapshot = {}
        for _, k in ipairs(PERSISTED_KEYS) do
                snapshot[k] = self[k]
        end
        pcall(function() self._plugin:SetSetting(SETTINGS_KEY, snapshot) end)
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

return SettingsStore
