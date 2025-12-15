local controls = require("controls")
--- @class GameMenuState: GameState
--- @field display Display
--- @overload fun(display:Display) : GameMenuState
local GameMenuState = spectrum.GameState:extend("GameMenuState")

function GameMenuState:__new(display)
	self.display = display
end

function GameMenuState:draw()
	local midpoint = math.floor(self.display.height / 2)

	self.display:clear()
	self.display:print(1, midpoint, "Prism is pretty cool", nil, nil, nil, "center", self.display.width)
	self.display:print(1, midpoint + 3, "[p] play", nil, nil, nil, "center", self.display.width)
	self.display:print(1, midpoint + 4, "[q] to quit", nil, nil, nil, "center", self.display.width)
	self.display:draw()
end

function GameMenuState:update(dt)
	controls:update()
	if controls.quit.pressed then
		love.event.quit()
	elseif controls.play.pressed then
		self.manager:enter(spectrum.gamestates.GameLevelState(self.display))
	end
end

return GameMenuState
