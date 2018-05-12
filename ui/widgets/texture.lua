local lg = love.graphics

local cmethods = {
	__draw__ = function(self)
		if (self.is_visible == true) then
			if (self.mode == "c") then
				lg.setColor(unpack(self.color))
				lg.rectangle("fill", self.left, self.top, self.width, self.height)
			elseif (self.mode == "t") then
				lg.setColor(1.0, 1.0, 1.0, 1.0)
				if (self.texture.quad == nil) then
					love.graphics.draw(self.texture.image, self.left, self.top, 0, self.scale_x, self.scale_z)
				else
					love.graphics.draw(self.texture.image, self.texture.quad, self.left, self.top, 0, self.scale_x, self.scale_z)
				end
			end
		end
	end
}

local methods = {
	updateSelf = function(self)
		SetPointHandler(self)
	end,

	isVisible = function(self)
		return self.is_visible
	end,

	setPoint = function(self, point, relative_to, relative_point, offset_x, offset_z)
		self.point = point
		self.relative_to = relative_to
		self.relative_point = relative_point
		self.offset_x = offset_x
		self.offset_z = offset_z

		self:updateSelf()
	end,

	setSize = function(self, width, height)
		self.width = width
		self.height = height

		self:updateSelf()
	end,

	setAllPoints = function(self, relative_to)
		self.point = "ALL"
		self.relative_to = relative_to
		self.relative_point = "ALL"
		self.offset_x = 0
		self.offset_y = 0

		self.width = relative_to.width
		self.height = relative_to.height

		self:updateSelf()
	end,

	setLevel = function(self, level)
		self.level = level
	end,

	setTexture = function(self, texture)
		self.mode = "t"
		self.texture = texture

		self.scale_x = self.width / texture.width
		self.scale_z = self.height / texture.height
	end,

	setColorTexture = function(self, color)
		self.mode = "c"
		self.color = color

		self.scale_x = 1
		self.scale_z = 1
	end,

	show = function(self)
		self.is_visible = true
	end,

	hide = function(self)
		self.is_visible = false
	end,
}

local texture = {}

function texture.CreateTexture(parent)
	local inst = {}

	inst.parent = parent
	inst.type = "texture"

	inst.left = -1
	inst.right = -1
	inst.top = -1
	inst.bottom = -1

	inst.width = -1
	inst.height = -1

	inst.is_visible = true

	inst.point = "NONE"
	inst.relative_to = parent
	inst.relative_point = "NONE"
	inst.offset_x = 0
	inst.offset_z = 0

	inst.level = 1

	for method, func in pairs(cmethods) do
		inst[method] = func
	end

	for method, func in pairs(methods) do
		inst[method] = func
	end

	return inst
end

return texture
