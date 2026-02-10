local FleeSubroutine = prism.BehaviorTree.Sequence:extend("FleeSubroutine")

function FleeSubroutine:__new()
	return prism.BehaviorTree.Sequence.__new(self, {
		prism.BehaviorTree.Sequence({
			prism.behaviours.FindFearedBehaviour(),
			prism.BehaviorTree.Selector({
				prism.BehaviorTree.Sequence({
					prism.behaviours.CheckRoomTargetBehaviour(),
					prism.behaviours.MoveBehaviour(),
				}),
				prism.BehaviorTree.Sequence({
					prism.behaviours.FindNearestRoomNotContainingEnemyBehaviour(),
					prism.behaviours.MoveBehaviour(),
				}),
			}),
		}),
	})
end

return FleeSubroutine
