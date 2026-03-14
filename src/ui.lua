local ThemeManager   = _VertexRequire("src/thememanager.lua")
local WindowManager  = _VertexRequire("src/windowmanager.lua")
local Core           = _VertexRequire("src/core.lua")
local Effects        = _VertexRequire("src/effects.lua")
local Notification   = _VertexRequire("src/components/notification.lua")
local Dropdown       = _VertexRequire("src/components/dropdown.lua")
local ColorPicker    = _VertexRequire("src/components/colorpicker.lua")
local Tooltip        = _VertexRequire("src/components/tooltip.lua")
local ContextMenu    = _VertexRequire("src/components/contextmenu.lua")
local Dialog         = _VertexRequire("src/components/dialog.lua")
local TabBar         = _VertexRequire("src/components/tabbar.lua")
local KeybindManager = _VertexRequire("src/keybindmanager.lua")
local ConfigManager  = _VertexRequire("src/configmanager.lua")

local UI = {}
UI.__index = UI

function UI.new(playerGui)
	local self = setmetatable({}, UI)
	self.playerGui = playerGui
	self.themeManager = ThemeManager.new()
	self.effects = Effects.new(self.themeManager)
	self.core = Core.new(self.themeManager, self.effects)
	self.windowManager = WindowManager.new(self.themeManager, self.effects, self.core)
	self.config = ConfigManager.new("vertex-config.json")
	self.config:load()
	self.keybinds = KeybindManager.new()

	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "Vertex"
	self.screenGui.ResetOnSpawn = false
	self.screenGui.IgnoreGuiInset = true
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.Parent = self.playerGui

	self.notifications    = Notification.new(self.themeManager, self.effects, self.screenGui)
	self.tooltip          = Tooltip.new(self.themeManager, self.effects, self.screenGui)
	self.contextMenu      = ContextMenu.new(self.themeManager, self.screenGui)
	self.dialog           = Dialog.new(self.themeManager, self.screenGui, self.core, self.effects)
	self.dropdownFactory  = Dropdown.new(self.themeManager, self.core)
	self.colorPickerFactory = ColorPicker.new(self.themeManager)

	self:_setupKeybinds()
	return self
end

function UI:_setupKeybinds()
	local openSignal = self.keybinds:bind("toggleVertex", Enum.KeyCode.RightControl)
	local _, buttonSignal = self.keybinds:createFloatingButton(self.screenGui)
	openSignal:Connect(function() self:togglePrimaryWindow() end)
	buttonSignal:Connect(function() self:togglePrimaryWindow() end)
end

function UI:createPrimaryWindow()
	if self.primaryWindow then return self.primaryWindow end
	local window = self.windowManager:createWindow(self.screenGui, "Vertex", UDim2.new(0, 520, 0, 380))
	self.primaryWindow = window
	self:_populatePrimaryWindow(window)
	return window
end

function UI:togglePrimaryWindow()
	if not self.primaryWindow then
		self:createPrimaryWindow()
		return
	end
	local frame = self.primaryWindow.frame
	frame.Visible = not frame.Visible
	if frame.Visible then
		self.windowManager:focusWindow(frame)
	end
end

