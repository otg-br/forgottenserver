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

function preyExperience.onGainExperience(player, source, exp, rawExp)
	if not source or not source:isMonster() then
		return exp
	end

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

	return true
end

preyLogin:register()
