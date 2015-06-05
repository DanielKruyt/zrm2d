
require "util"

mainmenu = {}
mainmenu.state = 0
mainmenu.buttons = {}

function mainmenu.load(self)
	self.bg = love.graphics.newImage("gfx/menu/mainbg.png")
	local b1 = {
		['img'] = love.graphics.newImage("gfx/menu/playbutton.png"),
		['mouseover'] = false,
		['x'] = 480,
		['y'] = 280
	}
	local b2 = {
		['img'] = love.graphics.newImage("gfx/menu/mapeditorbutton.png"),
		['mouseover'] = false,
		['x'] = 480,
		['y'] = 280
	}
	local b3 = {
		['img'] = love.graphics.newImage("gfx/menu/settingsbutton.png"),
		['mouseover'] = false,
		['x'] = 480,
		['y'] = 280
	}
	local b4 = {
		['img'] = love.graphics.newImage("gfx/menu/quitbutton.png"),
		['mouseover'] = false,
		['x'] = 480,
		['y'] = 280
	}

	table.insert(self.buttons,b1)
	table.insert(self.buttons,b2)
	table.insert(self.buttons,b3)
	table.insert(self.buttons,b4)
	local c = 0
	for _,b in pairs(self.buttons) do
		b.x = b.x - b.img.getWidth(b.img)/2
		b.y = b.y + 64*c
		if c == 2 then
			c = c + 1
		end
		c = c + 1
	end
end

function mainmenu.update(self)
	local mx, my = love.mouse.getPosition()
	for k,b in pairs(self.buttons) do
		if util.box_point_intersect( mx,my,
		b.x,b.y,
		b.img:getWidth(), b.img:getHeight()) then
			self.buttons[k].mouseover = true
		else
			self.buttons[k].mouseover = false
		end
	end
end

function mainmenu.draw(self)
	--draw menu background
	love.graphics.draw(self.bg)
	--draw buttons
	for _,b in pairs(self.buttons) do
		if b.mouseover then
			love.graphics.draw(b.img, b.x+16, b.y)
		else
			love.graphics.draw(b.img, b.x, b.y)
		end
	end
end

