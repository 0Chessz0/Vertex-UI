local Animator = _VertexRequire("src/animator.lua")
local Utils    = _VertexRequire("src/utils.lua")
local Signal   = _VertexRequire("src/signal.lua")
local UIS      = game:GetService("UserInputService")

local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker.new(theme)
	return setmetatable({ theme = theme }, ColorPicker)
end

function ColorPicker:create(parent, initial)
	local t    = self.theme:get()
	local h, s, v = 0, 1, 1
	if initial then h, s, v = initial:ToHSV() end
	local sig  = Signal.new()

	local holder = Instance.new("Frame")
	holder.Name  = "ColorPicker"
	holder.Size  = UDim2.new(0, 220, 0, 80)
	holder.BackgroundTransparency = 1
	holder.ZIndex = parent.ZIndex + 1
	holder.Parent = parent

	-- Swatch
	local swatch = Instance.new("Frame")
	swatch.Name  = "Swatch"
	swatch.Size  = UDim2.new(0, 40, 0, 28)
	swatch.Position = UDim2.new(0, 0, 0, 0)
	swatch.BackgroundColor3 = initial or t.accent
	swatch.BorderSizePixel = 0
	swatch.ZIndex = holder.ZIndex + 1
	swatch.Parent = holder
	Utils.corner(7).Parent = swatch
	Utils.stroke(1, t.border, 0.4).Parent = swatch

	-- Hue strip
	local hueW = 220 - 50
	local hueStrip = Instance.new("Frame")
	hueStrip.Name  = "Hue"
	hueStrip.Size  = UDim2.new(0, hueW, 0, 14)
	hueStrip.Position = UDim2.new(0, 50, 0, 7)
	hueStrip.BackgroundTransparency = 1
	hueStrip.BorderSizePixel = 0
	hueStrip.ZIndex = holder.ZIndex + 1
	hueStrip.Parent = holder
	Utils.corner(7).Parent = hueStrip

	local hueGrad = Instance.new("UIGradient")
	hueGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,    1, 1)),
		ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
		ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
		ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1)),
		ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
		ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
		ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,    1, 1)),
	})
	hueGrad.Parent = hueStrip

	-- Need a backing ImageLabel so the gradient shows (Frame gradient needs BackgroundColor)
	local hueBg = Instance.new("ImageLabel")
	hueBg.Size  = UDim2.new(1, 0, 1, 0)
	hueBg.BackgroundTransparency = 1
	hueBg.Image = ""
	hueBg.ZIndex = hueStrip.ZIndex
	hueBg.Parent = hueStrip

	-- SV box
	local svBox = Instance.new("Frame")
	svBox.Name  = "SV"
	svBox.Size  = UDim2.new(1, 0, 0, 40)
	svBox.Position = UDim2.new(0, 0, 0, 34)
	svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
	svBox.BorderSizePixel  = 0
	svBox.ZIndex = holder.ZIndex + 1
	svBox.Parent = holder
	Utils.corner(7).Parent = svBox
	Utils.stroke(1, t.border, 0.45).Parent = svBox

	-- White left→right gradient + black top→bottom overlay
	local wGrad = Instance.new("UIGradient")
	wGrad.Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.new(0,0,0))
	wGrad.Transparency = NumberSequence.new(NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1))
	wGrad.Rotation = 0
	wGrad.Parent   = svBox

	local bGrad = Instance.new("UIGradient")
	bGrad.Color = ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(0,0,0))
	bGrad.Transparency = NumberSequence.new(NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0))
	bGrad.Rotation = 90

	local bOverlay = Instance.new("Frame")
	bOverlay.Size  = UDim2.new(1,0,1,0)
	bOverlay.BackgroundTransparency = 0
	bOverlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
	bOverlay.BorderSizePixel = 0
	bOverlay.ZIndex = svBox.ZIndex + 1
	bOverlay.Parent = svBox
	Utils.corner(7).Parent = bOverlay
	bGrad.Parent = bOverlay

	local function emit()
		local c = Color3.fromHSV(h, s, v)
		Animator.spring(swatch, "BackgroundColor3", c, {stiffness=280, damping=24})
		svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		sig:Fire(c)
	end
	emit()

	local dragHue = false
	local dragSV  = false

	hueStrip.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then dragHue = true end
	end)
	svBox.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then dragSV = true end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			dragHue = false; dragSV = false
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseMovement
		and i.UserInputType ~= Enum.UserInputType.Touch then return end
		if dragHue then
			local ax = hueStrip.AbsolutePosition.X
			local aw = hueStrip.AbsoluteSize.X
			h = math.clamp((i.Position.X - ax) / math.max(aw, 1), 0, 1)
			emit()
		end
		if dragSV then
			local ap = svBox.AbsolutePosition
			local as = svBox.AbsoluteSize
			s = math.clamp((i.Position.X - ap.X) / math.max(as.X, 1), 0, 1)
			v = 1 - math.clamp((i.Position.Y - ap.Y) / math.max(as.Y, 1), 0, 1)
			emit()
		end
	end)

	return { holder = holder, changed = sig }
end

return ColorPicker
