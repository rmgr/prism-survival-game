-- Alternative: Just show cardinal/diagonal markers expanding out
spectrum.registerAnimation("SoundRadiusMarkersExpand", function(radius, centerX, centerY)
	return spectrum.Animation(function(t, display)
		local animationDuration = 0.3
		local progress = t / animationDuration

		if progress >= 1 then
			return true
		end

		-- Only animate expansion for radius > 5, otherwise show immediately
		local currentRadius = radius
		if radius > 1 then
			currentRadius = progress * radius
		end

		local markers = {
			{ radius, 0 }, -- East
			{ -radius, 0 }, -- West
			{ 0, radius }, -- South
			{ 0, -radius }, -- North
			{ radius, radius }, -- SE
			{ -radius, radius }, -- SW
			{ radius, -radius }, -- NE
			{ -radius, -radius }, -- NW
		}

		for _, pos in ipairs(markers) do
			-- Normalize the direction and scale by current radius
			local len = math.sqrt(pos[1] * pos[1] + pos[2] * pos[2])
			local dirX = pos[1] / len
			local dirY = pos[2] / len

			local x = math.floor(currentRadius * dirX + 0.5)
			local y = math.floor(currentRadius * dirY + 0.5)
			display:putBG(centerX + x, centerY + y, prism.Color4.fromHex(0x202020))
		end

		return false
	end)
end)
