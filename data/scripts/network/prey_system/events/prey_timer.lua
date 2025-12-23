local preyTimer = GlobalEvent("PreyTimer")

function preyTimer.onThink(interval)
	local players = Game.getPlayers()

	for _, player in pairs(players) do
		for slotId = 0, 2 do
			local slot = player:getPreyData(slotId)

			if slot and slot.state == 2 and slot.timeLeft > 0 then
				slot.timeLeft = slot.timeLeft - 1

				if slot.timeLeft <= 0 then
					slot.timeLeft = 0
					slot.state = 1
					slot.preyMonster = ""
					slot.bonusType = 0
					slot.bonusValue = 0
					slot.bonusGrade = 0

					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your prey bonus has expired!")
				end

				player:setPreyData(slotId, slot)
				player:reloadPreySlot(slotId)
			end
		end
	end

	return true
end

preyTimer:interval(60000)
preyTimer:register()
