local _texture = require("src.common.ui.widgets.texture")
local _font_string = require("src.common.ui.widgets.font_string")

local _setPointHandler = function(self)
	local relative_to = self.relative_to
	local point = self.point

	if (point == "ALL") then
		self.left = relative_to.left
		self.right = relative_to.right
		self.top = relative_to.top
		self.bottom = relative_to.bottom
	elseif (point == "NONE") then
		-- do nothing
	else
		local relative_point = self.relative_point

		local relative_x
		local relative_z

		if (relative_point:match("LEFT") ~= nil) then
			relative_x = relative_to.left
		elseif (relative_point:match("RIGHT") ~= nil) then
			relative_x = relative_to.right
		else
			relative_x = (relative_to.right + relative_to.left) / 2
		end

		if (relative_point:match("TOP") ~= nil) then
			relative_z = relative_to.top
		elseif (relative_point:match("BOTTOM") ~= nil) then
			relative_z = relative_to.bottom
		else
			relative_z = (relative_to.bottom + relative_to.top) / 2
		end

		if (point:match("LEFT") ~= nil) then
			self.left = relative_x
			self.right = self.left + self.width
		elseif (point:match("RIGHT") ~= nil) then
			self.right = relative_x
			self.left = self.right - self.width
		else
			self.left = relative_x - self.width / 2
			self.right = relative_x + self.width / 2
		end

		if (point:match("TOP") ~= nil) then
			self.top = relative_z
			self.bottom = self.top + self.height
		elseif (point:match("BOTTOM") ~= nil) then
			self.bottom = relative_z
			self.top = self.bottom - self.height
		else
			self.top = relative_z - self.height / 2
			self.bottom = relative_z + self.height / 2
		end

		self.left = self.left + self.offset_x
		self.right = self.right + self.offset_x
		self.top = self.top + self.offset_z
		self.bottom = self.bottom + self.offset_z
	end
end

local _shouldFireWM = function(self)
	return self:isMouseOver() and self:isVisible() == true and self.parent ~= nil and self.parent:isVisible() == true
end

local _shouldFireWOM = function(self)
	return self:isVisible() == true and self.parent ~= nil and self.parent:isVisible() == true
end

