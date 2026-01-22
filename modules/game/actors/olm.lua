prism.register(prism.Component:extend("Olm"))
prism.registerActor("Olm", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Olm"),
		prism.components.Position(),
		prism.components.Drawable({ index = "O", color = prism.Color4.NAVY }),
		prism.components.Collider(),
		prism.components.Senses(),
		prism.components.Sight({ range = 2, fov = true }),
		prism.components.Hearing(),
		prism.components.Mover({ "walk" }),
		prism.components.Scent({ strength = 20 }),
		prism.components.BTController(prism.BehaviorTree.Root({
			prism.BehaviorTree.Sequence({
				prism.behaviours.ListenBehaviour(),
				prism.behaviours.FindActorBehaviour({ prism.relations.FoeRelation }),
				prism.BehaviorTree.Selector({
					-- Either,
					prism.BehaviorTree.Sequence({
						prism.behaviours.HPBelowPercentageCheckBehaviour(20),
						prism.behaviours.FleeBehaviour(),
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
			prism.behaviours.WaitBehaviour(),
		})),
		prism.components.Health(6),
		prism.components.Attacker(5),
		prism.components.BelongsToFaction({ "OlmFaction" }),
		prism.components.DropTable({
			chance = 0.8,
			entry = prism.actors.MeatBrick(),
		}),
		prism.components.Olm(),
		prism.components.Speed(50),
		prism.components.Satiety(1000),
	})
end)
