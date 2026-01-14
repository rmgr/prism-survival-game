--- @class FindEnemyBehaviour : BehaviorTree.Node
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

	local target = senses:query(level, prism.components.Component):relation(actor, prism.relations.FoeRelation):first()

	if not target then
		target = controller.blackboard.long["last_heard"]
	end

	if not target then
		return false
	end

	controller.blackboard.short["target"] = target

	return true
end

return FindEnemyBehaviour
