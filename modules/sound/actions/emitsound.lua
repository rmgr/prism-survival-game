local VolumeTarget = prism.Target():isType("number")
local SkipAnimationsTarget = prism.Target():isType("boolean")
local ShowRadiusTarget = prism.Target():isType("boolean")
---@class EmitSound : Action
---@field volume integer
---@overload fun(owner: Actor, volume: integer ): EmitSound
local EmitSound = prism.Action:extend("EmitSound")

EmitSound.targets = { VolumeTarget, SkipAnimationsTarget, ShowRadiusTarget }
function EmitSound:perform(level, volume, skipAnimations, showRadius)
	local position = self.owner:getPosition()
	if not position then
		return
	end
	local originX, originY = position:decompose()
	if skipAnimations or false then
		level:yield(prism.messages.SkipAnimationsMessage())
	end
	if showRadius or false then
		level:yield(prism.messages.AnimationMessage({
			animation = spectrum.animations.SoundRadiusMarkersExpand(volume, originX, originY),
			actor = self.owner,
			skippable = true,
		}))
	end
	-- Initialize cache for this sound propagation
	self._soundCache = {}

	local q = prism.Queue()
	local visited = {}
	-- Initial state: {x, y, current_distance}
	q:push({ originX, originY, 0 })
	visited[originX .. "," .. originY] = true

	while not q:empty() do
		local curr = q:pop()
		local cx, cy, dist = curr[1], curr[2], curr[3]

		local actor = level:query(prism.components.Hearing):at(cx, cy):first()

		if actor and actor ~= self.owner then
			actor:addRelation(prism.relations.HearsRelation, self.owner)
		end

		-- Spread to neighbors if within the volume range
		if dist < volume then
			for _, dir in ipairs(prism.neighborhood) do
				local nx, ny = cx + dir.x, cy + dir.y
				local key = nx .. "," .. ny
				-- Check if we've been here and if sound can transmit through this cell
				if not visited[key] and self:canTransmitSound(level, nx, ny) then
					--[[					level:yield(prism.messages.AnimationMessage({
						animation = spectrum.animations.DistantSound(),
						x = nx,
						y = ny,
					}))]]

					visited[key] = true
					q:push({ nx, ny, dist + 1 })
				end
			end
		end
	end
end

--- Check if a cell can transmit sound
--- @param level Level
--- @param x integer
--- @param y integer
--- @return boolean
function EmitSound:canTransmitSound(level, x, y)
	-- Check bounds first
	if not level:inBounds(x, y) then
		return false
	end

	-- Use cache if available
	local cacheKey = x .. "," .. y
	if self._soundCache and self._soundCache[cacheKey] ~= nil then
		return self._soundCache[cacheKey]
	end

	local cell = level:getCell(x, y)
	if not cell then
		return false
	end
	local collider = cell:get(prism.components.Collider)
	if not collider then
		if self._soundCache then
			self._soundCache[cacheKey] = false
		end
		return false
	end

	local walkBit = prism.Collision.createBitmaskFromMovetypes({ "walk", "fly" })
	local flyBit = prism.Collision.createBitmaskFromMovetypes({ "fly" })
	local mask = collider:getMask()
	if not mask then
		if self._soundCache then
			self._soundCache[cacheKey] = false
		end
		return false
	end

	local passable = (bit.band(mask, walkBit) == walkBit) or bit.band(mask, flyBit) == flyBit
	if self._soundCache then
		self._soundCache[cacheKey] = passable
	end
	return passable
end

function EmitSound:canPerform(level)
	return true
end

return EmitSound
