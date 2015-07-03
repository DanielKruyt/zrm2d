require "map"
require "camera"


mapeditor = {
	
	map     = map.new(),
	toolbar = gui.window.new(),
	pallete_menu = gui.window.new(),
	camera  = camera.new(),
	brushes = {},
	
	pallete_menu_open = 0, -- 0 = closed, 1 = open by shift, 2 = open by menu
	
}

function mapeditor.new()
	local ret = util.deepcopy(mapeditor)

	ret.camera.origin.x = 600
	ret.camera.width = 720

	
	
	return ret
end

function mapeditor.update()
	local mx, my = love.mouse.getPosition()
	
end

function mapeditor.draw()
end
