-- Vertex UI — executor loader
-- Usage: loadstring(game:HttpGet("https://raw.githubusercontent.com/0Chessz0/Vertex-UI/main/main.lua"))()

-- Only load once per session — re-executing does nothing and returns the same instance
if _G._VertexLoaded then
	print("[Vertex] Already loaded, skipping.")
	return _G._VertexInstance
end
_G._VertexLoaded = true

local BASE  = "https://raw.githubusercontent.com/0Chessz0/Vertex-UI/main/"
local cache = {}

function _VertexRequire(path)
	if cache[path] then return cache[path] end
	local ok, src = pcall(game.HttpGet, game, BASE .. path)
	assert(ok, "[Vertex] HTTP failed: " .. path .. "\n" .. tostring(src))
	local fn, err = loadstring(src)
	assert(fn, "[Vertex] Compile error in " .. path .. "\n" .. tostring(err))
	local result = fn()
	cache[path] = result
	return result
end

local Players  = game:GetService("Players")
local VertexUI = _VertexRequire("src/ui.lua")
local ui       = VertexUI.new(Players.LocalPlayer:WaitForChild("PlayerGui"))
ui:createWindow()
_G._VertexInstance = ui
return ui
