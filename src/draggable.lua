local UIS = game:GetService("UserInputService")

local Draggable = {}
Draggable.__index = Draggable

function Draggable.new(target, handle)
	local self  = setmetatable({}, Draggable)
	handle      = handle or target
	local drag  = false
	local offset = Vector2.new()

	local c1 = handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			drag   = true
			local p = i.Position
			offset = Vector2.new(p.X, p.Y)
				- Vector2.new(target.AbsolutePosition.X, target.AbsolutePosition.Y)
		end
	end)

	local c2 = UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			drag = false
		end
	end)

	local c3 = UIS.InputChanged:Connect(function(i)
		if not drag then return end
		if i.UserInputType ~= Enum.UserInputType.MouseMovement
		and i.UserInputType ~= Enum.UserInputType.Touch then return end
		local p      = i.Position
		local desired = Vector2.new(p.X, p.Y) - offset
		local parent  = target.Parent
		local psize   = parent and parent.AbsoluteSize or Vector2.new(9999, 9999)
		local tsize   = target.AbsoluteSize
		target.Position = UDim2.new(0,
			math.clamp(desired.X, 0, math.max(0, psize.X - tsize.X)),
			0,
			math.clamp(desired.Y, 0, math.max(0, psize.Y - tsize.Y))
		)
	end)

	self._connections = {c1, c2, c3}
	return self
end

function Draggable:Destroy()
	for _, c in ipairs(self._connections) do c:Disconnect() end
end

return Draggable
