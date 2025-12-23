PreyMonsters = {
	"Demon",
	"Grim Reaper",
	"Diabolic Imp",
	"Juggernaut",
	"Dragon",
	"Dragon Lord",
	"Frost Dragon",
	"Ghastly Dragon",
	"Vampire",
	"Lich",
	"Necromancer",
	"Skeleton",
	"Ghost",
	"Orc",
	"Orc Warrior",
	"Orc Berserker",
	"Dwarf",
	"Dwarf Guard",
	"Cyclops",
	"Behemoth",
	"Giant Spider",
	"Fire Elemental",
	"Earth Elemental",
	"Energy Elemental",
	"Ice Golem",
	"Orshabaal",
	"Ferumbras",
	"Morgaroth"
}

function isValidPreyMonster(monsterName)
	for _, name in pairs(PreyMonsters) do
		if name:lower() == monsterName:lower() then
			return true
		end
	end
	return false
end

function getRandomPreyMonsters(count)
	local available = {}
	for _, name in pairs(PreyMonsters) do
		local mType = MonsterType(name)
		if mType then
			table.insert(available, name)
		end
	end
	
	if #available == 0 then
		return {}
	end
	
	local selected = {}
	for i = 1, math.min(count, #available) do
		local index = math.random(1, #available)
		table.insert(selected, available[index])
		table.remove(available, index)
	end
	
	return selected
end
