camera = {x=0,y=0}

function camera.new()
	return util.deepcopy(camera)
end

function camera.world_to_camera(self,x,y)
	return math.floor((x-self.x)*48+480.5),math.floor((y-self.y)*48+360.5)
end

function camera.move(self,x,y)
	self.x = x
	self.y = y
end
