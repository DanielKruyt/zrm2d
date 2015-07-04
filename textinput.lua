
text_input = {
	streams = {},
	max_stream_id = 0
}

function text_input.new_stream()
	local i = 1
	for i = 1, text_input.max_stream_id+1 do
		if text_input.streams[i] == nil then
			break
		end
	end
	text_input.streams[i] = ""
	return i
end

function text_input.delete_stream(id)
	text_input.streams[id] = nil
end

function text_input.get_stream(id)
	return text_input.streams[id]
end

function love.textinput(t)
	for k,v in pairs(text_input.streams) do
		text_input.streams[k] = v..t
	end
end
