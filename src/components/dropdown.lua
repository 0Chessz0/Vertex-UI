local Animator = _VertexRequire("src/animator.lua")
local Utils    = _VertexRequire("src/utils.lua")
local Signal   = _VertexRequire("src/signal.lua")

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(theme, core)
	return setmetatable({ theme = theme, core = core }, Dropdown)
end

local ITEM_H = 28

function Dropdown:create(parent, items, default)
	local t = self.theme:get()

	local holder = Instance.new("Frame")
	holder.Name  = "Dropdown"
	holder.Size  = UDim2.new(0, 200, 0, 34)
	holder.BackgroundTransparency = 1
	holder.ZIndex = parent.ZIndex + 1
	holder.Parent = parent

	-- Main button
	local btn = Instance.new("TextButton")
	btn.Name   = "Btn"
	btn.Size   = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = t.surface
	btn.BackgroundTransparency = 0.30
	btn.AutoButtonColor = false
	btn.Font   = Enum.Font.Gotham
	btn.TextSize = 13
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.TextColor3 = t.text
	btn.Text   = "  " .. (default or items[1] or "")
	btn.ZIndex = holder.ZIndex + 1
	btn.Parent = holder
	Utils.corner(9).Parent  = btn
	Utils.stroke(1, t.border, 0.45).Parent = btn

	-- Arrow
	local arrow = Instance.new("TextLabel")
	arrow.BackgroundTransparency = 1
	arrow.Size   = UDim2.new(0, 28, 1, 0)
	arrow.Position = UDim2.new(1, -28, 0, 0)
	arrow.Font   = Enum.Font.GothamBold
	arrow.TextSize = 12
	arrow.Text   = "▾"
	arrow.TextColor3 = t.subtext
	arrow.ZIndex = btn.ZIndex + 1
	arrow.Parent = btn

	-- List (hidden, grows downward)
	local list = Instance.new("Frame")
	list.Name   = "List"
	list.Size   = UDim2.new(1, 0, 0, 0)
	list.Position = UDim2.new(0, 0, 1, 4)
	list.BackgroundColor3 = t.surface
	list.BackgroundTransparency = 0.18
	list.BorderSizePixel = 0
	list.ClipsDescendants = true
	list.ZIndex = holder.ZIndex + 20
	list.Parent = holder
	Utils.corner(9).Parent = list
	Utils.stroke(1, t.border, 0.40).Parent = list

	local layout = Utils.listLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top, 2)
	layout.Parent = list
	Utils.padding(0, 4, 4, 4, 4).Parent = list

	local sig  = Signal.new()
	local open = false
	local fullH = #items * (ITEM_H + 2) + 8

	for _, text in ipairs(items) do
		local item = Instance.new("TextButton")
		item.Size  = UDim2.new(1, 0, 0, ITEM_H)
		item.BackgroundColor3 = t.surfaceHigh
		item.BackgroundTransparency = 1
		item.AutoButtonColor = false
		item.Font  = Enum.Font.Gotham
		item.TextSize = 13
		item.TextColor3 = t.text
		item.Text  = text
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.ZIndex = list.ZIndex + 1
		item.Parent = list
		Utils.corner(7).Parent = item
		Utils.padding(0, 8, 8, 0, 0).Parent = item

		item.MouseEnter:Connect(function()
			Animator.spring(item, "BackgroundTransparency", 0.55, {stiffness=280, damping=24})
		end)
		item.MouseLeave:Connect(function()
			Animator.spring(item, "BackgroundTransparency", 1, {stiffness=280, damping=24})
		end)
		item.MouseButton1Click:Connect(function()
			btn.Text = "  " .. text
			sig:Fire(text)
			open = false
			Animator.spring(list, "Size", UDim2.new(1, 0, 0, 0), {stiffness=320, damping=28})
			Animator.spring(arrow, "Rotation", 0, {stiffness=320, damping=28})
		end)
	end

	btn.MouseButton1Click:Connect(function()
		open = not open
		Animator.spring(list, "Size",
			open and UDim2.new(1, 0, 0, fullH) or UDim2.new(1, 0, 0, 0),
			{stiffness=320, damping=28}
		)
		Animator.spring(arrow, "Rotation", open and 180 or 0, {stiffness=320, damping=28})
		Animator.spring(btn, "BackgroundTransparency", open and 0.15 or 0.30, {stiffness=280, damping=24})
	end)

	-- close on outside click
	game:GetService("UserInputService").InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 and open then
			-- a short delay so the button's own click fires first
			task.delay(0.02, function()
				if open then
					open = false
					Animator.spring(list, "Size", UDim2.new(1, 0, 0, 0), {stiffness=320, damping=28})
					Animator.spring(arrow, "Rotation", 0, {stiffness=320, damping=28})
					Animator.spring(btn, "BackgroundTransparency", 0.30, {stiffness=280, damping=24})
				end
			end)
		end
	end)

	return { holder = holder, selected = sig }
end

return Dropdown
