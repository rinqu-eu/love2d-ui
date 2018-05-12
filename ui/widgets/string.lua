local DEFAULT_FONT_SIZE = 14
local DEFAULT_FONT_FILE = UIParent.fonts["default"]

local PADDING = 2

local function _GetTextWidth(font_file, font_size, text)
	return math.ceil(font_file:getWidth(text) * font_size / DEFAULT_FONT_SIZE)
end

local cmethods = {
	__draw__ = function(self)
		if (self.visible == true) then
			love.graphics.setFont(self.font_file)

			if (self.text:sub(1, 4) == "|cff" and self.text:len() > 10) then
				local hex = "#" .. self.text:sub(5, 10)
				local text = self.text:sub(11)

				love.graphics.setColor(unpack(HexToRGB(hex)))
				love.graphics.print(text, self.left, self.top, 0, self.scale_x, self.scale_z)
			else
				love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
				love.graphics.print(self.text, self.left, self.top, 0, self.scale_x, self.scale_z)

			end

			love.graphics.setFont(DEFAULT_FONT_FILE)
		end
	end
}

local methods = {
	updateSelf = function(self)
		SetPointHandler(self)
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

	setFont = function(self, font_file, font_size)
		if (UIParent.fonts[font_file] == nil) then
			self.font_file = UIParent.fonts["default"]
		else
			self.font_file = UIParent.fonts[font_file]
		end
		self.font_size = font_size
		self.scale_x = font_size / DEFAULT_FONT_SIZE
		self.scale_z = font_size / DEFAULT_FONT_SIZE
		self.width = _GetTextWidth(self.font_file, self.font_size, self.text)
		self.height = font_size

		self:updateSelf()
	end,

	setPoint = function(self, point, relative_to, relative_point, offset_x, offset_z)
		self.point = point
		self.relative_to = relative_to
		self.relative_point = relative_point
		self.offset_x = offset_x
		self.offset_z = offset_z

		self:updateSelf()
	end,

	setText = function(self, text)
		self.text = tostring(text)
		self.width = _GetTextWidth(self.font_file, self.font_size, text)

		self:updateSelf()
	end,


	setLevel = function(self, level)
		self.level = level
	end,

	getText = function(self)
		return self.text or ""
	end,

	show = function(self)
		self.visible = true
	end,

	hide = function(self)
		self.visible = false
	end,
}

local string = {}

function string.CreateString(parent)
	local inst = {}

	inst.parent = parent
	inst.type = "string"

	inst.point = "NONE"
	inst.relative_to = parent
	inst.relative_point = "NONE"

	inst.font_file = DEFAULT_FONT_FILE
	inst.font_size = DEFAULT_FONT_SIZE
	inst.scale_x = 1
	inst.scale_z = 1

	inst.width = 0
	inst.height = DEFAULT_FONT_SIZE
	inst.text = ""

	inst.visible = true
	inst.level = 1

	for method, func in pairs(cmethods) do
		inst[method] = func
	end

	for method, func in pairs(methods) do
		inst[method] = func
	end

	return inst
end

return string
