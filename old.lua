-- ZRM 2D - the zombie resistence movement 2d aww yess
survivor_sprites = {}
zombie_sprites = {}
projectile_sprites = {}
tileset = {}

player = {['x']=0,['y']=0,['isdead']=false,['speed']=4,['rot']=0,['drot']=0}
surviors  = {}
zombies = {}
projectiles = {}

map = {}

camera = {}
camera.x = 0
camera.y = 0

function love.load(args)
	love.graphics.setBackgroundColor(127,10,1)
	-- load survivor sprites
	table.insert(survivor_sprites,love.graphics.newImage("gfx/survivors/1.png"))
	-- load zombie sprites
	table.insert(zombie_sprites,love.graphics.newImage("gfx/zombies/1.png"))
	-- load projectile sprites
	table.insert( projectile_sprites, love.graphics.newImage("gfx/projectiles/bullet.png"))
	-- create quads for tilemap TODO:
	tileset.sprite = love.graphics.newImage("gfx/tileset.png")
	tileset.quads = {}
	for j = 0, 31 do
		for i = 0, 31 do
			table.insert(tileset.quads,love.graphics.newQuad(i*32,j*32, 32, 32, 1024, 1024))
		end
	end
	--load map from file? TODO:
	--
	for j = 0, 31 do
		map[j] = {}
		for i = 0,31 do
			map[j][i] = 1
			if j == 5 and i >3 then
				map[j][i]=2
			end
		end
	end
	tileset.tiletypes={}
	table.insert(tileset.tiletypes,'floor')
	table.insert(tileset.tiletypes,'wall')
	
	table.insert(zombies,{ ["pos"]={["x"]=100,["y"]=100}, ['rot']=0})
	zombies[1] = {}
	zombies[1].pos = {}
	zombies[1].pos.x = 2
	zombies[1].pos.y = 2
	zombies[1].rot = 0
end

function is_tile_walkable(tx,ty)
	-- TODO: fix range check on tile walkable thing
	if tx >= 0 and ty >= 0 then
		if tileset.tiletypes[map[ty][tx]]=="wall" then
			return false
		end
	end
	return true
end

function is_box_colliding(px,py,r)
	local possibilities = {}
	local collisions = {}
	local tx, ty = math.floor(px), math.floor(py)
	local dx, dy = 0, 0
	for i = -1,1 do
		for j = -1,1 do
			table.insert(possibilities,{tx+i,ty+j})
		end
	end
	for _,t in pairs(possibilities) do
		if t[1] >= 0 and t[2] >= 0 then
			if (math.abs(px - t[1]) < (0.5+r)) and (math.abs(py - t[2]) < (0.5+r))
			and not is_tile_walkable(t[1],t[2]) then
				table.insert(collisions,t)
			end
		end
	end
	for _,t in pairs(collisions) do
		dx = math.max(dx, (t[1] - px))
		dy = math.max(dy, (t[2] - py))
		print(dx,dy)
	end
	return dx,dy
end

function handle_inputs(dt)
	local dry = 0
	local drx = 0
	if love.keyboard.isDown("s") then
		dry = dry - 1
	end; if love.keyboard.isDown("w") then
		dry = dry + 1
	end; if love.keyboard.isDown("a") then
		drx = drx - 1
	end; if love.keyboard.isDown("d") then
		drx = drx + 1
	end
	-- normalise
	local drlen = math.sqrt(drx^2+dry^2)
	if drlen > 0 then
		drx = drx/drlen
		dry = dry/drlen
	end
	local npx = player.x + player.speed*drx*dt
	local npy = player.y + player.speed*dry*dt
	local dx = player.speed*drx*dt
	local dy = player.speed*dry*dt

	-- tile collisions
	if npx > 0 and npy > 0 then -- only if we are moving into the tile grid
		local tx = math.floor(npx)
		local ty = math.floor(npy)
		local frx = math.abs(npx-tx)
		local fry = math.abs(npy-ty)
		local u, d, l, r = (1-fry < 9/32), (fry < 9/32), (frx < 9/32), (1-frx < 9/32)
		local ddx, ddy = is_box_colliding(npx,npy,9/32)
		dx = dx + ddx
		dy = dy + ddy
	end
	npx = player.x+dx
	npy = player.y+dy


	player.x = npx
	player.y = npy
	if not player.isdead then
		camera.x = player.x
		camera.y = player.y
	end

	mx, my = love.mouse.getPosition()
	player.rot = math.atan2(-my+300,mx-400)
	player.drot = -player.rot -- displayable rotation
	--shoot
	if not mousedownrepeat then mousedownrepeat = false end
	if love.mouse.isDown("l") then
		if not mousedownrepeat then
			table.insert(projectiles,{1,player.x, player.y,player.rot})
		end
		mousedownrepeat = true
	else
		mousedownrepeat = false
	end
end

function update_zombies(dt)
	for k,v in pairs(zombies) do
		local z = zombies[k]
		z.rot = math.atan2(zombies[k].pos.y-player.y,zombies[k].pos.x-player.x,z)
		z.drot = -zombies[k].rot-math.pi
		z.pos.x = z.pos.x - 1*dt*math.cos(z.rot)
		z.pos.y = z.pos.y - 1*dt*math.sin(z.rot)
		zombies[k] = z
	end
end

function update_projectiles(dt)
	-- TODO: make projectiles disappear somehow
	for k,v in pairs(projectiles) do
		v[2] = v[2] + 20*dt*math.cos(v[4])
		v[3] = v[3] + 20*dt*math.sin(v[4])
		local doit = false
		for l,u in pairs(zombies) do
			if ((u.pos.x-v[2])^2+(u.pos.y-v[3])^2) < 0.43^2 then
				--hit
				table.remove(projectiles,k)
				table.remove(zombies,l)
				doit = false
			end
		end
		if doit then projectiles[k] = v end
	end
end
function love.update(dt)
	handle_inputs(dt)
	-- update zombies
	update_zombies(dt)
	update_projectiles(dt)
end

function world_coord_to_screen(x,y)
	return ((x-camera.x)*32+400),((-y+camera.y)*32+300)
end

function love.draw(dt)
	for j = 0, 31 do
		for i = 0,31 do
			local x,y = world_coord_to_screen(i,j)
			love.graphics.draw(tileset.sprite,tileset.quads[map[j][i]],x,y-32)
		end
	end
	local x,y = world_coord_to_screen(0,0)
	x,y = world_coord_to_screen(player.x,player.y)
	love.graphics.draw(survivor_sprites[1],x,y,player.drot,1,1,24,24)
	for k,z in pairs(zombies) do
		local x,y = world_coord_to_screen(z.pos.x, z.pos.y)
		love.graphics.draw(zombie_sprites[1], x, y,z.drot,1,1,24,24)
	end

	for k,v in pairs(projectiles) do
		local x, y = world_coord_to_screen(v[2],v[3])
		love.graphics.draw(projectile_sprites[v[1]], x,y,-v[4])
	end
	love.graphics.print('x: '..math.floor(player.x)..'; y: '..math.floor(player.y))
	love.graphics.print('fx: '..player.x..'; fy: '..player.y,0,20)
		
end

