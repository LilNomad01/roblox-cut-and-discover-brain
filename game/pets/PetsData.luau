--[[
	ServerScriptService.CorteEDescubra.PetsData  [Claude 2026-11-11]
	Regras puras do inventário de ajudantes (sem Instances, rede ou espera). Vai salvo no perfil em profile.Pets.
	  { version = 1, proximo = <próximo id>, pets = { ["<id>"] = "<espécie>" }, equipados = { "<id>", ... } }
]]
local Cat = require(game.ReplicatedStorage.Shared.PetsCatalogo)
local D = {}

function D.new()
	return { version = 1, proximo = 1, pets = {}, equipados = {} }
end

function D.contar(s)
	local n = 0
	for _ in pairs(s.pets) do n += 1 end
	return n
end

function D.valid(s)
	if type(s) ~= "table" or s.version ~= 1 then return false end
	if type(s.proximo) ~= "number" or s.proximo ~= s.proximo or s.proximo % 1 ~= 0 or s.proximo < 1 or s.proximo > 1000000000 then return false end
	if type(s.pets) ~= "table" or type(s.equipados) ~= "table" then return false end
	local n = 0
	for id, esp in pairs(s.pets) do
		n += 1
		if n > Cat.MaxInventario or type(id) ~= "string" or #id > 12 or type(esp) ~= "string" or not Cat.Especies[esp] then return false end
	end
	local vistos, total = {}, 0
	for k, id in pairs(s.equipados) do
		total += 1
		if type(k) ~= "number" or type(id) ~= "string" or not s.pets[id] or vistos[id] then return false end
		vistos[id] = true
	end
	return total <= Cat.MaxEquipados and total == #s.equipados
end

function D.bonus(s)
	local b = 0
	for _, id in ipairs(s.equipados) do b += Cat.bonus(s.pets[id]) end
	return b
end

function D.sortear(ninho, rng)
	local total = 0
	for _, c in ipairs(ninho.chances) do total += c[2] end
	local r = rng:NextNumber() * total
	for _, c in ipairs(ninho.chances) do
		r -= c[2]
		if r < 0 then return c[1] end
	end
	return ninho.chances[#ninho.chances][1]
end

return D
