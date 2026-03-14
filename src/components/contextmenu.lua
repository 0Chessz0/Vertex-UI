local Animator = _VertexRequire("src/animator.lua")
local Utils    = _VertexRequire("src/utils.lua")
local Signal   = _VertexRequire("src/signal.lua")
local UIS      = game:GetService("UserInputService")

local ContextMenu = {}
ContextMenu.__index = ContextMenu

function ContextMenu.new(theme, uiRoot)
	return setmetatable({ theme = theme, uiRoot = uiRoot }, ContextMenu)
end

function ContextMenu:attach(target, items)
	local t    = self.theme:get()
	local ITEM_H = 28
	local W    = 180
	local totalH = #items * (ITEM_H + 2) + 10

	local menu = Instance.new("Frame")
	menu.Name  = "ContextMenu"
	menu.Size  = UDim2.new(0, W, 0, totalH)
	menu.BackgroundColor3 = t.surface
	menu.BackgroundTransparency = 0.18
	menu.BorderSizePixel = 0
	menu.Visible = false
	menu.ZIndex  = 970
	menu.Parent  = self.uiRoot
	Utils.corner(10).Parent = menu
	Utils.stroke(1, t.border, 0.35).Parent = menu

	local layout = Utils.listLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top, 2)
	layout.Parent = menu
	Utils.padding(0, 4, 4, 4, 4).Parent = menu

	local signals = {}
	for _, def in ipairs(items) do
		local item = Instance.new("TextButton")
		item.Size  = UDim2.new(1, 0, 0, ITEM_H)
		item.BackgroundColor3 = t.surfaceHigh
		item.BackgroundTransparency = 1
		item.AutoButtonColor = false
		item.Font  = Enum.Font.Gotham
		item.TextSize = 13
		item.TextColor3 = t.text
		item.Text  = def.label
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.ZIndex = menu.ZIndex + 1
		item.Parent = menu
		Utils.corner(7).Parent = item
		Utils.padding(0, 8, 0, 0, 0).Parent = item

		local sig = Signal.new()
		signals[def.id or def.label] = sig

		item.MouseEnter:Connect(function()
			Animator.spring(item, "BackgroundTransparency", 0.55, {stiffness=280, damping=24})
		end)
		item.MouseLeave:Connect(function()
			Animator.spring(item, "BackgroundTransparency", 1, {stiffness=280, damping=24})
		end)
		item.MouseButton1Click:Connect(function()
			sig:Fire()
			menu.Visible = false
		end)
	end

	target.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
		local p  = i.Position
		local gs = self.uiRoot.AbsoluteSize
		local x  = math.clamp(p.X, 4, gs.X - W - 4)
		local y  = math.clamp(p.Y, 4, gs.Y - totalH - 4)
		menu.Position = UDim2.new(0, x, 0, y)
		menu.Visible  = true
		menu.BackgroundTransparency = 1
		Animator.spring(menu, "BackgroundTransparency", 0.18, {stiffness=320, damping=26})
	end)

	UIS.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 and menu.Visible then
			menu.Visible = false
		end
	end)

	return signals
end

return ContextMenu
