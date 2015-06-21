
map = {}
map.entities = {}
map.tilesets = {}
map.pages = {}
map.tile_attribs = {}
map.default_tile = 0

function map.new()
	return util.deepcopy(map)
end

function map.load_tilesets(self,filenames)
	for i=1,#filenames do
		local f = io.open(filename[i],"rb")
		if not f then return false end

		local c = f:read("*all")
		if c:sub(1,5) ~= "ZRMTS" then return false end
		c = c:sub(6)
		local p = 1
		local fn = ""
		while string.byte(c:sub(p,p)) ~= 0 do
			fn = fn..c:sub(p,p)
		end
		c = c:sub(fn:len()+2)

		local imgf = io.open("gfx/tiles/"..filename)
		if not imgf then return false end
		imgf:close()

		local tileset_img = love.graphics.newImage("gfx/tiles/"..filename)
		local width_in_tiles = math.floor(tileset_img:getWidth()/48)
		local height_in_tiles = math.floor(tileset_img:getHeight()/48)

		if c:len() ~= width_in_tiles*height_in_tiles then
			return false
		end

		local tiletypes = {}
		for y = 0, height_in_tiles-1 do
			for x = 0, width_in_tiles-1 do
				local tt = string.byte(c:sub(y*width_in_tiles+x)) 
				table.insert(tiletypes,tt)
			end
		end

		local quads = {}
		for y = 0, height_in_tiles-1 do
			for x = 0, width_in_tiles-1 do
				table.insert( quads,
					love.graphics.newQuad(
						x*48,y*48,48,48, tileset_img:getDimensions()
					)
				)
			end
		end

		local ts = {}
		ts.types = tiletypes
		ts.quads = quads
		ts.spritebatch = love.graphics.newSpriteBatch(tileset_img)
		table.insert(self.tilesets,ts)
	end
end
function map.load_from_file(self,filename)
	local f = io.open(filename,"rb")
	if not f then
		return false
	end

	local c = f:read("*all")
	f:close()

	if c:sub(1,5) ~= "ZRM2D" then
		return false
	end
	local version = c:sub(6,8)
	local ext_count = c:sub(9,12)
	local hash = c:sub(13,16)

	c = c:sub(17)
	local nhash = util.hash32()
	-- convert hash from string to number, assuming little endian store
	hash = string.byte(hash:sub(1))      + string.byte(hash:sub(2))*2^8 +
		   string.byte(hash:sub(3))*2^16 + string.byte(hash:sub(4))*2^24
	
	if nhash ~= hash then
		return false
	end

	while c ~= "" do
		local t = c:sub(1,4)
		t = string.byte(t:sub(1))      + string.byte(t:sub(2))*2^8 +
			string.byte(t:sub(3))*2^16 + string.byte(t:sub(4))*2^24
		if t == 1 then -- tileset descriptors
			c = c:sub(5)
			local numsets = string.byte(c:sub(1)) + string.byte(c:sub(2))*2^8 +
				string.byte(c:sub(3))*2^16 + string.byte(c:sub(4))*2^24
			c = c:sub(5)
			
			local strs = {}
			local s = ""
			local p = 1 
			local i = 0
			while i < numsets do
				if string.byte(c:sub(p,p)) == 0 then
					strs:insert(s)
					s = ""
					i = i + 1
				else
					s = s..c:sub(p,p)
				end
				p = p + 1
			end
			if not self:load_tilesets(strs) then
				return false
			end
		elseif t == 2 then -- tile pages
			c = c:sub(5)
			local np = c:sub(1,4)
			np = string.byte(np:sub(1))     + string.byte(np:sub(2))*2^8 +
				string.byte(np:sub(3))*2^16 + string.byte(np:sub(4))*2^24
			c = c:sub(5)
			for i =1, np do
				local px = string.byte(c:sub(1)) + string.byte(c:sub(2))*2^8
				local py = string.byte(c:sub(3)) + string.byte(c:sub(4))*2^8
				local pstr = c:sub(5,5+512)
				
				--TODO: sane page layout structure, map.load_from_file
				local p = {}

				for j = 1, pstr:len() do
					table.insert(p, string.byte(pstr:sub(2*j))
						+ string.byte(pstr:sub(2*j+1))*2^8)
				end
				if not self.pages[py] then
					self.pages[py] = {}
				end

				self.pages[py][px] = p
			end
		elseif t == 3 then -- entities
			c = c:sub(5)
			-- fuck this for tonight! :D TODO: entities in map:load_from_file
		else
			return false
		end
			
	end

	return true
end

function map.save_to_file(self,filename)
end

function map.get_tile_at(self,x,y)
	local px = math.floor(x/16)
	local py = math.floor(y/16)

	if not self.pages[py] then
		return self.default_tile
	elseif not self.pages[py][px] then
		return self.default_tile
	else
		return self.pages[py][px][1+math.floor(x-px) + 16*math.floor(y-py)]
	end
end

function map.set_tile_at(self,x,y, tilenum)
	local px,py = math.floor(x/16), math.floor(y/16)

	if not self.pages[py] then self.pages[py] = {} end
	if not self.pages[py][px] then
		self.pages[py][px] = {}
		for i = 1, 256 do
			self.pages[py][px][i] = self.default_tile
		end
		self.pages[py][px][1+math.floor(x)+math.floor(y)*16] = tilenum
	end
end

function map.tile_attrib(self,tilenum,attrib)
	if self.tile_attribs[attrib][tilenum] then
		return true
	else
		return false
	end
end

function map.test_box(self,px,py,r)
	print(self:get_tile_at(px-r/2,py-r/2))
	if self:tile_attrib(self:get_tile_at(px-r/2,py-r/2),"obstacle")
		or self:tile_attrib(self:get_tile_at(px-r/2,py+r/2),"obstacle")
		or self:tile_attrib(self:get_tile_at(px+r/2,py+r/2),"obstacle")
		or self:tile_attrib(self:get_tile_at(px+r/2,py-r/2),"obstacle")
	then
		return true
	else
		return false
	end
end
--[[
function map.line_intersect(self,x,y,m)
	local cx, cy = 0, 0
	local hit = false
	while not hit do

	end
end]]
function map.box_push(self, px, py, r, vx, vy)
	-- TODO: map.box_push for large r, and generalise to rectangles
	local mag = math.sqrt(vx^2 + vy^2)
	local step = mag/(math.ceil(mag)+1)
	local stepx = 0
	local stepy = 0
	if mag > 0 then
		stepx = step*vx/mag
		stepy = step*vy/mag
	end

	local x,y = px,py
	for i = 1, math.ceil(mag)+1 do
		local nx, ny = x+stepx, y+stepy
		if self:test_box(nx,ny,r) then
			local count = 0
			if self:test_box(nx,y,r) then
				nx = x --this is working kinda

				count = count + 1
			end
			if self:test_box(x,ny,r) then
				ny = y
				count = count + 1
			end
			if count == 0 then -- not a clue
				ny = y
				nx = x
			end
		end
		x = nx; y = ny
	end
	return x,y -- return position after attempted movement by vector v
end

