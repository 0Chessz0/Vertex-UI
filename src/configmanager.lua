local Http = game:GetService("HttpService")

local ConfigManager = {}
ConfigManager.__index = ConfigManager

function ConfigManager.new(filename)
	return setmetatable({ name = filename or "vertex.json", data = {} }, ConfigManager)
end

function ConfigManager:load()
	if not (isfile and readfile) then return end
	if not isfile(self.name) then return end
	local ok, raw = pcall(readfile, self.name)
	if not ok then return end
	local ok2, decoded = pcall(Http.JSONDecode, Http, raw)
	if ok2 then self.data = decoded or {} end
end

function ConfigManager:save()
	if not writefile then return end
	pcall(writefile, self.name, Http:JSONEncode(self.data or {}))
end

function ConfigManager:get(path, default)
	local t = self.data
	for seg in path:gmatch("[^%.]+") do
		if type(t) ~= "table" or t[seg] == nil then return default end
		t = t[seg]
	end
	return t
end

function ConfigManager:set(path, value)
	local segs = {}
	for s in path:gmatch("[^%.]+") do table.insert(segs, s) end
	local t = self.data
	for i = 1, #segs - 1 do
		t[segs[i]] = type(t[segs[i]]) == "table" and t[segs[i]] or {}
		t = t[segs[i]]
	end
	t[segs[#segs]] = value
end

return ConfigManager
