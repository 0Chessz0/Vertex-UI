local Animator = _VertexRequire("src/animator.lua")
local Utils    = _VertexRequire("src/utils.lua")
local Signal   = _VertexRequire("src/signal.lua")

local TabBar = {}
TabBar.__index = TabBar

local TAB_W  = 80    -- width of each tab button
local TAB_H  = 26    -- height of each tab button
local PAD    = 4     -- outer padding + gap between tabs
local PILL_H = TAB_H + PAD * 2  -- total pill height

function TabBar.new(theme)
	return setmetatable({ theme = theme }, TabBar)
end

-- tabRow : the Frame from WindowManager
-- tabs   : array of { id, label }
function TabBar:create(tabRow, tabs)
	local t   = self.theme:get()
	local n   = #tabs
	-- pill width = left_pad + (n tabs * width) + ((n-1) gaps) + right_pad
	local pillW = PAD + n * TAB_W + (n - 1) * PAD + PAD

	-- ── Pill container ─────────────────────────────────────────────
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

	-- ── Sliding indicator — child of pill but NO layout on it ──────
	-- IMPORTANT: we do NOT use UIListLayout on the pill itself because
	-- UIListLayout overrides Position on ALL children, which would
	-- fight with the spring animation on the indicator.
	-- Instead we position everything with pure math.
	local ind = Instance.new("Frame")
	ind.Name              = "Indicator"
	ind.Size              = UDim2.new(0, TAB_W, 0, TAB_H)
	ind.Position          = UDim2.new(0, PAD, 0, PAD)  -- starts at tab 1
	ind.BackgroundColor3  = t.accent
	ind.BackgroundTransparency = 0.80
	ind.BorderSizePixel   = 0
	ind.ZIndex            = pill.ZIndex + 1
	ind.Parent            = pill
	Utils.corner(TAB_H / 2).Parent = ind
	Utils.stroke(1, t.accent, 0.45).Parent = ind

	-- ── Tab buttons — manually positioned, no layout ───────────────
	local sig     = Signal.new()
	local buttons = {}
	local current = 0

	-- Pure math: X position of indicator (and button) for tab index i
	local function tabX(i)
		return PAD + (i - 1) * (TAB_W + PAD)
	end

	local function select(i)
		if i == current then return end
		current = i

		-- Spring indicator to this tab
		Animator.spring(ind, "Position", UDim2.new(0, tabX(i), 0, PAD), {stiffness=380, damping=30})

		-- Text color for all buttons
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
		btn.Position           = UDim2.new(0, tabX(i), 0, PAD)  -- manually placed
		btn.BackgroundTransparency = 1
		btn.AutoButtonColor    = false
		btn.Text               = def.label
		btn.Font               = Enum.Font.GothamMedium
		btn.TextSize           = 13
		btn.TextColor3         = t.subtext
		btn.ZIndex             = pill.ZIndex + 2   -- above indicator
		btn.Parent             = pill
		buttons[i]             = btn

		btn.MouseButton1Click:Connect(function() select(i) end)
	end

	-- Select the first tab immediately — no defer needed, pure math
	select(1)

	return {
		pill      = pill,
		selected  = sig,
		selectTab = select,
	}
end

return TabBar
