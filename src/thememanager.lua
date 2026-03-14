local Utils = _VertexRequire("src/utils.lua")

local ThemeManager = {}
ThemeManager.__index = ThemeManager

local defaultLight = {
	name = "Light",
	background = Color3.fromRGB(240, 240, 245),
	layer = Color3.fromRGB(255, 255, 255),
	border = Color3.fromRGB(200, 200, 210),
	text = Color3.fromRGB(20, 20, 30),
	mutedText = Color3.fromRGB(110, 110, 120),
	glassOpacity = 0.3,
	accent = Utils.hexToColor3("#0A84FF"),
}

local defaultDark = {
	name = "Dark",
	background = Color3.fromRGB(8, 8, 12),
	layer = Color3.fromRGB(25, 25, 35),
	border = Color3.fromRGB(70, 70, 90),
	text = Color3.fromRGB(230, 230, 240),
	mutedText = Color3.fromRGB(150, 150, 170),
	glassOpacity = 0.35,
	accent = Utils.hexToColor3("#0A84FF"),
}

function ThemeManager.new()
	local self = setmetatable({}, ThemeManager)
	self._themes = {
		Light = defaultLight,
		Dark = defaultDark,
	}
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
	self:_emit()
end

function ThemeManager:setTheme(name)
	local theme = self._themes[name]
	if not theme then
		return
	end
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
				if v == fn then
					table.remove(self._listeners, i)
					break
				end
			end
		end,
	}
end

function ThemeManager:_emit()
	for _, fn in ipairs(self._listeners) do
		fn(self._current)
	end
end

return ThemeManager
