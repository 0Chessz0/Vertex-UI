local Animator = _VertexRequire("src/animator.lua")
local Utils    = _VertexRequire("src/utils.lua")
local Signal   = _VertexRequire("src/signal.lua")

local Dialog = {}
Dialog.__index = Dialog

function Dialog.new(theme, uiRoot, core, effects)
	return setmetatable({ theme = theme, uiRoot = uiRoot, core = core, effects = effects }, Dialog)
end

function Dialog:show(title, message, buttons)
	local t = self.theme:get()
	buttons = buttons or {{ id = "ok", label = "OK", primary = true }}

	-- Dim overlay
	local overlay = Instance.new("Frame")
	overlay.Name  = "Overlay"
	overlay.Size  = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.ZIndex  = 960
	overlay.Active  = true
	overlay.Parent  = self.uiRoot
	overlay.InputBegan:Connect(function() end)  -- swallow clicks

	-- Modal card
	local modal = Instance.new("Frame")
	modal.Name  = "Dialog"
	modal.Size  = UDim2.new(0, 360, 0, 190)
	modal.AnchorPoint = Vector2.new(0.5, 0.5)
	modal.Position    = UDim2.new(0.5, 0, 0.5, 24)
	modal.BackgroundTransparency = 1
	modal.BorderSizePixel = 0
	modal.ZIndex  = overlay.ZIndex + 1
	modal.Parent  = overlay
	self.effects:glass(modal, 14)

	-- Title
	local titleLbl = Instance.new("TextLabel")
	titleLbl.BackgroundTransparency = 1
	titleLbl.Size   = UDim2.new(1, -32, 0, 26)
	titleLbl.Position = UDim2.new(0, 16, 0, 16)
	titleLbl.Font   = Enum.Font.GothamSemibold
	titleLbl.TextSize = 15
	titleLbl.TextColor3 = t.text
	titleLbl.Text   = title or "Alert"
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.ZIndex = modal.ZIndex + 2
	titleLbl.Parent = modal

	-- Message
	local msgLbl = Instance.new("TextLabel")
	msgLbl.BackgroundTransparency = 1
	msgLbl.Size    = UDim2.new(1, -32, 0, 56)
	msgLbl.Position = UDim2.new(0, 16, 0, 48)
	msgLbl.Font    = Enum.Font.Gotham
	msgLbl.TextSize = 13
	msgLbl.TextColor3 = t.subtext
	msgLbl.Text    = message or ""
	msgLbl.TextWrapped = true
	msgLbl.TextXAlignment = Enum.TextXAlignment.Left
	msgLbl.TextYAlignment = Enum.TextYAlignment.Top
	msgLbl.ZIndex  = modal.ZIndex + 2
	msgLbl.Parent  = modal

	-- Button row
	local btnRow = Instance.new("Frame")
	btnRow.BackgroundTransparency = 1
	btnRow.Size   = UDim2.new(1, -32, 0, 36)
	btnRow.Position = UDim2.new(0, 16, 1, -52)
	btnRow.ZIndex = modal.ZIndex + 2
	btnRow.Parent = modal
	local layout = Utils.listLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center, 8)
	layout.Parent = btnRow

	local chosen = Signal.new()

	local function dismiss()
		Animator.spring(overlay, "BackgroundTransparency", 1, {stiffness=280, damping=26})
		Animator.spring(modal, "Position", UDim2.new(0.5, 0, 0.5, 40), {stiffness=280, damping=26})
		task.delay(0.28, function() if overlay then overlay:Destroy() end end)
	end

	for _, def in ipairs(buttons) do
		local b = self.core:button({
			Parent  = btnRow,
			Text    = def.label,
			Size    = UDim2.new(0, 88, 0, 32),
			Accent  = def.primary or false,
			ZIndex  = btnRow.ZIndex + 1,
		})
		b.activated:Connect(function()
			chosen:Fire(def.id)
			dismiss()
		end)
	end

	-- Entrance
	Animator.spring(overlay, "BackgroundTransparency", 0.55, {stiffness=280, damping=26})
	Animator.spring(modal, "Position", UDim2.new(0.5, 0, 0.5, 0), {stiffness=280, damping=26})

	return chosen
end

return Dialog
