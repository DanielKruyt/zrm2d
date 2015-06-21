
require "util"
--json = assert(loadfile("json_be.lua"))()
resource_cache = {}
resource_cache.resources = {}


local fileformats = {
	['png'] = love.graphics.newImage,
	['jpg'] = love.graphics.newImage,
	['bmp'] = love.graphics.newImage,
	['wav'] = love.audio.newSource,
	['ogg'] = love.audio.newSource,
	['mp3'] = love.audio.newSource
}

function resource_cache.new()
	return util.deepcopy(resource_cache)
end

function resource_cache.add(self,filename,tag)
	local t = string.split(filename,"%.")
	local dat = nil
	if fileformats[t[#t]] then
		dat = fileformats[t[#t]](filename)
	else
		return false
	end
	self.resources[tag] = dat
	return true
end

function resource_cache.preload(self,filename)
	local f = io.open(filename,"r")
	if not f then return false end
	local c = f:read("*all")
	f:close()

	local t = json:decode(c)
	for k,v in pairs(t) do
		local f = io.open(v.filename,"r")
		if not f then return false end
		f:close()
		self:add(v.filename,v.tag)
	end
	return true
end

function resource_cache.fetch(self,tag)
	return self.resources[tag]
end

