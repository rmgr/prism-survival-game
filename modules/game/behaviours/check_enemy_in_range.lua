--- @class CheckEnemyInRangeBehaviour : BehaviorTree.Node
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
	local target = controller.blackboard["target"]
	if not target then
		return false
	end

	if prism.Actor:is(target) then
		target = target:getPosition()
	end
	-- Check if player is within specified range
	local distance = actor:getPosition():distance(target)
	return distance <= self.range
end

return CheckEnemyInRangeBehaviour
