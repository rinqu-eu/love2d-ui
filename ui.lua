UIParent = {
	children = {},
	fonts = {},

	left = 0,
	top = 0,
	right = WINDOW_WIDTH,
	bottom = WINDOW_HEIGHT,

	width = WINDOW_WIDTH,
	height = WINDOW_HEIGHT,

	visible = true,

	isVisible = function(self)
		return self.visible
	end,

	update = function(self, dt)
		for _, child in pairs(self.children) do
			child:__update(dt)
		end
	end,

	draw = function(self)
		for _, child in pairs(self.children) do
			child:__draw()
		end
	end,

	keypressed = function(self, key)
		for _, child in pairs(self.children) do
			child:keypressed(key)
		end
	end,

	keyreleased = function(self, key)
		for _, child in pairs(self.children) do
			child:keyreleased(key)
		end
	end,

	mousepressed = function(self, button, x, z)
		if (context_menu ~= nil) then
			if (button == 1 and context_menu:isMouseOver() == false) then
				context_menu:hide()
			end

			if (button == 2) then
				local position = game.player.position
				local tx = -1 * select(2, math.modf(position.gx)) * 64
				local tz = -1 * select(2, math.modf(position.gz)) * 64
				local gx = position.gx
				local gz = position.gz
				local x, z = windowToGameCords(x, z, 1, tx, tz, gx, gz)

				self.entity = GetTopEntity(x, z)

				if (self.entity ~= nil) then
					context_menu:show()
				end
			end
		end

		for _, child in pairs(self.children) do
			child:mousepressed(button, x, z)
		end
	end,

	mousereleased = function(self, button, x, z)
		for _, child in pairs(self.children) do
			child:mousereleased(button, x, z)
		end
	end,

	wheelmoved = function(self, dir)
		for _, child in pairs(self.children) do
			child:wheelmoved(dir)
		end
	end
}

UIParent.fonts["default"] = love.graphics.getFont()
UIParent.fonts["fira_code"] = love.graphics.newFont("assets/FiraCode.ttf", 14)

UIParent.container = {}
UIParent.container.textures = {}

UIParent.container.textures["exit_off"] = {image = love.graphics.newImage("assets/common/ui/exit_off.png"), width = 32, height = 32}
UIParent.container.textures["exit_on"] = {image = love.graphics.newImage("assets/common/ui/exit_on.png"), width = 32, height = 32}

require("src.common.ui.widgets.frame")
