require "map"
require "camera"
require "gui"
require "textinput"

mapeditor = {
	map     = map.new(),
	toolbar = gui.window.new(),
	palette_menu = gui.window.new(),
	camera  = camera.new(),
	add_tileset_menu = gui.window.new(),
	brushes = {},
	main_window = nil, -- where palette menu, add tileset menu, etc will appear
	
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
			b_exit.on_click = function() love.event.quit() end
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
					local b_add_tileset = gui.button.new()
					b_add_tileset.bgcolor = {69,69,69}
					b_add_tileset.width = 240-16
					b_add_tileset.height = 32
					b_add_tileset.position = {8,8}
					b_add_tileset.contents = "Add tileset"
					b_add_tileset.on_click = function()
						--spawn main window with textbox input for now
						ret.main_window = ret.add_tileset_menu
					end
					local b_open_palette_menu = gui.button.new()
					b_open_palette_menu.bgcolor = {69,69,69}
					b_open_palette_menu.width = 240-16
					b_open_palette_menu.height = 32
					b_open_palette_menu.position = {8,16+32}
					b_open_palette_menu.contents = "Palette Menu"
					table.insert(tc1.children, b_add_tileset)
					table.insert(tc1.children, b_open_palette_menu)
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
			t.position = {0,0} t.width = 720
			t.height = 720
			t.bgcolor = {25,0,55}
		table.insert(ret.palette_menu.children, t)
	end

	do -- add tileset menu
		ret.add_tileset_menu.bgcolor = {244,244,244}
		ret.add_tileset_menu.position = {240,0}
		ret.add_tileset_menu.width = 720
		ret.add_tileset_menu.height = 720
		local tb = gui.textbox.new()
		tb.width = 240
		tb.height = 32
		tb.padding = 4
		tb.bgcolor = {0,0,0}
		tb.fontcolor = {144,244,244}
		tb.text = "hi"
		tb.on_click = function()
			tb.stream_id = text_input.new_stream()

		end
		table.insert(ret.add_tileset_menu.children, tb) end return ret
end

--------------------------------------------------------------------------------
-- update/draw/textinput section
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
	-- draw toolbar
	self.toolbar:draw()
	-- draw main menu
	if self.main_window then
		self.main_window:draw()
	end
end



function mapeditor:handle_input(dt)
	local mx, my = love.mouse.getPosition()
	-- handle keyboard input
	if self.palette_menu_open == 0 then
		if love.keyboard.isDown("lshift","rshift") and not self.main_window then
			self.palette_menu_open = 1
			self.main_window = self.palette_menu
		end
	elseif self.palette_menu_open == 1 then
		if not love.keyboard.isDown("lshift","rshift") then
			self.palette_menu_open = 0
			self.main_window = nil
		end
	end
	
	--handle mouse input
	if mx < 240 then
		if love.mouse.isDown("l") then
			self.toolbar:on_click(mx,my)
		end
	elseif mx >= 240 then
		if self.main_window then
			if love.mouse.isDown("l") then
				self.main_window:on_click(mx-240,my)
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

