--[[
	ReplicatedStorage.Shared.AlbumConfig  [Claude 2026-11-12]
	Álbum de coleções (brain 19, item 5). Lido pelo servidor (AlbumServidor) e pelo cliente (AlbumCliente).
	Páginas:
	  * segredos   — segredos da floresta (lista em ReplicatedStorage.SegredosDaFloresta; coletados em ForestClaimedSecrets)
	  * ajudantes  — as 10 espécies de Shared.PetsCatalogo (registradas quando o jogador tem uma)
	  * ferramentas — as 15 raridades das ferramentas (Shared.OficinaConfig; ter uma raridade conta as anteriores)
	  * eventos    — os climas de Shared.EventosConfig (registrados quando o jogador está online durante um)
	Página completa: +BonusPorPagina de grama para sempre (BonusAlbum, na Economia.FatorGrama) e moedas x cortador.
]]
local C = {}

C.Paginas = {
	{ id = "segredos", nome = "Segredos da Floresta", icone = "🌲", moedas = 2000 },
	{ id = "ajudantes", nome = "Ajudantes do Jardim", icone = "🐾", moedas = 2000 },
	{ id = "ferramentas", nome = "Ferramentas", icone = "🔨", moedas = 3000 },
	{ id = "eventos", nome = "Climas e Eventos", icone = "🌦️", moedas = 1000 },
}
C.BonusPorPagina = 0.05

function C.valid(t)
	if type(t) ~= "table" or t.version ~= 1 then return false end
	for _, k in ipairs({ "especies", "eventos", "paginas" }) do
		local m = t[k]
		if type(m) ~= "table" then return false end
		local n = 0
		for id, v in pairs(m) do
			n += 1
			if type(id) ~= "string" or #id > 32 or v ~= true or n > 64 then return false end
		end
	end
	return true
end

return C
