local Animator = _VertexRequire("src/animator.lua")
local Utils = _VertexRequire("src/utils.lua")
local Signal = _VertexRequire("src/signal.lua")

local TabBar = {}
TabBar.__index = TabBar

local TAB_W      = 82
local TAB_H      = 28
local TAB_PAD_V  = 6    -- vertical padding inside the pill background
local PILL_H     = TAB_H + TAB_PAD_V * 2

function TabBar.new(themeManager)
	local self = setmetatable({}, TabBar)
	self.themeManager = themeManager
	return self
end

-- parent should be the tabRow frame from WindowManager
function TabBar:create(tabRow, tabs)
	local theme = self.themeManager:getTheme()
	local bgCorner = Utils.createCorner(17)
	local tabCount = #tabs
	local pillWidth = tabCount * TAB_W + (tabCount - 1) * 4 + 8

	-- Pill background container (centered in tabRow)
	local pill = Instance.new("Frame")
	pill.Name = "TabPill"
	pill.Size = UDim2.new(0, pillWidth, 0, PILL_H)
	pill.AnchorPoint = Vector2.new(0, 0.5)
	pill.Position = UDim2.new(0, 14, 0.5, 0)
	pill.BackgroundColor3 = theme.layer
	pill.BackgroundTransparency = 0.45
	pill.BorderSizePixel = 0
	pill.ZIndex = tabRow.ZIndex + 1
	pill.Parent = tabRow

	local pillCorner = Utils.createCorner(PILL_H / 2)
	pillCorner.Parent = pill

	local pillStroke = Instance.new("UIStroke")
	pillStroke.Thickness = 1
	pillStroke.Color = theme.border
	pillStroke.Transparency = 0.45
	pillStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	pillStroke.Parent = pill

	-- Sliding indicator (sits behind tab labels)
	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.new(0, TAB_W, 0, TAB_H)
	indicator.Position = UDim2.new(0, 4, 0, TAB_PAD_V)
	indicator.BackgroundColor3 = theme.accent
	indicator.BackgroundTransparency = 0.78
	indicator.BorderSizePixel = 0
	indicator.ZIndex = pill.ZIndex + 1
	indicator.Parent = pill

	local indCorner = Utils.createCorner(TAB_H / 2)
	indCorner.Parent = indicator

	-- Accent-colored border on indicator
	local indStroke = Instance.new("UIStroke")
	indStroke.Thickness = 1
	indStroke.Color = theme.accent
	indStroke.Transparency = 0.5
	indStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	indStroke.Parent = indicator

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = pill

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 4)
	padding.PaddingRight = UDim.new(0, 4)
	padding.Parent = pill

	local selectedSignal = Signal.new()
	local buttonRefs = {}
	local currentIndex = 0

	local function selectTab(index)
		if index == currentIndex then return end
		currentIndex = index
		local button = buttonRefs[index]
		if not button then return end

		-- Slide indicator to this tab
		local absPos = button.AbsolutePosition.X - pill.AbsolutePosition.X
		Animator.spring(indicator, "Position", UDim2.new(0, absPos, 0, TAB_PAD_V), {
			damping = 24, stiffness = 320,
		})
		Animator.spring(indicator, "Size", UDim2.new(0, button.AbsoluteSize.X, 0, TAB_H), {
			damping = 24, stiffness = 320,
		})

		-- Update text colors
		for i, btn in ipairs(buttonRefs) do
			local targetColor = (i == index) and theme.text or theme.mutedText
			Animator.spring(btn, "TextColor3", targetColor, { damping = 20, stiffness = 220 })
		end

		selectedSignal:Fire(tabs[index].id or tabs[index].label)
	end

	for i, def in ipairs(tabs) do
		local btn = Instance.new("TextButton")
		btn.Name = "Tab_" .. (def.id or i)
		btn.Size = UDim2.new(0, TAB_W, 0, TAB_H)
		btn.BackgroundTransparency = 1
		btn.AutoButtonColor = false
		btn.Text = def.label
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 13
		btn.TextColor3 = theme.mutedText
		btn.ZIndex = pill.ZIndex + 2
		btn.Parent = pill
		buttonRefs[i] = btn

		btn.MouseButton1Click:Connect(function()
			selectTab(i)
		end)
	end

	-- Select first tab after layout settles
	task.delay(0.05, function()
		selectTab(1)
	end)

	return {
		pill       = pill,
		selected   = selectedSignal,
		selectTab  = selectTab,
	}
end

return TabBar
