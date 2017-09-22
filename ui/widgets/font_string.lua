local DEFAULT_FONT_SIZE = 14
local DEFAULT_FONT_FILE = UIParent.fonts["default"]

local PADDING = 2

local _getTextWidth = function(font_file, font_size, text)
	return math.ceil(font_file:getWidth(text) * font_size / DEFAULT_FONT_SIZE)
end

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
			self.left = relative_x + PADDING
			self.right = self.left + self.width
		elseif (point:match("RIGHT") ~= nil) then
			self.left = relative_x - self.width - PADDING
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
			love.graphics.setFont(self.font_file)

			if (self.text:sub(1, 4) == "|cff" and self.text:len() > 10) then
				local hex = "#" .. self.text:sub(5, 10)
				local text = self.text:sub(11)

				love.graphics.setColor(unpack(ToRGB(hex)))
				love.graphics.print(text, self.left, self.top, 0, self.scale_x, self.scale_z)
				love.graphics.setColor(255, 255, 255, 255)
			else
				love.graphics.print(self.text, self.left, self.top, 0, self.scale_x, self.scale_z)

			end

			love.graphics.setFont(DEFAULT_FONT_FILE)
		end
	end,

	["__update"] = function(self)
		_setPointHandler(self)
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

	["setFont"] = function(self, font_file, font_size)
		if (UIParent.fonts[font_file] == nil) then
			self.font_file = UIParent.fonts["default"]
		else
			self.font_file = UIParent.fonts[font_file]
		end
		self.font_size = font_size
		self.scale_x = font_size / DEFAULT_FONT_SIZE
		self.scale_z = font_size / DEFAULT_FONT_SIZE
		self.width = _getTextWidth(self.font_file, self.font_size, self.text)
		self.height = font_size

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

	["setText"] = function(self, text)
		self.text = tostring(text)
		self.width = _getTextWidth(self.font_file, self.font_size, text)

		self:__update()
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

local font_string = {}

font_string.CreateFontString = function(parent)
	local inst = {}

	inst.parent = parent
	inst.type = "font_string"

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

	for method, func in pairs(methods) do
		inst[method] = func
	end

	return inst
end

return font_string