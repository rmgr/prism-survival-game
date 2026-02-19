local BspGenerator = prism.levelgen.util.BspGenerator
local RoomManager = prism.levelgen.util.RoomManager
--- @class Cavern : Generator
local Cavern = prism.levelgen.Generator:extend("Cavern")
local DEBUG = false

--- @param generatorInfo GeneratorInfo
--- @param player Actor
function Cavern:generate(generatorInfo, player, rng)
	local seed = generatorInfo.seed
	local w, h = generatorInfo.w, generatorInfo.h
	local depth = generatorInfo.depth
	local builder = prism.LevelBuilder()

	builder:addSeed(seed)
	local bspTree = BspGenerator:generateBspTree(w, h, rng)

	local visited = {}
	local stack = { bspTree }
	local placedPlayer = false

	-- Fill with walls
	for x = 1, w do
		for y = 1, h do
			builder:set(x, y, prism.cells.Wall())
		end
	end

	self:addRandomPits(builder, w, h, rng)

	while #stack > 0 do
		local item = table.remove(stack)
		if not visited[item] then
			visited[item] = true
			if item.left then
				table.insert(stack, item.left)
			end
			if item.right then
				table.insert(stack, item.right)
			end
			if not item.left and not item.right then
				if item.x + item.w < w and item.y + item.h < h and item.x - item.w > 0 and item.y - item.h > 0 then
					local room = self:createRoom(builder, item.x, item.y, item.w, item.h, rng)
					prism.decorators.CavernFloorDecorator.tryDecorate(generatorInfo, rng, builder, room)
					if not placedPlayer then
						builder:addActor(player, room.centerX, room.centerY)
						placedPlayer = true
					else
						if rng:random(1, 2) == 1 then
							builder:addActor(prism.actors.Beetle(), room.centerX, room.centerY)
						end
					end
					item.room = room
				end
			end
		end
	end

	self:connectSiblings(bspTree, builder, rng)
	for i = 1, 5 do
		local room = RoomManager.roomGraph.rooms[rng:random(1, #RoomManager.roomGraph.rooms)]
		local rect = prism.Rectangle(room.x, room.y, room.w, room.h)
		local corners = rect:toCorners()
		local attempts = 0

		while attempts < 4 do
			local randCorner = corners[rng:random(1, #corners)]
			local x, y = randCorner:decompose()
			local cell = builder:get(x, y)
			if not cell:has(prism.components.Void) then
				local path = prism.astar(randCorner, player:getPosition(), function(_x, _y)
					return builder:get(_x, _y) ~= nil
				end)

				if #path > 1 then
					builder:addActor(prism.actors.Olm(), x, y)
				end
			end
			attempts = attempts + 1
		end
	end

	local extraConnections = rng:random(6, 10)
	self:addExtraConnections(bspTree, builder, rng, extraConnections)
	prism.decorators.SalamanderNestDecorator.tryDecorate(
		generatorInfo,
		rng,
		builder,
		RoomManager.roomGraph.rooms[rng:random(1, #RoomManager.roomGraph.rooms)]
	)

	prism.decorators.KoboldNestDecorator.tryDecorate(
		generatorInfo,
		rng,
		builder,
		RoomManager.roomGraph.rooms[rng:random(1, #RoomManager.roomGraph.rooms)]
	)
	builder:pad(1, prism.cells.Wall)

	local roomGraph = RoomManager.roomGraph

	return builder, roomGraph
end

function Cavern:addRandomPits(builder, width, height, rng)
	local noiseOffsetX = rng:random(1, 10000)
	local noiseOffsetY = rng:random(1, 10000)
	local noiseScale = 5
	local pitThreshold = 0.5

	for x = 1, width do
		for y = 1, height do
			local noise = love.math.noise(x / noiseScale + noiseOffsetX, y / noiseScale + noiseOffsetY)
			if noise > pitThreshold then
				builder:set(x, y, prism.cells.Pit())
			end
		end
	end
end
return Cavern
