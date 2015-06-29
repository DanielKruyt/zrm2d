
require "util"

map = {}
map.entities = {} -- TODO: map entities
map.tileset = {quad={},attrib={},spritebatch={},detail={}}
map.page = {}
map.default_tile = 0

function map.new()
	return util.deepcopy(map)
end

--------------------------------------------------------------------------------
-- get/set section
--------------------------------------------------------------------------------



function map:get_tile(x,y)
	local px, py = math.floor(x/16), math.floor(y/16)
	if not self.page[py] or not self.page[py][px] then
		return self.default_tile
	end
	return self.page[py][px][ x%16 + 16*(y%16) ]
end



function map:set_tile(x,y,tilenum)
	local px, py = math.floor(x/16), math.floor(y/16)
	if not self.page[py] then
		self.page[py] = {}
	end
	if not self.page[py][px] then
		self.page[py][px] = {}
		for i = 0, 255 do
			self.page[py][px][i] = self.default_tile
		end
	end
	self.pages[py][px][ x-16*px + 16*(y-16*py) ] = tilenum
end



function map:get_tile_attrib(attrib,tilenum)
	if self.tileset.attrib[attrib] then
		if self.tileset.attrib[attrib][tilenum] then
			return true
		else
			return false
		end
	else
		return false
	end
end



function map:set_tile_attrib(attrib,tilenum,state)
	self.tileset.attrib[attrib][tilenum] = state
end



--------------------------------------------------------------------------------
-- collision section
--------------------------------------------------------------------------------



function map:test_box(px,py,r)
	if         self:get_tile_attrib("obstacle",self:get_tile(math.floor(px-r/2),math.floor(py-r/2)))
		or self:get_tile_attrib("obstacle",self:get_tile(math.floor(px-r/2),math.floor(py+r/2)))
		or self:get_tile_attrib("obstacle",self:get_tile(math.floor(px+r/2),math.floor(py+r/2)))
		or self:get_tile_attrib("obstacle",self:get_tile(math.floor(px+r/2),math.floor(py-r/2)))
	then
		return true
	else
		return false
	end
end



function map:box_push(px, py, r, vx, vy)
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



--------------------------------------------------------------------------------
-- load/save section
--------------------------------------------------------------------------------


function map:add_tileset(filename)
	print("function map:add_tileset(filename)")
		-- read tileset descriptor file
	local f = io.open("tiles/"..filename..".tile","rb")
	if not f then
		print("Attempted to add tileset which does not exist: "..filename)
		return false
	end

	local c = f:read("*all")
	f:close()

	if c:sub(1,5) ~= "ZRMTS" then
		print("Attempted to load tileset from invalid file: "..filename)
		return false
	end
	c = c:sub(6)
	c = c:sub(4) -- trimming version for now TODO: fix/continue this
	local index = 0
	if self.tileset.quad[0] then
		index = #self.tileset.quad + 1	
	end
	if not self.tileset.detail[index] then self.tileset.detail[index] = {} end
	
		-- read width, height and number of attributes
	local w, h = string.byte(c:sub(1)), string.byte(c:sub(2))
	self.tileset.detail[index].name = filename
	self.tileset.detail[index].width = w
	self.tileset.detail[index].height = h
	local num_attrib = string.byte(c:sub(3))-- + 256*string.byte(c:sub(4))
	c = c:sub(4)
		-- read attributes
	print('a1')
	local tile_attrs = {} 
	print('num_attrib', num_attrib)
	for i = 0, num_attrib-1 do
		local as, j = "", 1
		while c:sub(j,j) ~= "\x00" do
			as = as..c:sub(j,j)
			j = j + 1
		end
		print(as)
		local num_t = string.byte(c:sub(j+1))
		c = c:sub(j+2)
		tile_attrs[as] = {}

		for j = 1,num_t do
			tile_attrs[as]
				[string.byte(c:sub(j))] = true
			c = c:sub(2)
		end
	end
	print('a2')
		-- load image and create spritebatch for this tileset
	-- TODO: error message if image file missing when adding tileset; map:add_tileset
	local img = love.graphics.newImage("tiles/"..filename..".png")
	local sb = love.graphics.newSpriteBatch(img, 1000, "stream")



	
	for k,v in pairs(tile_attrs) do
		if not self.tileset.attrib[k] then self.tileset.attrib[k] = {} end
		for l,u in pairs(v) do
			self.tileset.attrib[k][index*256 + l] = true
		end
	end
	print('a3')
	self.tileset.quad[index] = {}
	self.tileset.spritebatch[index] = sb
	local qt = self.tileset.quad[index]

	local width, height = img:getWidth()/48, img:getHeight()/48
	for y = 0, height-1 do
		for x = 0, width-1 do
			qt[x + width*y] = love.graphics.newQuad(
				48*x, 48*y, 48,48,
				img:getWidth(), img:getHeight()
			)
		end
	end

	print(" END function map:add_tileset(filename)")
	return true
