local Utils = _VertexRequire("src/utils.lua")
local Animator = _VertexRequire("src/animator.lua")

local Effects = {}
Effects.__index = Effects

function Effects.new(themeManager)
	local self = setmetatable({}, Effects)
	self.themeManager = themeManager
	return self
end

function Effects:applyGlass(panel, light)
	panel.BackgroundTransparency = 1 - (self.themeManager:getTheme().glassOpacity or 0.3)
	panel.BackgroundColor3 = self.themeManager:getTheme().layer
	local corner = Utils.createCorner(12)
	corner.Parent = panel
	local stroke = Utils.createStroke(1, self.themeManager:getTheme().border, 0.4)
	stroke.Parent = panel
	local gradient = Utils.createGlassGradient(light or self.themeManager:getTheme().name == "Light")
	gradient.Parent = panel
end

function Effects:applySheen(panel)
	local sheen = Instance.new("Frame")
	sheen.Name = "Sheen"
	sheen.BackgroundTransparency = 1
	sheen.Size = UDim2.new(0, 0, 1, 0)
	sheen.Position = UDim2.new(0, 0, 0, 0)
	sheen.BorderSizePixel = 0
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	})
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.3, 0.4),
		NumberSequenceKeypoint.new(0.7, 0.8),
		NumberSequenceKeypoint.new(1, 1),
	})
	gradient.Rotation = 25
	gradient.Parent = sheen
	sheen.Parent = panel
	Animator.spring(sheen, "Size", UDim2.new(0, panel.AbsoluteSize.X * 2, 1, 0), {
		damping = 20,
		stiffness = 180,
	})
	Animator.spring(sheen, "Position", UDim2.new(0, panel.AbsoluteSize.X, 0, 0), {
		damping = 20,
		stiffness = 180,
	})
end

function Effects:applyAccentStroke(instance)
	local stroke = Utils.createStroke(1.2, self.themeManager:getTheme().accent, 0.15)
	stroke.Parent = instance
	return stroke
end

return Effects
