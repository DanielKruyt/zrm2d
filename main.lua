package.path = package.path..";~/daniel/zrm2d/src/?.lua"
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

require "game"

function love.load(arg)
	g = game.new()
	g:load()
	g.map:load("test")
end

function love.update(dt)
	local speed = 4
	local dirx,diry = 0, 0
	if love.keyboard.isDown("w") then
		diry = diry - 1
	end; if love.keyboard.isDown("s") then
		diry = diry + 1
	end; if love.keyboard.isDown("a") then
		dirx = dirx - 1
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
	local px, py = g.map:box_push(g.camera.x,g.camera.y, 32/48,dx,dy)
	g.camera:move(px,py)
end

function love.draw()
	love.graphics.setColor(255,255,255)
	g:draw()
	love.graphics.print("x: "..g.camera.x.." y: "..g.camera.y)
	love.graphics.setColor(0,255,255)
	love.graphics.rectangle("fill",480-16,360-16,32,32)
end

