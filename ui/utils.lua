-- ---- HexToRGB
-- @param hex String #rrggbb or #rrggbbaa
-- ----
-- @return [1] Table containing RGBA values 0.00 - 1.00
-- ----

function HexToRGB(hex)
	local r = tonumber(hex:sub(2, 3), 16) / 255
	local g = tonumber(hex:sub(4, 5), 16) / 255
	local b = tonumber(hex:sub(6, 7), 16) / 255
	local a = 1.0

	if (hex:len() == 9) then
		a = tonumber(hex:sub(8, 9), 16) / 255
	end

	return {r, g, b, a}
end
