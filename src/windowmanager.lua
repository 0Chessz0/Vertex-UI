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

	local W = size.X.Offset
	local H = size.Y.Offset

	-- ── Outer container (transparent, just for clipping + positioning) ──
	local win = Instance.new("Frame")
	win.Name              = "VertexWindow"
	win.Size              = size
	-- AnchorPoint MUST be (0,0) so that draggable's offset math works correctly.
	-- We fake centering by subtracting half-size from the scale-based position.
	win.AnchorPoint       = Vector2.new(0, 0)
	win.Position          = UDim2.new(0.5, -W / 2, 0.5, -H / 2)
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

	-- Traffic light buttons
	-- close = hide, min = shade to header only, max = toggle expand
	local minDot   = header:FindFirstChild("min")
	local maxDot   = header:FindFirstChild("max")
	local closeDot = header:FindFirstChild("close")

	local minimised = false
	local maximised = false
	local savedSize = size
	local savedPos  = nil   -- set after entrance anim

	local function makeTrafficBtn(dot, fn)
		if not dot then return end
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1,0,1,0)
		b.BackgroundTransparency = 1
		b.Text = ""
		b.ZIndex = z + 5
		b.Parent = dot
		b.MouseButton1Click:Connect(fn)
	end

	-- Close: fade out + hide
	makeTrafficBtn(closeDot, function()
		Animator.spring(win, "BackgroundTransparency", 1, {stiffness=300, damping=26})
		task.delay(0.22, function()
			if win then win.Visible = false; win.BackgroundTransparency = 1 end
		end)
	end)

	-- Minimise (yellow): shade window down to just the header bar
	makeTrafficBtn(minDot, function()
		savedPos = savedPos or win.Position
		if not minimised then
			minimised = true
			-- collapse to header height only
			Animator.spring(win, "Size", UDim2.new(0, W, 0, H_HEADER), {stiffness=320, damping=28})
		else
			minimised = false
			Animator.spring(win, "Size", maximised
				and UDim2.new(0, uiRoot.AbsoluteSize.X - 40, 0, uiRoot.AbsoluteSize.Y - 40)
				or savedSize,
				{stiffness=320, damping=28}
			)
		end
	end)

	-- Maximise (green): toggle between original size and near-fullscreen
	makeTrafficBtn(maxDot, function()
		savedPos = savedPos or win.Position
		if not maximised then
			maximised = true
			minimised = false
			local sw = uiRoot.AbsoluteSize.X
			local sh = uiRoot.AbsoluteSize.Y
			Animator.spring(win, "Size",     UDim2.new(0, sw - 40, 0, sh - 40),    {stiffness=320, damping=28})
			Animator.spring(win, "Position", UDim2.new(0, 20, 0, 20),              {stiffness=320, damping=28})
		else
			maximised = false
			Animator.spring(win, "Size",     savedSize, {stiffness=320, damping=28})
			Animator.spring(win, "Position", savedPos,  {stiffness=320, damping=28})
		end
	end)

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

	-- Open animation: fade in + slight upward drift into place
	local cx = 0.5 * (uiRoot.AbsoluteSize.X > 0 and uiRoot.AbsoluteSize.X or 800)
	local cy = 0.5 * (uiRoot.AbsoluteSize.Y > 0 and uiRoot.AbsoluteSize.Y or 600)
	win.Position = UDim2.new(0, cx - W / 2, 0, cy - H / 2 + 18)
	win.BackgroundTransparency = 1
	Animator.spring(win, "Position", UDim2.new(0, cx - W / 2, 0, cy - H / 2), {stiffness=300, damping=28})
	Animator.spring(win, "BackgroundTransparency", 0, {stiffness=300, damping=28})

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
