local Animator = _VertexRequire("src/animator.lua")
local Utils = _VertexRequire("src/utils.lua")
local Signal = _VertexRequire("src/signal.lua")

local ContextMenu = {}
ContextMenu.__index = ContextMenu

function ContextMenu.new(themeManager, uiRoot)
	local self = setmetatable({}, ContextMenu)
	self.themeManager = themeManager
	self.uiRoot = uiRoot
	return self
end

function ContextMenu:attach(target, items)
	local theme = self.themeManager:getTheme()
	local menu = Instance.new("Frame")
	menu.Name = "ContextMenu"
	menu.Size = UDim2.new(0, 180, 0, #items * 26 + 8)
	menu.BackgroundColor3 = theme.layer
	menu.BackgroundTransparency = 0.5
	menu.BorderSizePixel = 0
	menu.Visible = false
	menu.ClipsDescendants = true
	menu.ZIndex = 400
	menu.Parent = self.uiRoot
	local corner = Utils.createCorner(8)
	corner.Parent = menu
	local stroke = Utils.createStroke(1, theme.border, 0.4)
	stroke.Parent = menu
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.Padding = UDim.new(0, 2)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = menu
	local signals = {}
	for _, itemDef in ipairs(items) do
		local button = Instance.new("TextButton")
		button.Name = "Item"
		button.Size = UDim2.new(1, -8, 0, 24)
		button.Position = UDim2.new(0, 4, 0, 0)
		button.BackgroundColor3 = theme.layer
		button.BackgroundTransparency = 1
		button.AutoButtonColor = false
		button.Text = itemDef.label
		button.Font = Enum.Font.Gotham
		button.TextSize = 14
		button.TextColor3 = theme.text
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.ZIndex = menu.ZIndex + 1
		button.Parent = menu
		local signal = Signal.new()
		signals[itemDef.id or itemDef.label] = signal
		button.MouseButton1Click:Connect(function()
			signal:Fire()
			menu.Visible = false
		end)
		button.MouseEnter:Connect(function()
			Animator.spring(button, "BackgroundTransparency", 0.85, {
				damping = 22,
				stiffness = 260,
			})
		end)
		button.MouseLeave:Connect(function()
			Animator.spring(button, "BackgroundTransparency", 1, {
				damping = 22,
				stiffness = 260,
			})
		end)
	end
	local UserInputService = game:GetService("UserInputService")
	target.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			local pos = input.Position
			local screenSize = self.uiRoot.AbsoluteSize
			local width = menu.AbsoluteSize.X
			local height = menu.AbsoluteSize.Y
			local x = math.clamp(pos.X, 4, screenSize.X - width - 4)
			local y = math.clamp(pos.Y, 4, screenSize.Y - height - 4)
			menu.Position = UDim2.new(0, x, 0, y)
			menu.Visible = true
			menu.BackgroundTransparency = 1
			Animator.spring(menu, "BackgroundTransparency", 0.5, {
				damping = 22,
				stiffness = 260,
			})
		end
	end)
	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if menu.Visible then
				menu.Visible = false
			end
		end
	end)
	return signals
end

return ContextMenu