local methods = {
	["registerEvent"] = function(self, event)
		table.insert(hw_events[event].children, self)
	end,

	["setScript"] = function(self, handler, func)
		self.scripts[handler] = func
	end,

	["event"] = function(self, event, ...)
		if (self.scripts["OnEvent"] ~= nil and _shouldFireWOM(self) == true) then
			self.scripts.OnEvent(self, event, ...)
		end
	end,

	["mousepressed"] = function(self, button, x, z)
		if (self.scripts["OnMouseDown"] ~= nil and _shouldFireWM(self) == true) then
			self.scripts.OnMouseDown(self, button, x, z)
		end

		if (self:getNumChildren() > 0) then
			for _, child in pairs(self.children) do
				child:mousepressed(button, x, z)
			end
		end
	end,

	["mousereleased"] = function(self, button, x, z)
		if (self.scripts["OnMouseUp"] ~= nil and _shouldFireWM(self) == true) then
			self.scripts.OnMouseUp(self, button, x, z)
		end

		if (self:getNumChildren() > 0) then
			for _, child in pairs(self.children) do
				child:mousereleased(self, button, x, z)
			end
		end
	end,

	["wheelmoved"] = function(self, dir)
		if (self.scripts["OnMouseWheel"] ~= nil and _shouldFireWM(self) == true) then
			self.scripts.OnMouseWheel(self, dir)
		end

		if (self:getNumChildren() > 0) then
			for _, child in pairs(self.children) do
				child:wheelmoved(self,dir)
			end
		end
	end,

	["keypressed"] = function(self, key)
		if (self.scripts["OnKeyDown"] ~= nil and _shouldFireWOM(self) == true) then
			self.scripts.OnKeyDown(self, key)
		end

		if (self:getNumChildren() > 0) then
			for _, child in pairs(self.children) do
				child:keypressed(key)
			end
		end
	end,

	["keyreleased"] = function(self, key)
		if (self.scripts["OnKeyUp"] ~= nil and _shouldFireWOM(self) == true) then
			self.scripts.OnKeyUp(self, key)
		end

		if (self:getNumChildren() > 0) then
			for _, child in pairs(self.children) do
				child:keyreleased(key)
			end
		end
	end,

	["isMouseOver"] = function(self)
		local x, z = love.mouse.getPosition()
		local horizontal = x >= self.left and x < self.right
		local vertical = z >= self.top and z < self.bottom

		return horizontal and vertical
	end,

	["isVisible"] = function(self)
		return self.visible
	end,

	["createTexture"] = function(self)
		local inst = _texture.CreateTexture(self)

		table.insert(self.textures, inst)

		return inst
	end,

	["createFontString"] = function(self)
		local inst = _font_string.CreateFontString(self)

		table.insert(self.font_strings, inst)

		return inst
	end,

	["setSize"] = function(self, width, height)
		self.width = width
		self.height = height

		self:__update()
	end,

	["setPoint"] = function(self, point, relative_to, relative_point, offset_x, offset_z)
		self.point = point
		self.relative_to = relative_to
		self.relative_point = relative_point
		self.offset_x = offset_x
		self.offset_z = offset_z

		self:__update()
	end,

	["setAllPoints"] = function(self, relative_to)
		self.width = relative_to.width
		self.height = relative_to.height

		self.point = "ALL"
		self.relative_to = relative_to
		self.relative_point = "ALL"
		self.offset_x = 0
		self.offset_y = 0

		self:__update()
	end,

	["clearAllPoints"] = function(self)
		self.point = "NONE"
		self.relative_to = self.parent
		self.relative_point = "NONE"
		self.offset_x = 0
		self.offset_y = 0

		self:__update()
	end,

	["show"] = function(self)
		if (self.scripts["OnShow"] ~= nil) then
			self.scripts.OnShow(self)
		end

		self.visible = true

		self:__update()
	end,

	["hide"] = function(self)
		if (self.scripts["OnHide"] ~= nil) then
			self.scripts.OnHide(self)
		end

		self.visible = false

		self:__update()
	end,

	["__update"] = function(self, dt)
		if (self.scripts["OnUpdate"] ~= nil and _shouldFireWOM(self) == true) then
			self.scripts.OnUpdate(self, dt)
		end

		if (self:isMouseOver() ~= self.is_mouse_over) then
			self.is_mouse_over = self:isMouseOver()
			if (self.is_mouse_over == true and self.scripts["OnEnter"] ~= nil and _shouldFireWOM(self) == true) then
				self.scripts.OnEnter(self)
			end
			if (self.is_mouse_over == false and self.scripts["OnLeave"] ~= nil and _shouldFireWOM(self) == true) then
				self.scripts.OnLeave(self)
			end
		end

		_setPointHandler(self)

		if (self:getNumTextures() > 0) then
			for _, texture in pairs(self.textures) do
				texture:__update()
			end
		end

		if (self:getNumFontStrings() > 0) then
			for _, font_string in pairs(self.font_strings) do
				font_string:__update()
			end
		end

		if (self:getNumChildren() > 0) then
			for _, child in pairs(self.children) do
				child:__update(dt)
			end
		end
	end,

	["getNumChildren"] = function(self)
		local num_children = 0

		for _, _ in pairs(self.children) do
			num_children = num_children + 1
		end

		return num_children
	end,

	["getNumTextures"] = function(self)
		local num = 0

		for _, _ in pairs(self.textures) do
			num = num + 1
		end

		return num
	end,

	["getNumFontStrings"] = function(self)
		local num = 0

		for _, _ in pairs(self.font_strings) do
			num = num + 1
		end

		return num
	end,

	["__draw"] = function(self)
		if (self.visible == true) then
			for _, texture in pairs(self.textures) do
				texture:__draw()
			end

			for _, font_string in pairs(self.font_strings) do
				font_string:__draw()
			end

			if (self:getNumChildren() > 0) then
				for _, child in pairs(self.children) do
					child:__draw()
				end
			end
		end
	end
}

CreateFrame = function(parent, name)
	local inst = {}

	inst.type = "frame"

	table.insert(parent.children, inst)

	inst.name = name or ""

	inst.children = {}
	inst.textures = {}
	inst.font_strings = {}

	inst.scripts = {}

	inst.parent = parent

	inst.left = 0
	inst.right = 0
	inst.top = 0
	inst.bottom = 0

	inst.width = 0
	inst.height = 0
	inst.visible = true
	inst.is_mouse_over = false

	inst.point = "NONE"
	inst.relative_to = parent
	inst.relative_point = "NONE"
	inst.offset_x = 0
	inst.offset_z = 0

	for method, func in pairs(methods) do
		inst[method] = func
	end

	return inst
end
