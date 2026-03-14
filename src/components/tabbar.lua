local Animator = _VertexRequire("src/animator.lua")
local Utils    = _VertexRequire("src/utils.lua")
local Signal   = _VertexRequire("src/signal.lua")

local TabBar = {}
TabBar.__index = TabBar

local TAB_W   = 80   -- fixed tab width
local TAB_H   = 26   -- height of each tab
local PAD     = 4    -- left padding + gap between tabs
local PILL_H  = TAB_H + 8   -- pill container height (vertical padding = 4 each side)

function TabBar.new(theme)
	return setmetatable({ theme = theme }, TabBar)
end

-- tabRow: the Frame from WindowManager.tabRow
-- tabs: array of {id, label}
function TabBar:create(tabRow, tabs)
	local t        = self.theme:get()
	local n        = #tabs
	local pillW    = PAD + n * TAB_W + (n - 1) * PAD + PAD  -- 4 + n*80 + (n-1)*4 + 4

	-- Pill background
	local pill = Instance.new("Frame")
	pill.Name              = "Pill"
	pill.Size              = UDim2.new(0, pillW, 0, PILL_H)
	pill.AnchorPoint       = Vector2.new(0, 0.5)
	pill.Position          = UDim2.new(0, 14, 0.5, 0)
	pill.BackgroundColor3  = t.surface
	pill.BackgroundTransparency = 0.45
	pill.BorderSizePixel   = 0
	pill.ZIndex            = tabRow.ZIndex + 1
	pill.Parent            = tabRow
	Utils.corner(PILL_H / 2).Parent = pill
	Utils.stroke(1, t.border, 0.45).Parent = pill

	-- Sliding indicator — positioned mathematically, never touches AbsolutePosition
	local ind = Instance.new("Frame")
	ind.Name              = "Indicator"
	ind.Size              = UDim2.new(0, TAB_W, 0, TAB_H)
	ind.Position          = UDim2.new(0, PAD, 0, 4)   -- starts at first tab
	ind.BackgroundColor3  = t.accent
	ind.BackgroundTransparency = 0.80
	ind.BorderSizePixel   = 0
	ind.ZIndex            = pill.ZIndex + 1
	ind.Parent            = pill
	Utils.corner(TAB_H / 2).Parent = ind
	Utils.stroke(1, t.accent, 0.45).Parent = ind

	-- Tab buttons via UIListLayout + UIPadding so positions are deterministic
	local layout = Utils.listLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center, PAD)
	layout.Parent = pill
	Utils.padding(0, PAD, PAD, 0, 0).Parent = pill

	local sig     = Signal.new()
	local buttons = {}
	local current = 0

	-- Calculate indicator X for tab index i (math only, no AbsolutePosition)
	local function indicatorX(i)
		-- left padding = PAD, then (i-1) tabs of width TAB_W with PAD gap between
		return PAD + (i - 1) * (TAB_W + PAD)
	end

	local function select(i)
		if i == current then return end
		current = i

		-- slide indicator
		Animator.spring(ind, "Position", UDim2.new(0, indicatorX(i), 0, 4), {stiffness=360, damping=28})
		Animator.spring(ind, "Size",     UDim2.new(0, TAB_W, 0, TAB_H),     {stiffness=360, damping=28})

		-- text color
		for j, btn in ipairs(buttons) do
			Animator.spring(btn, "TextColor3",
				j == i and t.text or t.subtext,
				{stiffness=260, damping=22}
			)
		end

		sig:Fire(tabs[i].id or tabs[i].label)
	end

	for i, def in ipairs(tabs) do
		local btn = Instance.new("TextButton")
		btn.Name               = "Tab_" .. (def.id or i)
		btn.Size               = UDim2.new(0, TAB_W, 0, TAB_H)
		btn.BackgroundTransparency = 1
		btn.AutoButtonColor    = false
		btn.Text               = def.label
		btn.Font               = Enum.Font.GothamMedium
		btn.TextSize           = 13
		btn.TextColor3         = t.subtext
		btn.ZIndex             = pill.ZIndex + 2
		btn.Parent             = pill
		buttons[i]             = btn

		btn.MouseButton1Click:Connect(function() select(i) end)
	end

	-- select first tab immediately (no defer needed since we use math)
	select(1)

	return {
		pill      = pill,
		selected  = sig,
		selectTab = select,
	}
end

return TabBar
