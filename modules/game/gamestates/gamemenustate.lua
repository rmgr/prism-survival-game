local controls = require("controls")
--- @class GameMenuState: GameState
--- @field display Display
--- @overload fun(display:Display) : GameMenuState
local GameMenuState = spectrum.GameState:extend("GameMenuState")

function GameMenuState:__new(display)
	self.display = display
	self.save = love.filesystem.read("save.lz4")
end

function GameMenuState:draw()
	local midpoint = math.floor(self.display.height / 2)

	self.display:clear()
	self.display:print(1, midpoint, "Prism is pretty cool", nil, nil, nil, "center", self.display.width)
	self.display:print(1, midpoint + 3, "[p] play", nil, nil, nil, "center", self.display.width)

	local i = 0
	if self.save then
		i = i + 1
		self.display:print(1, midpoint + 3 + i, "[l] to load game", nil, nil, nil, "center", self.display.width)
	end

	self.display:print(1, midpoint + 4 + i, "[q] to quit", nil, nil, nil, "center", self.display.width)
	self.display:draw()
end

function GameMenuState:update(dt)
	controls:update()
	if controls.quit.pressed then
		love.event.quit()
	elseif controls.play.pressed then
		love.filesystem.remove("save.lz4")
		local builder = Game:generateNextFloor()
		self.manager:enter(spectrum.gamestates.GameLevelState(self.display, builder, Game:getLevelSeed()))
	elseif controls.load.pressed and self.save then
		local mp = love.data.decompress("string", "lz4", self.save)
		local save = prism.Object.deserialize(prism.messagepack.unpack(mp))
		Game = save
		self.manager:enter(spectrum.gamestates.GameLevelState(self.display, Game.level))
	end
end

return GameMenuState
