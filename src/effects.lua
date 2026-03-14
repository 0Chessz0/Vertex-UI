local Utils = _VertexRequire("src/utils.lua")
local Animator = _VertexRequire("src/animator.lua")

local Effects = {}
Effects.__index = Effects

function Effects.new(themeManager)
	local self = setmetatable({}, Effects)
	self.themeManager = themeManager
	return self
end

-- Main glass panel: dark tinted, top-lit gradient, visible border
function Effects:applyGlass(panel, isLight)
	local theme = self.themeManager:getTheme()
	panel.BackgroundColor3 = isLight and theme.glassTop or theme.glassTop
	panel.BackgroundTransparency = theme.glassOpacity
	panel.BorderSizePixel = 0

	-- Rounded corners
	local corner = Utils.createCorner(14)
	corner.Parent = panel

	-- Outer border stroke
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = theme.border
	stroke.Transparency = 0.25
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = panel

	-- Top-to-bottom gradient for depth
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   theme.glassTop),
		ColorSequenceKeypoint.new(0.5, theme.layer),
		ColorSequenceKeypoint.new(1,   theme.glassBottom),
	})
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   theme.glassOpacity - 0.04),
		NumberSequenceKeypoint.new(0.4, theme.glassOpacity),
		NumberSequenceKeypoint.new(1,   theme.glassOpacity + 0.04),
	})
	gradient.Rotation = 90
	gradient.Parent = panel

	-- Inner top highlight line (macOS gloss)
	local highlight = Instance.new("Frame")
	highlight.Name = "GlossHighlight"
	highlight.Size = UDim2.new(1, -32, 0, 1)
	highlight.Position = UDim2.new(0, 16, 0, 1)
	highlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	highlight.BackgroundTransparency = isLight and 0.6 or 0.82
	highlight.BorderSizePixel = 0
	highlight.ZIndex = panel.ZIndex + 1
	highlight.Parent = panel
	local highlightCorner = Utils.createCorner(1)
	highlightCorner.Parent = highlight
end

-- Header bar: slightly more opaque, distinct from body
function Effects:applyHeader(headerFrame, isLight)
	local theme = self.themeManager:getTheme()
	headerFrame.BackgroundColor3 = theme.header
	headerFrame.BackgroundTransparency = theme.glassOpacity - 0.02
	headerFrame.BorderSizePixel = 0

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, theme.glassTop),
		ColorSequenceKeypoint.new(1, theme.header),
	})
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, theme.glassOpacity - 0.05),
		NumberSequenceKeypoint.new(1, theme.glassOpacity),
	})
	gradient.Rotation = 90
	gradient.Parent = headerFrame

	-- Separator at the bottom of the header
	local sep = Instance.new("Frame")
	sep.Name = "Separator"
	sep.Size = UDim2.new(1, 0, 0, 1)
	sep.Position = UDim2.new(0, 0, 1, -1)
	sep.BackgroundColor3 = theme.separator
	sep.BackgroundTransparency = 0.3
	sep.BorderSizePixel = 0
	sep.ZIndex = headerFrame.ZIndex + 1
	sep.Parent = headerFrame
end

-- Accent stroke with a subtle glow color
function Effects:applyAccentStroke(instance)
	local theme = self.themeManager:getTheme()
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.5
	stroke.Color = theme.accent
	stroke.Transparency = 0.1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = instance
	return stroke
end

-- Sheen sweep animation (call on hover for buttons/panels)
function Effects:applySheen(panel)
	local sheen = Instance.new("Frame")
	sheen.Name = "Sheen"
	sheen.BackgroundTransparency = 1
	sheen.Size = UDim2.new(0, 40, 1, 0)
	sheen.Position = UDim2.new(-0.2, 0, 0, 0)
	sheen.BorderSizePixel = 0
	sheen.ZIndex = panel.ZIndex + 2
	sheen.Parent = panel

	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255))
	grad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   1),
		NumberSequenceKeypoint.new(0.4, 0.55),
		NumberSequenceKeypoint.new(0.6, 0.55),
		NumberSequenceKeypoint.new(1,   1),
	})
	grad.Rotation = 15
	grad.Parent = sheen

	Animator.spring(sheen, "Position", UDim2.new(1.2, 0, 0, 0), {
		damping = 28,
		stiffness = 160,
	})
end

return Effects
