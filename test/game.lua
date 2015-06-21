
require "resourcecache"
require "gamemode_environment"

game = {}
game.mode_env = {}
game.rcache = {}
	function game.load(self,filename)
		-- load gamemode
			-- rcache
		self.rcache = resource_cache.new()
			-- built-in hooks
		self.events.bools.load = {hooks={},value=false}
		self.events.bools.pretick = {hooks={},value=false}
		self.events.bools.posttick = {hooks={},value=false}

		self.events.lists.join = {hooks={},value={}}
		self.events.lists.leave = {hooks={},value={}}
		self.events.lists.msg = {hooks={},value={}}
			-- loadfile
		self.mode_env = gamemode_env(self)
		local f = loadfile(filename, nil, self.mode_env)
		f()
			-- initiate
		if not self.events.bools.load.hook[1] then
			print("No load hook!!")
			return false
		end
		self.events.bools.load.hook[1]()
			-- done
	end

	function game.update(self,dt)
		self:pretick(dt)
		self:update_map(dt)
		self:update_objects(dt)
		self:update_projectiles(dt)
		self:update_actors(dt)
		self:posttick(dt)
	end

	function game.draw()
	end

