--- @class FleeBehaviour : Object, IBehavior
local FleeBehaviour = prism.BehaviorTree.Node:extend("FleeBehaviour")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action|boolean
function FleeBehaviour:run(level, actor, controller)
	local senses = actor:get(prism.components.Senses)
	if not senses then
		return false
	end

	local player = senses:query(level, prism.components.PlayerController):first()
	if not player then
		return false
	end

	local mover = actor:get(prism.components.Mover)
	if not mover then
		return false
	end

	local direction = (actor:getPosition() - player:getPosition()):normalize()
	local targetPos = actor:getPosition() + (direction * 3)

	local path = level:findPath(actor:getPosition(), targetPos, actor, mover.mask, 1)

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

return FleeBehaviour
