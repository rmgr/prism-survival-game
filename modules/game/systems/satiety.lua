--- @class SatietySystem : System
local SatietySystem = prism.System:extend("SatietySystem")

function SatietySystem:onTurn(level, actor)
	local satietyComponent = actor:get(prism.components.Satiety)
	if not satietyComponent then
		return
	end

	if satietyComponent.satiety > 0 then
		satietyComponent.satiety = satietyComponent.satiety - 1
	end
	if satietyComponent.satiety <= 0 then
		if actor:has(prism.components.PlayerController) then
			level:tryPerform(prism.actions.Damage(actor, 1))
		end
	end
end

return SatietySystem
