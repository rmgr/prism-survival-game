local utf8 = require("utf8")
local controls = require("controls")

--- @class InventoryState : GameState
--- @overload fun(display: Display, overlay: Display, decision: ActionDecision, level: Level, inventory: Inventory)
local InventoryState = spectrum.GameState:extend("InventoryState")

local hud = love.graphics.newImage("display/hud.png")
local selected = love.graphics.newImage("display/selected_inventory.png")
--- @param display Display
--- @param decision ActionDecision
--- @param level Level
--- @param inventory Inventory
function InventoryState:__new(display, overlay, decision, level, inventory)
	self.display = display
	self.decision = decision
	self.level = level
	self.inventory = inventory
	self.items = inventory.inventory:getAllActors()
	self.overlay = overlay

	-- Calculate HUD dimensions in grid cells (accounting for scale of 2)
	local hudWidthInCells = hud:getWidth() / (overlay.cellSize.x / 2)
	local hudHeightInCells = hud:getHeight() / (overlay.cellSize.y / 2)

	-- Center in the overlay grid
	local centerGridX = (overlay.width - hudWidthInCells) / 2
	local centerGridY = (overlay.height - hudHeightInCells) / 2

	-- Convert back to pixels for drawing
	self.hudPosition = prism.Vector2(centerGridX * (overlay.cellSize.x / 2), centerGridY * (overlay.cellSize.y / 2))

	self.hudPositions = {}
	self.selectedPosition = 1
	local idx = 1
	for x = 0, 4 do
		for y = 0, 4 do
			self.hudPositions[idx] = prism.Vector2(4 + (4 * x), 5 + (4 * y))
			idx = idx + 1
		end
	end

	self.letters = {}
	for i = 1, #self.items do
		self.letters[i] = utf8.char(96 + i) -- a, b, c, ...
	end
end

function InventoryState:pixelToGrid(px, py)
	local dx = px / (self.overlay.cellSize.x / 2)
	local dy = py / (self.overlay.cellSize.y / 2)
	return math.floor(dx + 1), math.floor(dy + 1)
end

function InventoryState:gridToPixel(x, y)
	local dx = x - 1
	local dy = y - 1
	return dx * (self.overlay.cellSize.x / 2), dy * (self.overlay.cellSize.y / 2)
end

function InventoryState:load(previous)
	self.previousState = previous
end

function InventoryState:draw()
	self.previousState:draw()

	self.display:clear()
	self.overlay:clear()
	love.graphics.push()
	love.graphics.scale(2, 2)
	love.graphics.draw(hud, self.hudPosition.x, self.hudPosition.y)
	local pos = self.hudPositions[self.selectedPosition]
	local px, py = self:gridToPixel(pos.x, pos.y)
	love.graphics.draw(selected, self.hudPosition.x + px - 9, self.hudPosition.y + py - 6)
	love.graphics.pop()

	local ox, oy = self:pixelToGrid(self.hudPosition.x, self.hudPosition.y)
	self.overlay:print(ox + 2, oy + 2, "Inventory", nil, nil, 2, "left")

	--[[	local meat = prism.actors.MeatBrick()
	for i = 1, 25 do
		--		self.overlay:putActor(ox + self.hudPositions[i].x - 1, oy + self.hudPositions[i].y - 1, meat)
	end]]
	for i, actor in ipairs(self.items) do
		local name = actor:getName()
		local letter = self.letters[i]

		local item = actor:expect(prism.components.Item)
		self.overlay:putActor(ox + self.hudPositions[i].x - 1, oy + self.hudPositions[i].y - 1, actor)
		local countstr = ""
		if item.stackCount and item.stackCount > 1 then
			countstr = ("%sx "):format(item.stackCount)
		end

		local itemstr = ("[%s] %s%s"):format(letter, countstr, name)
		--		self.display:print(4, 4 + i, itemstr, nil, nil, 2, "left")
	end
	self.display:draw()
	self.overlay:draw()
end

function InventoryState:update(dt)
	controls:update()

	if controls.move.pressed then
		local currentPos = self.hudPositions[self.selectedPosition]
		local moveVec = controls.move.vector

		if currentPos and moveVec then
			-- Calculate new grid position
			local newX = currentPos.x + (4 * moveVec.x)
			local newY = currentPos.y + (4 * moveVec.y)

			-- Find the index that matches this position
			for idx, pos in ipairs(self.hudPositions) do
				if pos.x == newX and pos.y == newY then
					self.selectedPosition = idx
					break
				end
			end
		end
	end

	if controls.select.pressed then
		self.manager:push(
			spectrum.gamestates.InventoryActionState(
				self.display,
				self.decision,
				self.level,
				self.items[self.selectedPosition]
			)
		)
	end

	if controls.inventory.pressed or controls.back.pressed then
		self.manager:pop()
	end
end

function InventoryState:resume()
	if self.decision:validateResponse() then
		self.manager:pop()
	end
end
return InventoryState
