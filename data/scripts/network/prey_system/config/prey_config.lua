PreyConfig = {
	maxSlots = 3,
	slot2UnlockPrice = 900,
	timeToFreeReroll = 1200,
	preyDuration = 120,
	rerollPrice = 50,
	rerollPricePerLevel = 150,
	bonusRerollPrice = 1,
	lockRerollPrice = 5,
	selectionListPrice = 5,
	selectionCount = 9
}

PreyBonusType = {
	DAMAGE_BOOST = 0,
	DAMAGE_REDUCTION = 1,
	EXPERIENCE_BONUS = 2,
	IMPROVED_LOOT = 3
}

PreyBonuses = {
	[PreyBonusType.DAMAGE_BOOST] = {
		name = "Damage Boost",
		initialValue = 7,
		step = 2,
		maxValue = 40
	},
	[PreyBonusType.DAMAGE_REDUCTION] = {
		name = "Damage Reduction",
		initialValue = 12,
		step = 2,
		maxValue = 40
	},
	[PreyBonusType.EXPERIENCE_BONUS] = {
		name = "Experience Bonus",
		initialValue = 13,
		step = 3,
		maxValue = 40
	},
	[PreyBonusType.IMPROVED_LOOT] = {
		name = "Improved Loot",
		initialValue = 13,
		step = 3,
		maxValue = 40
	}
}

PreyBonusRarity = {
	COMMON = 0,
	UNCOMMON = 1,
	RARE = 2,
	VERY_RARE = 3
}

function getPreyBonusValue(bonusType, rarity)
	local config = PreyBonuses[bonusType]
	if not config then
		return 0
	end
	local value = config.initialValue + (config.step * rarity)
	return math.min(value, config.maxValue)
end

function generateRandomPreyBonus()
	local bonusType = math.random(0, 3)
	local rarity = math.random(0, 3)
	local value = getPreyBonusValue(bonusType, rarity)
	return {
		type = bonusType,
		value = value,
		rarity = rarity
	}
end

PreyDataState = {
	Locked = 0,
	Inactive = 1,
	Active = 2,
	Selection = 3,
	SelectionChangeMonster = 4,
	ListSelection = 5
}

PreyBonus = {
	Damage = 0,
	Defense = 1,
	Experience = 2,
	Loot = 3,
	None = 4
}

PreyHelper = {}

function PreyHelper.getSlotData(player, slotId)
	return player:getPreySlotData(slotId)
end

function PreyHelper.saveSlotData(player, slot)
	return player:setPreySlotData(slot)
end

function PreyHelper.getRandomMonsters(count)
	return getRandomPreyMonsters(count)
end

function PreyHelper.getRandomBonus()
	return generateRandomPreyBonus()
end

function PreyHelper.unlockSlot(player, slotId)
	local slot = PreyHelper.getSlotData(player, slotId)
	if slot.state == PreyDataState.Locked then
		slot.state = PreyDataState.Inactive
		PreyHelper.saveSlotData(player, slot)
		return true
	end
	return false
end

function PreyHelper.getWildcards(player)
	return player:getPreyWildcards()
end

function PreyHelper.addWildcards(player, amount)
	return player:addPreyWildcards(amount)
end

function PreyHelper.removeWildcards(player, amount)
	return player:removePreyWildcards(amount)
end
