local PreyAction = {
	ListReroll = 0,
	BonusReroll = 1,
	MonsterSelection = 2,
	ListAll_Cards = 3,
	ListAll_Selection = 4,
	Option = 5
}

local handler = PacketHandler(0xEB)

function handler.onReceive(player, msg)
	local slotId = msg:getByte()
	local action = msg:getByte()
	
	local slot = player:getPreyData(slotId)
	if not slot then
		return
	end
	
	if action == PreyAction.ListReroll then
		local freeRerollTime = player:getFreeRerollTime(slotId)
		
		if freeRerollTime > 0 then
			local rerollPrice = PreyConfig.rerollPrice + (player:getLevel() * PreyConfig.rerollPricePerLevel)
			
			if not player:removeTotalMoney(rerollPrice) then
				player:sendTextMessage(MESSAGE_STATUS_SMALL, string.format("You don't have enough money. You need %d gold coins to reroll.", rerollPrice))
				return
			end
		else
			player:setFreeRerollTime(slotId, PreyConfig.timeToFreeReroll)
		end
		
		local monsterList = getRandomPreyMonsters(9)
		slot.state = 3
		slot.preyList = monsterList
		player:setPreyData(slotId, slot)
		
		local resourceMsg = NetworkMessage()
		resourceMsg:addByte(0xEE)
		resourceMsg:addByte(1)
		resourceMsg:addU64(player:getMoney())
		resourceMsg:sendToPlayer(player)
		resourceMsg:delete()
		
		player:reloadPreySlot(slotId)
		
	elseif action == PreyAction.BonusReroll then
		if slot.state ~= 2 then
			player:sendTextMessage(MESSAGE_STATUS_SMALL, "You don't have an active prey in this slot.")
			return
		end
		
	local wildcards = player:getPreyWildcards()
		if wildcards < PreyConfig.bonusRerollPrice then
			player:sendTextMessage(MESSAGE_STATUS_SMALL, string.format("You don't have enough prey wildcards. You need %d wildcards.", PreyConfig.bonusRerollPrice))
			return
		end
		
		if not player:removePreyWildcards(PreyConfig.bonusRerollPrice) then
			return
		end
		
		print("[PREY DEBUG] Wildcards removed. Generating bonus...")

		
		local bonus = generateRandomPreyBonus()
		slot.bonusType = bonus.type
		slot.bonusValue = bonus.value
		slot.bonusGrade = bonus.rarity
		player:setPreyData(slotId, slot)
		
		local resourceMsg = NetworkMessage()
		resourceMsg:addByte(0xEE)
		resourceMsg:addByte(10)
		resourceMsg:addU64(player:getPreyWildcards())
		resourceMsg:sendToPlayer(player)
		resourceMsg:delete()
		
		player:reloadPreySlot(slotId)
		
	elseif action == PreyAction.MonsterSelection then
		if msg:len() < 1 then
			return
		end
		
		local monsterIndex = msg:getByte()
		
		if slot.state ~= 3 or monsterIndex >= #slot.preyList then
			return
		end
		
		local selectedMonster = slot.preyList[monsterIndex + 1]
		local bonus = generateRandomPreyBonus()
		
		slot.state = 2
		slot.preyMonster = selectedMonster
		slot.bonusType = bonus.type
		slot.bonusValue = bonus.value
		slot.bonusGrade = bonus.rarity
		slot.timeLeft = PreyConfig.preyDuration * 60
		slot.preyList = {}
		player:setPreyData(slotId, slot)
		
		player:reloadPreySlot(slotId)
		
	elseif action == PreyAction.ListAll_Cards then
		local wildcards = player:getPreyWildcards()
		if wildcards < PreyConfig.selectionListPrice then
			player:sendTextMessage(MESSAGE_STATUS_SMALL, string.format("You don't have enough prey wildcards. You need %d wildcards.", PreyConfig.selectionListPrice))
			return
		end
		
		if not player:removePreyWildcards(PreyConfig.selectionListPrice) then
			return
		end
		
		slot.state = 5
		slot.bonusTimeLeft = 0
		slot.preyMonster = ""
		player:setPreyData(slotId, slot)
		
		local resourceMsg = NetworkMessage()
		resourceMsg:addByte(0xEE)
		resourceMsg:addByte(10)
		resourceMsg:addU64(player:getPreyWildcards())
		resourceMsg:sendToPlayer(player)
		resourceMsg:delete()
		
		player:reloadPreySlot(slotId)
		
	elseif action == PreyAction.ListAll_Selection then
		if msg:len() < 2 or slot.state ~= 5 then
			return
		end
		
		local raceId = msg:getU16()
		local mType = MonsterType(raceId)
		if not mType then
			return
		end
		
		local bonus = generateRandomPreyBonus()
		slot.state = 2
		slot.preyMonster = mType:getName()
		slot.bonusType = bonus.type
		slot.bonusValue = bonus.value
		slot.bonusGrade = bonus.rarity
		slot.timeLeft = PreyConfig.preyDuration * 60
		slot.preyList = {}
		player:setPreyData(slotId, slot)
		
		player:reloadPreySlot(slotId)
		
	elseif action == PreyAction.Option then
		local option = msg:getByte()
		
		slot.option = option
		player:setPreyData(slotId, slot)
		
		player:reloadPreySlot(slotId)
	end
end

handler:register()
