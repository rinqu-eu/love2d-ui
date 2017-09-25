local _texture = require(ui.path_req .. ".widgets.texture")
local _font_string = require(ui.path_req .. ".widgets.font_string")

function _setPointHandler(self)
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

local cmethods = {
	__update__ = function(self, dt)
		self:runScript("OnUpdate", dt)
	end,

	__draw__ = function(self)
		if (self.is_visible == true) then
			for _, texture in pairs(self.__textures__) do
				texture:__draw__()
			end
			for _, font_string in pairs(self.__font_str__) do
				font_string:__draw__()
			end
		end
	end,

	__keypressed__ = function(self, key)
		self:runScript("OnKeyDown", key)
	end,

	__keyreleased__ = function(self, key)
		self:runScript("OnKeyUp", key)
	end,

	__mousepressed__ = function(self, x, y, button)
		self:runScript("OnMouseDown", x, y, button)
	end,

	__mousereleased__ = function(self, x, y, button)
		self:runScript("OnMouseUp", x, y, button)
	end,

	__mousemoved__ = function(self, x, y, dx, dy)
		if (self.is_mouse_over ~= self:isMouseOver()) then
			self.is_mouse_over = self:isMouseOver()
			if (self.is_mouse_over == true) then
				self:runScript("OnEnter")
			else
				self:runScript("OnLeave")
			end
		end
	end,

	__wheelmoved__ = function(self, x, y)
		self:runScript("OnMouseWheel", x, y)
	end,
}

--[[
scripts
	OnUpdate
	OnEnter
	OnLeave
	OnShow
	OnHide
	OnMouseDown w/mouse
	OnMouseUp w/mouse
	OnMouseWheel w/ mouse
	OnKeyDown
	OnKeyUp
]]

local methods = {
	updateSelf = function(self)
		_setPointHandler(self)

		for _, texture in pairs(self.__textures__) do
			texture:updateSelf()
		end
		for _, child in pairs(self.__children__) do
			child:updateSelf()
		end
	end,

	setPoint = function(self, point, relative_to, relative_point, offset_x, offset_z)
		self.point = point
		self.relative_to = relative_to
		self.relative_point = relative_point
		self.offset_x = offset_x
		self.offset_z = offset_z
		self:updateSelf()
	end,

	setAllPoints = function(self, relative_to)
		self.width = relative_to.width
		self.height = relative_to.height

		self.point = "ALL"
		self.relative_to = relative_to
		self.relative_point = "ALL"
		self.offset_x = 0
		self.offset_y = 0

		self:updateSelf()
	end,

	setSize = function(self, width, height)
		self.width = width
		self.height = height
		self:updateSelf()
	end,

	createTexture = function(self)
		local inst = _texture.CreateTexture(self)

		table.insert(self.__textures__, inst)

		return inst
	end,

	createFontString = function(self)
		local inst = _font_string.CreateFontString(self)

		table.insert(self.__font_str__, inst)

		return inst
	end,

	isMouseOver = function(self)
		local x, z = love.mouse.getPosition()
		local h = x >= self.left and x < self.right
		local v = z >= self.top and z < self.bottom

		return h and v
	end,

	isVisible = function(self)
		return self.is_visible
	end,

	hide = function(self)
		self.is_visible = false
		self:runScript("OnHide")
	end,

	show = function(self)
		self.is_visible = true
		self:runScript("OnShow")
	end,

	setScript = function(self, handler, func)
		self.__scripts__[handler] = func
	end,

	runScript = function(self, handler, ...)
		if (self.__scripts__[handler] ~= nil) then
			if (handler == "OnHide") then
				if (self.parent ~= nil and self.parent:isVisible() == true) then
					self.__scripts__[handler](self, ...)
				end
			else
				if (self:isVisible() == true and self.parent ~= nil and self.parent:isVisible() == true) then
					self.__scripts__[handler](self, ...)
				end
			end
		end
	end,
}

function CreateFrame(parent, name)
	local inst = {}

	inst.parent = parent
	inst.name = name or ""
	inst.type = "frame"
	table.insert(parent.__children__, inst)
	table.insert(ui.__frames__, inst)

	inst.left = -1
	inst.right = -1
	inst.top = -1
	inst.bottom = -1

	inst.width = -1
	inst.height = -1

	inst.level = -1
	inst.strata = -1

	inst.is_visible = true
	inst.is_mouse_over = false

	inst.point = "NONE"
	inst.relative_to = parent
	inst.relative_point = "NONE"
	inst.offset_x = 0
	inst.offset_z = 0

	inst.__children__ = {}
	inst.__textures__ = {}
	inst.__font_str__ = {}
	inst.__scripts__ = {}

	for method, func in pairs(cmethods) do
		inst[method] = func
	end

	for method, func in pairs(methods) do
		inst[method] = func
	end

	return inst
end
