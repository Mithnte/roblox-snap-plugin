local BaseTool = require(script.Parent.BaseTool)

local MoveTool = setmetatable({}, BaseTool)
MoveTool.__index = MoveTool

local function averagePosition(instances)
	local sum = Vector3.zero
	local n = 0
	for _, inst in ipairs(instances) do
		local ok, cf = pcall(function()
			if inst:IsA("Model") then
				return inst:GetPivot()
			elseif inst:IsA("BasePart") then
				return inst.CFrame
			end
		end)
		if ok and cf then
			sum += cf.Position
			n += 1
		end
	end
	if n == 0 then
		return nil
	end
	return sum / n
end

function MoveTool.new(ctx)
	local self = BaseTool.new(ctx)
	return setmetatable(self, MoveTool)
end

function MoveTool:Activate()
	BaseTool.Activate(self)

	self._mouse = self.ctx.plugin:GetMouse()
	self._dragging = false
	self._dragStartPoint = nil
	self._dragStartAvg = nil
	self._lastAppliedAvg = nil

	self._downConn = self._mouse.Button1Down:Connect(function()
		local selection = self.ctx.selectionStore:Get()
		if #selection == 0 then return end

		self._dragging = true
		self._dragStartPoint = self._mouse.Hit.Position
		self._dragStartAvg = averagePosition(selection)
		self._lastAppliedAvg = self._dragStartAvg

		self.ctx.history:Waypoint("Builder: Move (start)")
	end)

	self._upConn = self._mouse.Button1Up:Connect(function()
		if not self._dragging then return end
		self._dragging = false
		self._dragStartPoint = nil
		self._dragStartAvg = nil
		self._lastAppliedAvg = nil
		self.ctx.history:Waypoint("Builder: Move (end)")
	end)

	self._moveConn = self._mouse.Move:Connect(function()
		if not self._dragging then return end
		local selection = self.ctx.selectionStore:Get()
		if #selection == 0 then return end
		if not self._dragStartAvg then return end

		local currentPoint = self._mouse.Hit.Position
		local delta = currentPoint - self._dragStartPoint

		-- snap by desired average position
		local desiredAvg = self._dragStartAvg + delta
		local snappedAvg = self.ctx.snap:SnapPosition(desiredAvg)
		local appliedDelta = snappedAvg - (self._lastAppliedAvg or self._dragStartAvg)

		if appliedDelta.Magnitude > 0 then
			self.ctx.transform:Translate(selection, appliedDelta)
			self._lastAppliedAvg = (self._lastAppliedAvg or self._dragStartAvg) + appliedDelta
		end
	end)
end

function MoveTool:Deactivate()
	BaseTool.Deactivate(self)

	if self._downConn then self._downConn:Disconnect() end
	if self._upConn then self._upConn:Disconnect() end
	if self._moveConn then self._moveConn:Disconnect() end

	self._downConn = nil
	self._upConn = nil
	self._moveConn = nil
	self._mouse = nil
	self._dragging = false
end

function MoveTool:OnKeyDown(input)
	-- Basic shortcut: M to switch to move
	if input.KeyCode == Enum.KeyCode.M then
		self.ctx.toolController:SetActive("move")
	end
end

return MoveTool
