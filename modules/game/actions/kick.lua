local Log = prism.components.Log
local Name = prism.components.Name
local ConditionHolder = prism.components.ConditionHolder

local KickTarget = prism.Target(prism.components.Collider):range(1):sensed()
---@class KickAction : Action
local Kick = prism.Action:extend("Kick")

Kick.targets = { KickTarget }

Kick.requiredComponents = {
	prism.components.Controller,
}

function Kick:canPerform(level)
	return true
end

local mask = prism.Collision.createBitmaskFromMovetypes({ "fly" })

--- @param level Level
--- @param kicked Actor
function Kick:perform(level, kicked)
	local direction = (kicked:getPosition() - self.owner:getPosition())

	--[[
	-- DEBUG: Flip faction relationship to friendly
	local changeRelationship =
		prism.actions.ChangeFactionRelationship(self.owner, "PlayerFaction", "KoboldFaction", 200)
	level:tryPerform(changeRelationship)
   ]]
	local damageModifiers = ConditionHolder.getActorModifiers(self.owner, prism.modifiers.DamageModifier)
	local modifiedDamage = 1
	for _, modifier in ipairs(damageModifiers) do
		modifiedDamage = modifiedDamage + modifier.delta
	end

	local modifiers = ConditionHolder.getActorModifiers(self.owner, prism.modifiers.KnockbackModifier)
	local modifiedKnockback = 2
	for _, modifier in ipairs(modifiers) do
		modifiedKnockback = modifiedKnockback + modifier.delta
	end
	local final = kicked:expectPosition()
	for _ = 1, modifiedKnockback do
		local nextpos = final + direction
		if not level:getCellPassable(nextpos.x, nextpos.y, mask) then
			break
		end
		final = nextpos
	end

	level:yield(prism.messages.AnimationMessage({
		animation = spectrum.animations.Attack(self.owner, kicked:getPosition()),
	}))
	level:moveActor(kicked, final)
	local damage = prism.actions.Damage(kicked, modifiedDamage)
	level:tryPerform(damage)

	local kickName = Name.lower(kicked)
	local ownerName = Name.lower(self.owner)
	local dealt = damage.dealt or 0

	Log.addMessage(self.owner, "You kick the %s for %i damage!", kickName, dealt)
	Log.addMessage(kicked, "The %s kicks you for %i damage!", ownerName, dealt)
	Log.addMessageSensed(level, self, "The %s kicks the %s for %i damage!", ownerName, kickName, dealt)
end

return Kick
