local preyKill = CreatureEvent("PreyKill")

function preyKill.onKill(player, target)
	if not target:isMonster() then
		return true
	end

	local monsterType = target:getType()
	if not monsterType then
		return true
	end

	local monsterName = monsterType:getName()
	local targetPos = target:getPosition()

	for slotId = 0, 2 do
		local slot = player:getPreyData(slotId)
		if slot and slot.state == 2 and slot.preyMonster == monsterName and slot.bonusType == 3 then
			addEvent(function()
				local tile = Tile(targetPos)
				if tile then
					local corpse = tile:getTopDownItem()
					if corpse and corpse:getType():isCorpse() then
						local container = Container(corpse:getUniqueId())
						if container then
							local items = {}
							for i = 0, container:getSize() - 1 do
								local item = container:getItem(i)
								if item then
									table.insert(items, item:getId())
								end
							end

							if #items > 0 and math.random(100) <= slot.bonusValue then
								local randomItemId = items[math.random(#items)]
								container:addItem(randomItemId, 1)
							end
						end
					end
				end
			end, 100)
			break
		end
	end

	return true
end

preyKill:register()

local preyExperience = Event()

local function checkPreyTick(player)
	local lastTick = player:getStorageValue(PlayerStorageKeys.preyTick)
	if lastTick > os.time() then
		player:setStorageValue(PlayerStorageKeys.preyTick, os.time())
		lastTick = os.time()
	end
	
	if (os.time() - lastTick) < 60 then
		return
	end
	
	player:setStorageValue(PlayerStorageKeys.preyTick, os.time())
	
	local changed = false
	for slotId = 0, 2 do
		local slot = player:getPreyData(slotId)
		if slot and slot.state == PreyDataState.Active then
			slot.timeLeft = slot.timeLeft - 60
			
			if slot.timeLeft <= 0 then
				slot.timeLeft = 0
				
				local rerolled = false
				if slot.option == 1 then
					if player:removePreyWildcards(PreyConfig.bonusRerollPrice) then
						local bonus = PreyHelper.getRandomBonus()
						slot.bonusType = bonus.type
						slot.bonusValue = bonus.value
						slot.bonusGrade = bonus.rarity
						slot.timeLeft = PreyConfig.preyDuration * 60
						player:sendTextMessage(MESSAGE_STATUS_SMALL, "Your prey bonus has been automatically rerolled.")
						rerolled = true
					else
						player:sendTextMessage(MESSAGE_STATUS_SMALL, "You don't have enough wildcards for automatic reroll.")
					end
				elseif slot.option == 2 then
					if player:removePreyWildcards(PreyConfig.lockRerollPrice) then
						local bonus = PreyHelper.getRandomBonus()
						slot.bonusType = bonus.type
						slot.bonusValue = bonus.value
						slot.bonusGrade = bonus.rarity
						slot.timeLeft = PreyConfig.preyDuration * 60
						player:sendTextMessage(MESSAGE_STATUS_SMALL, "Your prey has been locked and bonus rerolled.")
						rerolled = true
					else
						player:sendTextMessage(MESSAGE_STATUS_SMALL, "You don't have enough wildcards to lock your prey.")
					end
				end
				
				if not rerolled then
					slot.state = PreyDataState.Selection
					slot.bonusType = PreyBonus.None
					slot.bonusValue = 0
					slot.bonusGrade = PreyBonusRarity.COMMON
					player:sendTextMessage(MESSAGE_STATUS_SMALL, "Your prey bonus has expired.")
				end
				
				changed = true
			end
			
			player:setPreyData(slotId, slot)
		end
	end
	
	if changed then
		for slotId = 0, 2 do
			player:reloadPreySlot(slotId)
		end
	end
end

function preyExperience.onGainExperience(player, source, exp, rawExp)
	if not source or not source:isMonster() then
		return exp
	end

    checkPreyTick(player)

	local monsterType = source:getType()
	if not monsterType then
		return exp
	end

	local monsterName = monsterType:getName()

	for slotId = 0, 2 do
		local slot = player:getPreyData(slotId)
		if slot and slot.state == 2 and slot.preyMonster == monsterName and slot.bonusType == 2 then
			local bonus = 1 + (slot.bonusValue / 100)
			return math.floor(exp * bonus)
		end
	end

	return exp
end

preyExperience:register()

local preyLogin = CreatureEvent("PreyLogin")

function preyLogin.onLogin(player)
	player:registerEvent("PreyKill")
	player:registerEvent("PreyExperience")

	local slot0 = player:getPreyData(0)
	if slot0.state == 0 then
		local monsterList = getRandomPreyMonsters(9)
		local preyData = {
			state = 3,
			bonusType = 0,
			bonusValue = 0,
			bonusGrade = 0,
			preyMonster = "",
			timeLeft = 0,
			preyList = monsterList
		}
		player:setPreyData(0, preyData)
		player:setFreeRerollTime(0, 0)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Prey slot 0 unlocked!")
	end

	if player:isPremium() then
		local slot1 = player:getPreyData(1)
		if slot1.state == 0 then
			local monsterList = getRandomPreyMonsters(9)
			local preyData = {
				state = 3,
				bonusType = 0,
				bonusValue = 0,
				bonusGrade = 0,
				preyMonster = "",
				timeLeft = 0,
				preyList = monsterList
			}
			player:setPreyData(1, preyData)
			player:setFreeRerollTime(1, 0)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Prey slot 1 unlocked (Premium)!")
		end
	else
		local slot1 = player:getPreyData(1)
		if slot1.state ~= 0 then
			local preyData = {
				state = 0,
				bonusType = 0,
				bonusValue = 0,
				bonusGrade = 0,
				preyMonster = "",
				timeLeft = 0,
				preyList = {}
			}
			player:setPreyData(1, preyData)
		end
	end
	
	for slotId = 0, 2 do
		player:reloadPreySlot(slotId)
	end

	return true
end

preyLogin:register()
