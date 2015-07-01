
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
	local tile_attrs = {} 
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

	return true
end

function map:new_tileset(name)
	
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
			local px = (string.byte(x:sub(1)) + string.byte(x:sub(2))*2^8)-2^15
			local py = (string.byte(x:sub(3)) + string.byte(x:sub(4))*2^8)-2^15
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
	local version = "\x00\x00\x00"
	local ts = {}
	local num_ts = #(self.tileset.quad)+1
	if not (num_ts == 1 and not self.tileset.quad[0]) then
		for attrib, tiles in pairs(self.tileset.attrib) do
			for i,_ in pairs(tiles) do
				if not ts[math.floor(i/256)] then ts[math.floor(i/256)] = {} end
				if not ts[math.floor(i/256)][attrib] then ts[math.floor(i/256)][attrib] = {} end 
				table.insert(ts[math.floor(i/256)][attrib], i%256)
			end
		end
		
		for i=0,#i do
			local f = io.open("tiles/"..self.tileset.detail[i]..".tile","wb")
			f:write("ZRMTS"..version)
			f:write(string.char(self.tileset.detail[i].width))
			f:write(string.char(self.tileset.detail[i].height))
			local num_attribs = 0
			for _,_ in pairs(ts[i]) do num_attribs = num_attribs + 1 end
			f:write(string.char(num_attribs))
			for attrib, tiles in pairs(ts[i]) do
				f:write(attrib.."\x00")
				if not (#tiles==0 and not tiles[0]) then
					f:write(string.char(#tiles+1))
					for j=0,#tiles do
						f:write(string.char(tiles[j]))
					end
				else
					f:write("\x00")
				end
			end
			f:close()
		end
	end
end


function map:save(filename) -- TODO: finish map:save (entities?)
	local version = "\x00\x00\x00"
	self:save_tilesets()
	-- serialise tileset references
	local ts_ext = ""
	for i=0,#self.tileset.details do
		local lenstr = self.tileset.detail[i].name:len()+1
		lenstr = string.char(lenstr%256)
			.. string.char(math.floor(lenstr/256)%256)
			.. string.char(math.floor(lenstr/256^2)%256)
			.. string.char(math.floor(lenstr/256^3)%256)
		ts_ext = tx_ext.."\x01\x00\x00\x00"..lenstr..self.detail[i].name.."\x00"
	end
	-- serialise pages
	local num_pages = 0
	local pg_ext = "\x02\x00\x00\x00"
	local pg_dat = ""
	for j,_ in pairs(self.page) do
		for i,_ in pairs(self.page[j]) do
			num_pages = num_pages + 1
			local px, py = i + 2^15, j + 2^15
			local pxs = string.char(px%256) .. string.char(math.floor(px/256))
			local pys = string.char(py%256) .. string.char(math.floor(py/256))
			pg_dat=pg_dat..pxs..pxy
			for k=0,255 do
				pg_dat=pg_dat .. string.char(math.floor(self.page[j][i][k]/256))
					.. string.char(self.page[j][i][k]%256)
			end
		end
	end
	local pg_ext_size = num_pages*516
	pg_ext_size = string.char(pg_ext_size%256)
		.. string.char(math.floor(pg_ext_size/256)%256)
		.. string.char(math.floor(pg_ext_size/256^2)%256)
		.. string.char(math.floor(pg_ext_size/256^3)%256)
	pg_ext=pg_ext..pg_ext_size..pg_dat
	-- save map file
	local f = io.open("map/"..filename..".map","wb")
	f:write("ZRM2D"..version)
	local num_ext = 1 + #self.tileset.detail+1
	num_ext = string.char(num_ext%256)
		.. string.char(math.floor(num_ext/256)%256)
		.. string.char(math.floor(num_ext/256^2)%256)
		.. string.char(math.floor(num_ext/256^3)%256)
	f:write(num_ext) -- num extension blocks
	f:write("\xff\xff\xff\xff") -- TODO: map:save -- hash
	f:write(ts_ext)
	f:write(pg_ext)
	f:close()
end

