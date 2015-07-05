require "util"
require "textinput"

local container = {}
	container.id = "container"
	container.position = {0, 0}
	container.width = 0
	container.height = 0
	container.padding = 0
	container.border = { 0, {0,0,0} } -- width, rgb -- drawn inside box, ie: MARGIN |BORDER PADDING

	container.bgcolor = {0,0,0} --rgb
	container.children = {}

	function container.on_click(self,x,y)
		for k,v in pairs(self.children) do
			print(self,k,v)
			if (v.position[1]+self.padding) < x and x < (v.position[1]+self.padding+v.width) then
				if (v.position[2]+self.padding) < y and y < (v.position[2]+self.padding+v.height) then
					return self.children[k]:on_click(x-(self.padding+v.position[1]), y-(self.padding+v.position[2]))
				end
			end
		end
		return self
	end
	function container.draw(self)
		love.graphics.push("all")

		love.graphics.setColor( self.bgcolor )
		love.graphics.rectangle( "fill", 0, 0, self.width, self.height )
		if self.border[1] > 0 then
			love.gaphics.setColor( self.border[2] )
			love.graphics.rectangle( "line", 0,0, self.width, self.height )
		end
		love.graphics.translate( self.padding, self.padding )

		for k,_ in pairs(self.children) do
			self.children[k]:draw()
		end

		love.graphics.pop()
	end
	function container.new()
		return util.deepcopy(gui.container)
	end
	
	function container:on_focus()
	end
	function container:on_unfocus()
	end




local window = {}
	window.id = "window"
	window.position = {0, 0}
	window.width = 0
	window.height = 0
	window.padding = 0
	window.border = { 0, {0,0,0} }

	window.bgcolor = {0,0,0}
	window.children = {}

	function window.on_click(self,x,y)
		for k,v in pairs(self.children) do
			if (v.position[1]+self.padding) < x and x < (v.position[1]+self.padding+v.width) then
				if (v.position[2]+self.padding) < y and y < (v.position[2]+self.padding+v.height) then
					return self.children[k]:on_click(x-(self.padding+v.position[1]), y-(self.padding+v.position[2]))
				end
			end
		end
		return self
	end

	function window.draw(self)
		love.graphics.push("all")

		love.graphics.setColor(self.bgcolor)
		love.graphics.translate(self.position[1],self.position[2])
		love.graphics.rectangle("fill", 0, 0, self.width, self.height)
		if self.border[1] > 0 then
			love.graphics.setColor(self.border[2])
			love.graphics.rectangle("line", 0, 0, self.width, self.height)
		end
		love.graphics.translate(self.padding, self.padding)

		for k,_ in pairs(self.children) do
			self.children[k]:draw()
		end

		love.graphics.pop()
	end

	function window.new()
		return util.deepcopy(gui.window)
	end

	function window:on_focus()
	end
	function window:on_unfocus()
	end





