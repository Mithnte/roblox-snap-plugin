local Workspace = game:GetService("Workspace")

local RaycastService = {}
RaycastService.__index = RaycastService

function RaycastService.new(ctx)
	local self = setmetatable({}, RaycastService)
	self._ctx = ctx
	return self
end

function RaycastService:RaycastFromScreen(mouse)
	local origin = mouse.Origin.p
	local dir = (mouse.Hit.p - origin).Unit * 10000
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	-- ignore current selection to avoid snapping to itself
	params.FilterDescendantsInstances = self._ctx.selectionStore:Get()
	return Workspace:Raycast(origin, dir, params)
end

return RaycastService
