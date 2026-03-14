-- Core UI primitives: Label, Button, Textbox, Slider, Toggle
local Utils    = _VertexRequire("src/utils.lua")
local Animator = _VertexRequire("src/animator.lua")
local Signal   = _VertexRequire("src/signal.lua")

local Core = {}
Core.__index = Core

function Core.new(theme, effects)
	return setmetatable({ theme = theme, effects = effects }, Core)
end

function Core:label(props)
	local t   = self.theme:get()
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Font          = props.Font or Enum.Font.Gotham
	lbl.TextSize      = props.TextSize  or 14
	lbl.TextColor3    = props.TextColor3 or t.text
	lbl.TextXAlignment= props.TextXAlignment or Enum.TextXAlignment.Left
	lbl.TextYAlignment= Enum.TextYAlignment.Center
	lbl.RichText      = true
	lbl.TextWrapped   = props.TextWrapped or false
	lbl.Text          = props.Text or ""
	lbl.Name          = props.Name or "Label"
	lbl.Size          = props.Size or UDim2.new(1, 0, 0, 20)
	lbl.Position      = props.Position or UDim2.new()
	lbl.ZIndex        = props.ZIndex or 1
	lbl.Parent        = props.Parent
	return lbl
end

-- back-compat
function Core:createTextLabel(props) return self:label(props) end

function Core:button(props)
	local t    = self.theme:get()
	local btn  = Instance.new("TextButton")
	btn.Name   = props.Name or "Button"
	btn.Size   = props.Size or UDim2.new(0, 120, 0, 32)
	btn.Position = props.Position or UDim2.new()
	btn.BackgroundColor3    = t.surface
	btn.BackgroundTransparency = 0.30
	btn.AutoButtonColor     = false
	btn.Font                = Enum.Font.GothamMedium
	btn.TextSize            = props.TextSize or 14
	btn.TextColor3          = t.text
	btn.Text                = props.Text or "Button"
	btn.ZIndex              = props.ZIndex or 1
	btn.Parent              = props.Parent

	Utils.corner(10).Parent  = btn
	Utils.stroke(1, t.border, 0.45).Parent = btn

	if props.Accent then
		self.effects:accentStroke(btn)
	end

	local sig = Signal.new()
	btn.MouseButton1Click:Connect(function() sig:Fire() end)

	btn.MouseEnter:Connect(function()
		Animator.spring(btn, "BackgroundTransparency", 0.10, {stiffness=260, damping=22})
	end)
	btn.MouseLeave:Connect(function()
		Animator.spring(btn, "BackgroundTransparency", 0.30, {stiffness=260, damping=22})
	end)
	btn.MouseButton1Down:Connect(function()
		Animator.spring(btn, "BackgroundTransparency", 0.02, {stiffness=400, damping=28})
	end)
	btn.MouseButton1Up:Connect(function()
		Animator.spring(btn, "BackgroundTransparency", 0.10, {stiffness=260, damping=22})
	end)

	return { instance = btn, activated = sig }
end

function Core:createButton(props) return self:button(props) end

function Core:textbox(props)
	local t   = self.theme:get()
	local box = Instance.new("TextBox")
	box.Name              = props.Name or "Textbox"
	box.Size              = props.Size or UDim2.new(0, 180, 0, 32)
	box.Position          = props.Position or UDim2.new()
	box.BackgroundColor3  = t.surface
	box.BackgroundTransparency = 0.35
	box.Font              = Enum.Font.Gotham
	box.TextSize          = 14
	box.TextColor3        = t.text
	box.PlaceholderColor3 = t.subtext
	box.PlaceholderText   = props.PlaceholderText or ""
	box.Text              = props.Text or ""
	box.ClearTextOnFocus  = props.ClearTextOnFocus or false
	box.ZIndex            = props.ZIndex or 1
	box.Parent            = props.Parent
	Utils.corner(8).Parent = box
	Utils.stroke(1, t.border, 0.45).Parent = box

	-- highlight border on focus
	local stroke2 = Utils.stroke(1.5, t.accent, 0.0)
	stroke2.Transparency = 1
	stroke2.Parent = box
	box.Focused:Connect(function()
		Animator.spring(stroke2, "Transparency", 0.0, {stiffness=300, damping=24})
	end)
	box.FocusLost:Connect(function()
		Animator.spring(stroke2, "Transparency", 1, {stiffness=300, damping=24})
	end)

	local sig = Signal.new()
	box.FocusLost:Connect(function(enter) sig:Fire(box.Text, enter) end)
	return { instance = box, changed = sig }
end

function Core:createTextbox(props) return self:textbox(props) end

