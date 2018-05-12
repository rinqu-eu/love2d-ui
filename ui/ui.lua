ui = {}
UIParent = ui

setmetatable(ui, {__index = _G})
setfenv(1, ui)

__VERSION = 0.02

__children__ = {}
__frames__ = {}

path = ...
path_req = path:sub(1, -4)
path_load = path:sub(1, -4):gsub("%.", "/")

type = "UIParent"
name = "UIParent"

left = 0
right = love.graphics.getWidth()
top = 0
bottom = love.graphics.getHeight()

width = right
height = bottom

level = 255
layer = 5
is_visible = true

local function _SortDrawables(frames)
	for _, layer in ipairs(frames) do
		if (#layer < 2) then break end

		local l, m = 1, #layer

		for i = 1, m - 1 do
			for j = i, m do
				if (layer[j][2] < layer[i][2]) then
					layer[i], layer[j] = layer[j], layer[i]
				end
			end
		end
	end
end

function update(self, dt)
	for _, frame in pairs(self.__frames__) do
		frame:__update__(dt)
	end
end

function draw(self)
	local to_draw = {{},{},{},{},{}}

	for _, frame in pairs(self.__frames__) do
		table.insert(to_draw[frame.layer], {frame, frame.level})
	end

	_SortDrawables(to_draw)

	for _, layer in ipairs(to_draw) do
		for _, frame in ipairs(layer) do
			frame[1]:__draw__()
		end
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
	return self.is_visible
end

UIParent.fonts = {}
UIParent.fonts["default"] = love.graphics.getFont()
UIParent.fonts["fira_code"] = love.graphics.newFont(path_load .. "/assets/FiraCode.ttf", 14)

do
	require(path_req .. ".utils.color")
	require(path_req .. ".utils.math")
	require(path_req .. ".widgets.frame")
	require(path_req .. ".widgets.dropdown")
end
