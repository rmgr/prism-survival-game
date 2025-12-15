--- @class FindEnemyBehaviour : Object, IBehavior
local FindEnemyBehaviour = prism.BehaviorTree.Node:extend("FindEnemyBehaviour")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return boolean|Action
function FindEnemyBehaviour:run(level, actor, controller)
	local senses = actor:get(prism.components.Senses)

	if not senses then
		return false
	end

	local player = senses:query(level, prism.components.PlayerController):first()
	if not player then
		return false
	end

	return true
end

return FindEnemyBehaviour
