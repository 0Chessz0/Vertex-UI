local UserInputService = game:GetService("UserInputService")

local Signal = _VertexRequire("src/signal.lua")

local KeybindManager = {}
KeybindManager.__index = KeybindManager

function KeybindManager.new()
	local self = setmetatable({}, KeybindManager)
	self.binds = {}
	self.floatingButton = nil
	self.floatingSignal = Signal.new()
	self:_connect()
	return self
end

function KeybindManager:_connect()
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		for _, bind in pairs(self.binds) do
			if bind.enabled and bind.key == input.KeyCode then
				bind.signal:Fire()
			end
		end
	end)
end

function KeybindManager:bind(name, keyCode)
	local existing = self.binds[name]
	if existing then
		existing.key = keyCode
		return existing.signal
	end
	local signal = Signal.new()
	self.binds[name] = {
		key = keyCode,
		signal = signal,
		enabled = true,
	}
	return signal
end

function KeybindManager:setEnabled(name, enabled)
	local bind = self.binds[name]
	if bind then
		bind.enabled = enabled
	end
end

function KeybindManager:createFloatingButton(parentGui)
	if self.floatingButton then
		return self.floatingButton, self.floatingSignal
	end
	local button = Instance.new("ImageButton")
	button.Name = "VertexFloating"
	button.AnchorPoint = Vector2.new(1, 1)
	button.Position = UDim2.new(1, -20, 1, -20)
	button.Size = UDim2.new(0, 48, 0, 48)
	button.BackgroundTransparency = 0.4
	button.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	button.Image = "rbxassetid://0"
	button.AutoButtonColor = false
	button.ZIndex = 1000
	button.Parent = parentGui
	button.MouseButton1Click:Connect(function()
		self.floatingSignal:Fire()
	end)
	self.floatingButton = button
	return button, self.floatingSignal
end

return KeybindManager
