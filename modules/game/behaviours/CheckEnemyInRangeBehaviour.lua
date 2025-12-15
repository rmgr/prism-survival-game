--- @class CheckEnemyInRangeBehaviour : Object, IBehavior
--- @field range number
local CheckEnemyInRangeBehaviour = prism.BehaviorTree.Node:extend("CheckEnemyInRangeBehaviour")

--- @param range number
function CheckEnemyInRangeBehaviour:__new(range)
	self.range = range or 1
end

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return boolean
function CheckEnemyInRangeBehaviour:run(level, actor, controller)
	local senses = actor:get(prism.components.Senses)
	if not senses then
		return false
	end

	local player = senses:query(level, prism.components.PlayerController):first()
	if not player then
		return false
	end

	-- Check if player is within specified range
	local distance = actor:getPosition():distance(player:getPosition())
	return distance <= self.range
end

return CheckEnemyInRangeBehaviour
