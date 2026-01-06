prism.registerActor("Kobold", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Kobold"),
		prism.components.Position(),
		prism.components.Drawable({ index = "k", color = prism.Color4.RED }),
		prism.components.Collider(),
		prism.components.Senses(),
		prism.components.Sight({ range = 12, fov = true }),
		prism.components.Mover({ "walk" }),
		prism.components.Smell({ threshold = 20 }),
		prism.components.Scent({ strength = 20 }),
		prism.components.BTController(prism.BehaviorTree.Root({
			prism.BehaviorTree.Sequence({
				prism.behaviours.FindEnemyBehaviour(),
				prism.BehaviorTree.Selector({
					-- Either,
					prism.BehaviorTree.Sequence({
						prism.behaviours.HPBelowPercentageCheckBehaviour(34),
						prism.behaviours.FleeBehaviour(),
						prism.behaviours.MoveBehaviour(),
					}),
					prism.BehaviorTree.Sequence({
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
	})
end)
