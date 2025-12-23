-- Comando para testar funções C++ do Prey
function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	
	print("=== PREY TEST START ===")
	
	-- Testar se as funções C++ existem
	if not player.getPreyData then
		print("[ERROR] player:getPreyData() não existe!")
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "ERRO: Funções C++ do Prey não foram compiladas!")
		return false
	end
	
	print("[OK] Funções C++ do Prey existem")
	
	-- Testar setPreyData
	print("Testando setPreyData para slot 0...")
	local testData = {
		state = 1,
		bonusType = 0,
		bonusValue = 10,
		bonusGrade = 1,
		preyMonster = "Demon",
		timeLeft = 100,
		preyList = {"Demon", "Dragon"}
	}
	
	local success = player:setPreyData(0, testData)
	if success then
		print("[OK] setPreyData funcionou")
	else
		print("[ERROR] setPreyData falhou")
	end
	
	-- Testar getPreyData
	print("Testando getPreyData para slot 0...")
	local data = player:getPreyData(0)
	if data then
		print("[OK] getPreyData retornou dados:")
		print("  state: " .. data.state)
		print("  bonusType: " .. data.bonusType)
		print("  bonusValue: " .. data.bonusValue)
		print("  preyMonster: " .. data.preyMonster)
	else
		print("[ERROR] getPreyData retornou nil")
	end
	
	print("=== PREY TEST END ===")
	
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Teste concluído! Veja o console do servidor.")
	return false
end
