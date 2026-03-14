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
	local sig = Signal.new()

	local holder = Instance.new("Frame")
	holder.Name  = "ColorPicker"
	holder.Size  = UDim2.new(1, 0, 0, 104)
	holder.BackgroundTransparency = 1
	holder.ZIndex = parent.ZIndex + 1
	holder.Parent = parent

	-- ── Swatch ────────────────────────────────────────────────────
	local swatch = Instance.new("Frame")
	swatch.Size              = UDim2.new(0, 40, 0, 40)
	swatch.Position          = UDim2.new(0, 0, 0, 0)
	swatch.BackgroundColor3  = initial or t.accent
	swatch.BackgroundTransparency = 0
	swatch.BorderSizePixel   = 0
	swatch.ZIndex            = holder.ZIndex + 1
	swatch.Parent            = holder
	Utils.corner(8).Parent  = swatch
	Utils.stroke(1, t.border, 0.4).Parent = swatch

	-- ── Hue strip ─────────────────────────────────────────────────
	-- IMPORTANT: BackgroundTransparency must be < 1 for UIGradient to be visible
	local HUE_X = 50
	local hueStrip = Instance.new("Frame")
	hueStrip.Size             = UDim2.new(1, -(HUE_X + 0), 0, 16)
	hueStrip.Position         = UDim2.new(0, HUE_X, 0, 12)
	hueStrip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- must be set!
	hueStrip.BackgroundTransparency = 0                         -- must be 0!
	hueStrip.BorderSizePixel  = 0
	hueStrip.ZIndex           = holder.ZIndex + 1
	hueStrip.Parent           = holder
	Utils.corner(8).Parent   = hueStrip

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

	-- Hue cursor (thin white line showing current hue)
	local hueCursor = Instance.new("Frame")
	hueCursor.Size             = UDim2.new(0, 2, 1, 4)
	hueCursor.AnchorPoint      = Vector2.new(0.5, 0.5)
	hueCursor.Position         = UDim2.new(h, 0, 0.5, 0)
	hueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hueCursor.BackgroundTransparency = 0
	hueCursor.BorderSizePixel  = 0
	hueCursor.ZIndex           = hueStrip.ZIndex + 1
	hueCursor.Parent           = hueStrip
	Utils.corner(1).Parent    = hueCursor

	-- ── SV box ────────────────────────────────────────────────────
	local svBox = Instance.new("Frame")
	svBox.Size             = UDim2.new(1, 0, 0, 56)
	svBox.Position         = UDim2.new(0, 0, 0, 40)
	svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
	svBox.BackgroundTransparency = 0
	svBox.BorderSizePixel  = 0
	svBox.ZIndex           = holder.ZIndex + 1
	svBox.Parent           = holder
	Utils.corner(8).Parent = svBox
	Utils.stroke(1, t.border, 0.45).Parent = svBox

	-- White left→right saturation gradient
	local satGrad = Instance.new("UIGradient")
	satGrad.Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))
	satGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	satGrad.Rotation = 0
	satGrad.Parent   = svBox

	-- Black top→bottom value overlay (separate frame so we can stack two gradients)
	local darkOverlay = Instance.new("Frame")
	darkOverlay.Size              = UDim2.new(1, 0, 1, 0)
	darkOverlay.BackgroundColor3  = Color3.fromRGB(0, 0, 0)
	darkOverlay.BackgroundTransparency = 0
	darkOverlay.BorderSizePixel   = 0
	darkOverlay.ZIndex            = svBox.ZIndex + 1
	darkOverlay.Parent            = svBox
	Utils.corner(8).Parent       = darkOverlay

	local darkGrad = Instance.new("UIGradient")
	darkGrad.Color = ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(0,0,0))
	darkGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0),
	})
	darkGrad.Rotation = 90
	darkGrad.Parent   = darkOverlay

	-- SV cursor dot
	local svCursor = Instance.new("Frame")
	svCursor.Size             = UDim2.new(0, 10, 0, 10)
	svCursor.AnchorPoint      = Vector2.new(0.5, 0.5)
	svCursor.Position         = UDim2.new(s, 0, 1 - v, 0)
	svCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	svCursor.BackgroundTransparency = 0
	svCursor.BorderSizePixel  = 0
	svCursor.ZIndex           = darkOverlay.ZIndex + 1
	svCursor.Parent           = svBox
	Utils.corner(5).Parent   = svCursor
	Utils.stroke(1, Color3.fromRGB(0,0,0), 0.3).Parent = svCursor

	-- ── Logic ─────────────────────────────────────────────────────
	local function emit()
		local c = Color3.fromHSV(h, s, v)
		Animator.spring(swatch, "BackgroundColor3", c, {stiffness=300, damping=26})
		svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		svCursor.Position      = UDim2.new(s, 0, 1 - v, 0)
		hueCursor.Position     = UDim2.new(h, 0, 0.5, 0)
		sig:Fire(c)
	end
	emit()

	local dragHue = false
	local dragSV  = false

	hueStrip.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			dragHue = true
		end
	end)
	svBox.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			dragSV = true
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			dragHue = false
			dragSV  = false
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
