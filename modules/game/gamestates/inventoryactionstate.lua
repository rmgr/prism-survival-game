local controls = require("controls")
local Name = prism.components.Name

--- @class InventoryActionState : GameState
--- @field decision ActionDecision
--- @field previousState GameState
--- @overload fun(display: Display, decision: ActionDecision, level: Level, item: Actor)
local InventoryActionState = spectrum.GameState:extend("InventoryActionState")

local hud = love.graphics.newImage("display/actions.png")
--- @param display Display
--- @param decision ActionDecision
--- @param level Level
--- @param item Actor
function InventoryActionState:__new(display, decision, level, item)
	self.display = display
	self.decision = decision
	self.level = level
	self.item = item
	local actionPriorities = {
		["Eat"] = 1,
		["Equip"] = 2,
	}
	self.actions = {}
	local actions = self.decision.actor:getActions()

	table.sort(actions, function(a, b)
		local nameA = string.gsub(a.className, "Action", "")
		local nameB = string.gsub(b.className, "Action", "")

		local priorityA = actionPriorities[nameA] or 999
		local priorityB = actionPriorities[nameB] or 999

		if priorityA ~= priorityB then
			return priorityA < priorityB
		else
			-- Same priority, sort alphabetically
			return nameA < nameB
		end
	end)

	for _, Action in ipairs(actions) do
		if Action:validateTarget(1, level, self.decision.actor, item) and not Action:isAbstract() then
			table.insert(self.actions, Action)
		end
	end
end

function InventoryActionState:load(previous)
	--- @cast previous InventoryState
	self.previousState = previous
end

function InventoryActionState:draw()
	self.previousState:draw()
	self.display:clear()
	love.graphics.push()
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 540, 150, 320, 200)
	love.graphics.setColor(0.2, 0.18, 0.3)
	love.graphics.rectangle("line", 540, 150, 320, 200)
	love.graphics.pop()
	self.display:print(35, 11, Name.get(self.item), nil, nil, 2, "left")

	for i, action in ipairs(self.actions) do
		local letter = string.char(96 + i)
		local name = string.gsub(action:getName(), "Action", "")
		self.display:print(36, 12 + i, string.format("[%s] %s", letter, name), nil, nil, nil, "left")
	end

	self.display:draw()
end

function InventoryActionState:update(dt)
	controls:update()
	for i, action in ipairs(self.actions) do
		if spectrum.Input.key[string.char(i + 96)].pressed then
			if self.decision:setAction(action(self.decision.actor, self.item), self.level) then
				self.manager:pop()
				return
			end
			self.selectedAction = action
			self.targets = { self.item }
			for j = action:getNumTargets(), 2, -1 do
				self.manager:push(
					spectrum.gamestates.GeneralTargetHandler(
						self.display,
						self.previousState.previousState,
						self.targets,
						action:getTarget(j),
						self.targets
					)
				)
			end
		end
	end

	if controls.inventory.pressed or controls.back.pressed then
		self.manager:pop()
	end
end
function InventoryActionState:resume()
	if self.targets then
		local action = self.selectedAction(self.decision.actor, unpack(self.targets))
		local success, err = self.level:canPerform(action)
		if success then
			self.decision:setAction(action, self.level)
		else
			prism.components.Log.addMessage(self.decision.actor, err)
		end

		self.manager:pop()
	end
end
return InventoryActionState
