--- @class AdoreBehaviour : Object, IBehavior
local AdoreBehaviour = prism.BehaviorTree.Node:extend("AdoreBehaviour")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action|boolean
function AdoreBehaviour:run(level, actor, controller)
	local senses = actor:get(prism.components.Senses)
	local player =
		senses:query(level, prism.components.PlayerController):relation(actor, prism.relations.FriendRelation):first()
	if not player then
		return false
	end
	local on = { index = "!", color = prism.Color4.PINK }
	local off = { index = " ", color = prism.Color4.BLACK }
	local animation = spectrum.Animation({ on, off, on }, 0.2, "pauseAtEnd")

	level:yield(prism.messages.AnimationMessage({
		animation = animation,
		actor = actor,
	}))
	return prism.actions.Wait(actor)
end

return AdoreBehaviour
