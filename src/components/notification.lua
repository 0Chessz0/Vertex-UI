local Animator = _VertexRequire("src/animator.lua")
local Utils    = _VertexRequire("src/utils.lua")

local Notification = {}
Notification.__index = Notification

function Notification.new(theme, effects, uiRoot)
	local self   = setmetatable({}, Notification)
	self.theme   = theme
	self.effects = effects

	-- Fixed stack container at bottom-right
	local container = Instance.new("Frame")
	container.Name  = "Notifications"
	container.Size  = UDim2.new(0, 300, 1, -32)
	container.AnchorPoint = Vector2.new(1, 1)
	container.Position    = UDim2.new(1, -16, 1, -16)
	container.BackgroundTransparency = 1
	container.ZIndex  = 950
	container.Parent  = uiRoot

	local list = Utils.listLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom, 8)
	list.Parent = container

	self.container = container
	return self
end

function Notification:push(message, duration)
	local t = self.theme:get()

	local toast = Instance.new("Frame")
	toast.Name  = "Toast"
	toast.Size  = UDim2.new(1, 0, 0, 44)
	toast.BackgroundColor3 = t.surface
	toast.BackgroundTransparency = 0.18
	toast.BorderSizePixel = 0
	toast.ZIndex = self.container.ZIndex + 1
	Utils.corner(10).Parent  = toast
	Utils.stroke(1, t.border, 0.40).Parent = toast

	-- Accent left bar
	local bar = Instance.new("Frame")
	bar.Size   = UDim2.new(0, 3, 1, -12)
	bar.Position = UDim2.new(0, 0, 0.5, 0)
	bar.AnchorPoint = Vector2.new(0, 0.5)
	bar.BackgroundColor3 = t.accent
	bar.BackgroundTransparency = 0
	bar.BorderSizePixel = 0
	bar.ZIndex = toast.ZIndex + 1
	bar.Parent = toast
	Utils.corner(2).Parent = bar

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size     = UDim2.new(1, -24, 1, 0)
	lbl.Position = UDim2.new(0, 14, 0, 0)
	lbl.Font     = Enum.Font.Gotham
	lbl.TextSize = 13
	lbl.TextColor3 = t.text
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextWrapped = true
	lbl.ZIndex   = toast.ZIndex + 1
	lbl.Text     = message
	lbl.Parent   = toast

	-- Slide in via transparency (UIListLayout controls position)
	toast.BackgroundTransparency = 1
	bar.BackgroundTransparency   = 1
	lbl.TextTransparency         = 1
	toast.Parent = self.container
	Animator.spring(toast, "BackgroundTransparency", 0.18, {stiffness=280, damping=26})
	Animator.spring(lbl,   "TextTransparency",       0,    {stiffness=280, damping=26})
	Animator.spring(bar,   "BackgroundTransparency", 0,    {stiffness=280, damping=26})

	-- Auto-dismiss
	task.delay(duration or 3.5, function()
		if not toast or not toast.Parent then return end
		Animator.spring(toast, "BackgroundTransparency", 1, {stiffness=260, damping=22})
		Animator.spring(lbl,   "TextTransparency",       1, {stiffness=260, damping=22})
		task.delay(0.35, function()
			if toast and toast.Parent then toast:Destroy() end
		end)
	end)
end

return Notification
