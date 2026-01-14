prism.register(prism.Component:extend("Kobold"))
prism.registerActor("Kobold", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Kobold"),
		prism.components.Position(),
		prism.components.Drawable({ index = "k", color = prism.Color4.RED, layer = math.huge - 5 }),
		prism.components.Collider(),
		prism.components.Senses(),
		prism.components.Satiety(100),
		prism.components.Sight({ range = 12, fov = true }),
		prism.components.Mover({ "walk" }),
		prism.components.Smell({ threshold = 20 }),
		prism.components.Hearing(),
		prism.components.Scent({ strength = 20 }),
		prism.components.BTController(prism.BehaviorTree.Root({
			prism.BehaviorTree.Selector({
				-- Hunger Subroutine
				prism.BehaviorTree.Sequence({
					prism.behaviours.SatietyBelowPercentageCheckBehaviour(90),
					prism.behaviours.FindEdibleBehaviour(),
					prism.BehaviorTree.Selector({
						prism.BehaviorTree.Sequence({
							prism.behaviours.CheckTargetInRangeBehaviour(0),
							prism.behaviours.EatBehaviour(),
						}),
						prism.behaviours.MoveBehaviour(0),
					}),
				}),
				-- Hunt Subroutine
				prism.BehaviorTree.Sequence({
					prism.behaviours.FindEnemyBehaviour(),
					prism.BehaviorTree.Selector({
						-- Either,
						prism.BehaviorTree.Sequence({
							prism.behaviours.CheckRoomTargetBehaviour(),
							prism.behaviours.MoveBehaviour(),
						}),
						prism.BehaviorTree.Sequence({
							prism.behaviours.HPBelowPercentageCheckBehaviour(34),
							prism.behaviours.FindNearestRoomNotContainingEnemyBehaviour(),
							prism.behaviours.MoveBehaviour(),
						}),
						prism.BehaviorTree.Sequence({
							-- if Enemy in range, attack it.
							prism.behaviours.CheckTargetInRangeBehaviour(1),
							prism.behaviours.AttackBehaviour(),
						}),
						-- Move
						prism.behaviours.MoveBehaviour(),
						-- Or finally, wait
						-- We need this here to catch the case where we can't move or attack
						prism.behaviours.WaitBehaviour(),
					}),
				}),
			}),
			prism.behaviours.WaitBehaviour(),
		})),
		prism.components.Health(3),
		prism.components.Attacker(1),
		prism.components.BelongsToFaction({ "KoboldFaction" }),
		prism.components.DropTable({
			chance = 0.3,
			entry = prism.actors.MeatBrick(),
		}),
		prism.components.Kobold(),
	})
end)
