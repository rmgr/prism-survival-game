--- @class HPBelowPercentageCheckBehaviour : BehaviorTree.Node
--- @field percentage number
local HPBelowPercentageCheckBehaviour = prism.BehaviorTree.Node:extend("HPBelowPercentageCheckBehaviour")

--- @param percentage number
function HPBelowPercentageCheckBehaviour:__new(percentage)
	self.percentage = percentage or 100
end
--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return boolean|Action
function HPBelowPercentageCheckBehaviour:run(level, actor, controller)
	local health = actor:get(prism.components.Health)

	if not health then
		return false
	end
	if (health.hp / health.maxHP) * 100 < self.percentage then
		return true
	end

	return false
end

return HPBelowPercentageCheckBehaviour
