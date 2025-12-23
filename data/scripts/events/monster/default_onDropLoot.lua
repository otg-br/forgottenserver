local event = Event()

event.onDropLoot = function(self, corpse)
	if configManager.getNumber(configKeys.RATE_LOOT) == 0 then
		return
	end

	local player = Player(corpse:getCorpseOwner())
	local mType = self:getType()
	local doCreateLoot = false

	if not player or player:getStamina() > 840 or not configManager.getBoolean(configKeys.STAMINA_SYSTEM) then
		doCreateLoot = true
	end

	if doCreateLoot then
		local monsterLoot = mType:getLoot()
		for i = 1, #monsterLoot do
			local item = corpse:createLootItem(monsterLoot[i])
			if not item then
				print("[Warning] DropLoot: Could not add loot item to corpse.")
			end
		end
	end

	if player then
		local text
		if doCreateLoot then
			text = ("Loot of %s: %s."):format(mType:getNameDescription(), corpse:getContentDescription())
		else
			text = ("Loot of %s: nothing (due to low stamina)."):format(mType:getNameDescription())
		end
		
		local preyActivators = {}
		local monsterName = mType:getName()
		
		local function checkPrey(p)
			if not p then return end
			for slotId = 0, 2 do
				local slot = p:getPreyData(slotId)
				if slot and slot.state == 2 and slot.preyMonster == monsterName and slot.bonusType == 3 then
					table.insert(preyActivators, p:getName())
					return
				end
			end
		end

		checkPrey(player)

		local party = player:getParty()
		if party and party:isSharedExperienceActive() then
			local leader = party:getLeader()
			if leader and leader:getId() ~= player:getId() then
				checkPrey(leader)
			end
			for _, member in ipairs(party:getMembers()) do
				if member:getId() ~= player:getId() then
					checkPrey(member)
				end
			end
		end

		if #preyActivators > 0 then
			text = text .. string.format(" (active prey bonus for %s)", table.concat(preyActivators, ", "))
		end
		local party = player:getParty()
		if party then
			party:broadcastPartyLoot(text)
		else
			player:sendTextMessage(MESSAGE_LOOT, text)
		end
	end
end

event:register()
