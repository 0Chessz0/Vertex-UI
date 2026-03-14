local Animator = _VertexRequire("src/animator.lua")
local Utils = _VertexRequire("src/utils.lua")
local Signal = _VertexRequire("src/signal.lua")

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(themeManager, core)
	local self = setmetatable({}, Dropdown)
	self.themeManager = themeManager
	self.core = core
	return self
end

function Dropdown:create(parent, items, defaultText)
	local theme = self.themeManager:getTheme()
	local holder = Instance.new("Frame")
	holder.Name = "Dropdown"
	holder.Size = UDim2.new(0, 180, 0, 30)
	holder.BackgroundTransparency = 1
	holder.ZIndex = parent.ZIndex + 1
	holder.Parent = parent
	local button = Instance.new("TextButton")
	button.Name = "Button"
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundColor3 = theme.layer
	button.BackgroundTransparency = 0.4
	button.AutoButtonColor = false
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.TextColor3 = theme.text
	button.Text = defaultText or (items[1] or "")
	button.ZIndex = holder.ZIndex + 1
	button.Parent = holder
	local corner = Utils.createCorner(10)
	corner.Parent = button
	local stroke = Utils.createStroke(1, theme.border, 0.4)
	stroke.Parent = button
	local arrow = Instance.new("TextLabel")
	arrow.BackgroundTransparency = 1
	arrow.Size = UDim2.new(0, 24, 1, 0)
	arrow.Position = UDim2.new(1, -24, 0, 0)
	arrow.Font = Enum.Font.Gotham
	arrow.TextSize = 18
	arrow.Text = "⌄"
	arrow.TextColor3 = theme.mutedText
	arrow.ZIndex = button.ZIndex + 1
	arrow.Parent = button
	local listFrame = Instance.new("Frame")
	listFrame.Name = "List"
	listFrame.Size = UDim2.new(1, 0, 0, 0)
	listFrame.Position = UDim2.new(0, 0, 1, 4)
	listFrame.BackgroundColor3 = theme.layer
	listFrame.BackgroundTransparency = 0.4
	listFrame.BorderSizePixel = 0
	listFrame.ClipsDescendants = true
	listFrame.ZIndex = button.ZIndex + 10
	listFrame.Parent = holder
	local listCorner = Utils.createCorner(10)
	listCorner.Parent = listFrame
	local listStroke = Utils.createStroke(1, theme.border, 0.4)
	listStroke.Parent = listFrame
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.Padding = UDim.new(0, 2)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = listFrame
	local selectedSignal = Signal.new()
	local itemHeight = 26
	for _, text in ipairs(items) do
		local item = Instance.new("TextButton")
		item.Name = "Item"
		item.AutoButtonColor = false
		item.Size = UDim2.new(1, -8, 0, itemHeight)
		item.Position = UDim2.new(0, 4, 0, 0)
		item.BackgroundColor3 = theme.layer
		item.BackgroundTransparency = 1
		item.Text = text
		item.Font = Enum.Font.Gotham
		item.TextSize = 14
		item.TextColor3 = theme.text
		item.ZIndex = listFrame.ZIndex + 1
		item.Parent = listFrame
		item.MouseButton1Click:Connect(function()
			button.Text = text
			selectedSignal:Fire(text)
			Animator.spring(listFrame, "Size", UDim2.new(1, 0, 0, 0), {
				damping = 22,
				stiffness = 260,
			})
		end)
	end
	local open = false
	button.MouseButton1Click:Connect(function()
		open = not open
		local targetHeight = open and (#items * (itemHeight + 2) + 8) or 0
		Animator.spring(listFrame, "Size", UDim2.new(1, 0, 0, targetHeight), {
			damping = 22,
			stiffness = 260,
		})
		Animator.spring(button, "BackgroundTransparency", open and 0.25 or 0.4, {
			damping = 22,
			stiffness = 260,
		})
	end)
	return {
		holder = holder,
		selected = selectedSignal,
	}
end

return Dropdown

