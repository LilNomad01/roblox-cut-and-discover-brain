--[[
	ReplicatedStorage.Shared.NpcFalas  [Claude 2026-11-11]
	Falas dos NPCs (balão no cliente). Regra do projeto: nada de fala "fingida". Cada dica descreve uma
	mecânica que existe no jogo hoje (catálogo ForestCommerceCatalog, GameServer, FerramentasServer).
	O jardineiro do lote NÃO fala da Floresta Esquecida (ideia estacionada: ideas/IDEIAS_FUTURAS_NAO_IMPLEMENTAR.md).
	contexto(player) devolve uma fala baseada no estado atual do jogador, ou nil.
]]
local F = {}

local function sacoCheio(p: Player): boolean
	return (p:GetAttribute("Saco") or 0) >= (p:GetAttribute("SacoMax") or math.huge)
end

F.Jardineiro = {
	primeira = "Olá! Eu cuido dos serviços deste jardim. Corte a grama e venda na caçamba dourada.",
	saudacao = { "Bom dia! Esse gramado não se corta sozinho.", "Opa! Pronto pra deixar o jardim no capricho?", "De volta ao trabalho? Gosto de ver!" },
	contexto = function(p: Player): string?
		if p:GetAttribute("JardimPronto") then return "Jardim impecável! Aperte E aqui comigo para pegar um novo serviço." end
		if sacoCheio(p) then return "Saco cheio! Venda a grama na caçamba dourada aqui pertinho." end
		if p:GetAttribute("FerramentaAtiva") == "Nenhuma" then return "Mãos vazias? Escolha uma ferramenta nas teclas 1 a 4." end
		local faltam = math.max(0, 64 - (p:GetAttribute("JardimCortes") or 0))
		if faltam > 0 then return ("Faltam %d tufos para terminar este jardim."):format(faltam) end
		return nil
	end,
	dicas = {
		"O carrinho corta faixas largas. A foice e a enxada ajudam nos cantinhos.",
		"Às vezes o gramado esconde um baú. Fique de olho enquanto corta!",
		"Aperte de novo o número da ferramenta para guardá-la.",
	},
}

F.Guto = {
	primeira = "Bolso cheio? A aventura merece uma mochila maior!",
	saudacao = { "E aí, aventureiro! Chegou na hora certa.", "Opa! Veio ver as mochilas novas?" },
	contexto = function(p: Player): string?
		if sacoCheio(p) then return "Saco cheio? A caçamba aqui do lado compra sua grama." end
		local saco, max = p:GetAttribute("Saco"), p:GetAttribute("SacoMax")
		if saco and max then return ("Seu saco está em %d de %d. Uma mochila maior ajuda!"):format(saco, max) end
		return nil
	end,
	dicas = {
		"Cada mochila substitui a anterior: o bônus não soma.",
		"Aperte E no balcão para ver todas as mochilas.",
	},
}

F.Lia = {
	primeira = "Marque o caminho de volta. As pedras azuis guardam uma história...",
	saudacao = { "Oi! Perdido? Eu também já fiquei.", "Que bom te ver inteiro por aqui!" },
	contexto = function(p: Player): string?
		if sacoCheio(p) then return "Mochila pesada? Tem uma caçamba de venda aqui do lado." end
		return nil
	end,
	dicas = {
		"A lanterna ilumina até 18 studs ao seu redor.",
		"A bússola aponta para os comerciantes que você já visitou.",
		"O kit de exploração destaca pistas visíveis por 12 segundos.",
	},
}

F.Teca = {
	primeira = "As flores do orvalho crescem longe da trilha. Traga algumas para minha pesquisa!",
	saudacao = { "Cuidado onde pisa, essas mudinhas são novas!", "Olá! Achou alguma flor bonita por aí?" },
	contexto = function(p: Player): string? return nil end,
	dicas = {
		"Troco cada flor do orvalho por 40 moedas.",
		"Três cogumelos raros valem um kit de exploração.",
		"Minha caçamba está quebrada. A pesquisa do orvalho me ajuda a consertá-la.",
	},
}

return F
