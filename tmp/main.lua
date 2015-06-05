package.path = package.path..";./src/?.lua"
require "mainmenu"

function love.load()
	mainmenu:load()
end

function love.update()
	if state == MAIN_MENU then
		--update_mouse()
		mainmenu:update()
	elseif state == IN_GAME then
		--donothingrofl
	end
end

function love.draw()
	if state == MAIN_MENU then
		mainmenu:draw()
	elseif state == IN_GAME then
		--donothingrofl
	end
end

