--- @class GeneratorInfo
--- @field w integer
--- @field h integer
--- @field seed any
--- @field depth integer

--- @class Generator : Object
local Generator = prism.Object:extend("Generator")

--- @param generatorInfo GeneratorInfo
---@param player Actor
---@param rng RNG
function Generator.generate(generatorInfo, player, rng)
	error("This must be overriden!")
end

return Generator
