
require "mapeditor"
function love.load(arg)
	me = mapeditor.new()
end


function love.update(dt)
	me:update(dt)
end

function love.draw()
	me:draw()
end

