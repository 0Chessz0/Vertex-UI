local Utils = {}

function Utils.corner(r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	return c
end

function Utils.stroke(thickness, color, transparency)
	local s = Instance.new("UIStroke")
	s.Thickness      = thickness or 1
	s.Color          = color or Color3.new(1, 1, 1)
	s.Transparency   = transparency or 0.6
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return s
end

function Utils.gradient(colorA, colorB, rotation)
	local g = Instance.new("UIGradient")
	g.Color    = ColorSequence.new(colorA, colorB)
	g.Rotation = rotation or 90
	return g
end

function Utils.padding(all, left, right, top, bottom)
	local p = Instance.new("UIPadding")
	local v = UDim.new(0, all or 0)
	p.PaddingLeft   = UDim.new(0, left   or all or 0)
	p.PaddingRight  = UDim.new(0, right  or all or 0)
	p.PaddingTop    = UDim.new(0, top    or all or 0)
	p.PaddingBottom = UDim.new(0, bottom or all or 0)
	return p
end

function Utils.listLayout(dir, halign, valign, padding, sortOrder)
	local l = Instance.new("UIListLayout")
	l.FillDirection        = dir    or Enum.FillDirection.Vertical
	l.HorizontalAlignment  = halign or Enum.HorizontalAlignment.Left
	l.VerticalAlignment    = valign or Enum.VerticalAlignment.Top
	l.Padding              = UDim.new(0, padding or 0)
	l.SortOrder            = sortOrder or Enum.SortOrder.LayoutOrder
	return l
end

function Utils.hexToColor3(hex)
	hex = hex:gsub("#", "")
	if #hex == 3 then
		hex = hex:sub(1,1):rep(2) .. hex:sub(2,2):rep(2) .. hex:sub(3,3):rep(2)
	end
	return Color3.fromRGB(
		tonumber(hex:sub(1, 2), 16) or 0,
		tonumber(hex:sub(3, 4), 16) or 0,
		tonumber(hex:sub(5, 6), 16) or 0
	)
end

function Utils.copy(t)
	local out = {}
	for k, v in pairs(t) do out[k] = v end
	return out
end

return Utils
