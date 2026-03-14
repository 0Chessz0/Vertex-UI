local HttpService = game:GetService("HttpService")

local ConfigManager = {}
ConfigManager.__index = ConfigManager

function ConfigManager.new(name)
	local self = setmetatable({}, ConfigManager)
	self.name = name or "vertex-config.json"
	self.data = {}
	return self
end

function ConfigManager:load()
	if not isfile or not readfile then
		return
	end
	if not isfile(self.name) then
		return
	end
	local ok, content = pcall(readfile, self.name)
	if not ok then
		return
	end
	local success, decoded = pcall(HttpService.JSONDecode, HttpService, content)
	if not success then
		return
	end
	self.data = decoded or {}
end

function ConfigManager:save()
	if not writefile then
		return
	end
	local encoded = HttpService:JSONEncode(self.data or {})
	pcall(writefile, self.name, encoded)
end

function ConfigManager:get(path, defaultValue)
	local segments = {}
	for segment in string.gmatch(path, "[^%.]+") do
		table.insert(segments, segment)
	end
	local current = self.data
	for i = 1, #segments do
		local key = segments[i]
		if current[key] == nil then
			return defaultValue
		end
		current = current[key]
	end
	return current
end

function ConfigManager:set(path, value)
	local segments = {}
	for segment in string.gmatch(path, "[^%.]+") do
		table.insert(segments, segment)
	end
	local current = self.data
	for i = 1, #segments - 1 do
		local key = segments[i]
		current[key] = current[key] or {}
		current = current[key]
	end
	current[segments[#segments]] = value
end

return ConfigManager

