local ThemeManager   = _VertexRequire("src/thememanager.lua")
local WindowManager  = _VertexRequire("src/windowmanager.lua")
local Core           = _VertexRequire("src/core.lua")
local Effects        = _VertexRequire("src/effects.lua")
local ConfigManager  = _VertexRequire("src/configmanager.lua")
local KeybindManager = _VertexRequire("src/keybindmanager.lua")
local TabBar         = _VertexRequire("src/components/tabbar.lua")
local Notification   = _VertexRequire("src/components/notification.lua")
local Tooltip        = _VertexRequire("src/components/tooltip.lua")
local Dropdown       = _VertexRequire("src/components/dropdown.lua")
local ColorPicker    = _VertexRequire("src/components/colorpicker.lua")
local ContextMenu    = _VertexRequire("src/components/contextmenu.lua")
local Dialog         = _VertexRequire("src/components/dialog.lua")

local UI = {}
UI.__index = UI

function UI.new(playerGui)
	local self = setmetatable({}, UI)

	self.theme   = ThemeManager.new()
	self.effects = Effects.new(self.theme)
	self.core    = Core.new(self.theme, self.effects)
	self.wm      = WindowManager.new(self.theme, self.effects, self.core)
	self.config  = ConfigManager.new("vertex.json")
	self.config:load()
	self.keybinds = KeybindManager.new()

	-- Restore saved theme
	local savedTheme = self.config:get("theme", nil)
	if savedTheme then self.theme:set(savedTheme) end

	self.gui = Instance.new("ScreenGui")
	self.gui.Name           = "Vertex"
	self.gui.ResetOnSpawn   = false
	self.gui.IgnoreGuiInset = true
	self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.gui.Parent         = playerGui

	self.notifications = Notification.new(self.theme, self.effects, self.gui)
	self.tooltip       = Tooltip.new(self.theme, self.effects, self.gui)
	self.contextMenu   = ContextMenu.new(self.theme, self.gui)
	self.dialog        = Dialog.new(self.theme, self.gui, self.core, self.effects)
	self.dropdowns     = Dropdown.new(self.theme, self.core)
	self.colorPickers  = ColorPicker.new(self.theme)

	-- Toggle keybind + floating button
	local toggleSig = self.keybinds:bind("toggle", Enum.KeyCode.RightControl)
	local _, floatSig = self.keybinds:floatingButton(self.gui)
	toggleSig:Connect(function() self:toggle() end)
	floatSig:Connect(function() self:toggle() end)

	self._windows = {}
	return self
end

-- ── Public API ────────────────────────────────────────────────────────────────

-- Create the default demo window. Scripts that build their own window
-- should call UI:newWindow() instead.
function UI:createWindow()
	return self:_buildDemoWindow()
end

-- Create a blank window and return {frame, header, tabRow, content}
-- Pass tabs = {{id, label}, ...} to get a TabBar installed automatically.
function UI:newWindow(title, size, tabs)
	local win = self.wm:createWindow(self.gui, title, size)
	if tabs then
		local tb = TabBar.new(self.theme):create(win.tabRow, tabs)
		win.tabBar = tb

		-- Auto-create page frames inside win.content keyed by tab id
		local pages = {}
		for i, def in ipairs(tabs) do
			local page = Instance.new("Frame")
			page.Name  = def.id
			page.Size  = UDim2.new(1, 0, 1, 0)
			page.BackgroundTransparency = 1
			page.Visible = (i == 1)
			page.ZIndex  = win.content.ZIndex + 1
			page.Parent  = win.content
			pages[def.id] = page
		end
		win.pages = pages

		tb.selected:Connect(function(id)
			for _, p in pairs(pages) do p.Visible = false end
			if pages[id] then pages[id].Visible = true end
		end)
	end
	table.insert(self._windows, win)
	return win
end

function UI:toggle()
	if not self._primaryWin then return end
	local f = self._primaryWin.frame
	f.Visible = not f.Visible
end

-- ── Demo window (shown on first load) ────────────────────────────────────────

