
controller = {}
	
controller.survivor = {}

	controller.survivor.physical = function(survivor,dt)
		-- TODO: customisable input keys in survivor-controller
		local dirx, diry = 0, 0
		if love.keyboard.isDown('w') then
			diry = diry - 1
		end; if love.keyboard.isDown('s') then
			diry = diry + 1
		end; if love.keyboard.isDown('a') then
			dirx = dirx - 1
		end; if love.keyboard.isDown('d') then
			dirx = dirx + 1
		end
		local mag = math.sqrt(dirx^2+diry^2)
		local dx, dy = dirx*survivor.speed*dt diry*survivor.speed*dt

		if mag > 0 then
			local dx = dx/mag
			local dy = dy/mag
		end
		local fx, fy = map:box_push(survivor.pos.x,survivor.pos.y,survivor.radius,dx,dy)
		survivor.pos.x = fx; survivor.pos.y = fy
	end

	controller.survivor.network = function(survivor)
		--TODO: survivor.network controller
	end

	controller.survivor.ai = function(survivor)
		--TODO: survivor.ai controller
	end





