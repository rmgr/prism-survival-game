prism.cells.TallGrass = function()
	return prism.Cell.fromComponents({
		prism.components.Name("TallGrass"),
		prism.components.Drawable({ index = ";", color = prism.Color4.GREEN }),
		prism.components.Flammable(16, 0),
		prism.components.Collider({ allowedMovetypes = { "walk", "fly" } }),
		prism.components.Sound(3),
		prism.components.Opaque(),
	})
end
