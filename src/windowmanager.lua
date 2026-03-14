local Draggable = _VertexRequire("src/draggable.lua")
local Utils = _VertexRequire("src/utils.lua")
local Animator = _VertexRequire("src/animator.lua")

local WindowManager = {}
WindowManager.__index = WindowManager

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
	local window = Instance.new("Frame")
	window.Name = "VertexWindow"
	window.Size = size or UDim2.new(0, 420, 0, 320)
	window.BackgroundTransparency = 0.4
	window.BackgroundColor3 = theme.layer
	window.BorderSizePixel = 0
	window.Position = UDim2.new(0.5, -210, 0.5, -160)
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.ZIndex = self.zCounter
	window.Parent = uiRoot
	self.effects:applyGlass(window, theme.name == "Light")
	local dragBar = Instance.new("Frame")
	dragBar.Name = "TitleBar"
	dragBar.BackgroundTransparency = 1
	dragBar.Size = UDim2.new(1, -24, 0, 32)
	dragBar.Position = UDim2.new(0, 12, 0, 8)
	dragBar.ZIndex = window.ZIndex + 1
	dragBar.Parent = window
	local titleLabel = self.core:createTextLabel({
		Parent = dragBar,
		Text = title or "Vertex",
		TextSize = 16,
		TextColor3 = theme.text,
	})
	titleLabel.Size = UDim2.new(1, -120, 1, 0)
	titleLabel.Position = UDim2.new(0, 0, 0, 0)
	local searchBox = self.core:createTextbox({
		Parent = dragBar,
		Name = "Search",
		PlaceholderText = "Search",
		Size = UDim2.new(0, 140, 0, 24),
		Position = UDim2.new(1, -140, 0.5, -12),
		ZIndex = dragBar.ZIndex + 1,
	})
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, -24, 1, -56)
	content.Position = UDim2.new(0, 12, 0, 44)
	content.ZIndex = window.ZIndex + 1
	content.Parent = window
	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Vertical
	list.Padding = UDim.new(0, 8)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = content
	local drag = Draggable.new(window, dragBar)
	window.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:focusWindow(window)
		end
	end)
	self.zCounter = self.zCounter + 1
	self.windows[window] = {
		frame = window,
		content = content,
		titleBar = dragBar,
		search = searchBox,
		drag = drag,
	}
	return self.windows[window]
end

function WindowManager:focusWindow(window)
	local data = self.windows[window]
	if not data then
		return
	end
	self.zCounter = self.zCounter + 1
	window.ZIndex = self.zCounter
	for _, element in pairs(window:GetDescendants()) do
		if element:IsA("GuiObject") then
			element.ZIndex = window.ZIndex + (element.ZIndex - window.ZIndex)
		end
	end
	Animator.spring(window, "BackgroundTransparency", 0.35, {
		damping = 20,
		stiffness = 220,
	})
	for otherWindow, otherData in pairs(self.windows) do
		if otherWindow ~= window then
			Animator.spring(otherWindow, "BackgroundTransparency", 0.45, {
				damping = 20,
				stiffness = 220,
			})
		end
	end
end

function WindowManager:destroyWindow(window)
	local data = self.windows[window]
	if not data then
		return
	end
	if data.drag then
		data.drag:Destroy()
	end
	window:Destroy()
	self.windows[window] = nil
end

return WindowManager
