---@class SoundSystem : System
local SoundSystem = prism.System:extend("SoundSystem")

function SoundSystem:onMove(level, actor) end

--- Called by SensesSystem for each actor with Hearing component
--- @param level Level
--- @param actor Actor
function SoundSystem:onSenses(level, actor)
	local isPlayer = actor:has(prism.components.PlayerController)
	local hearing = actor:get(prism.components.Hearing)
	if not hearing then
		return
	end

	local sensesComponent = actor:get(prism.components.Senses)
	if not sensesComponent then
		return
	end

	-- Process heard sounds
	local heardRelations = actor:getRelations(prism.relations.HearsRelation)
	if heardRelations then
		for soundEmitter, _ in pairs(heardRelations) do
			---@cast soundEmitter Actor
			if isPlayer and not actor:hasRelation(prism.relations.SeesRelation, soundEmitter) then
				local x, y = soundEmitter:getPosition():decompose()

				level:yield(prism.messages.AnimationMessage({
					animation = spectrum.animations.DistantSound(),
					x = x,
					y = y,
				}))

				local soundIcon = prism.actors.Sound()

				level:addActor(soundIcon, x, y)
				actor:addRelation(prism.relations.SensesRelation, soundIcon)
			else
				actor:addRelation(prism.relations.SensesRelation, soundEmitter)
			end
		end
		--actor:removeAllRelations(prism.relations.HearsRelation)
	end
end

function SoundSystem:onTurnEnd(level, actor)
	actor:removeAllRelations(prism.relations.HearsRelation)
	if actor:has(prism.components.PlayerController) then
		for icon in level:query(prism.components.SoundIcon):iter() do
			level:removeActor(icon)
		end
	end
end

function SoundSystem:onActorAdded(level, actor)
	local sound = actor:get(prism.components.Sound)
	if not sound then
		return
	end
end

return SoundSystem
