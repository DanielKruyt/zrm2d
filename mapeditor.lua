require "map"
require "camera"
require "gui"

mapeditor = {
	map     = map.new(),
	toolbar = gui.window.new(),
	palette_menu = gui.window.new(),
	camera  = camera.new(),
	brushes = {},
	
	palette_menu_open = 0, -- 0 = closed, 1 = open by shift, 2 = open by menu
	
	cx = 0, cy = 0,
	space_drag_start = true,
	drag_start_x = 0, drag_start_y = 0
}


function mapeditor.new()
	local ret = util.deepcopy(mapeditor)

	ret.camera.origin.x = 600
	ret.camera.width = 720
	do
		--ret.toolbar
		ret.toolbar.width = 240
		ret.toolbar.height = 720
		ret.toolbar.bgcolor = {69,69,69}
		--buttons
		local b_new = gui.button.new()
			b_new.bgcolor = {33,33,33}
			b_new.position = {9,9}
			b_new.width = 32
			b_new.height = 32
			b_new.contents = "new"
		table.insert(ret.toolbar.children,b_new)
		local b_load = gui.button.new()
			b_load.bgcolor = {33,33,33}
			b_load.position = {47,9}
			b_load.width = 32
			b_load.height = 32
			b_load.contents = "load"
		table.insert(ret.toolbar.children,b_load)
		local b_save = gui.button.new()
			b_save.bgcolor = {33,33,33}
			b_save.position = {85,9}
			b_save.width = 32
			b_save.height = 32
			b_save.contents = "save"
		table.insert(ret.toolbar.children,b_save)
		local b_settings = gui.button.new()
			b_settings.bgcolor = {33,33,33}
			b_settings.position = {123,9}
			b_settings.width = 32
			b_settings.height = 32
			b_settings.contents = "opts"
		table.insert(ret.toolbar.children,b_settings)
		local b_test = gui.button.new()
			b_test.bgcolor = {33,33,33}
			b_test.position = {161,9}
			b_test.width = 32
			b_test.height = 32
			b_test.contents = "test"
		table.insert(ret.toolbar.children,b_test)
		local b_exit = gui.button.new()
			b_exit.bgcolor = {33,33,33}
			b_exit.position = {199,9}
			b_exit.width = 32
			b_exit.height = 32
			b_exit.contents = "exit"
		table.insert(ret.toolbar.children,b_exit)
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
				table.insert(t.tabs,{"Tiles",tc1})
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
		table.insert(ret.toolbar.children,t)
	end
	
	do
		-- palette menu
		ret.palette_menu.bgcolor = {255,255,255}
		ret.palette_menu.position = {240,0}
		ret.palette_menu.width = 720
		ret.palette_menu.height = 720
		-- tabstack
			local t = gui.tabstack.new()
			t.position = 3
		table.insert(ret.palette_menu.children, t)
	end
	return ret
end

--------------------------------------------------------------------------------
-- update/draw section
--------------------------------------------------------------------------------



function mapeditor:update(dt)	
	self:handle_input(dt)
end



function mapeditor:draw()
	-- self.map:draw
	-- draw_grid()
	love.graphics.setColor(200,240,0)
	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle('rough')
	for i = -8, 8 do
		local x, _ = self.camera:world_to_camera(math.floor(self.camera.x)-i,0)
		love.graphics.line(x,0,x,720)
	end
	for j = -8, 8 do
		local _, y = self.camera:world_to_camera(0,math.floor(self.camera.y)-j)
		love.graphics.line(240,y,960,y)
	end
	-- draw_current_block()
	self.toolbar:draw()
	if self.palette_menu_open > 0 then
		self.palette_menu:draw()
	end
end



function mapeditor:handle_input(dt)
	local mx, my = love.mouse.getPosition()
	-- handle keyboard input
	if self.palette_menu_open == 0 then
		if love.keyboard.isDown("lshift","rshift") then
			self.palette_menu_open = 1
		end
	elseif self.palette_menu_open == 1 then
		if not love.keyboard.isDown("lshift","rshift") then
			self.palette_menu_open = 0
		end
	end
	
	--handle mouse input
	if mx < 240 then
		if love.mouse.isDown("l") then
			self.toolbar:on_click(mx,my)
		end
	elseif mx >= 240 then
		if self.palette_menu_open > 0 then
			if love.mouse.isDown("l") then
				self.palette_menu:on_click(mx,my)
			end
		else
			if love.keyboard.isDown(" ") then
				if self.space_drag_start then
					print('hit',self.cx, self.cy)
					self.drag_start_x = mx
					self.drag_start_y = my
					self.space_drag_start = false
				end
				self.camera:move((self.drag_start_x-mx)/48+self.cx, (self.drag_start_y-my)/48+self.cy)
			else
				if not self.space_drag_start then
					self.cx = self.camera.x
					self.cy = self.camera.y
				end
				self.space_drag_start = true
			end
			-- TODO: mapeditor:handle_input -> tile placing with brushes n shit
			
		end
	end
end

