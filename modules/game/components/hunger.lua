--- @class Satiety : Component
--- @field satiety integer
--- @field maxSatiety integer
--- @overload fun(maxSatiety: integer): Satiety
local Satiety = prism.Component:extend("Satiety")

function Satiety:__new(maxSatiety)
	self.satiety = maxSatiety
	self.maxSatiety = maxSatiety
end

return Satiety
