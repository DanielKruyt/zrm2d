
require "gui"
require "camera"

function love.load(arg)
	c = camera:new()
	w = gui.window.new()
		w.width = 240
		w.height = 720
		w.bgcolor = {69,69,69}
		--buttons
		local b_new = gui.button.new()
			b_new.bgcolor = {33,33,33}
			b_new.position = {9,9}
			b_new.width = 32
			b_new.height = 32
			b_new.contents = "new"
		table.insert(w.children,b_new)
		local b_load = gui.button.new()
			b_load.bgcolor = {33,33,33}
			b_load.position = {47,9}
			b_load.width = 32
			b_load.height = 32
			b_load.contents = "load"
		table.insert(w.children,b_load)
		local b_save = gui.button.new()
			b_save.bgcolor = {33,33,33}
			b_save.position = {85,9}
			b_save.width = 32
			b_save.height = 32
			b_save.contents = "save"
		table.insert(w.children,b_save)
		local b_settings = gui.button.new()
			b_settings.bgcolor = {33,33,33}
			b_settings.position = {123,9}
			b_settings.width = 32
			b_settings.height = 32
			b_settings.contents = "opts"
		table.insert(w.children,b_settings)
		local b_test = gui.button.new()
			b_test.bgcolor = {33,33,33}
			b_test.position = {161,9}
			b_test.width = 32
			b_test.height = 32
			b_test.contents = "test"
		table.insert(w.children,b_test)
		local b_exit = gui.button.new()
			b_exit.bgcolor = {33,33,33}
			b_exit.position = {199,9}
			b_exit.width = 32
			b_exit.height = 32
			b_exit.contents = "exit"
		table.insert(w.children,b_exit)
		-- tabstack
		local t = gui.tabstack.new()
			t.bgcolor = {69,169,69}
			t.position = {0,18+32}
			t.width = 240
			t.height = 720-(18+32)
			t.tabwidth = 64
			t.tabheight = 32
			t.fontcolor = {0,0,0}
			t.tabcolor = {79,179,79}
			t.selection = 1
				local tc1 = gui.container.new()
				tc1.bgcolor = {169,69,69}
				tc1.width = 240
				tc1.height = 720-(18+32+32)
				table.insert(t.tabs,{"Brushes",tc1})
				local tc2 = gui.container.new()
				tc2.bgcolor = {169,69,69}
				tc2.width = 240
				tc2.height = 720-(18+32+32)
				table.insert(t.tabs,{"Entities",tc2})
				local tc3 = gui.container.new()
				tc3.bgcolor = {169,69,69}
				tc3.width = 240
				tc3.height = 720-(18+32+32)
				table.insert(t.tabs,{"Tools",tc3})
		table.insert(w.children,t)
end


local mdown = false
local sdown = false
local sdownx, sdowny = 0,0
local cx,cy = 0, 0
local mbx, mby = 0,0
local tile_editor = false
local te_child = gui.window.new()
		te_child.width = 720
		te_child.height = 720
		te_child.position = {240,0}
		te_child.bgcolor = {244,244,244}
function love.update(dt)
	local mx,my = love.mouse.getPosition()
	mbx = math.floor(c.x + (mx-600)/48)
	mby = math.floor(c.y + (my-360)/48)
	if love.mouse.isDown("l") then
		if not down then
			if mx < 240 then
				w:on_click(mx,my)
				down = true
			end
		end
	else
		down = false
	end
	if love.keyboard.isDown(" ") then
		if not sdown then
			sdownx, sdowny = mx, my
			sdown = true
		end
		c:move(cx-(mx-sdownx)/48,cy-(my-sdowny)/48)
	else
		if sdown then
			cx, cy = c.x, c.y
		end
		sdown = false
	end
	if love.keyboard.isDown("lshift") then
		tile_editor = true
	else
		tile_editor = false
	end
end

function love.draw()
	
	-- draw map grid
	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle('rough')

	local sx, sy = math.floor( c.x-8 ), math.floor(c.y-8)
	local ex, ey = math.ceil(c.x+8), math.ceil(c.y+8)
	love.graphics.setColor(150,200,0)
	for i = sx, ex do
		local x, _ = c:world_to_camera(i,0)
		love.graphics.line(x+120,0,x+120,720)
	end
	for j = sy, ey do
		local _, y = c:world_to_camera(0,j)
		love.graphics.line(240,y,960,y)
	end
	love.graphics.setColor(150,200,0,75 + 25*math.sin(love.timer.getTime()*3))
	local x,y = c:world_to_camera(mbx,mby)
	love.graphics.rectangle('fill',x+120,y,48,48)
	w:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.print("X: "..mbx.."  Y: "..mby, 245, 5)
	
	if tile_editor then
		te_child:draw()
	end
end

