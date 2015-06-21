
function gamemode_env(game)
	local env = {}
	env.math = math
	env.io = io
	env.rcache = game.rcache

	local function env.registerevent(e,t)
		if t == "bool" then
			game.events.bools[e] = { value = false, hooks = {} }
		elseif t == "list" then
			game.events.lists[e] = { value = {}, hooks = {} }
		else
			print("Attempted to register event with invalid type: t = "..t)
		end
	end

	local function env.addhook(e,f)
		if game.events.bools[e] then
			table.insert(game.events.bools[e].hooks, f)
		elseif game.events.lists[e] then
			table.insert(game.events.lists[e].hooks, f)
		else
			print("Attempted to hook into non-existent event: name = "..n)
		end
	end

	local function env.trigger(e,s)
		if game.events.bools[e] then
			game.events.bools[e].value = true
		elseif game.events.lists[e] then
			table.insert(game.events.bools[e].value, s)
		else
			print("Attempted to trigger non-existent event: event = "..e)
		end
	end

	local function env.registeractor(n,t)
		if game.actors.types[n] then
			print("Attempted to re-register actor: "..n)
			return false
		end
		if not env[t] or type(env[t]) != "table"
			or type(env[t].update) != "function"
			or type(env[t].get_drawstate) != "function"
		then
			print("Attempted to register actor with invalid template: "..n)
			return false
		end

		game.actors.types[n] = util.deepcopy(env[t])
		return true
	end

	local function env.spawnactor(t)
		if not game.actors.types[t] then
			print("Attempted to spawn actor of non-existent type: t = "..t)
			return false
		end

		table.insert(game.actors.instances,game.actors.types[t])
		return #(game.actors.instances[t])
	end

	local function env.deleteactor(id)
		game.actors.instances[id] = nil
	end

	local function env.registercontroller(n,f)
		if game.controllers[n] then
			print("Attempted to re-register controller: "..n)
			return false
		end
		if not env[f] or type(env[f]) != "function" then
			print("Attempted to register invalid function for controller: "..n)
			return false
		end
		game.controllers[n] = env[f]
	end

	local function env.setcontroller(id,n)
		if not game.actors.instances[id] then
			print("Attempted to set controller on non-existent actor: "..id, n)
			return false
		end
		if not game.controllers[n] then
			print("Attempted to set actor to non-existent controller: "..n)
			return false
		end
		game.actors.instances[id].controller = game.controllers[n]
	end

	local function env.registerprojectile(n,t)
		-- TODO: env.registerprojectile
	end

	local function env.spawnprojectile(t,s)
		-- TODO: env.spawnprojectile
	end

	local function env.deleteprojectile(id)
		-- TODO: env.deleteporjectile(id)
	end

	local function env.addtimer(t,f)
		if not env[f] or type(env[f]) != "function" then
			print("Attempted to add timer with invalid function: "..f)
		end
		local time = love.timer.getTime()
		table.insert(game.timers,
			{start_time = time, end_time =  time+t, func = env[f]}
		)
	end

	local function env.map(x,y)
		return game.map:get_tile_at(x,y)
	end

	local function env.tileinfo(t,a)
		if type(t) != "number" or type(a) != "string" then
			print("Attempted to check tile attribs with invalid args.")
			return false
		end
		if not game.tileinfo[a] then
			print("Attempted to check non-existent attribute of tile: a = "..a)
		end

		if game.tileinfo[a][t] then
			return true
		else
			return false
		end
	end
	
	return env
end

