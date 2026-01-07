--- @class RandomMoveBehaviour : BehaviorTree.Node
local RandomMoveBehaviour = prism.BehaviorTree.Node:extend("RandomMoveBehaviour")

function RandomMoveBehaviour:__new() end

--- @param self BehaviorTree.Node
--- @param level Level
--- @param actor Actor
--- @param controller Controller
--- @return Action|boolean
function RandomMoveBehaviour:run(level, actor, controller)
	local mover = actor:get(prism.components.Mover)
	if not mover then
		return false
	end

	local currentPos = actor:getPosition()
	if not currentPos then
		return false
	end

	-- Get all neighbors using prism.neighborhood
	local validPositions = {}

	for _, dir in ipairs(prism.neighborhood) do
		local nx, ny = currentPos.x + dir.x, currentPos.y + dir.y
		local targetPos = prism.Vector2(nx, ny)
		local move = prism.actions.Move(actor, targetPos)
		if level:canPerform(move) then
			table.insert(validPositions, targetPos)
		end
	end

	-- If no valid positions, fail
	if #validPositions == 0 then
		return false
	end

	-- Pick a random valid position and store it in blackboard
	local randomIndex = love.math.random(1, #validPositions)
	controller.blackboard.short["target"] = validPositions[randomIndex]

	return true
end

return RandomMoveBehaviour