local tabstack = {}
	tabstack.id = "tabstack"
	tabstack.position = {0, 0}
	tabstack.width = 0
	tabstack.height = 0
	tabstack.padding = 0
	tabstack.border = { 0, {0,0,0} }

	tabstack.tabheight = 0
	tabstack.tabwidth = 0

	tabstack.bgcolor = {0,0,0}
	tabstack.tabcolor = {0,20,0}

	tabstack.tabs = {} -- tabs = {   {['title']="",container},   etc   }
	tabstack.selection = -1
	
	function tabstack.on_click(self,x,y)
		if y < self.tabheight then
			local nsel = math.floor(x/self.tabwidth)+1
			if nsel > #self.tabs then
				return self
			else
				self.selection = nsel
			end
		else
			local xx = x - (self.padding + self.tabs[self.selection][2].position[1])
			local yy = y - (self.padding + self.tabs[self.selection][2].position[2] + self.tabheight) 
			return self.tabs[self.selection][2]:on_click(xx, yy)
		end
	end

	function tabstack.draw(self)
		love.graphics.push("all")
		love.graphics.translate(self.position[1],self.position[2])
		love.graphics.setColor(self.bgcolor)
		love.graphics.rectangle("fill",0,0,self.width,self.height)
		if self.selection > 0 then
			--draw tabstack itself
			for k,v in pairs(self.tabs) do
				if k == self.selection then
					love.graphics.setColor(v[2].bgcolor)
				else
					love.graphics.setColor(self.tabcolor)
				end
				love.graphics.rectangle("fill", self.tabwidth*(k-1), 0, self.tabwidth, self.tabheight)

				love.graphics.setColor(self.fontcolor)
				local tw = love.graphics.getFont():getWidth(self.tabs[k][1])
				local lh = love.graphics.getFont():getHeight()
				love.graphics.printf(self.tabs[k][1], self.tabwidth*(k-1)-tw/2+self.tabwidth/2, self.tabheight/2-lh/2, tw, "center")
			end

			--draw container
			love.graphics.translate(self.padding,self.padding+self.tabheight)
			self.tabs[self.selection][2]:draw()
		end

		love.graphics.pop()
	end

	function tabstack.new()
		return util.deepcopy(gui.tabstack)
	end

	function tabstack:update(dt)
		for k,v in pairs(self.tabs) do
			self.tabs[k][2]:update(dt)
		end
	end
	function tabstack:on_focus()
	end
	function tabstack:on_unfocus()
	end





local button = {}
	button.id = "button"
	button.position = {0,0}
	button.width = 0
	button.height = 0
	button.padding = 0
	button.border = { 0, {0,0,0} }

	button.bgcolor = {0,0,0}
	button.fontcolor = {0,0,0}
	button.contents = ""
		-- TODO: images on buttons
		--button.contents.position = {0,0}
		--button.contents.content = -1 -- replace with LOVE drawable, eg img/text
	
	button.on_click = function(self) return self end
	button.on_hover = function(self,time) end

	function button.draw(self)
		love.graphics.push("all")

		local tw = love.graphics.getFont():getWidth(self.contents)
		local lh = love.graphics.getFont():getHeight()
		love.graphics.setColor(self.bgcolor)
		love.graphics.rectangle("fill",self.position[1],self.position[2],self.width,self.height)
		love.graphics.setColor(self.fontcolor)
		love.graphics.printf(self.contents, self.position[1]+self.width/2-tw/2, self.position[2]+self.height/2-lh/2, tw, "center")

		love.graphics.pop()
	end
	function button.new()
		return util.deepcopy(gui.button)
	end
	function button:on_focus()
	end
	function button:on_unfocus()
	end





local checkbox = {}
	checkbox.id = "checkbox"
	checkbox.position = {0,0}
	checkbox.state = false
	checkbox.width = 0
	checkbox.height = 0

	checkbox.bgcolor = {0,0,0}
	checkbox.fgcolor = {0,0,0}
	checkbox.padding = 0

	function checkbox.on_click(self,x,y)
		self.state = not self.state
		return self
	end

	function checkbox.draw(self)
		love.graphics.push("all")
		love.graphics.setColor(self.bgcolor)
		love.graphics.rectangle("fill",self.position[1], self.position[2], self.width, self.height)
		if self.state == true then
			love.graphics.setColor(self.fgcolor)
			love.graphics.rectangle("fill",
				self.position[1] + self.padding, self.position[2] + self.padding,
				self.width-self.padding*2, self.height-self.padding*2)
		end
		love.graphics.pop()
	end

	function checkbox.new()
		return util.deepcopy(gui.checkbox)
	end
	function checkbox:on_focus()
	end
	function checkbox:on_unfocus()
	end





