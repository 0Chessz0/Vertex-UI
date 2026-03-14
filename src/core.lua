local Utils = _VertexRequire("src/utils.lua")
local Animator = _VertexRequire("src/animator.lua")
local Signal = _VertexRequire("src/signal.lua")

local Core = {}
Core.__index = Core

function Core.new(themeManager, effects)
	local self = setmetatable({}, Core)
	self.themeManager = themeManager
	self.effects = effects
	return self
end

function Core:createTextLabel(props)
	local theme = self.themeManager:getTheme()
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = props.TextSize or 14
	label.TextColor3 = props.TextColor3 or theme.text
	label.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	label.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	label.RichText = true
	label.Text = props.Text or ""
	label.Name = props.Name or "Label"
	label.ZIndex = props.ZIndex or 1
	label.Size = props.Size or UDim2.new(0, 100, 0, 24)
	label.Position = props.Position or UDim2.new()
	label.Parent = props.Parent
	return label
end

function Core:createButton(props)
	local theme = self.themeManager:getTheme()
	local button = Instance.new("TextButton")
	button.Name = props.Name or "Button"
	button.Size = props.Size or UDim2.new(0, 120, 0, 32)
	button.Position = props.Position or UDim2.new()
	button.AutoButtonColor = false
	button.BackgroundColor3 = theme.layer
	button.BackgroundTransparency = 0.3
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 14
	button.TextColor3 = theme.text
	button.Text = props.Text or "Button"
	button.ZIndex = props.ZIndex or 1
	button.Parent = props.Parent
	local corner = Utils.createCorner(12)
	corner.Parent = button
	local stroke = Utils.createStroke(1, theme.border, 0.4)
	stroke.Parent = button
	local signal = Signal.new()
	button.MouseButton1Click:Connect(function()
		signal:Fire()
	end)
	if props.Accent then
		self.effects:applyAccentStroke(button)
	end
	button.MouseEnter:Connect(function()
		Animator.spring(button, "BackgroundTransparency", 0.15, {
			damping = 18,
			stiffness = 200,
		})
	end)
	button.MouseLeave:Connect(function()
		Animator.spring(button, "BackgroundTransparency", 0.3, {
			damping = 18,
			stiffness = 200,
		})
	end)
	return {
		instance = button,
		activated = signal,
	}
end

function Core:createTextbox(props)
	local theme = self.themeManager:getTheme()
	local box = Instance.new("TextBox")
	box.Name = props.Name or "Textbox"
	box.Size = props.Size or UDim2.new(0, 160, 0, 30)
	box.Position = props.Position or UDim2.new()
	box.ClearTextOnFocus = props.ClearTextOnFocus or false
	box.PlaceholderText = props.PlaceholderText or ""
	box.Text = props.Text or ""
	box.BackgroundColor3 = theme.layer
	box.BackgroundTransparency = 0.4
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	box.TextColor3 = theme.text
	box.PlaceholderColor3 = theme.mutedText
	box.ZIndex = props.ZIndex or 1
	box.Parent = props.Parent
	local corner = Utils.createCorner(10)
	corner.Parent = box
	local stroke = Utils.createStroke(1, theme.border, 0.4)
	stroke.Parent = box
	local changed = Signal.new()
	box.FocusLost:Connect(function(enter)
		changed:Fire(box.Text, enter)
	end)
	return {
		instance = box,
		changed = changed,
	}
end

function Core:createSlider(props)
	local theme = self.themeManager:getTheme()
	local min = props.Min or 0
	local max = props.Max or 1
	local value = props.Value or min
	local frame = Instance.new("Frame")
	frame.Name = props.Name or "Slider"
	frame.Size = props.Size or UDim2.new(0, 180, 0, 28)
	frame.Position = props.Position or UDim2.new()
	frame.BackgroundTransparency = 1
	frame.ZIndex = props.ZIndex or 1
	frame.Parent = props.Parent
	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.BackgroundColor3 = theme.layer
	bar.BackgroundTransparency = 0.4
	bar.BorderSizePixel = 0
	bar.AnchorPoint = Vector2.new(0.5, 0.5)
	bar.Position = UDim2.new(0.5, 0, 0.5, 0)
	bar.Size = UDim2.new(1, -16, 0, 6)
	bar.ZIndex = frame.ZIndex
	bar.Parent = frame
	local barCorner = Utils.createCorner(3)
	barCorner.Parent = bar
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = theme.accent
	fill.BackgroundTransparency = 0.1
	fill.BorderSizePixel = 0
	fill.AnchorPoint = Vector2.new(0, 0.5)
	fill.Position = UDim2.new(0, 0, 0.5, 0)
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.ZIndex = frame.ZIndex + 1
	fill.Parent = bar
	local fillCorner = Utils.createCorner(3)
	fillCorner.Parent = fill
	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	knob.BackgroundColor3 = theme.layer
	knob.BackgroundTransparency = 0.2
	knob.BorderSizePixel = 0
	knob.ZIndex = frame.ZIndex + 2
	knob.Parent = frame
	local knobCorner = Utils.createCorner(8)
	knobCorner.Parent = knob
	local knobStroke = Utils.createStroke(1.2, theme.border, 0.2)
	knobStroke.Parent = knob
	local changed = Signal.new()
	local function setValue(newValue)
		value = math.clamp(newValue, min, max)
		local alpha = (value - min) / (max - min)
		Animator.spring(fill, "Size", UDim2.new(alpha, 0, 1, 0), {
			damping = 20,
			stiffness = 230,
		})
		local barAbs = bar.AbsoluteSize.X
		if barAbs > 0 then
			local x = bar.AbsolutePosition.X + barAbs * alpha
			local localX = x - frame.AbsolutePosition.X
			Animator.spring(knob, "Position", UDim2.new(0, localX, 0.5, 0), {
				damping = 20,
				stiffness = 230,
			})
		end
		changed:Fire(value)
	end
	setValue(value)
	local dragging = false
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local pos = input.Position.X
			local startX = bar.AbsolutePosition.X
			local width = bar.AbsoluteSize.X
			local alpha = math.clamp((pos - startX) / math.max(width, 1), 0, 1)
			setValue(min + (max - min) * alpha)
		end
	end)
	return {
		instance = frame,
		changed = changed,
		setValue = setValue,
	}
end

return Core