function UI:_populatePrimaryWindow(window)
	local tabRow = window.tabRow
	local content = window.content

	local tabs = {
		{ id = "general",    label = "General" },
		{ id = "appearance", label = "Appearance" },
		{ id = "about",      label = "About" },
	}

	-- Build tab bar inside the tabRow zone
	local tb = TabBar.new(self.themeManager):create(tabRow, tabs)
	self.tabBar = tb

	-- Page frames
	local pages = {}
	for i, def in ipairs(tabs) do
		local page = Instance.new("Frame")
		page.Name = def.id
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.Visible = (i == 1)
		page.ZIndex = content.ZIndex + 1
		page.Parent = content
		pages[def.id] = page
	end

	tb.selected:Connect(function(id)
		for _, page in pairs(pages) do page.Visible = false end
		if pages[id] then pages[id].Visible = true end
	end)

	-- ── General page ─────────────────────────────────────────────
	local gp = pages.general
	local z = gp.ZIndex + 1

	self.core:createTextLabel({
		Parent = gp, Text = "Welcome to Vertex.",
		TextSize = 18, Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.new(0, 0, 0, 0), ZIndex = z,
	})

	self.core:createTextLabel({
		Parent = gp, Text = "macOS-inspired UI library for Roblox.",
		TextSize = 13, Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 0, 0, 28), ZIndex = z,
		TextColor3 = self.themeManager:getTheme().mutedText,
	})

	local notifBtn = self.core:createButton({
		Parent = gp, Text = "Show Notification",
		Size = UDim2.new(0, 160, 0, 32),
		Position = UDim2.new(0, 0, 0, 64),
		Accent = true, ZIndex = z,
	})
	notifBtn.activated:Connect(function()
		self.notifications:push("This is a Vertex notification.")
	end)
	self.tooltip:attach(notifBtn.instance, "Show a sample toast notification.")

	local dialogBtn = self.core:createButton({
		Parent = gp, Text = "Show Dialog",
		Size = UDim2.new(0, 140, 0, 32),
		Position = UDim2.new(0, 0, 0, 104), ZIndex = z,
	})
	dialogBtn.activated:Connect(function()
		local chosen = self.dialog:show("Confirm", "Apply the current settings?", {
			{ id = "cancel", label = "Cancel" },
			{ id = "apply",  label = "Apply", primary = true },
		})
		chosen:Connect(function(id)
			if id == "apply" then self.notifications:push("Settings applied.") end
		end)
	end)

	local ctxLabel = self.core:createTextLabel({
		Parent = gp, Text = "Right-click here for context menu.",
		TextSize = 13, Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.new(0, 0, 0, 148), ZIndex = z,
		TextColor3 = self.themeManager:getTheme().mutedText,
	})
	self.contextMenu:attach(ctxLabel, {
		{ id = "ping",  label = "Ping" },
		{ id = "theme", label = "Toggle Theme" },
	})

	-- ── Appearance page ──────────────────────────────────────────
	local ap = pages.appearance
	local az = ap.ZIndex + 1

	self.core:createTextLabel({
		Parent = ap, Text = "Appearance",
		TextSize = 18, Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.new(0, 0, 0, 0), ZIndex = az,
	})
	self.core:createTextLabel({
		Parent = ap, Text = "Theme",
		TextSize = 13, Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.new(0, 0, 0, 36), ZIndex = az,
		TextColor3 = self.themeManager:getTheme().mutedText,
	})

	local themeDD = self.dropdownFactory:create(ap, { "Dark", "Light" }, self.themeManager:getTheme().name)
	themeDD.holder.Position = UDim2.new(0, 0, 0, 56)
	themeDD.selected:Connect(function(name)
		self.themeManager:setTheme(name)
		self.config:set("theme.name", name)
		self.config:save()
		self.notifications:push("Theme set to " .. name)
	end)

	self.core:createTextLabel({
		Parent = ap, Text = "Accent Color",
		TextSize = 13, Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.new(0, 0, 0, 100), ZIndex = az,
		TextColor3 = self.themeManager:getTheme().mutedText,
	})
	local picker = self.colorPickerFactory:create(ap, self.themeManager:getTheme().accent)
	picker.holder.Position = UDim2.new(0, 0, 0, 120)
	picker.changed:Connect(function(color)
		self.themeManager:setAccent(color)
		self.config:set("theme.accent", { color.R, color.G, color.B })
		self.config:save()
	end)

	-- ── About page ───────────────────────────────────────────────
	local ab = pages.about
	local bz = ab.ZIndex + 1

	self.core:createTextLabel({
		Parent = ab, Text = "Vertex UI",
		TextSize = 22, Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.new(0, 0, 0, 0), ZIndex = bz,
	})
	self.core:createTextLabel({
		Parent = ab, Text = "A macOS-inspired UI library for Roblox exploiting.",
		TextSize = 13, Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.new(0, 0, 0, 36), ZIndex = bz,
		TextColor3 = self.themeManager:getTheme().mutedText,
	})
	self.core:createTextLabel({
		Parent = ab, Text = "Toggle UI:  Right Ctrl  or  floating button",
		TextSize = 12, Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 0, 0, 82), ZIndex = bz,
		TextColor3 = self.themeManager:getTheme().mutedText,
	})
end

return UI
