local BASE = "https://raw.githubusercontent.com/0Chessz0/Vertex-UI/main/"
local cache = {}

function _VertexRequire(path)
	if cache[path] then return cache[path] end
	local src = game:HttpGet(BASE .. path)
	local fn = assert(loadstring(src), "[Vertex] Failed to compile: " .. path)
	local result = fn()
	cache[path] = result
	return result
end

local Players = game:GetService("Players")

local VertexUI = _VertexRequire("src/ui.lua")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local ui = VertexUI.new(playerGui)

ui:createPrimaryWindow()

return ui
