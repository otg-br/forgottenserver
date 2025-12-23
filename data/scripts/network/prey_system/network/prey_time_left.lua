local handler = PacketHandler(0xE7)

function handler.onReceive(player, msg)
	local slotId = msg:getByte()
	player:sendPreyTimeLeft(slotId)
end

handler:register()
