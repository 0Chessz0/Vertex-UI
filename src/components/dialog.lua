local Animator = _VertexRequire("src/animator.lua")
local Utils = _VertexRequire("src/utils.lua")
local Signal = _VertexRequire("src/signal.lua")

local Dialog = {}
Dialog.__index = Dialog

function Dialog.new(themeManager, uiRoot, core, effects)
	local self = setmetatable({}, Dialog)
	self.themeManager = themeManager
	self.uiRoot = uiRoot
	self.core = core
	self.effects = effects
	return self
end

function Dialog:show(title, message, buttons)
	local theme = self.themeManager:getTheme()
	local overlay = Instance.new("Frame")
	overlay.Name = "VertexDialogOverlay"
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.ZIndex = 900
	overlay.Parent = self.uiRoot
	local modal = Instance.new("Frame")
	modal.Name = "Dialog"
	modal.Size = UDim2.new(0, 360, 0, 180)
	modal.AnchorPoint = Vector2.new(0.5, 0.5)
	modal.Position = UDim2.new(0.5, 0, 0.5, 40)
	modal.BackgroundColor3 = theme.layer
	modal.BackgroundTransparency = 0.4
	modal.BorderSizePixel = 0
	modal.ZIndex = overlay.ZIndex + 1
	modal.Parent = overlay
	self.effects:applyGlass(modal, theme.name == "Light")
	local titleLabel = self.core:createTextLabel({
		Parent = modal,
		Text = title or "Alert",
		TextSize = 16,
		Size = UDim2.new(1, -32, 0, 26),
		Position = UDim2.new(0, 16, 0, 16),
		ZIndex = modal.ZIndex + 1,
	})
	local messageLabel = self.core:createTextLabel({
		Parent = modal,
		Text = message or "",
		TextSize = 14,
		Size = UDim2.new(1, -32, 0, 60),
		Position = UDim2.new(0, 16, 0, 48),
		ZIndex = modal.ZIndex + 1,
	})
	messageLabel.TextWrapped = true
	local buttonRow = Instance.new("Frame")
	buttonRow.Name = "Buttons"
	buttonRow.Size = UDim2.new(1, -32, 0, 32)
	buttonRow.Position = UDim2.new(0, 16, 1, -48)
	buttonRow.BackgroundTransparency = 1
	buttonRow.ZIndex = modal.ZIndex + 1
	buttonRow.Parent = modal
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = buttonRow
	local chosen = Signal.new()
	local definitions = buttons or {
		{ id = "ok", label = "OK", primary = true },
	}
	for _, def in ipairs(definitions) do
		local created = self.core:createButton({
			Parent = buttonRow,
			Text = def.label,
			Size = UDim2.new(0, 90, 0, 30),
			Accent = def.primary or false,
			ZIndex = buttonRow.ZIndex + 1,
		})
		created.activated:Connect(function()
			chosen:Fire(def.id)
			Animator.spring(modal, "Position", UDim2.new(0.5, 0, 0.5, 70), {
				damping = 22,
				stiffness = 260,
			})
			Animator.spring(overlay, "BackgroundTransparency", 1, {
				damping = 22,
				stiffness = 260,
			})
			task.delay(0.25, function()
				if overlay then
					overlay:Destroy()
				end
			end)
		end)
	end
	overlay.Active = true
	overlay.InputBegan:Connect(function() end)
	overlay.BackgroundTransparency = 1
	Animator.spring(overlay, "BackgroundTransparency", 0.4, {
		damping = 22,
		stiffness = 260,
	})
	Animator.spring(modal, "Position", UDim2.new(0.5, 0, 0.5, 0), {
		damping = 22,
		stiffness = 260,
	})
	return chosen
end

return Dialog

