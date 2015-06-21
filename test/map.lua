
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

function map.tile_attrib(self,tilenum,attrib)
	return self.tile_attribs[attrib][tilenum]
end

function map.box_push(self, px, py, r, vx, vy)
	-- TODO: map.box_push for large r, and generalise to rectangles
	local mag = math.sqrt(vx^2 + vy^2)
	local step = mag/math.ceil(mag)
	local stepx = step*vx/mag
	local stepy = step*vy/mag
	local c1x, c1y = px-r/2, py+r/2; local c2x, c2y = px+r/2, py+r/2
	local c3x, c3y = px-r/2, py-r/2; local c4x, c4y = px+r/2, py-r/2

	for i = 1, math.ceil(mag) do
		c1x = c1x + stepx; c1y = c1y + stepy;   c2x = c2x + stepx; c2y = c2y + stepy
		c3x = c3x + stepx; c3y = c3y + stepy;   c4x = c4x + stepx; c4y = c4y + stepy
		local dx, dy = 0, 0
		print(self:get_tile_at(c1x,c1y),"x: "..c1x.." y: "..c1y)
		if self:tile_attrib(self:get_tile_at(c1x,c1y),'obstacle') then
			-- determine which face
			local flx = math.floor(c1x)
			local fly = math.floor(c1y)
			local clx = math.ceil(c1x)
			local cly = math.ceil(c1y)
			local m = (vy/vx)
			local c = py - m*px
			
			local i1 = (c-fly)/m
			local i2 = m*flx + c
			local i3 = (c-cly)/m
			local i4 = m*clx + c

			local f1 = util.between(i1,flx,clx) and vy > 0
			local f2 = util.between(i2,fly,cly) and vx < 0
			local f3 = util.between(i3,flx,clx) and vy < 0
			local f4 = util.between(i4,fly,cly) and vx > 0
			-- move back by normal to face
			if f1 then
				dy = fly - c1y
			elseif f2 then
				dx = clx - c1x
			elseif f3 then
				dy = cly - c1y
			elseif f4 then
				dx = flx - c1x
			end
		end
		if self:tile_attrib(self:get_tile_at(c2x,c2y),'obstacle') then
			-- determine which face
			local flx = math.floor(c2x)
			local fly = math.floor(c2y)
			local clx = math.ceil(c2x)
			local cly = math.ceil(c2y)
			local m = (vy/vx)
			local c = py - m*px
			
			local i1 = (c-fly)/m
			local i2 = m*flx + c
			local i3 = (c-cly)/m
			local i4 = m*clx + c

			local f1 = util.between(i1,flx,clx) and vy > 0
			local f2 = util.between(i2,fly,cly) and vx < 0
			local f3 = util.between(i3,flx,clx) and vy < 0
			local f4 = util.between(i4,fly,cly) and vx > 0
			-- move back by normal to face
			if f1 then
				dy = fly - c2y
			elseif f2 then
				dx = clx - c2x
			elseif f3 then
				dy = cly - c2y
			elseif f4 then
				dx = flx - c2x
			end
		end
		if self:tile_attrib(self:get_tile_at(c3x,c3y),'obstacle') then
			-- determine which face
			local flx = math.floor(c3x)
			local fly = math.floor(c3y)
			local clx = math.ceil(c3x)
			local cly = math.ceil(c3y)
			local m = (vy/vx)
			local c = py - m*px
			
			local i1 = (c-fly)/m
			local i2 = m*flx + c
			local i3 = (c-cly)/m
			local i4 = m*clx + c

			local f1 = util.between(i1,flx,clx) and vy > 0
			local f2 = util.between(i2,fly,cly) and vx < 0
			local f3 = util.between(i3,flx,clx) and vy < 0
			local f4 = util.between(i4,fly,cly) and vx > 0
			-- move back by normal to face
			if f1 then
				dy = fly - c3y
			elseif f2 then
				dx = clx - c3x
			elseif f3 then
				dy = cly - c3y
			elseif f4 then
				dx = flx - c3x
			end
		end
		if self:tile_attrib(self:get_tile_at(c4x,c4y),'obstacle') then
			-- determine which face
			local flx = math.floor(c4x)
			local fly = math.floor(c4y)
			local clx = math.ceil(c4x)
			local cly = math.ceil(c4y)
			local m = (vy/vx)
			local c = py - m*px
			
			local i1 = (c-fly)/m
			local i2 = m*flx + c
			local i3 = (c-cly)/m
			local i4 = m*clx + c

			local f1 = util.between(i1,flx,clx) and vy > 0
			local f2 = util.between(i2,fly,cly) and vx < 0
			local f3 = util.between(i3,flx,clx) and vy < 0
			local f4 = util.between(i4,fly,cly) and vx > 0
			-- move back by normal to face
			if f1 then
				dy = fly - c4y
			elseif f2 then
				dx = clx - c4x
			elseif f3 then
				dy = cly - c4y
			elseif f4 then
				dx = flx - c4x
			end
		end

		c1x = c1x + dx; c1y = c1y + dy;   c2x = c2x + dx; c2y = c2y + dy
		c3x = c3x + dx; c3y = c3y + dy;   c4x = c4x + dx; c4y = c4y + dy
	end
	return (c1x+r/2), (c1y-r/2) -- return position after attempted movement by vector v
end

