-- ---- Clamp
-- @param number Number
-- @param min Number
-- @param max Number
-- ----
-- @return [1] Number
-- ----

function Clamp(number, min, max)
	local n = number

	if (number < min) then n = min end
	if (number > max) then n = max end

	return n
end
