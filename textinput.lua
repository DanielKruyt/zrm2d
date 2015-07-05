
text_input = {
	streams = {},
	max_stream_id = 0
}

function text_input.new_stream(t)
	local i = 1
	for i = 1, text_input.max_stream_id+1 do
		if text_input.streams[i] == nil then
			break
		end
	end
	if not t then t = "" end
	text_input.streams[i] = t
	return i
end

function text_input.new_textbox(t)
	local i = 1
	for i = 1, text_input.max_stream_id+1 do
		if text_input.streams[i] == nil then
			break
		end
	end
	if not t then assert(false,"Attempted to create textbox stream but did not supply the box.") end
	text_input.streams[i] = t
	return i
	
end

function text_input.delete(id)
	text_input.streams[id] = nil
end

function text_input.get_stream(id)
	return text_input.streams[id]
end

function love.textinput(t)
	for k,v in pairs(text_input.streams) do
		if type(v) == 'string' then
			text_input.streams[k] = text_input.streams[k] .. t
		else -- assume textbox
			v:insert(t)
		end
	end
end

function love.keypressed(key,is_repeat)
	if key == "backspace" then
		for k,v in pairs(text_input.streams) do
			if type(v) == "string" then
				text_input.streams[k] = v:sub(1,v:len()-1)
			else -- assume textbox
				v:delete()
			end
		end
	end
end



