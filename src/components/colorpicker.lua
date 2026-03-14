local Animator = _VertexRequire("src/animator.lua")
local Utils = _VertexRequire("src/utils.lua")
local Signal = _VertexRequire("src/signal.lua")

local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker.new(themeManager)
	local self = setmetatable({}, ColorPicker)
	self.themeManager = themeManager
	return self
end

function ColorPicker:create(parent, initial)
	local theme = self.themeManager:getTheme()
	local holder = Instance.new("Frame")
	holder.Name = "ColorPicker"
	holder.Size = UDim2.new(0, 190, 0, 70)
	holder.BackgroundTransparency = 1
	holder.ZIndex = parent.ZIndex + 1
	holder.Parent = parent
	local swatch = Instance.new("Frame")
	swatch.Name = "Swatch"
	swatch.Size = UDim2.new(0, 50, 0, 26)
	swatch.Position = UDim2.new(0, 0, 0, 0)
	swatch.BackgroundColor3 = initial or theme.accent
	swatch.BackgroundTransparency = 0.1
	swatch.BorderSizePixel = 0
	swatch.ZIndex = holder.ZIndex + 1
	swatch.Parent = holder
	local swatchCorner = Utils.createCorner(8)
	swatchCorner.Parent = swatch
	local hueStrip = Instance.new("ImageLabel")
	hueStrip.Name = "Hue"
	hueStrip.Size = UDim2.new(1, -60, 0, 16)
	hueStrip.Position = UDim2.new(0, 60, 0, 5)
	hueStrip.BackgroundTransparency = 1
	hueStrip.BorderSizePixel = 0
	hueStrip.ZIndex = holder.ZIndex + 1
	hueStrip.Parent = holder
	local hueGradient = Instance.new("UIGradient")
	hueGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
		ColorSequenceKeypoint.new(0.16, Color3.fromHSV(0.16, 1, 1)),
		ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
		ColorSequenceKeypoint.new(0.66, Color3.fromHSV(0.66, 1, 1)),
		ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
	})
	hueGradient.Parent = hueStrip
	local satVal = Instance.new("Frame")
	satVal.Name = "SV"
	satVal.Size = UDim2.new(1, -10, 0, 30)
	satVal.Position = UDim2.new(0, 5, 0, 34)
	satVal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	satVal.BackgroundTransparency = 0
	satVal.BorderSizePixel = 0
	satVal.ZIndex = holder.ZIndex + 1
	satVal.Parent = holder
	local satCorner = Utils.createCorner(8)
	satCorner.Parent = satVal
	local satGradient = Instance.new("UIGradient")
	satGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0, 0, 0))
	satGradient.Rotation = 90
	satGradient.Parent = satVal
	local valueOverlay = Instance.new("ImageLabel")
	valueOverlay.Name = "Overlay"
	valueOverlay.BackgroundTransparency = 1
	valueOverlay.BorderSizePixel = 0
	valueOverlay.Size = UDim2.new(1, 0, 1, 0)
	valueOverlay.ZIndex = satVal.ZIndex + 1
	valueOverlay.Parent = satVal
	local currentH = 0
	local currentS = 1
	local currentV = 1
	if initial then
		local h, s, v = initial:ToHSV()
		currentH, currentS, currentV = h, s, v
	end
	local changed = Signal.new()
	local function updateSatVal()
		local color = Color3.fromHSV(currentH, 1, 1)
		satGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), color)
	end
	updateSatVal()
	local function emit()
		local c = Color3.fromHSV(currentH, currentS, currentV)
		Animator.spring(swatch, "BackgroundColor3", c, {
			damping = 20,
			stiffness = 220,
		})
		changed:Fire(c)
	end
	emit()
	local draggingHue = false
	local draggingSV = false
	local UserInputService = game:GetService("UserInputService")
	hueStrip.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingHue = true
		end
	end)
	hueStrip.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingHue = false
		end
	end)
	satVal.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSV = true
		end
	end)
	satVal.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSV = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if draggingHue then
			local pos = input.Position.X
			local startX = hueStrip.AbsolutePosition.X
			local width = hueStrip.AbsoluteSize.X
			local alpha = math.clamp((pos - startX) / math.max(width, 1), 0, 1)
			currentH = alpha
			updateSatVal()
			emit()
		end
		if draggingSV then
			local pos = input.Position
			local start = satVal.AbsolutePosition
			local size = satVal.AbsoluteSize
			local sx = math.clamp((pos.X - start.X) / math.max(size.X, 1), 0, 1)
			local vy = math.clamp((pos.Y - start.Y) / math.max(size.Y, 1), 0, 1)
			currentS = sx
			currentV = 1 - vy
			emit()
		end
	end)
	return {
		holder = holder,
		changed = changed,
	}
end

return ColorPicker

