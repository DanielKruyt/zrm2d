camera = {
	width = 960,
	height = 720,
	origin = { x = 480, y = 360 },
	x = 0,
	y = 0
}

function camera.new()
	return util.deepcopy(camera)
end

function camera:world_to_camera(x,y)
	return math.floor( (x-self.x)*48 + self.origin.x + 0.5 ), math.floor( (y-self.y)*48 + self.origin.y + 0.5 )
end

function camera:move(x,y)
	self.x = x
	self.y = y
end

function camera:displace(x,y)
	self.x = self.x + x
	self.y = self.y + y
end
