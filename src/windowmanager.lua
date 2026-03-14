local Draggable = _VertexRequire("src/draggable.lua")
local Utils     = _VertexRequire("src/utils.lua")
local Animator  = _VertexRequire("src/animator.lua")

-- Layout constants (pixels)
local H_HEADER  = 44
local H_TABROW  = 40
local H_TOP     = H_HEADER + H_TABROW   -- content Y start
local PAD_SIDE  = 18
local PAD_BOT   = 16

local WindowManager = {}
WindowManager.__index = WindowManager

function WindowManager.new(theme, effects, core)
	return setmetatable({
		theme = theme, effects = effects, core = core,
		windows = {}, _z = 50,
	}, WindowManager)
end

function WindowManager:_nextZ()
	self._z = self._z + 100
	return self._z
end

function WindowManager:createWindow(uiRoot, title, size)
	local t  = self.theme:get()
	local z  = self:_nextZ()
	size     = size or UDim2.new(0, 520, 0, 400)

	-- ── Outer container (transparent, just for clipping + positioning) ──
	local win = Instance.new("Frame")
	win.Name              = "VertexWindow"
	win.Size              = size
	win.Position          = UDim2.new(0.5, 0, 0.5, 0)
	win.AnchorPoint       = Vector2.new(0.5, 0.5)
	win.BackgroundTransparency = 1
	win.BorderSizePixel   = 0
	win.ClipsDescendants  = false
	win.ZIndex            = z
	win.Parent            = uiRoot

	-- ── Glass body (full window, sits at z) ──────────────────────
	local body = Instance.new("Frame")
	body.Name             = "Body"
	body.Size             = UDim2.new(1, 0, 1, 0)
	body.BackgroundTransparency = 1
	body.BorderSizePixel  = 0
	body.ZIndex           = z
	body.Parent           = win
	self.effects:glass(body, 14)

	-- drop shadow simulation (larger frame behind, darker, blurred by offset)
	local shadow = Instance.new("Frame")
	shadow.Name  = "Shadow"
	shadow.Size  = UDim2.new(1, 30, 1, 30)
	shadow.Position = UDim2.new(0, -15, 0, -10)
	shadow.AnchorPoint = Vector2.new(0, 0)
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.72
	shadow.BorderSizePixel = 0
	shadow.ZIndex = z - 1
	shadow.Parent = win
	Utils.corner(18).Parent = shadow

	-- ── Header (drag zone + traffic lights + title) ───────────────
	local header = Instance.new("Frame")
	header.Name             = "Header"
	header.Size             = UDim2.new(1, 0, 0, H_HEADER)
	header.Position         = UDim2.new(0, 0, 0, 0)
	header.BackgroundColor3 = t.surface
	header.BackgroundTransparency = 0.15
	header.BorderSizePixel  = 0
	header.ZIndex           = z + 2
	header.ClipsDescendants = true
	header.Parent           = win

	-- header: subtle gradient
	local hgrad = Instance.new("UIGradient")
	hgrad.Color = ColorSequence.new(t.surfaceHigh, t.surface)
	hgrad.Rotation = 90
	hgrad.Parent = header

	-- header bottom separator
	local sep = Instance.new("Frame")
	sep.Size             = UDim2.new(1, 0, 0, 1)
	sep.Position         = UDim2.new(0, 0, 1, -1)
	sep.BackgroundColor3 = t.border
	sep.BackgroundTransparency = 0.4
	sep.BorderSizePixel  = 0
	sep.ZIndex           = z + 3
	sep.Parent           = header

	-- traffic lights
	local DOTS = {
		{Color3.fromRGB(255, 95, 87),  "close"},
		{Color3.fromRGB(255, 189, 46), "min"},
		{Color3.fromRGB(40, 200, 64),  "max"},
	}
	for i, d in ipairs(DOTS) do
		local dot = Instance.new("Frame")
		dot.Name  = d[2]
		dot.Size  = UDim2.new(0, 12, 0, 12)
		dot.AnchorPoint = Vector2.new(0, 0.5)
		dot.Position = UDim2.new(0, 14 + (i-1) * 20, 0.5, 0)
		dot.BackgroundColor3 = d[1]
		dot.BackgroundTransparency = 0
		dot.BorderSizePixel = 0
		dot.ZIndex = z + 4
		dot.Parent = header
		Utils.corner(6).Parent = dot
	end

	-- close button on the red dot
	local closeDot = header:FindFirstChild("close")
	if closeDot then
		local cbtn = Instance.new("TextButton")
		cbtn.Size = UDim2.new(1,0,1,0)
		cbtn.BackgroundTransparency = 1
		cbtn.Text = ""
		cbtn.ZIndex = z + 5
		cbtn.Parent = closeDot
		cbtn.MouseButton1Click:Connect(function()
			Animator.spring(win, "BackgroundTransparency", 1, {stiffness=300, damping=26})
			task.delay(0.2, function()
				win.Visible = false
				win.BackgroundTransparency = 1
			end)
		end)
	end

	-- centered title
	local titleLbl = Instance.new("TextLabel")
	titleLbl.Name              = "Title"
	titleLbl.BackgroundTransparency = 1
	titleLbl.Size              = UDim2.new(1, -160, 1, 0)
	titleLbl.Position          = UDim2.new(0.5, 0, 0, 0)
	titleLbl.AnchorPoint       = Vector2.new(0.5, 0)
	titleLbl.Font               = Enum.Font.GothamSemibold
	titleLbl.TextSize           = 13
	titleLbl.TextColor3         = t.text
	titleLbl.Text               = title or "Vertex"
	titleLbl.TextXAlignment     = Enum.TextXAlignment.Center
	titleLbl.TextYAlignment     = Enum.TextYAlignment.Center
	titleLbl.ZIndex             = z + 4
	titleLbl.Parent             = header

	-- ── Tab row (populated by TabBar externally) ──────────────────
	local tabRow = Instance.new("Frame")
	tabRow.Name             = "TabRow"
	tabRow.Size             = UDim2.new(1, 0, 0, H_TABROW)
	tabRow.Position         = UDim2.new(0, 0, 0, H_HEADER)
	tabRow.BackgroundColor3 = t.surface
	tabRow.BackgroundTransparency = 0.20
	tabRow.BorderSizePixel  = 0
	tabRow.ZIndex           = z + 2
	tabRow.Parent           = win

	local tsep = Instance.new("Frame")
	tsep.Size             = UDim2.new(1, 0, 0, 1)
	tsep.Position         = UDim2.new(0, 0, 1, -1)
	tsep.BackgroundColor3 = t.border
	tsep.BackgroundTransparency = 0.4
	tsep.BorderSizePixel  = 0
	tsep.ZIndex           = z + 3
	tsep.Parent           = tabRow

	-- ── Content area ──────────────────────────────────────────────
	local content = Instance.new("Frame")
	content.Name             = "Content"
	content.BackgroundTransparency = 1
	content.Size             = UDim2.new(1, -(PAD_SIDE * 2), 1, -(H_TOP + PAD_BOT + 8))
	content.Position         = UDim2.new(0, PAD_SIDE, 0, H_TOP + 8)
	content.ZIndex           = z + 1
	content.Parent           = win

	-- Drag on header
	Draggable.new(win, header)

	-- Open animation: fade in + slight upward drift
	win.BackgroundTransparency = 1
	Animator.spring(win, "BackgroundTransparency", 0, {stiffness=280, damping=26})
	-- small position offset for entry feel
	local startPos = UDim2.new(0.5, 0, 0.5, 20)
	local endPos   = UDim2.new(0.5, 0, 0.5, 0)
	win.Position   = startPos
	Animator.spring(win, "Position", endPos, {stiffness=280, damping=26})

	local data = {
		frame   = win,
		header  = header,
		tabRow  = tabRow,
		content = content,
		z       = z,
	}
	self.windows[win] = data
	return data
end

-- Bring window to front
function WindowManager:focus(win)
	local data = self.windows[win]
	if not data then return end
	local newZ = self:_nextZ()
	-- update all ZIndex offsets relative to new base
	local oldZ = data.z
	for _, el in ipairs(win:GetDescendants()) do
		if el:IsA("GuiObject") then
			el.ZIndex = newZ + (el.ZIndex - oldZ)
		end
	end
	win.ZIndex = newZ
	data.z     = newZ
end

function WindowManager:focusWindow(win)
	self:focus(win)
end

return WindowManager
