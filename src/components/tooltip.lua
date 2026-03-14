local Animator = _VertexRequire("src/animator.lua")
local Utils    = _VertexRequire("src/utils.lua")

local Tooltip = {}
Tooltip.__index = Tooltip

function Tooltip.new(theme, effects, uiRoot)
	return setmetatable({ theme = theme, effects = effects, uiRoot = uiRoot }, Tooltip)
end

function Tooltip:attach(target, text)
	local t = self.theme:get()

	local tip = Instance.new("Frame")
	tip.Name  = "Tooltip"
	tip.Size  = UDim2.new(0, 0, 0, 28)   -- auto-width via TextBounds
	tip.BackgroundColor3 = t.surface
	tip.BackgroundTransparency = 0.18
	tip.BorderSizePixel = 0
	tip.AnchorPoint = Vector2.new(0.5, 1)
	tip.Visible     = false
	tip.ZIndex      = 980
	tip.Parent      = self.uiRoot
	Utils.corner(7).Parent  = tip
	Utils.stroke(1, t.border, 0.4).Parent = tip

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size     = UDim2.new(1, -16, 1, 0)
	lbl.Position = UDim2.new(0, 8, 0, 0)
	lbl.Font     = Enum.Font.Gotham
	lbl.TextSize = 12
	lbl.TextColor3 = t.text
	lbl.Text     = text
	lbl.TextXAlignment = Enum.TextXAlignment.Center
	lbl.ZIndex   = tip.ZIndex + 1
	lbl.Parent   = tip

	-- auto-size tip to text
	task.defer(function()
		local bounds = game:GetService("TextService"):GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(300, 100))
		tip.Size = UDim2.new(0, bounds.X + 20, 0, 28)
	end)

	target.MouseEnter:Connect(function()
		local ap  = target.AbsolutePosition
		local as  = target.AbsoluteSize
		tip.Position = UDim2.new(0, ap.X + as.X * 0.5, 0, ap.Y - 6)
		tip.Visible  = true
		tip.BackgroundTransparency = 1
		lbl.TextTransparency = 1
		Animator.spring(tip, "BackgroundTransparency", 0.18, {stiffness=300, damping=26})
		Animator.spring(lbl, "TextTransparency",       0,    {stiffness=300, damping=26})
	end)
	target.MouseLeave:Connect(function()
		Animator.spring(tip, "BackgroundTransparency", 1, {stiffness=260, damping=22})
		Animator.spring(lbl, "TextTransparency",       1, {stiffness=260, damping=22})
		task.delay(0.2, function() if tip then tip.Visible = false end end)
	end)
end

return Tooltip
