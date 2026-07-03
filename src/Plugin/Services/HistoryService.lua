local ChangeHistoryService = game:GetService("ChangeHistoryService")

local HistoryService = {}
HistoryService.__index = HistoryService

function HistoryService.new()
        return setmetatable({}, HistoryService)
end

function HistoryService:Waypoint(name)
        ChangeHistoryService:SetWaypoint(name)
end

function HistoryService:Undo()
        ChangeHistoryService:Undo()
end

function HistoryService:Redo()
        ChangeHistoryService:Redo()
end

return HistoryService
