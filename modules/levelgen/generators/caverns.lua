local BspGenerator = prism.levelgen.util.BspGenerator
--- @class Cavern : Generator
local Cavern = prism.levelgen.Generator:extend("Cavern")

function Cavern:generate(generatorInfo, player, rng)
	local seed = generatorInfo.seed
	local w, h = generatorInfo.w, generatorInfo.h
	local depth = generatorInfo.depth
	local builder = prism.LevelBuilder()

	builder:addSeed(seed)
	local bspTree, roomGraph = BspGenerator:generateBspTree(w, h, rng)

	local visited = {}
	local stack = { bspTree }
	local placedPlayer = false

	-- Fill with walls
	for x = 1, w do
		for y = 1, h do
			builder:set(x, y, prism.cells.Pit())
		end
	end
	return builder, roomGraph
end
return Cavern
