-- Rick's MLC SqueakyToy
--
-- Requires Brutal handwork
-- Will make a squeak sound if you punch a zombie with a Spiffo or one of Spiffo's friends in your secondary hand.
-- Note: At this time (2023-09-09) Brutal Handwork will error if a non-weapon is in the primary hand.

require "ISBaseObject"
require "TimedActions/BH_MeleeAttackTimedAction"

RicksMLC_SqueakyToy = ISBaseObject:derive("RicksMLC_SqueakyToy");

RicksMLC_SqueakyToyInstance = nil

function RicksMLC_SqueakyToy:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self

	punching = false
	lHand = false

    return o
end

if BHMeleeAttack then
	local BrutalAttack = require("BrutalAttack")

	local overrideSetAnimVariable = BHMeleeAttack.setAnimVariable
	function BHMeleeAttack.setAnimVariable(self, parameter, value)
		overrideSetAnimVariable(self, parameter, value)
		if parameter == "LAttackType" then
			RicksMLC_SqueakyToyInstance.punching = true
			if value == "lpunch1" or value == "lpunch2" then
				RicksMLC_SqueakyToyInstance.lHand = true
			elseif value == "rpunch1" or value == "rpunch2" then
				RicksMLC_SqueakyToyInstance.lHand = false
			end
		end
	end

	local overrideBHMeleeAttackanimEvent = BHMeleeAttack.animEvent
	function BHMeleeAttack.animEvent(self, event, parameter)
		overrideBHMeleeAttackanimEvent(self, event, parameter)
		if event == 'EndAttack' then
			RicksMLC_SqueakyToyInstance.punching = false
		end
	end

	function RicksMLC_SqueakyToy.OnGameStart()
		if not RicksMLC_SqueakyToyInstance then
			RicksMLC_SqueakyToyInstance = RicksMLC_SqueakyToy:new()
		end
	end

	local squeakyToys = {
		["Spiffo"] = true, 
		["JacquesBeaver"] = true,
		["FreddyFox"] = true,
		["PancakeHedgehog"] = true,
		["BorisBadger"] = true,
		["FluffyfootBunny"] = true,
		["MoleyMole"] = true,
		["FurbertSquirrel"] = true
	}
	function RicksMLC_SqueakyToy.IsSqueakyToy(item)
		return item and squeakyToys[item:getType()]
	end

	function RicksMLC_SqueakyToy.OnWeaponHitCharacter(player, target, weapon, damage)
		--DebugLog.log(DebugType.Mod, "RicksMLC_SqueakyToy.OnWeaponHitCharacter() '" .. tostring(weapon:getName()) .. "'")

		if not RicksMLC_SqueakyToyInstance.punching then return end

		local handItem = nil
		if RicksMLC_SqueakyToyInstance.lHand then
			handItem = player:getSecondaryHandItem()
		else
			handItem = player:getPrimaryHandItem()
		end
		if not handItem then return	end	 
		
		if not RicksMLC_SqueakyToy.IsSqueakyToy(handItem) then return end

		-- Choose a random squeak toy sound (1 -> 8)
		local n = ZombRand(1, 8)
		local soundFileName = "SqueakToy0" .. tostring(n)

		getPlayer():playSound(soundFileName)
	end

	Events.OnWeaponHitCharacter.Add(RicksMLC_SqueakyToy.OnWeaponHitCharacter)
	Events.OnGameStart.Add(RicksMLC_SqueakyToy.OnGameStart)
end