local handler = PacketHandler(0xE9)

function handler.onReceive(player, msg)
	local response = NetworkMessage()
	response:addByte(0xE9)
	
	local rerollPrice = PreyConfig.rerollPrice + (player:getLevel() * PreyConfig.rerollPricePerLevel)
	response:addU32(rerollPrice)
	response:addByte(PreyConfig.bonusRerollPrice)
	response:addByte(PreyConfig.selectionListPrice)
	response:addU32(0)
	response:addU32(0)
	response:addByte(0)
	response:addByte(0)
	
	response:sendToPlayer(player)
	response:delete()
end

handler:register()
