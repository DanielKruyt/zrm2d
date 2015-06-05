util = {}

function util.box_point_intersect(x,y,bx,by,w,h)
	if x < (bx+w) and y < (by+h) then
		if x > bx and y > by then
			return true
		end
	end
	return false
end
