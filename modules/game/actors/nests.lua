prism.registerActor("KoboldNest", function()
	return prism.Actor.fromComponents({
		prism.components.Name("KoboldNest"),
		prism.components.Position(),
		prism.components.KoboldNest(),
	})
end)
prism.registerActor("SalamanderNest", function()
	return prism.Actor.fromComponents({
		prism.components.Name("SalamanderNest"),
		prism.components.Position(),
		prism.components.SalamanderNest(),
	})
end)
