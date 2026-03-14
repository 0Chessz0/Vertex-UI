local Signal = {}
Signal.__index = Signal

function Signal.new()
	local self = setmetatable({}, Signal)
	self._bindings = {}
	self._once = {}
	self._firing = false
	self._queue = {}
	return self
end

function Signal:Connect(fn)
	local binding = {
		_connected = true,
		_fn = fn,
	}
	function binding:Disconnect()
		self._connected = false
	end
	table.insert(self._bindings, binding)
	return binding
end

function Signal:Once(fn)
	local connection = self:Connect(fn)
	self._once[connection] = true
	return connection
end

function Signal:Wait()
	local thread = coroutine.running()
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread, ...)
	end)
	return coroutine.yield()
end

function Signal:Fire(...)
	if self._firing then
		table.insert(self._queue, table.pack(...))
		return
	end
	self._firing = true
	local index = 1
	while index <= #self._bindings do
		local binding = self._bindings[index]
		if not binding._connected then
			table.remove(self._bindings, index)
		else
			local ok, err = pcall(binding._fn, ...)
			if not ok then
				warn(err)
			end
			if self._once[binding] then
				self._once[binding] = nil
				binding._connected = false
			else
				index = index + 1
			end
		end
	end
	self._firing = false
	if #self._queue > 0 then
		local queued = self._queue
		self._queue = {}
		for _, payload in ipairs(queued) do
			self:Fire(table.unpack(payload, 1, payload.n))
		end
	end
end

function Signal:Destroy()
	self._bindings = {}
	self._once = {}
	self._queue = {}
end

return Signal

