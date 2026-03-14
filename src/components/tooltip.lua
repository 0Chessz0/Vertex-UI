local Animator = _VertexRequire("src/animator.lua")
local Utils = _VertexRequire("src/utils.lua")

local Tooltip = {}
Tooltip.__index = Tooltip

function Tooltip.new(themeManager, effects, uiRoot)
	local self = setmetatable({}, Tooltip)
	self.themeManager = themeManager
	self.effects = effects
	self.uiRoot = uiRoot
	return self
end

function Tooltip:attach(target, text)
	local theme = self.themeManager:getTheme()
	local tip = Instance.new("Frame")
	tip.Name = "Tooltip"
	tip.Size = UDim2.new(0, 200, 0, 26)
	tip.BackgroundColor3 = theme.layer
	tip.BackgroundTransparency = 0.4
	tip.BorderSizePixel = 0
	tip.AnchorPoint = Vector2.new(0.5, 1)
	tip.Position = UDim2.new(0, 0, 0, 0)
	tip.Visible = false
	tip.ZIndex = 500
	tip.Parent = self.uiRoot
	self.effects:applyGlass(tip, theme.name == "Light")
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -16, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextColor3 = theme.text
	label.Text = text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = tip.ZIndex + 1
	label.Parent = tip
	target.MouseEnter:Connect(function()
		local abs = target.AbsolutePosition
		local size = target.AbsoluteSize
		tip.Position = UDim2.new(0, abs.X + size.X / 2, 0, abs.Y - 4)
		tip.Visible = true
		tip.BackgroundTransparency = 1
		Animator.spring(tip, "BackgroundTransparency", 0.4, {
			damping = 20,
			stiffness = 220,
		})
	end)
	target.MouseLeave:Connect(function()
		Animator.spring(tip, "BackgroundTransparency", 1, {
			damping = 20,
			stiffness = 220,
		})
		task.delay(0.18, function()
			if tip then
				tip.Visible = false
			end
		end)
	end)
end

return Tooltip

