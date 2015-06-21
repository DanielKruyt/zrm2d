
require "resourcecache"
require "gamemode_environment"
require "util"
require "map"
require "camera"

game = {}
game.mode_env = {}
game.rcache = {}
game.objects = {}
game.projectiles = {}
game.events = {bools={},lists={}}
game.map = {}
game.actors = {
	types = {},
	instances = {}
}

function game.load(self,filename)
	-- load gamemode
		-- rcache
	self.rcache = resource_cache.new()
	self.map = map.new()
	self.camera = camera.new()
		-- built-in hooks
	
	self.events.bools.load = {hooks={},value=false}
	self.events.bools.pretick = {hooks={},value=false}
	self.events.bools.posttick = {hooks={},value=false}

	self.events.lists.join = {hooks={},value={}}
	self.events.lists.leave = {hooks={},value={}}
	self.events.lists.msg = {hooks={},value={}}
		-- loadfile
	self.mode_env = gamemode_env(self)
	if filename then
		local f = loadfile(filename, nil, self.mode_env)
		f()
	end
		-- initiate
	if not self.events.bools.load.hooks[1] then
		print("No load hook!!")
		return false
	end
	self.events.bools.load.hook[1]()
		-- done
end


function game.update(self,dt)
	self:pretick(dt)

	self:update_map(dt) -- TODO: game.update_map
	-- TODO: projectiles and objects
	--self:update_objects(dt)
	--self:update_projectiles(dt)
	self:update_actors(dt)

	self:process_events()
	self:posttick(dt)
end
firstdraw = true
function game:draw()
	-- for each drawable
	-- if drawable.aabb intersects viewport
	-- put into drawlist
	local is, ie = math.floor(self.camera.x-10), math.ceil(self.camera.x+10)
	local js, je = math.floor(self.camera.y-8), math.ceil(self.camera.y+8)
	local drawlist = {}
	-- TODO: fix sprite batches
	local c = 0
	for i = is, ie do
		for j = js, je do
			local tilenum = self.map:get_tile(i,j)
			local x,y = self.camera:world_to_camera(i,j)
			if not drawlist[math.floor(tilenum/256)] then drawlist[math.floor(tilenum/256)] = {} end
			table.insert(drawlist[math.floor(tilenum/256)],{tilenum%256,x,y})
			c = c + 1
		end
	end
	print(c)
	for k,v in pairs(drawlist) do
		self.map.tileset.spritebatch[k]:clear()
		self.map.tileset.spritebatch[k]:bind()
		for l,u in pairs(v) do
			self.map.tilesets[k+1].spritebatch:add(
				self.map.tilesets[k+1].quads[u[1]+1], u[2], u[3]
			)
		end
		self.map.tilesets[k+1].spritebatch:unbind()
		love.graphics.draw(self.map.tilesets[k+1].spritebatch)
	end

	if firstdraw then firstdraw = false end

	for k,v in pairs(self.map.tilesets) do
		love.graphics.draw(v.spritebatch)
	end
	-- sort drawlist by 'height'
	-- draw everything in sorted order of lowest to heighest height
end

function game:new()
	return util.deepcopy(game)
end


--------------------------------------------------------------------------------


function game:process_events()
	for _,e in pairs(self.events.bools) do
		if e.value then
			for k,v in pairs(e.hooks) do
				v()
			end
		end
	end
	for _,e in pairs(self.events.lists) do
		if e.value ~= {} then
			for _,v in pairs(e.value) do
				for _,h in pairs(e.hooks) do
					h(v)
				end
			end
		end
	end
end

function game:update_actors(dt)
	for k,a in pairs(self.actors) do
		self.actors[k]:controller(dt)
	end
end

function game:update_map(dt)
	-- ? TODO: game.update_map
end


--------------------------------------------------------------------------------


function game:pretick()
	self.events.bools.pretick.hooks[1]()
end

function game:posttick()
	self.events.bools.posttick.hooks[1]()
end 

function game:trigger(e,s)
	if self.events.bools[e] then
		self.events.bools[e].value = true
	elseif self.events.lists[e] then
		table.insert(self.events.lists[e].value,s)
	else
		print("Attempted to trigger non-existent event: event = "..e)
	end
end

