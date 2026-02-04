prism.register(prism.Component:extend("Salamander"))
prism.registerActor("Salamander", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Salamander"),
		prism.components.Position(),
		prism.components.Drawable({ index = "S", color = prism.Color4.ORANGE, layer = math.huge - 5 }),
		prism.components.Collider(),
		prism.components.Senses(),
		prism.components.Satiety(150),
		prism.components.Sight({ range = 12, fov = true }),
		prism.components.Mover({ "walk" }),
		prism.components.Smell({ threshold = 20 }),
		prism.components.Hearing(),
		prism.components.FireProof(),
		prism.components.Scent({ strength = 20 }),
		prism.components.BTController(prism.BehaviorTree.Root({
			prism.BehaviorTree.Selector({
				-- Hunger Subroutine
				prism.BehaviorTree.Sequence({
					prism.behaviours.SatietyBelowPercentageCheckBehaviour(80),
					prism.BehaviorTree.Selector({
						-- Try to find actual food first
						prism.BehaviorTree.Sequence({
							prism.behaviours.FindEdibleBehaviour(),
							prism.BehaviorTree.Selector({
								prism.BehaviorTree.Sequence({
									prism.behaviours.CheckTargetInRangeBehaviour(0),
									prism.behaviours.EatBehaviour(),
								}),
								prism.behaviours.MoveBehaviour(0),
							}),
						}),
						-- If no food found, hunt anyone (allies included when desperate)
						prism.BehaviorTree.Sequence({
							prism.behaviours.FindActorBehaviour({}),
							prism.BehaviorTree.Selector({
								prism.BehaviorTree.Sequence({
									prism.behaviours.CheckTargetInRangeBehaviour(1),
									prism.behaviours.AttackBehaviour(),
								}),
								prism.behaviours.MoveBehaviour(),
							}),
						}),
					}),
				}),
				-- Flee scary monsters
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
				-- Hunt Subroutine (only actual foes)
				prism.BehaviorTree.Sequence({
					prism.behaviours.FindActorBehaviour({ prism.relations.FoeRelation }),
					prism.BehaviorTree.Selector({
						prism.BehaviorTree.Sequence({
							prism.behaviours.HPBelowPercentageCheckBehaviour(34),
							prism.BehaviorTree.Selector({
								prism.BehaviorTree.Sequence({
									prism.behaviours.RandomChanceBehaviour(),
									prism.behaviours.CheckTargetInRangeBehaviour(3),
									prism.behaviours.SpitFireBehaviour(),
								}),
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
						prism.BehaviorTree.Sequence({
							prism.behaviours.CheckTargetInRangeBehaviour(1),
							prism.behaviours.AttackBehaviour(),
						}),
						prism.behaviours.MoveBehaviour(),
					}),
				}),
			}),
			prism.behaviours.RandomMoveBehaviour(),
			prism.behaviours.WaitBehaviour(),
		})),
		prism.components.Health(30),
		prism.components.AfraidOf({ "OlmFaction" }),
		prism.components.Attacker(10),
		prism.components.BelongsToFaction({ "SalamanderFaction" }),
		prism.components.DropTable({
			chance = 0.8,
			entry = prism.actors.MeatBrick(),
		}),
		prism.components.Salamander(),
	})
end)