end

function map:load_ext(t,l,c)
	local x = util.deepcopy(c)
	if t == 1 then -- tileset descriptor

		local i = 1
		while string.byte(x:sub(i)) ~= 0 do
			i = i + 1
		end
		local filename = x:sub(1,i-1)
		x = x:sub(i)

		if not self:add_tileset(filename) then
			return false
		end

	elseif t == 2 then -- page descriptor

		local num_pages = string.byte(x:sub(1)) + string.byte(x:sub(2))*2^8 +
			string.byte(x:sub(3))*2^16 + string.byte(x:sub(4))*2^24
		print('num_pages',num_pages)
		x = x:sub(5)
		for i = 0, num_pages-1 do
			local p = {}
			local px = string.byte(x:sub(1)) + string.byte(x:sub(2))*2^8
			local py = string.byte(x:sub(3)) + string.byte(x:sub(4))*2^8
			print('page',i,'x|y',px,py)
			x = x:sub(5)

			for j = 0, 255 do
				p[j] = string.byte(x:sub(1+2*j))*256 + 
				string.byte(x:sub(2+2*j))
			end
			if not self.page[py] then self.page[py] = {} end
			self.page[py][px] = p
			x = x:sub(513)
		end

	elseif t == 3 then -- entity descriptor

		print("TODO: map:load_ext; option t == 3; entity descriptor")

	else -- unknown extention type

		print("Attempted to load unknown extention type: "..t)
		return false

	end
end


function map:load(filename,check_hash)
		-- read file contents, if exists
	if not love.filesystem.exists("maps/"..filename..".map") then
		print("Attempted to load non-existent map: "..filename)
		return false
	end

	local f = io.open("maps/"..filename..".map")
	if not f then
		print("Attempted to load non-existent map: "..filename)
		return false
	end
	local c = f:read("*all")
	f:close()

	if c:sub(1,5) ~= "ZRM2D" then
		print("Attempted to load invalid map: "..filename)
		return false
	end
	
	local format_version = c:sub(6,8)
	c = c:sub(9)
	local num_ext = string.byte(c:sub(1)) + string.byte(c:sub(2))*2^8 +
		string.byte(c:sub(3))*2^16 + string.byte(c:sub(4))*2^24

	c = c:sub(5)
	if check_hash then
		local hash = string.byte(c:sub(1)) + string.byte(c:sub(2))*2^8 +
			string.byte(c:sub(3))*2^16 + string.byte(c:sub(4))*2^24
		local nhash = util.hash32(c:sub(5))
		
		if not (hash==nhash) then
			print("Attempted to load (corrupt) map: "..filename)
			return false
		end
	end
	local hash = string.byte(c:sub(1)) + string.byte(c:sub(2))*2^8 +
		string.byte(c:sub(3))*2^16 + string.byte(c:sub(4))*2^24
	c = c:sub(5)

	local n = 0
	while n < num_ext do
		local ext_type = string.byte(c:sub(1)) + string.byte(c:sub(2))*2^8 +
			string.byte(c:sub(3))*2^16 + string.byte(c:sub(4))*2^24
		local length = string.byte(c:sub(5)) + string.byte(c:sub(6))*2^8 +
			string.byte(c:sub(7))*2^16 + string.byte(c:sub(8))*2^24
		print('length: ',length)
		c = c:sub(9)
		self:load_ext(ext_type,length,c)
		c = c:sub(length+1)
		n = n + 1
	end
end
 

function map:save_tilesets()
	-- collect tileset infos
	local ts = {}
	local num_ts = #(self.tileset.quad)+1
	if not (num_ts == 1 and not self.tileset.quad[0]) then
		for attrib, tiles in pairs(self.tileset.attrib) do
			for i,_ in pairs(tiles) do
				if not ts[math.floor(i/256)+1] then ts[math.floor(i/256)+1] = {} end
				if not ts[math.floor(i/256)+1][attrib] then ts[math.floor(i/256)+1][attrib] = {} end 
				table.insert(ts[math.floor(i/256)+1][attrib], i%256)
			end
		end
		
		for i, v in ipairs(ts) do

		end
	end
end


function map:save(filename) -- TODO: finish map:save
	
	-- serialise tileset references
	-- serialise pages
	-- save map file
	
end

