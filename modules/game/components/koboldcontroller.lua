--- @class KoboldController : Controller
--- @overload fun() : KoboldController
local KoboldController = prism.components.Controller:extend("KoboldController")
local BT = prism.BehaviorTree

function KoboldController:__new()
	self.tree = BT.Root({
		BT.Selector({
			-- Either,
			prism.behaviours.AdoreBehaviour(),
			BT.Sequence({
				prism.behaviours.HPBelowPercentageCheckBehaviour(34),
				prism.behaviours.FleeBehaviour(),
			}),
			BT.Sequence({
				-- if Enemy in range, attack it.
				prism.behaviours.CheckEnemyInRangeBehaviour(1),
				prism.behaviours.AttackBehaviour(),
			}),
			-- Move
			prism.behaviours.MoveBehaviour(),
			-- Or finally, wait
			-- We need this here to catch the case where we can't move or attack
			prism.behaviours.WaitBehaviour(),
		}),
	})
end

function KoboldController:act(level, actor)
	-- Initialize tree if it doesn't exist (e.g., after loading from save)
	if not self.tree then
		self:__new()
	end
	return self.tree:run(level, actor, self)
end

return KoboldController
