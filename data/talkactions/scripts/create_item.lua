local invalidIds = {1, 2, 3, 4, 5, 6, 7, 10, 11, 13, 14, 15, 19, 21, 26, 27, 28, 35, 43}
local destinations = {"inbox", "storeinbox", "tile", "house", "depot"}

local function getDestination(target, param, index)
	if not param then
		return target
	end

	local destinationMap = {
		inbox = function(t)
			return t:getInbox()
		end,
		storeinbox = function(t)
			return t:getStoreInbox()
		end,
		tile = function(t)
			return t:getTile()
		end,
		house = function(t)
			local house = t:getHouse()
			local doors = house and house:getDoors()
			local randomDoor = doors and doors[math.random(#doors)]
			return randomDoor and randomDoor:getTile() or t
		end,
		depot = function(t)
			local depotId = tonumber(index) or 0
			return t:getDepotChest(depotId, true) or t
		end
	}

	param = param:lower()
	return destinationMap[param] and destinationMap[param](target) or target
end

local function addItemToDestination(destination, itemId, count, subType)
	-- Sanitization
	if not subType then subType = 1 end

	local result = {}
	
	if destination:isCreature() and destination:isPlayer() then
		local item = Game.createItem(itemId, count)
		if not item then
			return {false}
		end
		
		-- player:addItem returns a ReturnValue number (0 = success)
		local ret = destination:addItem(item, true, CONST_SLOT_WHEREEVER)
		if ret ~= RETURNVALUE_NOERROR then
			item:remove()
			return {false}
		end
		table.insert(result, item)
		
	elseif destination:isContainer() then
		-- Container might support ID or Object. Safest is Object if using addItemEx
		-- But existing code used addItem with ID. Let's try creating object too to be safe.
		local item = Game.createItem(itemId, count)
		if not item then return {false} end
		
		local ret = destination:addItemEx(item)
		if ret ~= RETURNVALUE_NOERROR then
			item:remove()
			return {false}
		end
		table.insert(result, item)
		
	elseif destination:isTile() then
		-- For tiles, creating directly on position is best
		local item = Game.createItem(itemId, count, destination:getPosition())
		if item then
			table.insert(result, item)
		else
			return {false}
		end
	end

	return result
end

local function sendPlayerItemInformation(player, data)
	local lines = {}
	for label, value in pairs(data) do
		if value ~= nil then
			table.insert(lines, label .. ": " .. tostring(value))
		end
	end

	if #lines > 0 then
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
		player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Item created successfully. [" .. table.concat(lines, ", ") .. "]")
	end
	return true
end

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	local itemType
	local count = 1
	local subType
	local destinationParam
	local targetName
	local indexParam
	local keyNumber

	-- Check if param has comma (Comma separated strictly)
	if param:find(',') then
		local split = param:splitTrimmed(",")
		
		-- Item check
		itemType = ItemType(split[1])
		if itemType:getId() == 0 then
			itemType = ItemType(tonumber(split[1]))
			if not tonumber(split[1]) or itemType:getId() == 0 then
				player:sendCancelMessage("There is no item with that id or name.")
				return false
			end
		end

		if table.contains(invalidIds, itemType:getId()) then
			return false
		end

		-- Parse remaining arguments
		for i = 2, #split do
			local arg = split[i]:trim()
			local lowerArg = arg:lower()
			local numArg = tonumber(arg)

			if table.contains(destinations, lowerArg) and not destinationParam then
				destinationParam = lowerArg
			elseif numArg then
				if not count or count == 1 then -- Prefer setting count first if default
					count = itemType:isFluidContainer() and math.max(0, math.min(numArg, itemType:getCharges())) or math.min(10000, math.max(1, numArg))
				elseif not subType and not keyNumber then
					if not itemType:isStackable() then
						if itemType:isKey() then
							keyNumber = numArg
						else
							subType = numArg
						end
					else
						subType = 1
					end
				elseif not indexParam and destinationParam then
					indexParam = numArg
				end
			elseif not targetName then
				targetName = arg
			end
		end

	else
		-- Space separated parsing (Attempt to find item name first)
		-- Try largest match first? No, we need to split by space.
		local split = param:split(" ")
		local foundInfo = false
		
		-- Attempt to find item name by progressively joining parts
		for i = #split, 1, -1 do
			local nameAttempt = table.concat(split, " ", 1, i)
			local tempItem = ItemType(nameAttempt)
			if tempItem:getId() ~= 0 then
				itemType = tempItem
				
				-- Parse rest
				for j = i + 1, #split do
					local arg = split[j]
					local lowerArg = arg:lower()
					local numArg = tonumber(arg)
					
					if table.contains(destinations, lowerArg) and not destinationParam then
						destinationParam = lowerArg
					elseif numArg then
						-- Simple logic for space separated: Number is usually count
						if count == 1 then -- We assume 1 is default, so if we see a number update it
							count = itemType:isFluidContainer() and math.max(0, math.min(numArg, itemType:getCharges())) or math.min(10000, math.max(1, numArg))
						else
							-- If count already set, maybe subtype?
							if not subType then subType = numArg end
						end
					elseif not targetName then
						targetName = arg
					end
				end
				
				foundInfo = true
				break
			end
		end
		
		-- Try checking if first arg is numeric ID
		if not foundInfo then
			local possibleId = tonumber(split[1])
			if possibleId then
				local tempItem = ItemType(possibleId)
				if tempItem:getId() ~= 0 then
					itemType = tempItem
					-- Parse rest same as above
					for j = 2, #split do
						local arg = split[j]
						local lowerArg = arg:lower()
						local numArg = tonumber(arg)
						
						if table.contains(destinations, lowerArg) and not destinationParam then
							destinationParam = lowerArg
						elseif numArg then
							if count == 1 then
								count = itemType:isFluidContainer() and math.max(0, math.min(numArg, itemType:getCharges())) or math.min(10000, math.max(1, numArg))
							else
								if not subType then subType = numArg end
							end
						elseif not targetName then
							targetName = arg
						end
					end
					foundInfo = true
				end
			end
		end
		
		if not foundInfo then
			player:sendCancelMessage("There is no item with that id or name.")
			return false
		end
	end

	if table.contains(invalidIds, itemType:getId()) then
		return false
	end

	local targetPlayer = targetName and Player(targetName) or player
	if targetName and not targetPlayer then
		player:sendCancelMessage("Player \"" .. targetName .. "\" not found.")
		return false
	end

	local destination = getDestination(targetPlayer, destinationParam, indexParam)
	
	if not subType then subType = 1 end
	
	local result = addItemToDestination(destination, itemType:getId(), count, subType)

	for _, item in ipairs(result) do
		if item and type(item) ~= "boolean" then
			if itemType:isKey() then
				item:setAttribute(ITEM_ATTRIBUTE_ACTIONID, keyNumber)
			end
			if not itemType:isStackable() then
				item:decay()
			end
		end
	end

	if #result > 0 and (type(result[1]) == "boolean" and not result[1]) then
		player:sendCancelMessage("Could not create item. (Limit reached or invalid item)")
		return false
	end

	sendPlayerItemInformation(player, {
		id = itemType:getId(),
		count = count,
		subtype = subType,
		keynumber = keyNumber,
		destination = destinationParam,
		target = targetName,
		index = indexParam
	})

	return false
end
