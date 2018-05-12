local _texture = require(ui.path_req .. ".widgets.texture")
local _string = require(ui.path_req .. ".widgets.string")

local function _SortDrawables(drawables)
	if (#drawables < 2) then return end

	local l, m = 1, #drawables

	for i = 1, m - 1 do
		for j = i, m do
			if (drawables[j][2] < drawables[i][2]) then
				drawables[i], drawables[j] = drawables[j], drawables[i]
			end
		end
	end
end

local cmethods = {
	__update__ = function(self, dt)
		if (self:isVisible() ==  true) then
			self:runScript("OnUpdate", dt)
		end
	end,

	__draw__ = function(self)
		if (self.is_visible == true and self.parent.is_visible == true) then
			local to_draw = {}

			for _, texture in pairs(self.__textures__) do
				table.insert(to_draw, {texture, texture.level})
			end

			for _, string in pairs(self.__strings__) do
				table.insert(to_draw, {string, string.level})
			end

			_SortDrawables(to_draw)

			for _, drawable in ipairs(to_draw) do
				drawable[1]:__draw__()
			end

		end
	end,

	__keypressed__ = function(self, key)
		if (self:isVisible() ==  true) then
			self:runScript("OnKeyDown", key)
		end
	end,

	__keyreleased__ = function(self, key)
		if (self:isVisible() ==  true) then
			self:runScript("OnKeyUp", key)
		end
	end,

	__mousepressed__ = function(self, x, y, button)
		if (self:isVisible() == true and self:isMouseOver() == true) then
			self:runScript("OnMouseDown", x, y, button)
		end
	end,

	__mousereleased__ = function(self, x, y, button)
		if (self:isVisible() == true and self:isMouseOver() == true) then
			self:runScript("OnMouseUp", x, y, button)
		end
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
		if (self:isVisible() == true and self:isMouseOver() == true) then
			self:runScript("OnMouseWheel", x, y)
		end
	end,
}

local methods = {
	updateSelf = function(self)
		SetPointHandler(self)

		for _, texture in pairs(self.__textures__) do
			texture:updateSelf()
		end

		for _, string in pairs(self.__strings__) do
			string:updateSelf()
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

	createString = function(self)
		local inst = _string.CreateString(self)

		table.insert(self.__strings__, inst)

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
		if (self.is_visible == true) then
			self.is_visible = false
			self:runScript("OnHide")
		end
	end,

	show = function(self)
		if (self.is_visible == false) then
			self.is_visible = true
			self:runScript("OnShow")
		end
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

	setLevel = function(self, level)
		self.level = Clamp(level, 1, 255)
	end,

	setLayer = function(self, layer)
		self.layer = Clamp(layer, 1, 5)
	end
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

	inst.level = 1
	inst.layer = 1

	inst.is_visible = true
	inst.is_mouse_over = false

	inst.point = "NONE"
	inst.relative_to = parent
	inst.relative_point = "NONE"
	inst.offset_x = 0
	inst.offset_z = 0

	inst.__children__ = {}
	inst.__textures__ = {}
	inst.__strings__ = {}
	inst.__scripts__ = {}

	for method, func in pairs(cmethods) do
		inst[method] = func
	end

	for method, func in pairs(methods) do
		inst[method] = func
	end

	return inst
end
