--- @class MoveBehaviour : Object, IBehavior
local MoveBehaviour = prism.BehaviorTree.Node:extend("MoveBehaviour")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action|boolean
function MoveBehaviour:run(level, actor, controller)
	local senses = actor:get(prism.components.Senses)
	local player =
		senses:query(level, prism.components.PlayerController):relation(actor, prism.relations.FoeRelation):first()

	if not player then
		return false
	end

	local mover = actor:get(prism.components.Mover)
	if not mover then
		return false
	end

	local path = level:findPath(actor:getPosition(), player:getPosition(), actor, mover.mask, 1)

	if not path then
		return false
	end

	local nextStep = path:pop()
	local move = prism.actions.Move(actor, nextStep)

	if level:canPerform(move) then
		return move
	end

	return false
end

return MoveBehaviour
