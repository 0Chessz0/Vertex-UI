local Utils    = _VertexRequire("src/utils.lua")
local Animator = _VertexRequire("src/animator.lua")

local Effects = {}
Effects.__index = Effects

function Effects.new(theme)
	return setmetatable({ theme = theme }, Effects)
end

-- Glass panel — macOS frosted dark look
function Effects:glass(frame, cornerRadius)
	local t = self.theme:get()
	frame.BackgroundColor3    = t.surface
	frame.BackgroundTransparency = 0.22      -- slightly see-through
	frame.BorderSizePixel     = 0

	local c = Utils.corner(cornerRadius or 12)
	c.Parent = frame

	-- border
	local s = Utils.stroke(1, t.border, 0.35)
	s.Parent = frame

	-- top-to-bottom depth gradient
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   t.surfaceHigh),
		ColorSequenceKeypoint.new(0.6, t.surface),
		ColorSequenceKeypoint.new(1,   t.bg),
	})
	g.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.10),
		NumberSequenceKeypoint.new(0.5, 0.22),
		NumberSequenceKeypoint.new(1,   0.32),
	})
	g.Rotation = 90
	g.Parent   = frame

	-- 1px gloss line at very top
	local hl = Instance.new("Frame")
	hl.Name                  = "Gloss"
	hl.Size                  = UDim2.new(1, -24, 0, 1)
	hl.Position              = UDim2.new(0, 12, 0, 0)
	hl.BackgroundColor3      = Color3.fromRGB(255, 255, 255)
	hl.BackgroundTransparency = t.name == "Light" and 0.55 or 0.80
	hl.BorderSizePixel        = 0
	hl.ZIndex                 = frame.ZIndex + 1
	hl.Parent                 = frame
end

-- Accent-colored stroke for primary buttons / highlights
function Effects:accentStroke(frame)
	local t  = self.theme:get()
	local s  = Utils.stroke(1.5, t.accent, 0.05)
	s.Parent = frame
	return s
end

-- Separator line (1px horizontal rule)
function Effects:separator(parent, zIndex)
	local t   = self.theme:get()
	local sep = Instance.new("Frame")
	sep.Name                  = "Separator"
	sep.Size                  = UDim2.new(1, 0, 0, 1)
	sep.BackgroundColor3      = t.border
	sep.BackgroundTransparency = 0.45
	sep.BorderSizePixel        = 0
	sep.ZIndex                 = zIndex or (parent.ZIndex + 1)
	sep.Parent                 = parent
	return sep
end

return Effects
