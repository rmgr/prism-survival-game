--- @class AttackBehaviour : Object, IBehavior
local AttackBehaviour = prism.BehaviorTree.Node:extend("AttackBehaviour")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action | boolean
function AttackBehaviour:run(level, actor, controller)
	local senses = actor:get(prism.components.Senses)
	if not senses then
		return false
	end

	local player = senses:query(level, prism.components.PlayerController):first()

	if not player then
		return false
	end
	return prism.actions.Attack(actor, player)
end

return AttackBehaviour
