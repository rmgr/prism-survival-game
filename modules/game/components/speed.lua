--- The 'Speed' component stores an actor's movement/action speed.
--- Higher speed values mean the actor gets more turns in the scheduler.
--- @class Speed : Component
--- @overload fun(speed: number): Speed
local Speed = prism.Component:extend("Speed")

--- Constructor for the Speed component.
--- @param speed number The initial speed value (default: 100)
function Speed:__new(speed)
	self.speed = speed or 100
end

--- Gets the current speed value.
--- @return number The actor's speed.
function Speed:getSpeed()
	return self.speed
end

--- Sets the speed value.
--- @param speed number The new speed value.
function Speed:setSpeed(speed)
	self.speed = speed
end

--- Modifies the speed by adding a value (can be negative).
--- @param delta number The amount to add to the current speed.
function Speed:modifySpeed(delta)
	self.speed = self.speed + delta
end

--- Multiplies the speed by a factor.
--- Useful for temporary speed boosts or debuffs.
--- @param multiplier number The multiplier to apply.
function Speed:multiplySpeed(multiplier)
	self.speed = self.speed * multiplier
end

--- Clamps the speed to a minimum value.
--- Prevents speed from going below a certain threshold.
--- @param minSpeed number The minimum allowed speed (default: 1)
function Speed:clampSpeed(minSpeed)
	minSpeed = minSpeed or 1
	if self.speed < minSpeed then
		self.speed = minSpeed
	end
end

--- Returns a string representation of the component.
--- @return string A description of the speed value.
function Speed:__tostring()
	return string.format("Speed(%d)", self.speed)
end

return Speed
