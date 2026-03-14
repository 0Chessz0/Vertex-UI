local Utils = {}

local RunService = game:GetService("RunService")

function Utils.lerp(a, b, t)
	return a + (b - a) * t
end

function Utils.lerpVector2(a, b, t)
	return Vector2.new(
		Utils.lerp(a.X, b.X, t),
		Utils.lerp(a.Y, b.Y, t)
	)
end

function Utils.lerpUDim2(a, b, t)
	return UDim2.new(
		Utils.lerp(a.X.Scale, b.X.Scale, t),
		Utils.lerp(a.X.Offset, b.X.Offset, t),
		Utils.lerp(a.Y.Scale, b.Y.Scale, t),
		Utils.lerp(a.Y.Offset, b.Y.Offset, t)
	)
end

function Utils.hexToColor3(hex)
	hex = hex:gsub("#", "")
	if #hex == 3 then
		hex = hex:sub(1, 1) .. hex:sub(1, 1) .. hex:sub(2, 2) .. hex:sub(2, 2) .. hex:sub(3, 3) .. hex:sub(3, 3)
	end
	local r = tonumber(hex:sub(1, 2), 16) or 0
	local g = tonumber(hex:sub(3, 4), 16) or 0
	local b = tonumber(hex:sub(5, 6), 16) or 0
	return Color3.fromRGB(r, g, b)
end

function Utils.colorLerp(a, b, t)
	return Color3.new(
		Utils.lerp(a.R, b.R, t),
		Utils.lerp(a.G, b.G, t),
		Utils.lerp(a.B, b.B, t)
	)
end

function Utils.hsvToColor3(h, s, v)
	return Color3.fromHSV(h, s, v)
end

function Utils.createCorner(radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	return corner
end

function Utils.createStroke(thickness, color, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness or 1
	stroke.Color = color or Color3.new(1, 1, 1)
	stroke.Transparency = transparency or 0.4
	return stroke
end

function Utils.createGlassGradient(light)
	local gradient = Instance.new("UIGradient")
	if light then
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 210, 210)),
		})
	else
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 50)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20)),
		})
	end
	gradient.Rotation = 90
	return gradient
end

function Utils.bindToRenderStep(name, priority, fn)
	if RunService:IsClient() then
		RunService:BindToRenderStep(name, priority or Enum.RenderPriority.Last.Value, fn)
	else
		RunService.Heartbeat:Connect(fn)
	end
end

function Utils.unbindFromRenderStep(name)
	if RunService:IsClient() then
		RunService:UnbindFromRenderStep(name)
	end
end

function Utils.trim(str)
	return (str:gsub("^%s+", ""):gsub("%s+$", ""))
end

function Utils.containsIgnoreCase(haystack, needle)
	haystack = string.lower(haystack)
	needle = string.lower(needle)
	return string.find(haystack, needle, 1, true) ~= nil
end

function Utils.shallowCopy(tbl)
	local result = {}
	for k, v in pairs(tbl) do
		result[k] = v
	end
	return result
end

return Utils

