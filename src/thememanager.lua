local Utils = _VertexRequire("src/utils.lua")

local ThemeManager = {}
ThemeManager.__index = ThemeManager

local defaultDark = {
	name = "Dark",
	background    = Color3.fromRGB(10, 10, 16),
	header        = Color3.fromRGB(18, 18, 26),
	layer         = Color3.fromRGB(22, 22, 32),
	layerHover    = Color3.fromRGB(32, 32, 46),
	border        = Color3.fromRGB(55, 55, 75),
	separator     = Color3.fromRGB(40, 40, 58),
	text          = Color3.fromRGB(235, 235, 245),
	mutedText     = Color3.fromRGB(140, 140, 165),
	glassTop      = Color3.fromRGB(38, 38, 54),
	glassBottom   = Color3.fromRGB(12, 12, 20),
	glassOpacity  = 0.08,
	accent        = Utils.hexToColor3("#0A84FF"),
	accentGlow    = Utils.hexToColor3("#0A84FF"),
}

local defaultLight = {
	name = "Light",
	background    = Color3.fromRGB(235, 235, 242),
	header        = Color3.fromRGB(248, 248, 252),
	layer         = Color3.fromRGB(255, 255, 255),
	layerHover    = Color3.fromRGB(240, 240, 248),
	border        = Color3.fromRGB(195, 195, 210),
	separator     = Color3.fromRGB(215, 215, 228),
	text          = Color3.fromRGB(18, 18, 26),
	mutedText     = Color3.fromRGB(105, 105, 122),
	glassTop      = Color3.fromRGB(255, 255, 255),
	glassBottom   = Color3.fromRGB(220, 220, 232),
	glassOpacity  = 0.12,
	accent        = Utils.hexToColor3("#0A84FF"),
	accentGlow    = Utils.hexToColor3("#0A84FF"),
}

function ThemeManager.new()
	local self = setmetatable({}, ThemeManager)
	self._themes = { Dark = defaultDark, Light = defaultLight }
	self._current = self._themes.Dark
	self._listeners = {}
	return self
end

function ThemeManager:getTheme()
	return self._current
end

function ThemeManager:setAccent(color3)
	self._current = Utils.shallowCopy(self._current)
	self._current.accent = color3
	self._current.accentGlow = color3
	self:_emit()
end

function ThemeManager:setTheme(name)
	local theme = self._themes[name]
	if not theme then return end
	self._current = theme
	self:_emit()
end

function ThemeManager:registerTheme(name, definition)
	self._themes[name] = definition
end

function ThemeManager:onChanged(fn)
	table.insert(self._listeners, fn)
	fn(self._current)
	return {
		Disconnect = function()
			for i, v in ipairs(self._listeners) do
				if v == fn then table.remove(self._listeners, i) break end
			end
		end,
	}
end

function ThemeManager:_emit()
	for _, fn in ipairs(self._listeners) do fn(self._current) end
end

return ThemeManager
