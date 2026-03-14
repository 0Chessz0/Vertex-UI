local Animator = _VertexRequire("src/animator.lua")
local Utils = _VertexRequire("src/utils.lua")

local Notification = {}
Notification.__index = Notification

function Notification.new(themeManager, effects, uiRoot)
	local self = setmetatable({}, Notification)
	self.themeManager = themeManager
	self.effects = effects
	self.uiRoot = uiRoot
	self.container = Instance.new("Frame")
	self.container.Name = "VertexNotifications"
	self.container.AnchorPoint = Vector2.new(1, 1)
	self.container.Position = UDim2.new(1, -24, 1, -24)
	self.container.Size = UDim2.new(0, 320, 1, -48)
	self.container.BackgroundTransparency = 1
	self.container.ZIndex = 200
	self.container.Parent = uiRoot
	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Vertical
	list.VerticalAlignment = Enum.VerticalAlignment.Bottom
	list.Padding = UDim.new(0, 8)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = self.container
	return self
end

function Notification:push(message, duration)
	local theme = self.themeManager:getTheme()
	local toast = Instance.new("Frame")
	toast.Name = "Toast"
	toast.BackgroundColor3 = theme.layer
	toast.BackgroundTransparency = 0.9
	toast.Size = UDim2.new(1, 0, 0, 40)
	toast.BorderSizePixel = 0
	toast.ZIndex = self.container.ZIndex + 1
	toast.Parent = self.container
	self.effects:applyGlass(toast, theme.name == "Light")
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = message
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextColor3 = theme.text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Size = UDim2.new(1, -28, 1, 0)
	label.Position = UDim2.new(0, 14, 0, 0)
	label.ZIndex = toast.ZIndex + 1
	label.Parent = toast
	local startPos = UDim2.new(1, 20, 1, 0)
	local endPos = UDim2.new(1, 0, 1, 0)
	toast.Position = startPos
	Animator.spring(toast, "Position", endPos, {
		damping = 22,
		stiffness = 260,
	})
	task.delay(duration or 3, function()
		if not toast.Parent then
			return
		end
		Animator.spring(toast, "Position", UDim2.new(1, 40, 1, 0), {
			damping = 22,
			stiffness = 260,
		})
		task.delay(0.3, function()
			if toast.Parent then
				toast:Destroy()
			end
		end)
	end)
end

return Notification