function Core:slider(props)
	local t    = self.theme:get()
	local UIS  = game:GetService("UserInputService")
	local min  = props.Min or 0
	local max  = props.Max or 100
	local val  = math.clamp(props.Value or min, min, max)

	local frame = Instance.new("Frame")
	frame.Name  = props.Name or "Slider"
	frame.Size  = props.Size or UDim2.new(1, 0, 0, 36)
	frame.Position = props.Position or UDim2.new()
	frame.BackgroundTransparency = 1
	frame.ZIndex = props.ZIndex or 1
	frame.Parent = props.Parent

	-- Track
	local track = Instance.new("Frame")
	track.Name  = "Track"
	track.AnchorPoint = Vector2.new(0, 0.5)
	track.Size  = UDim2.new(1, -20, 0, 5)
	track.Position = UDim2.new(0, 10, 0.5, 0)
	track.BackgroundColor3 = t.surfaceHigh
	track.BackgroundTransparency = 0.2
	track.BorderSizePixel = 0
	track.ZIndex = frame.ZIndex + 1
	track.Parent = frame
	Utils.corner(3).Parent = track

	-- Fill
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.AnchorPoint = Vector2.new(0, 0.5)
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.Position = UDim2.new(0, 0, 0.5, 0)
	fill.BackgroundColor3 = t.accent
	fill.BackgroundTransparency = 0
	fill.BorderSizePixel = 0
	fill.ZIndex = track.ZIndex + 1
	fill.Parent = track
	Utils.corner(3).Parent = fill

	-- Knob
	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BackgroundTransparency = 0
	knob.BorderSizePixel = 0
	knob.ZIndex = frame.ZIndex + 3
	knob.Parent = frame
	Utils.corner(8).Parent = knob
	Utils.stroke(1, t.accent, 0.3).Parent = knob

	local sig = Signal.new()
	local function updateVisual(v, animate)
		local alpha = (v - min) / math.max(max - min, 0.0001)
		local newFillSize = UDim2.new(alpha, 0, 1, 0)
		-- knob X relative to frame: track starts at 10, track width = frame.AbsoluteSize.X - 20
		local trackW = frame.AbsoluteSize.X - 20
		local knobX  = 10 + trackW * alpha
		local newKnobPos = UDim2.new(0, knobX, 0.5, 0)
		if animate then
			Animator.spring(fill, "Size", newFillSize, {stiffness=280, damping=24})
			Animator.spring(knob, "Position", newKnobPos, {stiffness=280, damping=24})
		else
			fill.Size   = newFillSize
			knob.Position = newKnobPos
		end
	end

	local function setValue(v, animate)
		val = math.clamp(v, min, max)
		updateVisual(val, animate)
		sig:Fire(val)
	end

	-- set initial position after parenting (AbsoluteSize needs a frame)
	task.defer(function() updateVisual(val, false) end)

	local dragging = false
	local function getAlpha(inputX)
		local absX = track.AbsolutePosition.X
		local absW = track.AbsoluteSize.X
		return math.clamp((inputX - absX) / math.max(absW, 1), 0, 1)
	end

	track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setValue(min + (max - min) * getAlpha(i.Position.X), true)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if not dragging then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement
		or i.UserInputType == Enum.UserInputType.Touch then
			setValue(min + (max - min) * getAlpha(i.Position.X), true)
		end
	end)

	return { instance = frame, changed = sig, setValue = setValue, getValue = function() return val end }
end

function Core:createSlider(props) return self:slider(props) end

function Core:toggle(props)
	local t    = self.theme:get()
	local on   = props.Default or false

	local frame = Instance.new("Frame")
	frame.Name  = props.Name or "Toggle"
	frame.Size  = UDim2.new(0, 44, 0, 24)
	frame.Position = props.Position or UDim2.new()
	frame.BackgroundColor3 = on and t.accent or t.surfaceHigh
	frame.BackgroundTransparency = 0.1
	frame.BorderSizePixel = 0
	frame.ZIndex = props.ZIndex or 1
	frame.Parent = props.Parent
	Utils.corner(12).Parent = frame

	local knob = Instance.new("Frame")
	knob.Size  = UDim2.new(0, 18, 0, 18)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = on and UDim2.new(0, 33, 0.5, 0) or UDim2.new(0, 11, 0.5, 0)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BackgroundTransparency = 0
	knob.BorderSizePixel = 0
	knob.ZIndex = frame.ZIndex + 1
	knob.Parent = frame
	Utils.corner(9).Parent = knob

	local sig = Signal.new()
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.ZIndex = frame.ZIndex + 2
	btn.Parent = frame

	btn.MouseButton1Click:Connect(function()
		on = not on
		Animator.spring(frame, "BackgroundColor3", on and t.accent or t.surfaceHigh, {stiffness=260, damping=22})
		Animator.spring(knob,  "Position", on and UDim2.new(0, 33, 0.5, 0) or UDim2.new(0, 11, 0.5, 0), {stiffness=340, damping=26})
		sig:Fire(on)
	end)

	return { instance = frame, changed = sig, getValue = function() return on end }
end

return Core
