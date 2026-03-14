local RunService = game:GetService("RunService")

local Utils = _VertexRequire("src/utils.lua")
local Animator = _VertexRequire("src/animator.lua")

local Draggable = {}
Draggable.__index = Draggable

function Draggable.new(target, dragHandle)
	local self = setmetatable({}, Draggable)
	self.target = target
	self.handle = dragHandle or target
	self.dragging = false
	self.offset = Vector2.new()
	self.goal = target.Position
	self.connectionInputBegan = nil
	self.connectionInputEnded = nil
	self.connectionChanged = nil
	self:updateInputConnections()
	return self
end

function Draggable:updateInputConnections()
	if self.connectionInputBegan then
		self.connectionInputBegan:Disconnect()
	end
	if self.connectionInputEnded then
		self.connectionInputEnded:Disconnect()
	end
	if self.connectionChanged then
		self.connectionChanged:Disconnect()
	end
	local UserInputService = game:GetService("UserInputService")
	self.connectionInputBegan = self.handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.dragging = true
			local pos = input.Position
			self.offset = Vector2.new(pos.X, pos.Y) - Vector2.new(self.target.AbsolutePosition.X, self.target.AbsolutePosition.Y)
		end
	end)
	self.connectionInputEnded = self.handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.dragging = false
		end
	end)
	self.connectionChanged = UserInputService.InputChanged:Connect(function(input)
		if not self.dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local pos = input.Position
			local desired = Vector2.new(pos.X, pos.Y) - self.offset
			local parentSize = self.target.Parent and self.target.Parent.AbsoluteSize or Vector2.new(0, 0)
			local size = self.target.AbsoluteSize
			local clamped = Vector2.new(
				math.clamp(desired.X, 0, math.max(0, parentSize.X - size.X)),
				math.clamp(desired.Y, 0, math.max(0, parentSize.Y - size.Y))
			)
			self.goal = UDim2.new(0, clamped.X, 0, clamped.Y)
			Animator.spring(self.target, "Position", self.goal, {
				damping = 22,
				stiffness = 260,
			})
		end
	end)
end

function Draggable:Destroy()
	if self.connectionInputBegan then
		self.connectionInputBegan:Disconnect()
	end
	if self.connectionInputEnded then
		self.connectionInputEnded:Disconnect()
	end
	if self.connectionChanged then
		self.connectionChanged:Disconnect()
	end
end

return Draggable
