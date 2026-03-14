-- Lightweight signal (like BindableEvent but in Lua)
local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({ _connections = {}, _firing = false, _queue = {} }, Signal)
end

function Signal:Connect(fn)
	local conn = { fn = fn, connected = true }
	conn.Disconnect = function() conn.connected = false end
	table.insert(self._connections, conn)
	return conn
end

function Signal:Once(fn)
	local conn
	conn = self:Connect(function(...)
		conn:Disconnect()
		fn(...)
	end)
	return conn
end

function Signal:Fire(...)
	if self._firing then
		table.insert(self._queue, { ... })
		return
	end
	self._firing = true
	local i = 1
	while i <= #self._connections do
		local c = self._connections[i]
		if not c.connected then
			table.remove(self._connections, i)
		else
			pcall(c.fn, ...)
			i = i + 1
		end
	end
	self._firing = false
	if #self._queue > 0 then
		local q = self._queue
		self._queue = {}
		for _, args in ipairs(q) do self:Fire(table.unpack(args)) end
	end
end

function Signal:Destroy()
	self._connections = {}
	self._queue = {}
end

return Signal
