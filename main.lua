-- Vertex UI — executor loader
-- Usage: loadstring(game:HttpGet("https://raw.githubusercontent.com/0Chessz0/Vertex-UI/main/main.lua"))()

if _G._VertexLoaded then
	print("[Vertex] Already loaded.")
	return _G._VertexInstance
end
_G._VertexLoaded = true

local BASE  = "https://raw.githubusercontent.com/0Chessz0/Vertex-UI/main/"
local cache = {}

-- ── Loading screen (shown immediately, before any HTTP) ───────────────────────
local Players   = game:GetService("Players")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local loadGui = Instance.new("ScreenGui")
loadGui.Name           = "VertexLoader"
loadGui.ResetOnSpawn   = false
loadGui.IgnoreGuiInset = true
loadGui.DisplayOrder   = 9999
loadGui.Parent         = playerGui

local bg = Instance.new("Frame")
bg.Size                  = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3      = Color3.fromRGB(10, 10, 16)
bg.BackgroundTransparency = 0
bg.BorderSizePixel        = 0
bg.ZIndex                 = 1
bg.Parent                 = loadGui

-- Centered logo (black logo → tint white via ImageColor3)
local logo = Instance.new("ImageLabel")
logo.Size               = UDim2.new(0, 90, 0, 90)
logo.AnchorPoint        = Vector2.new(0.5, 0.5)
logo.Position           = UDim2.new(0.5, 0, 0.5, -24)
logo.BackgroundTransparency = 1
logo.Image              = "https://raw.githubusercontent.com/0Chessz0/Vertex-UI/main/assets/logo.png"
logo.ImageColor3        = Color3.fromRGB(255, 255, 255)   -- invert black→white
logo.ScaleType          = Enum.ScaleType.Fit
logo.ZIndex             = 2
logo.Parent             = bg

local loadLbl = Instance.new("TextLabel")
loadLbl.Size               = UDim2.new(0, 200, 0, 22)
loadLbl.AnchorPoint        = Vector2.new(0.5, 0.5)
loadLbl.Position           = UDim2.new(0.5, 0, 0.5, 44)
loadLbl.BackgroundTransparency = 1
loadLbl.Font               = Enum.Font.Gotham
loadLbl.TextSize           = 13
loadLbl.TextColor3         = Color3.fromRGB(130, 130, 155)
loadLbl.Text               = "Loading Vertex…"
loadLbl.ZIndex             = 2
loadLbl.Parent             = bg

-- Thin progress line at bottom
local bar = Instance.new("Frame")
bar.Size              = UDim2.new(0, 0, 0, 2)
bar.Position          = UDim2.new(0, 0, 1, -2)
bar.BackgroundColor3  = Color3.fromRGB(10, 132, 255)
bar.BackgroundTransparency = 0
bar.BorderSizePixel   = 0
bar.ZIndex            = 3
bar.Parent            = bg

-- ── Module loader ─────────────────────────────────────────────────────────────
local FILES = {
	"src/signal.lua", "src/utils.lua", "src/animator.lua",
	"src/thememanager.lua", "src/effects.lua", "src/draggable.lua",
	"src/configmanager.lua", "src/keybindmanager.lua", "src/core.lua",
	"src/windowmanager.lua",
	"src/components/tabbar.lua", "src/components/notification.lua",
	"src/components/tooltip.lua", "src/components/dropdown.lua",
	"src/components/colorpicker.lua", "src/components/contextmenu.lua",
	"src/components/dialog.lua",
	"src/ui.lua",
}
local total = #FILES
local loaded = 0

function _VertexRequire(path)
	if cache[path] then return cache[path] end
	local ok, src = pcall(game.HttpGet, game, BASE .. path)
	assert(ok, "[Vertex] HTTP failed: " .. path .. "\n" .. tostring(src))
	local fn, err = loadstring(src)
	assert(fn, "[Vertex] Compile error in " .. path .. "\n" .. tostring(err))
	local result = fn()
	cache[path] = result
	loaded = loaded + 1
	-- update progress bar
	bar.Size = UDim2.new(loaded / total, 0, 0, 2)
	return result
end

-- Preload everything in order so the progress bar animates
for _, path in ipairs(FILES) do
	_VertexRequire(path)
end

-- ── Dismiss loading screen ────────────────────────────────────────────────────
task.delay(0.3, function()
	-- fade out
	for i = 1, 10 do
		bg.BackgroundTransparency = i / 10
		logo.ImageTransparency    = i / 10
		loadLbl.TextTransparency  = i / 10
		task.wait(0.03)
	end
	loadGui:Destroy()
end)

-- ── Boot Vertex ───────────────────────────────────────────────────────────────
local VertexUI = cache["src/ui.lua"]
local ui       = VertexUI.new(playerGui)
ui:createWindow()
_G._VertexInstance = ui
return ui
