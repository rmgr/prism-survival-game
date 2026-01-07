--- @class AttackBehaviour : BehaviorTree.Node
local AttackBehaviour = prism.BehaviorTree.Node:extend("AttackBehaviour")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action | boolean
function AttackBehaviour:run(level, actor, controller)
	local player = controller.blackboard.short["target"]

	if not player then
		return false
	end
	return prism.actions.Attack(actor, player)
end

return AttackBehaviour
