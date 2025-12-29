local DEBUG = false

local PARTITIONS = 3
local chestloot = require("loot.chest")

--- @param rng RNG
--- @param player Actor
--- @param width integer
--- @param height integer
--- @param builder? LevelBuilder
return function(rng, player, width, height, builder)
	if not builder then
		builder = prism.LevelBuilder(prism.cells.Wall)
	end

	-- Debug: Use a simple test map instead of procedural generation
	if DEBUG then
		builder:rectangle("line", 0, 0, 32, 32, prism.cells.Wall)
		-- Fill the interior with floor tiles
		builder:rectangle("fill", 1, 1, 31, 31, prism.cells.Floor)
		-- Add a small block of walls within the map
		builder:rectangle("fill", 5, 5, 7, 7, prism.cells.Wall)
		-- Add a pit area to the southeast
		builder:rectangle("fill", 20, 20, 25, 25, prism.cells.Pit)

		-- Place the player character at a starting location
		builder:addActor(player, 12, 12)

		return builder
	end

	-- Fill the map with random noise of pits and walls.
	local nox, noy = rng:random(1, 10000), rng:random(1, 10000)
	for x = 1, width do
		for y = 1, height do
			local noise = love.math.perlinNoise(x / 5 + nox, y / 5 + noy)
			local cell = noise > 0.5 and prism.cells.Wall or prism.cells.Pit
			builder:set(x, y, cell())
		end
	end

	-- Create rooms in each of the partitions.
	--- @type table<number, Rectangle>
	local rooms = {}

	local missing = prism.Vector2(rng:random(0, PARTITIONS - 1), rng:random(0, PARTITIONS - 1))
	local pw, ph = math.floor(width / PARTITIONS), math.floor(height / PARTITIONS)
	local minrw, minrh = math.floor(pw / 3), math.floor(ph / 3)
	local maxrw, maxrh = pw - 2, ph - 2 -- Subtract 2 to ensure there's a margin.
	for px = 0, PARTITIONS - 1 do
		for py = 0, PARTITIONS - 1 do
			if not missing:equals(px, py) then
				local rw, rh = rng:random(minrw, maxrw), rng:random(minrh, maxrh)
				local x = rng:random(px * pw + 1, (px + 1) * pw - rw - 1)
				local y = rng:random(py * ph + 1, (py + 1) * ph - rh - 1)

				local roomRect = prism.Rectangle(x, y, rw, rh)
				rooms[prism.Vector2._hash(px, py)] = roomRect

				builder:rectangle("fill", x, y, x + rw, y + rh, prism.cells.Grass)
			end
		end
	end

	-- Helper function to connect two points with an L-shaped hallway.
	--- @param a Rectangle
	--- @param b Rectangle
	local function createLShapedHallway(a, b)
		if not a or not b then
			return
		end

		local ax, ay = a:center():floor():decompose()
		local bx, by = b:center():floor():decompose()
		-- Randomly choose one of two L-shaped tunnel patterns for variety.
		if rng:random() > 0.5 then
			builder:line(ax, ay, bx, ay, prism.cells.Grass)
			builder:line(bx, ay, bx, by, prism.cells.Grass)
		else
			builder:line(ax, ay, ax, by, prism.cells.Grass)
			builder:line(ax, by, bx, by, prism.cells.Grass)
		end
	end

	for hash, currentRoom in pairs(rooms) do
		local px, py = prism.Vector2._unhash(hash)

		createLShapedHallway(currentRoom, rooms[prism.Vector2._hash(px + 1, py)])
		createLShapedHallway(currentRoom, rooms[prism.Vector2._hash(px, py + 1)])
	end

	-- Choose the first room (top-left partition) to place the player.
	local startRoom
	while not startRoom do
		local x, y = rng:random(0, PARTITIONS - 1), rng:random(0, PARTITIONS - 1)
		startRoom = rooms[prism.Vector2._hash(x, y)]
	end

	local playerPos = startRoom:center():floor()
	builder:addActor(player, playerPos.x, playerPos.y)

	for _, room in pairs(rooms) do
		if room ~= startRoom then
			local cx, cy = room:center():floor():decompose()

			builder:addActor(prism.actors.Kobold(), cx, cy)
		end
	end
	builder:pad(1, prism.cells.Wall)

	--- @type Rectangle[]
	local availableRooms = {}
	for _, room in pairs(rooms) do
		if room ~= startRoom then
			table.insert(availableRooms, room)
		end
	end

	local stairRoom = availableRooms[rng:random(1, #availableRooms)]
	local corners = stairRoom:toCorners()
	local randCorner = corners[rng:random(1, #corners)]

	builder:addActor(prism.actors.Stairs(), randCorner.x, randCorner.y)
	local chestRoom = availableRooms[rng:random(1, #availableRooms)]
	local center = chestRoom:center():floor()
	local drops = prism.components.DropTable(chestloot):getDrops(rng)

	builder:addActor(prism.actors.Chest(drops), center:decompose())
	return builder
end
