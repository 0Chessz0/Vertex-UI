local UIS    = game:GetService("UserInputService")
local Signal = _VertexRequire("src/signal.lua")

local KeybindManager = {}
KeybindManager.__index = KeybindManager

function KeybindManager.new()
	local self = setmetatable({ binds = {}, _floatBtn = nil, _floatSig = Signal.new() }, KeybindManager)
	UIS.InputBegan:Connect(function(input, processed)
		if processed then return end
		for _, b in pairs(self.binds) do
			if b.enabled and b.key == input.KeyCode then b.signal:Fire() end
		end
	end)
	return self
end

function KeybindManager:bind(name, key)
	if self.binds[name] then
		self.binds[name].key = key
		return self.binds[name].signal
	end
	local sig = Signal.new()
	self.binds[name] = { key = key, signal = sig, enabled = true }
	return sig
end

function KeybindManager:setEnabled(name, v)
	if self.binds[name] then self.binds[name].enabled = v end
end

function KeybindManager:floatingButton(parent)
	if self._floatBtn then return self._floatBtn, self._floatSig end
	local Utils = _VertexRequire("src/utils.lua")
	local btn   = Instance.new("TextButton")
	btn.Name               = "VertexToggle"
	btn.Size               = UDim2.new(0, 44, 0, 44)
	btn.AnchorPoint        = Vector2.new(1, 1)
	btn.Position           = UDim2.new(1, -16, 1, -16)
	btn.BackgroundColor3   = Color3.fromRGB(20, 20, 32)
	btn.BackgroundTransparency = 0.2
	btn.BorderSizePixel    = 0
	btn.Text               = "V"
	btn.Font               = Enum.Font.GothamBold
	btn.TextSize           = 16
	btn.TextColor3         = Color3.fromRGB(240, 240, 255)
	btn.AutoButtonColor    = false
	btn.ZIndex             = 900
	btn.Parent             = parent
	Utils.corner(22).Parent = btn
	Utils.stroke(1, Color3.fromRGB(70, 70, 100), 0.4).Parent = btn
	btn.MouseButton1Click:Connect(function() self._floatSig:Fire() end)
	self._floatBtn = btn
	return btn, self._floatSig
end

-- back-compat alias
function KeybindManager:createFloatingButton(parent)
	return self:floatingButton(parent)
end

return KeybindManager
