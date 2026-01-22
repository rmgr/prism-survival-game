--- @class RandomChanceBehaviour : BehaviorTree.Node
local RandomChanceBehaviour = prism.BehaviorTree.Node:extend("RandomChanceBehaviour")

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action | boolean
function RandomChanceBehaviour:run(level, actor, controller)
	return level.RNG:random(0, 1) == 0
end

return RandomChanceBehaviour