function UI:_buildDemoWindow()
	local TABS = {
		{ id = "general",    label = "General" },
		{ id = "appearance", label = "Appearance" },
		{ id = "about",      label = "About" },
	}
	local win  = self:newWindow("Vertex", UDim2.new(0, 520, 0, 400), TABS)
	self._primaryWin = win
	local t    = self.theme:get()

	-- ── General ─────────────────────────────────────────────────
	local gp = win.pages.general
	local gz = gp.ZIndex + 1

	self.core:label({
		Parent = gp, Text = "Welcome to Vertex",
		TextSize = 20, Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 0), ZIndex = gz,
	})
	self.core:label({
		Parent = gp, Text = "macOS-style UI library for Roblox exploiting.",
		TextSize = 13, TextColor3 = t.subtext,
		Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 30), ZIndex = gz,
	})

	-- Separator
	local sep1 = Instance.new("Frame")
	sep1.Size  = UDim2.new(1, 0, 0, 1)
	sep1.Position = UDim2.new(0, 0, 0, 56)
	sep1.BackgroundColor3 = t.border
	sep1.BackgroundTransparency = 0.5
	sep1.BorderSizePixel = 0
	sep1.ZIndex = gz
	sep1.Parent = gp

	local notifBtn = self.core:button({
		Parent   = gp,
		Text     = "Show Notification",
		Size     = UDim2.new(0, 164, 0, 32),
		Position = UDim2.new(0, 0, 0, 68),
		Accent   = true,
		ZIndex   = gz,
	})
	notifBtn.activated:Connect(function()
		self.notifications:push("This is a Vertex notification.")
	end)
	self.tooltip:attach(notifBtn.instance, "Show a sample toast")

	local dialogBtn = self.core:button({
		Parent   = gp,
		Text     = "Show Dialog",
		Size     = UDim2.new(0, 140, 0, 32),
		Position = UDim2.new(0, 0, 0, 110),
		ZIndex   = gz,
	})
	dialogBtn.activated:Connect(function()
		local c = self.dialog:show("Confirm Action", "Are you sure you want to apply these settings?", {
			{ id = "cancel", label = "Cancel" },
			{ id = "apply",  label = "Apply",  primary = true },
		})
		c:Connect(function(id)
			if id == "apply" then self.notifications:push("Settings applied.") end
		end)
	end)

	-- Toggle demo
	self.core:label({
		Parent = gp, Text = "Enable feature",
		TextSize = 13, Size = UDim2.new(0, 110, 0, 20),
		Position = UDim2.new(0, 0, 0, 156), ZIndex = gz,
	})
	self.core:toggle({
		Parent   = gp,
		Position = UDim2.new(0, 120, 0, 154),
		ZIndex   = gz,
	})

	-- Slider demo
	self.core:label({
		Parent = gp, Text = "Speed",
		TextSize = 13, TextColor3 = t.subtext,
		Size = UDim2.new(0, 60, 0, 18), Position = UDim2.new(0, 0, 0, 190), ZIndex = gz,
	})
	self.core:slider({
		Parent   = gp,
		Min      = 0, Max = 100, Value = 50,
		Size     = UDim2.new(1, 0, 0, 36),
		Position = UDim2.new(0, 0, 0, 206),
		ZIndex   = gz,
	})

	-- Right-click label
	local ctxLbl = self.core:label({
		Parent = gp, Text = "Right-click anywhere here",
		TextSize = 12, TextColor3 = t.subtext,
		Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 252), ZIndex = gz,
	})
	self.contextMenu:attach(ctxLbl, {
		{ id = "ping",   label = "Ping" },
		{ id = "toggle", label = "Toggle Theme" },
	})

	-- ── Appearance ──────────────────────────────────────────────
	local ap = win.pages.appearance
	local az = ap.ZIndex + 1

	self.core:label({
		Parent = ap, Text = "Theme",
		TextSize = 12, TextColor3 = t.subtext,
		Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 0), ZIndex = az,
	})
	local dd = self.dropdowns:create(ap, {"Dark", "Light"}, self.theme:get().name)
	dd.holder.Position = UDim2.new(0, 0, 0, 20)
	dd.selected:Connect(function(name)
		self.theme:set(name)
		self.config:set("theme", name)
		self.config:save()
		self.notifications:push("Theme: " .. name)
	end)

	self.core:label({
		Parent = ap, Text = "Accent color",
		TextSize = 12, TextColor3 = t.subtext,
		Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 68), ZIndex = az,
	})
	local cp = self.colorPickers:create(ap, self.theme:get().accent)
	cp.holder.Position = UDim2.new(0, 0, 0, 88)
	cp.changed:Connect(function(color)
		self.theme:setAccent(color)
	end)

	-- ── About ───────────────────────────────────────────────────
	local ab = win.pages.about
	local bz = ab.ZIndex + 1

	self.core:label({
		Parent = ab, Text = "Vertex UI",
		TextSize = 22, Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 0), ZIndex = bz,
	})
	self.core:label({
		Parent = ab, Text = "A macOS-inspired UI library built for\nRoblox script executors.",
		TextSize = 13, TextColor3 = t.subtext, TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 44), Position = UDim2.new(0, 0, 0, 36), ZIndex = bz,
	})

	local lines = {
		"Toggle UI    →   Right Ctrl  /  floating button",
		"Close window →   red traffic light dot",
	}
	for i, line in ipairs(lines) do
		self.core:label({
			Parent = ab, Text = line,
			TextSize = 12, TextColor3 = t.subtext,
			Size = UDim2.new(1, 0, 0, 18),
			Position = UDim2.new(0, 0, 0, 88 + (i - 1) * 22),
			ZIndex = bz,
		})
	end

	return win
end

return UI
