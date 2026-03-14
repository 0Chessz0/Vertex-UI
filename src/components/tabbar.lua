local Animator = _VertexRequire("src/animator.lua")
local Utils = _VertexRequire("src/utils.lua")
local Signal = _VertexRequire("src/signal.lua")

local TabBar = {}
TabBar.__index = TabBar

function TabBar.new(themeManager)
	local self = setmetatable({}, TabBar)
	self.themeManager = themeManager
	return self
end

function TabBar:create(parent, tabs)
	local theme = self.themeManager:getTheme()
	local holder = Instance.new("Frame")
	holder.Name = "TabBar"
	holder.Size = UDim2.new(1, -24, 0, 34)
	holder.BackgroundTransparency = 1
	holder.Position = UDim2.new(0, 12, 0, 0)
	holder.ZIndex = parent.ZIndex + 1
	holder.Parent = parent
	local background = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.new(0, 220, 1, 0)
	background.Position = UDim2.new(0, 0, 0, 0)
	background.BackgroundColor3 = theme.layer
	background.BackgroundTransparency = 0.5
	background.BorderSizePixel = 0
	background.ZIndex = holder.ZIndex + 1
	background.Parent = holder
	local bgCorner = Utils.createCorner(17)
	bgCorner.Parent = background
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = background
	local slider = Instance.new("Frame")
	slider.Name = "Slider"
	slider.Size = UDim2.new(0, 0, 1, -6)
	slider.Position = UDim2.new(0, 0, 0, 3)
	slider.BackgroundColor3 = theme.accent
	slider.BackgroundTransparency = 0.1
	slider.BorderSizePixel = 0
	slider.ZIndex = background.ZIndex + 1
	slider.Parent = background
	local sliderCorner = Utils.createCorner(16)
	sliderCorner.Parent = slider
	local selectedSignal = Signal.new()
	local buttonRefs = {}
	local function selectTab(index)
		local button = buttonRefs[index]
		if not button then
			return
		end
		local absSize = button.AbsoluteSize.X
		local absPos = button.AbsolutePosition.X - background.AbsolutePosition.X
		Animator.spring(slider, "Size", UDim2.new(0, absSize, 1, -6), {
			damping = 22,
			stiffness = 260,
		})
		Animator.spring(slider, "Position", UDim2.new(0, absPos, 0, 3), {
			damping = 22,
			stiffness = 260,
		})
		selectedSignal:Fire(tabs[index].id or tabs[index].label)
	end
	for index, def in ipairs(tabs) do
		local button = Instance.new("TextButton")
		button.Name = "Tab"
		button.Size = UDim2.new(0, 70, 1, -6)
		button.BackgroundTransparency = 1
		button.AutoButtonColor = false
		button.Text = def.label
		button.Font = Enum.Font.Gotham
		button.TextSize = 14
		button.TextColor3 = theme.text
		button.ZIndex = background.ZIndex + 2
		button.Parent = background
		buttonRefs[index] = button
		button.MouseButton1Click:Connect(function()
			selectTab(index)
		end)
	end
	task.delay(0.05, function()
		selectTab(1)
	end)
	return {
		holder = holder,
		selected = selectedSignal,
		selectTab = selectTab,
	}
end

return TabBar