local textbox = {}
	textbox.id = "textbox"
	textbox.position = {0,0}
	textbox.width = 0
	textbox.height = 0
	textbox.padding = 0

	textbox.bgcolor = {0,0,0}
	textbox.fontcolor = {0,0,0}
	textbox.text = ""
	textbox.viewport = {0,0} -- start, end
	textbox.cursor = -1
	
	function textbox.update_viewport(self,direction)
		local font = love.graphics.getFont()
			

		if font:getWidth(self.text:sub(self.viewport[1], self.viewport[2])) > (self.width-2*self.padding) then
			if direction and direction < 0 then
				while font:getWidth(self.text:sub(self.viewport[1], self.viewport[2])) > (self.width-2*self.padding) do
					self.viewport[1] = self.viewport[1]+1
				end
			else
				while font:getWidth(self.text:sub(self.viewport[1], self.viewport[2])) > (self.width-2*self.padding) do
					self.viewport[2] = self.viewport[2]-1
				end
			end
		elseif font:getWidth(self.text:sub(self.viewport[1], self.viewport[2])) < (self.width-2*self.padding) then
			if direction and direction < 0 then
				while font:getWidth(self.text:sub(self.viewport[1], self.viewport[2])) < (self.width-2*self.padding) do
					self.viewport[1] = self.viewport[1]-1
				end
			else
				while font:getWidth(self.text:sub(self.viewport[1], self.viewport[2])) < (self.width-2*self.padding) do
					self.viewport[2] = self.viewport[2]+1
				end
			end
			self.viewport[2] = self.viewport[2] -1
		end
		print(self.viewport[1], self.viewport[2])
	end

	function textbox.insert(self,txt)
		if self.cursor < 1 or self.text == "" then
			self.cursor = 1
			self.text = txt
			textbox.viewport = {1, self.text:len()}
			self:update_viewport()
		else
			self.text = string.insert(self.text,txt,self.cursor)
			self.cursor = self.cursor + 1
			self:update_viewport()
		end
	end
	
	function textbox.delete(self)
		if self.text:len() > 0 then
			self.text = self.text:sub(1,self.cursor-1)..self.text:sub(self.cursor+1)
			self.cursor = self.cursor - 1
			self:update_viewport()
		end
	end

	function textbox.move_cursor(self, np)
		self.cursor = np
		if np < 1 then np = 1 end
		if np > self.text:len() then np = self.text:len() end

		if np < self.viewport[1] then
			self.cursor = np
			self.viewport[1] = np
			self:update_viewport()
		end
		if np > self.viewport[2] then
			self.cursor = np
			self.viewport[2] = np
			self:update_viewport(-1)
		end
	end

	function textbox.draw(self)
		--if self.cursor > 0 then -- if actually in this textbox
			love.graphics.push("all")

			local tw = love.graphics.getFont():getWidth(self.text:sub(self.viewport[1],self.viewport[2]))
			local lh = love.graphics.getFont():getHeight()
			
			love.graphics.setColor(self.bgcolor)
			love.graphics.rectangle("fill",self.position[1], self.position[2], self.width, self.height)

			love.graphics.setColor(self.fontcolor)
			love.graphics.printf(self.text:sub(self.viewport[1],self.viewport[2]),
				self.position[1]+self.padding, self.position[2]+self.padding,
				self.width, "center")

			love.graphics.pop()
		--end
	end

	function textbox.new()
		return util.deepcopy(gui.textbox)
	end
	
	function textbox:on_focus()
		self.stream_id = text_input.add_textbox(self)
	end
	
	function textbox:on_unfocus()
		text_input.delete(self.stream_id)
	end
	
	function textbox:on_click()
		return self
	end



local list = {}
	list.id = "list"
	list.position = {0,0}
	list.width = 0
	list.height = 0
	list.padding = 0

	list.bgcolor = {0,0,0}
	list.item_height = 0
	list.scroll_pos = 0
	list.items = {}
	list.selection = 0

	function list.new()
		return util.deepcopy(gui.list)
	end
	function list:on_focus()
	end
	function list:on_unfocus()
	end





local droplist = {}
	droplist.position = {0,0}
	droplist.width = 0
	droplist.height = 0
	droplist.list = util.deepcopy(list)
	droplist.padding = 0

	function droplist.draw(self)

	end

	function droplist.new()
		return util.deepcopy(gui.droplist)
	end
	function droplist:on_focus()
	end
	function droplist:on_unfocus()
	end





gui = {}
gui.container = container
gui.window = window
gui.tabstack = tabstack
gui.button = button
gui.checkbox = checkbox
gui.textbox = textbox
gui.list = list
gui.droplist = droplist

