ui = {}
UIParent = ui

setmetatable(ui, {__index = _G})
setfenv(1, ui)

__VERSION = 0.00

__children__ = {}
__frames__ = {}

path = ...
path_req = path:sub(1, -4)
path_load = path:sub(1, -4):gsub("%p", "/")

type = "UIParent"
name = "UIParent"

left = 0
right = love.graphics.getWidth()
top = 0
bottom = love.graphics.getHeight()

width = right
height = bottom

level = 0
strata = 0

function update(self, dt)
	for _, frame in pairs(self.__frames__) do
		frame:__update__(dt)
	end
end

function draw(self)
	for _, frame in pairs(self.__frames__) do
		frame:__draw__()
	end
end

function keypressed(self, key)
	for _, frame in pairs(self.__frames__) do
		frame:__keypressed__(key)
	end
end

function keyreleased(self, key)
	for _, frame in pairs(self.__frames__) do
		frame:__keyreleased__(key)
	end
end

function mousepressed(self, x, y, button)
	for _, frame in pairs(self.__frames__) do
		frame:__mousepressed__(x, y, button)
	end
end

function mousereleased(self, x, y, button)
	for _, frame in pairs(self.__frames__) do
		frame:__mousereleased__(x, y, button)
	end
end

function mousemoved(self, x, y, dx, dy)
	for _, frame in pairs(self.__frames__) do
		frame:__mousemoved__(x, y, dx, dy)
	end
end

function wheelmoved(self, x, y)
	for _, frame in pairs(self.__frames__) do
		frame:__wheelmoved__(x, y)
	end
end

function isVisible(self)
	return true
end



UIParent.fonts = {}
UIParent.fonts["default"] = love.graphics.getFont()
UIParent.fonts["fira_code"] = love.graphics.newFont(path_load .. "/assets/FiraCode.ttf", 14)

do
	require(path_req.. ".widgets.frame")
end
-- UIParent.container = {}
-- UIParent.container.textures = {}

-- UIParent.container.textures["exit_off"] = {image = love.graphics.newImage("assets/common/ui/exit_off.png"), width = 32, height = 32}
-- UIParent.container.textures["exit_on"] = {image = love.graphics.newImage("assets/common/ui/exit_on.png"), width = 32, height = 32}

