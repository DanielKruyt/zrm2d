package.path = package.path..";./src/?.lua"
--[[
require "statemachine"
require "mainmenu"




function love.load()
	mainmenu:load()
end

function love.update()
	if state == MAIN_MENU then
		--update_mouse()
		mainmenu:update(dt)
	elseif state == IN_GAME then
		-- TODO: game update()
	elseif state == MAP_EDITOR then
		mapeditor:update(dt)
	else
		return
	end
end

function love.draw()
	if state == MAIN_MENU then
		mainmenu:draw()
	elseif state == IN_GAME then
		-- TODO: game draw()
	elseif state == MAP_EDITOR then
		mapeditor:draw()
	end
end
]]
--[[
require "gui"

function love.load()
	w = gui.window.new()
	w.bgcolor = {255,0,0}
	w.width = 800
	w.height = 600
	w.position = {100,100}
	
	c = gui.container.new()
	c.bgcolor = {255,255,0}
	c.width = 800
	c.height = 600-20

	d = util.deepcopy(c)
	e = util.deepcopy(d)
	
		but = gui.button.new()
		but.contents = "hello"
		but.width = 100
		but.height = 20
		but.bgcolor = {68,68,68}
		but.position = { 100,100}

		cb = gui.checkbox.new()
		cb.width = 20; cb.height = 20
		cb.bgcolor = {10,80,129}; cb.fgcolor = {0,0,0}
		cb.padding = 5
		cb.position = {300,30}
	
	table.insert(c.children,but)
	table.insert(c.children,cb)
		
		tb = gui.textbox.new()
		tb.bgcolor = { 53, 12, 200}; tb.fontcolor = { 0, 0, 0}
		tb.viewport = { 1,  #tb.text};
		tb.width = 100; tb.height = 20
		tb.cursor = 1; 
		tb:insert("your mom is a very nice lady")
		tb.on_click = function (self,x,y)
			self:move_cursor(self.cursor+1)
		end
	table.insert(d.children,tb)



	t = gui.tabstack.new()
	t.width = 800
	t.height = 600
	t.tabwidth = 20
	t.tabheight = 20
	t.tabcolor = {0,200,0}
	t.bgcolor = {98,98,98}
	t.tabs = {    { "oh", c },    {"oh",d}, {"oh",e} }
	t.selection = 1
	
	table.insert(w.children,t)

	repeatclick = false
end

function love.update(dt)
	local mx, my = love.mouse.getPosition()
	if love.mouse.isDown("l") then
		if not repeatclick then
			if util.box_point_intersect(mx,my, w.position[1], w.position[2], w.width, w.height) then
				w:on_click(mx-w.position[1], my-w.position[2])
			end
		end
		repeatclick = true
	else
		repeatclick = false
	end
	if love.mouse.isDown("wu") then

	elseif love.mouse.isDown("wd") then
	end
end

function love.draw()
	w:draw()
end
]]

require "resourcecache"
require "map"
require "camera"

function love.load(arg)
	m = map.new()
	m.pages[0] = {}
	m.pages[0][0] = {}
	for i=1,256 do
		m.pages[0][0][i] = 0
	end
	for i = 1,16 do
		m.pages[0][0][i] = 1
	end
	m.tile_attribs['obstacle'] = {}
	m.tile_attribs.obstacle[1] = true
	player = {x=0,y=0}
end

function love.update(dt)
	local speed = 4
	local dirx,diry = 0, 0
	if love.keyboard.isDown("w") then
		diry = diry - 1
	end; if love.keyboard.isDown("s") then
		diry = diry + 1
	end; if love.keyboard.isDown("a") then
		dirx = dirx -1
	end; if love.keyboard.isDown("d") then
		dirx = dirx + 1
	end

	local mag = math.sqrt(dirx^2 + diry^2)
	if mag > 0 then
		dirx = dirx/mag
		diry = diry/mag
	end
	local dx = dirx*dt*speed
	local dy = diry*dt*speed
	player.x, player.y = m:box_push(player.x,player.y, 16/48,dx,dy)
	camera:move(player.x,player.y)
end

function love.draw()
	for j = 0,15 do
		for i = 0,15 do
			if m.pages[0][0][1+i+16*j] == 1 then
				love.graphics.setColor(255,0,0)
			else
				love.graphics.setColor(0,32,0)
			end
			local x,y = camera:world_to_camera(i,j)
			love.graphics.rectangle("fill",x,y,48,48)
		end
	end
	love.graphics.setColor(255,255,255)
	love.graphics.print("x: "..player.x.." y: "..player.y)
	love.graphics.setColor(0,255,255)
	love.graphics.rectangle("fill",480-16,360-16,32,32)
end

