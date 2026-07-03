local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({ _handlers = {} }, Signal)
end

function Signal:Connect(fn)
	table.insert(self._handlers, fn)
	local alive = true
	return {
		Disconnect = function()
			if not alive then
				return
			end
			alive = false
			for i, h in ipairs(self._handlers) do
				if h == fn then
					table.remove(self._handlers, i)
					break
				end
			end
		end,
	}
end

function Signal:Fire(...)
	for _, fn in ipairs(self._handlers) do
		task.spawn(fn, ...)
	end
end

return Signal
