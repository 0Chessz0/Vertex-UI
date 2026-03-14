local ThemeManager = _VertexRequire("src/thememanager.lua")
local WindowManager = _VertexRequire("src/windowmanager.lua")
local Core = _VertexRequire("src/core.lua")
local Effects = _VertexRequire("src/effects.lua")
local Notification = _VertexRequire("src/components/notification.lua")
local Dropdown = _VertexRequire("src/components/dropdown.lua")
local ColorPicker = _VertexRequire("src/components/colorpicker.lua")
local Tooltip = _VertexRequire("src/components/tooltip.lua")
local ContextMenu = _VertexRequire("src/components/contextmenu.lua")
local Dialog = _VertexRequire("src/components/dialog.lua")
local TabBar = _VertexRequire("src/components/tabbar.lua")
local KeybindManager = _VertexRequire("src/keybindmanager.lua")
local ConfigManager = _VertexRequire("src/configmanager.lua")

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
	self.notifications = Notification.new(self.themeManager, self.effects, self.screenGui)
	self.tooltip = Tooltip.new(self.themeManager, self.effects, self.screenGui)
	self.contextMenu = ContextMenu.new(self.themeManager, self.screenGui)
	self.dialog = Dialog.new(self.themeManager, self.screenGui, self.core, self.effects)
	self.tabBar = nil
	self.dropdownFactory = Dropdown.new(self.themeManager, self.core)
	self.colorPickerFactory = ColorPicker.new(self.themeManager)
	self:_setupKeybinds()
	return self
end

function UI:_setupKeybinds()
	local openSignal = self.keybinds:bind("toggleVertex", Enum.KeyCode.RightControl)
	local button, buttonSignal = self.keybinds:createFloatingButton(self.screenGui)
	openSignal:Connect(function()
		self:togglePrimaryWindow()
	end)
	buttonSignal:Connect(function()
		self:togglePrimaryWindow()
	end)
end

function UI:createPrimaryWindow()
	if self.primaryWindow then
		return self.primaryWindow
	end
	local window = self.windowManager:createWindow(self.screenGui, "Vertex", UDim2.new(0, 520, 0, 360))
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
	local content = window.content
	local tabs = {
		{ id = "general", label = "General" },
		{ id = "appearance", label = "Appearance" },
		{ id = "about", label = "About" },
	}
	self.tabBar = TabBar.new(self.themeManager):create(window.frame, tabs)
	self.tabBar.selected:Connect(function(id)
		for _, child in ipairs(content:GetChildren()) do
			if child:IsA("Frame") then
				child.Visible = false
			end
		end
		local target = content:FindFirstChild(id, true)
		if target then
			target.Visible = true
		end
	end)
	local generalPage = Instance.new("Frame")
	generalPage.Name = "general"
	generalPage.Size = UDim2.new(1, 0, 1, 0)
	generalPage.BackgroundTransparency = 1
	generalPage.ZIndex = content.ZIndex + 1
	generalPage.Parent = content
	local appearancePage = Instance.new("Frame")
	appearancePage.Name = "appearance"
	appearancePage.Size = UDim2.new(1, 0, 1, 0)
	appearancePage.BackgroundTransparency = 1
	appearancePage.Visible = false
	appearancePage.ZIndex = content.ZIndex + 1
	appearancePage.Parent = content
	local aboutPage = Instance.new("Frame")
	aboutPage.Name = "about"
	aboutPage.Size = UDim2.new(1, 0, 1, 0)
	aboutPage.BackgroundTransparency = 1
	aboutPage.Visible = false
	aboutPage.ZIndex = content.ZIndex + 1
	aboutPage.Parent = content
	local generalLabel = self.core:createTextLabel({
		Parent = generalPage,
		Text = "Welcome to Vertex.",
		TextSize = 18,
		Size = UDim2.new(1, -24, 0, 28),
		Position = UDim2.new(0, 12, 0, 8),
		ZIndex = generalPage.ZIndex + 1,
	})
	local appearanceLabel = self.core:createTextLabel({
		Parent = appearancePage,
		Text = "Appearance",
		TextSize = 18,
		Size = UDim2.new(1, -24, 0, 28),
		Position = UDim2.new(0, 12, 0, 8),
		ZIndex = appearancePage.ZIndex + 1,
	})
	local aboutLabel = self.core:createTextLabel({
		Parent = aboutPage,
		Text = "Vertex UI Library",
		TextSize = 18,
		Size = UDim2.new(1, -24, 0, 28),
		Position = UDim2.new(0, 12, 0, 8),
		ZIndex = aboutPage.ZIndex + 1,
	})
	local themeDropdown = self.dropdownFactory:create(appearancePage, { "Dark", "Light" }, self.themeManager:getTheme().name)
	themeDropdown.holder.Position = UDim2.new(0, 16, 0, 56)
	themeDropdown.selected:Connect(function(name)
		self.themeManager:setTheme(name)
		self.config:set("theme.name", name)
		self.config:save()
		self.notifications:push("Theme set to " .. name)
	end)
	local picker = self.colorPickerFactory:create(appearancePage, self.themeManager:getTheme().accent)
	picker.holder.Position = UDim2.new(0, 16, 0, 100)
	picker.changed:Connect(function(color)
		self.themeManager:setAccent(color)
		self.config:set("theme.accent", { color.R, color.G, color.B })
		self.config:save()
	end)
	local notifBtn = self.core:createButton({
		Parent = generalPage,
		Text = "Show Notification",
		Size = UDim2.new(0, 160, 0, 30),
		Position = UDim2.new(0, 12, 0, 56),
		Accent = true,
		ZIndex = generalPage.ZIndex + 1,
	})
	notifBtn.activated:Connect(function()
		self.notifications:push("This is a Vertex notification.")
	end)
	self.tooltip:attach(notifBtn.instance, "Show a sample toast notification.")
	local dialogBtn = self.core:createButton({
		Parent = generalPage,
		Text = "Show Dialog",
		Size = UDim2.new(0, 140, 0, 30),
		Position = UDim2.new(0, 12, 0, 96),
		ZIndex = generalPage.ZIndex + 1,
	})
	dialogBtn.activated:Connect(function()
		local chosen = self.dialog:show("Confirm", "Apply the current settings?", {
			{ id = "cancel", label = "Cancel" },
			{ id = "apply", label = "Apply", primary = true },
		})
		chosen:Connect(function(id)
			if id == "apply" then
				self.notifications:push("Settings applied.")
			end
		end)
	end)
	local contextLabel = self.core:createTextLabel({
		Parent = generalPage,
		Text = "Right-click here for context menu.",
		TextSize = 14,
		Size = UDim2.new(1, -24, 0, 28),
		Position = UDim2.new(0, 12, 0, 140),
		ZIndex = generalPage.ZIndex + 1,
	})
	self.contextMenu:attach(contextLabel, {
		{ id = "ping", label = "Ping" },
		{ id = "theme", label = "Toggle Theme" },
	})
	self.tabBar.selectTab(1)
end

return UI
