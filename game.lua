local levelgen = require("levelgen")

--- @class Game : Object
--- @field depth integer
--- @field rng RNG
--- @field level Level?
--- @field player Actor?
--- @field factions table<string, Actor>

--- @overload fun(seed: string): Game
local Game = prism.Object:extend("Game")

--- @param seed string
function Game:__new(seed)
	self.depth = 0
	self.rng = prism.RNG(seed)
	self.player = prism.actors.Player()

	-- Initialize factions once
	self.factions = {
		PlayerFaction = prism.actors.PlayerFaction(),
		KoboldFaction = prism.actors.KoboldFaction(),
	}

	-- Establish initial faction relationships
	self.factions.PlayerFaction:addRelation(
		prism.relations.FactionRelationshipRelation(-100),
		self.factions.KoboldFaction
	)
end

--- @return string
function Game:getLevelSeed()
	return tostring(self.rng:random())
end

--- @param builder? LevelBuilder
--- @return LevelBuilder builder
function Game:generateNextFloor(builder)
	self.depth = self.depth + 1

	local genRNG = prism.RNG(self:getLevelSeed())
	return levelgen(genRNG, self.player, 60, 30, builder)
end

_G.Game = Game(tostring(os.time()))
