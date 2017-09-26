local methods = {
	setText = function(self, text)
		self.text:setText(text)
	end,

	open = function(self)
		self.dropdown:show()
	end,

	close = function(self)
		self.dropdown:hide()
	end,

	addElement = function(self, index)
		local inst = CreateFrame(self.dropdown, self.name .. "_element" .. index)

		inst.type = "dropdown_element"
		inst.index = index
		inst:setSize(self.settings.el_width, self.settings.el_height)
		inst:setPoint("TOPLEFT", self.dropdown, "TOPLEFT", 0, self.settings.el_height * (inst.index - 1))

		inst.bg = inst:createTexture()
		inst.bg:setAllPoints(inst)
		inst.bg:setColorTexture(self.settings.el_color)

		inst.text = inst:createFontString()
		inst.text:setPoint("LEFT", inst, "LEFT", 3, 0)

		inst:setScript("OnMouseDown", function(self, x, y, button)
			if (button == 1 and self:isMouseOver() == true) then
				self.bg:setColorTexture(self.parent.parent.settings.el_color)
				self.parent.parent:setText(self.text:getText())
				self.parent.parent.selected_idx = self.index

				self.parent.parent:close()
			end
		end)
		inst:setScript("OnEnter", function(self)
			self.bg:setColorTexture(self.parent.parent.settings.el_color_s)
		end)
		inst:setScript("OnLeave", function(self)
			self.bg:setColorTexture(self.parent.parent.settings.el_color)
		end)

		table.insert(self.dropdown.elements, inst)
	end,

	update = function(self)
		local num_elements = #self.dropdown.elements

		for i = 1, num_elements do
			local e = self.dropdown.elements[i]
			local d = self.data[i]

			if (d ~= nil) then
				e.text:setText(d[self.text_field] or "")
				e:show()
			else
				e:hide()
			end
		end
		self.dropdown:setSize(self.settings.el_width, num_elements * self.settings.el_height)
	end,

	setData = function(self, data, text_field)
		self.data = data
		self.text_field = text_field
		self:update()
	end,

	getIndex = function(self)
		self.index = self.index + 1
		return self.index
	end,
}

function CreateDropdown(parent, name)
	local inst = CreateFrame(parent, name)

	inst.type = "dropdown"
	inst.index = 0

	inst.settings = {
		bg_color = {35, 35, 35, 255},
		el_color = {50, 50, 50, 255},
		el_color_s = {100, 100, 100, 255},
		el_width = 400,
		el_height = 20,
	}

	-- inst.colors = {
		-- bg = {35, 35, 35, 255},
		-- dd_el_bg = {50, 50, 50, 255},
		-- dd_el_bg_sel = {100, 100, 100, 255}
	-- }
	-- inst.element_width = 400
	-- inst.element_height = 20

	inst.data = {}
	inst.text_field = ""

	inst.bg = inst:createTexture()
	inst.bg:setAllPoints(inst)
	inst.bg:setColorTexture(inst.settings.bg_color)

	inst.text = inst:createFontString()
	inst.text:setPoint("LEFT", inst, "LEFT", 3, 0)

	inst.dropdown = CreateFrame(inst)
	inst.dropdown:setPoint("TOPLEFT", inst, "BOTTOMLEFT", 0, 0)

	inst.dropdown.elements = {}

	inst:setScript("OnMouseDown", function(self, x, y, button)
		if (button == 1 and self:isMouseOver() == true) then
			if (self.dropdown:isVisible() == true) then
				self:close()
			else
				self:open()
			end
		elseif (button == 1 and self.dropdown:isMouseOver() == true) then
			--let the elements close it
		else
			self:close()
		end
	end)

	for method, func in pairs(methods) do
		inst[method] = func
	end

	inst:close()

	for i = 1, 10 do
		inst:addElement(inst:getIndex())
	end

	return inst
end
