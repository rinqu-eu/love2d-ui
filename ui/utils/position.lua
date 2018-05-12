local points = {
	TOPLEFT = 1,
	TOP = 2,
	TOPRIGHT = 3,
	LEFT = 4,
	CENTER = 5,
	RIGHT = 6,
	BOTTOMLEFT = 7,
	BOTTOM = 8,
	BOTTOMRIGHT = 9,
	ALL = 10,
	NONE = 11
}

function SetPointHandler(self)
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
