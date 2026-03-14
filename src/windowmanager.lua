local Draggable = _VertexRequire("src/draggable.lua")
local Utils = _VertexRequire("src/utils.lua")
local Animator = _VertexRequire("src/animator.lua")

local WindowManager = {}
WindowManager.__index = WindowManager

-- Layout constants
local HEADER_H   = 44   -- title bar + traffic lights
local TAB_H      = 40   -- tab row
local BODY_TOP   = HEADER_H + TAB_H  -- content starts here
local SIDE_PAD   = 0

function WindowManager.new(themeManager, effects, core)
	local self = setmetatable({}, WindowManager)
	self.themeManager = themeManager
	self.effects = effects
	self.core = core
	self.windows = {}
	self.zCounter = 10
	return self
end

function WindowManager:createWindow(uiRoot, title, size)
	local theme = self.themeManager:getTheme()
	local isLight = theme.name == "Light"

	-- ── Outer shell ──────────────────────────────────────────────
	local window = Instance.new("Frame")
	window.Name = "VertexWindow"
	window.Size = size or UDim2.new(0, 520, 0, 380)
	window.Position = UDim2.new(0.5, 0, 0.5, 0)
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.BackgroundTransparency = 1
	window.BorderSizePixel = 0
	window.ZIndex = self.zCounter
	window.ClipsDescendants = true
	window.Parent = uiRoot

	-- Glass body (full window)
	local body = Instance.new("Frame")
	body.Name = "Body"
	body.Size = UDim2.new(1, 0, 1, 0)
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.ZIndex = window.ZIndex
	body.Parent = window
	self.effects:applyGlass(body, isLight)

	-- ── Header ───────────────────────────────────────────────────
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, HEADER_H)
	header.Position = UDim2.new(0, 0, 0, 0)
	header.BorderSizePixel = 0
	header.ZIndex = window.ZIndex + 2
	header.ClipsDescendants = true
	header.Parent = window
	self.effects:applyHeader(header, isLight)

	-- Traffic light dots
	local dotColors = {
		Color3.fromRGB(255, 95,  87),   -- close  (red)
		Color3.fromRGB(255, 189, 46),   -- min    (yellow)
		Color3.fromRGB(40,  200, 64),   -- max    (green)
	}
	for i, col in ipairs(dotColors) do
		local dot = Instance.new("Frame")
		dot.Name = "Dot" .. i
		dot.Size = UDim2.new(0, 11, 0, 11)
		dot.AnchorPoint = Vector2.new(0, 0.5)
		dot.Position = UDim2.new(0, 14 + (i - 1) * 18, 0.5, 0)
		dot.BackgroundColor3 = col
		dot.BackgroundTransparency = 0
		dot.BorderSizePixel = 0
		dot.ZIndex = header.ZIndex + 1
		dot.Parent = header
		local c = Utils.createCorner(6)
		c.Parent = dot
	end
	-- Close dot actually closes
	local closeDot = header:FindFirstChild("Dot1")
	if closeDot then
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.ZIndex = closeDot.ZIndex + 1
		btn.Parent = closeDot
		btn.MouseButton1Click:Connect(function()
			Animator.spring(window, "Size", UDim2.new(0, window.AbsoluteSize.X, 0, 0), { damping = 22, stiffness = 280 })
			task.delay(0.25, function() if window then window.Visible = false; window.Size = size or UDim2.new(0, 520, 0, 380) end end)
		end)
	end

	-- Centered title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -160, 1, 0)
	titleLabel.Position = UDim2.new(0, 80, 0, 0)
	titleLabel.AnchorPoint = Vector2.new(0, 0)
	titleLabel.Font = Enum.Font.GothamMedium
	titleLabel.TextSize = 14
	titleLabel.TextColor3 = theme.text
	titleLabel.Text = title or "Vertex"
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.ZIndex = header.ZIndex + 1
	titleLabel.Parent = header

	-- ── Tab row ──────────────────────────────────────────────────
	local tabRow = Instance.new("Frame")
	tabRow.Name = "TabRow"
	tabRow.Size = UDim2.new(1, 0, 0, TAB_H)
	tabRow.Position = UDim2.new(0, 0, 0, HEADER_H)
	tabRow.BackgroundColor3 = theme.header
	tabRow.BackgroundTransparency = theme.glassOpacity + 0.01
	tabRow.BorderSizePixel = 0
	tabRow.ZIndex = window.ZIndex + 2
	tabRow.Parent = window
	-- Tab row bottom separator
	local tabSep = Instance.new("Frame")
	tabSep.Name = "Separator"
	tabSep.Size = UDim2.new(1, 0, 0, 1)
	tabSep.Position = UDim2.new(0, 0, 1, -1)
	tabSep.BackgroundColor3 = theme.separator
	tabSep.BackgroundTransparency = 0.3
	tabSep.BorderSizePixel = 0
	tabSep.ZIndex = tabRow.ZIndex + 1
	tabSep.Parent = tabRow

	-- ── Content area ─────────────────────────────────────────────
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, -32, 1, -(BODY_TOP + 16))
	content.Position = UDim2.new(0, 16, 0, BODY_TOP + 8)
	content.ZIndex = window.ZIndex + 1
	content.Parent = window

	-- Make header the drag handle
	local drag = Draggable.new(window, header)

	window.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:focusWindow(window)
		end
	end)

	-- Entrance animation
	window.Size = UDim2.new(0, (size or UDim2.new(0, 520, 0, 380)).X.Offset, 0, 0)
	Animator.spring(window, "Size", size or UDim2.new(0, 520, 0, 380), { damping = 24, stiffness = 300 })

	self.zCounter = self.zCounter + 1
	self.windows[window] = {
		frame   = window,
		header  = header,
		tabRow  = tabRow,
		content = content,
		drag    = drag,
	}
	return self.windows[window]
end

function WindowManager:focusWindow(window)
	local data = self.windows[window]
	if not data then return end
	self.zCounter = self.zCounter + 1
	window.ZIndex = self.zCounter
	for _, el in pairs(window:GetDescendants()) do
		if el:IsA("GuiObject") then
			el.ZIndex = window.ZIndex + 1
		end
	end
end

function WindowManager:destroyWindow(window)
	local data = self.windows[window]
	if not data then return end
	if data.drag then data.drag:Destroy() end
	window:Destroy()
	self.windows[window] = nil
end

return WindowManager
