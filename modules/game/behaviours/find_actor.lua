	--- @class FindActorBehaviour : BehaviorTree.Node
--- @field relations table
--- @overload fun(relations: table): BehaviorTree.Node
local FindActorBehaviour = prism.BehaviorTree.Node:extend("FindActorBehaviour")

--- @param relations table
function FindActorBehaviour:__new(relations)
	self.relations = relations or {} -- Provide default empty table
end

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return boolean|Action
function FindActorBehaviour:run(level, actor, controller)
	local senses = actor:get(prism.components.Senses)
	if not senses then
		return false
		end
		if not controller or not controller.blackboard or not controller.blackboard.short then
			return false
			end


	local query = senses:query(level, prism.components.Component)

	if self.relations and #self.relations > 0 then
		for _, relation in ipairs(self.relations) do
			query:relation(actor, relation)
		end
	end
	local target = query:first()

	if target == actor then
		return false
	end

	if not target then
		target = controller.blackboard.long["last_heard"]
	end

	if not target then
		return false
	end

	controller.blackboard.short["target"] = target
	return true
end

return FindActorBehaviour
