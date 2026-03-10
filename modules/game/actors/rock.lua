prism.register(prism.Component:extend("Rock"))
prism.registerActor("Rock", function()
	return prism.Actor.fromComponents({
		prism.components.Name("Rock"),
		prism.components.Position(),
		prism.components.Item(),
		prism.components.Drawable({ index = "o", color = prism.Color4.WHITE }),
		prism.components.Throwable(),
	})
end)
