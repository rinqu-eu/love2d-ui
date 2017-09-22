local _setPointHandler = function(self)
	local relative_to = self.relative_to
	local point = self.point

	if (point == "ALL") then
		self.left = relative_to.left
		self.right = relative_to.right
		self.top = relative_to.top
		self.bottom = relative_to.bottom

		self.width = relative_to.width
		self.height = relative_to.height
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
			self.left = relative_x - self.width
			self.right = relative_x
		else
			self.left = relative_x - self.width / 2
			self.right = relative_x + self.width / 2
		end

		if (point:match("TOP") ~= nil) then
			self.top = relative_z
			self.bottom = self.top + self.height
		elseif (point:match("BOTTOM") ~= nil) then
			self.top = relative_z - self.height
			self.bottom = relative_z
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

local methods = {
	["__draw"] = function(self)
		if (self.visible == true) then
			if (self.mode == 1) then
				if (self.texture.quad == nil) then
					love.graphics.draw(self.texture.image, self.left, self.top, 0, self.scale_x, self.scale_z)
				else
					love.graphics.draw(self.texture.image, self.texture.quad, self.left, self.top, 0, self.scale_x, self.scale_z)
				end
			elseif (self.mode == 2) then
				love.graphics.setColor(unpack(self.color))
				love.graphics.rectangle("fill", self.left, self.top, self.width, self.height)
				love.graphics.setColor(255, 255, 255, 255)
			end
		end
	end,

	["__update"] = function(self)
		_setPointHandler(self)
	end,

	["isVisible"] = function(self)
		return self.visible
	end,

	["setPoint"] = function(self, point, relative_to, relative_point, offset_x, offset_z)
		self.point = point
		self.relative_to = relative_to
		self.relative_point = relative_point
		self.offset_x = offset_x
		self.offset_z = offset_z

		self:__update()
	end,

	["setSize"] = function(self, width, height)
		self.width = width
		self.height = height

		self:__update()
	end,

	["setAllPoints"] = function(self, relative_to)
		self.point = "ALL"
		self.relative_to = relative_to
		self.relative_point = "ALL"
		self.offset_x = 0
		self.offset_y = 0

		self.width = relative_to.width
		self.height = relative_to.height

		self:__update()
	end,

	["setTexture"] = function(self, texture)
		self.mode = 1
		self.texture = texture

		self.scale_x = self.width / texture.width
		self.scale_z = self.height / texture.height
	end,

	["setColorTexture"] = function(self, color)
		self.mode = 2
		self.color = color

		self.scale_x = 1
		self.scale_z = 1
	end,

	["show"] = function(self)
		self.visible = true

		self:__update()
	end,

	["hide"] = function(self)
		self.visible = false

		self:__update()
	end,
}

local texture = {}

texture.CreateTexture = function(parent)
	local inst = {}

	inst.parent = parent
	inst.type = "texture"

	inst.point = "NONE"
	inst.relative_to = parent
	inst.relative_point = "NONE"

	inst.visible = true

	for method, func in pairs(methods) do
		inst[method] = func
	end

	return inst
end

return texture
