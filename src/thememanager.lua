local Utils = _VertexRequire("src/utils.lua")

local ThemeManager = {}
ThemeManager.__index = ThemeManager

-- Each theme: bg, surface, surfaceHigh, border, text, subtext, accent
local THEMES = {
	Dark = {
		name       = "Dark",
		bg         = Color3.fromRGB( 12,  12,  18),
		surface    = Color3.fromRGB( 24,  24,  36),
		surfaceHigh= Color3.fromRGB( 34,  34,  50),
		border     = Color3.fromRGB( 58,  58,  82),
		text       = Color3.fromRGB(232, 232, 245),
		subtext    = Color3.fromRGB(138, 138, 162),
		accent     = Utils.hexToColor3("#0A84FF"),
	},
	Light = {
		name       = "Light",
		bg         = Color3.fromRGB(232, 232, 240),
		surface    = Color3.fromRGB(248, 248, 252),
		surfaceHigh= Color3.fromRGB(255, 255, 255),
		border     = Color3.fromRGB(195, 195, 212),
		text       = Color3.fromRGB( 18,  18,  28),
		subtext    = Color3.fromRGB(102, 102, 120),
		accent     = Utils.hexToColor3("#0A84FF"),
	},
}

function ThemeManager.new()
	local self = setmetatable({}, ThemeManager)
	self._themes    = THEMES
	self._current   = THEMES.Dark
	self._listeners = {}
	return self
end

function ThemeManager:get()
	return self._current
end

-- back-compat alias
function ThemeManager:getTheme()
	return self._current
end

function ThemeManager:set(name)
	if self._themes[name] then
		self._current = self._themes[name]
		self:_emit()
	end
end

function ThemeManager:setTheme(name)
	self:set(name)
end

function ThemeManager:setAccent(color)
	self._current = Utils.copy(self._current)
	self._current.accent = color
	self:_emit()
end

function ThemeManager:register(name, def)
	self._themes[name] = def
end

function ThemeManager:registerTheme(name, def)
	self:register(name, def)
end

function ThemeManager:onChange(fn)
	table.insert(self._listeners, fn)
	return { Disconnect = function()
		for i, v in ipairs(self._listeners) do
			if v == fn then table.remove(self._listeners, i); break end
		end
	end }
end

function ThemeManager:_emit()
	for _, fn in ipairs(self._listeners) do fn(self._current) end
end

return ThemeManager
