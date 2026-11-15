--[[
	ReplicatedStorage.Shared.PetsCatalogo  [Claude 2026-11-11]
	Ajudantes do Jardim: espécies originais, raridades, bônus e ninhos (público: o cliente mostra as chances).
	O bônus é um MULTIPLICADOR DE GRAMA: soma dos bônus dos equipados; grama por tufo x (1 + soma).
	Ninhos custam só moedas ganhas jogando (o jogo não vende moedas por Robux). Se um dia vender, os ninhos
	passam a ser "itens aleatórios pagos" (exigem PolicyService) — ver brain/19.
]]
local C = {}

C.MaxEquipados = 3
C.MaxInventario = 30

C.Raridades = {
	Comum = { ordem = 1, nome = "Comum", cor = { 214, 210, 196 }, bonus = 0.10 },
	Incomum = { ordem = 2, nome = "Incomum", cor = { 110, 224, 120 }, bonus = 0.20 },
	Raro = { ordem = 3, nome = "Raro", cor = { 90, 170, 255 }, bonus = 0.40 },
	Lendario = { ordem = 4, nome = "Lendário", cor = { 255, 202, 70 }, bonus = 0.75 },
	Mitologico = { ordem = 5, nome = "Mitológico", cor = { 206, 124, 255 }, bonus = 1.50 },
}

C.Especies = {
	joaninha = { nome = "Joaninha", raridade = "Comum", icone = "🐞", cor = { 220, 52, 46 } },
	minhoca = { nome = "Minhoca", raridade = "Comum", icone = "🐛", cor = { 236, 150, 158 } },
	coelho = { nome = "Coelho", raridade = "Incomum", icone = "🐰", cor = { 240, 236, 226 } },
	ourico = { nome = "Ouriço", raridade = "Incomum", icone = "🦔", cor = { 168, 124, 86 } },
	toupeira = { nome = "Toupeira", raridade = "Raro", icone = "🐹", cor = { 96, 78, 66 } },
	sapo = { nome = "Sapo", raridade = "Raro", icone = "🐸", cor = { 96, 186, 84 } },
	coruja = { nome = "Coruja", raridade = "Lendario", icone = "🦉", cor = { 176, 134, 92 } },
	raposa = { nome = "Raposa", raridade = "Lendario", icone = "🦊", cor = { 238, 132, 52 } },
	cervo = { nome = "Cervo de Musgo", raridade = "Mitologico", icone = "🦌", cor = { 150, 120, 84 } },
	vagalume = { nome = "Vaga-lume Rei", raridade = "Mitologico", icone = "✨", cor = { 246, 226, 110 } },
}

-- chances em % (somam 100 em cada ninho)
C.Ninhos = {
	{ id = "jardim", nome = "Ninho do Jardim", preco = 300,
		chances = { { "joaninha", 40 }, { "minhoca", 30 }, { "coelho", 18 }, { "ourico", 10 }, { "toupeira", 2 } } },
	{ id = "floresta", nome = "Ninho da Floresta", preco = 6000,
		chances = { { "coelho", 30 }, { "ourico", 25 }, { "toupeira", 22 }, { "sapo", 15 }, { "coruja", 6 }, { "raposa", 2 } } },
	{ id = "real", nome = "Ninho Real", preco = 60000,
		chances = { { "toupeira", 30 }, { "sapo", 30 }, { "coruja", 22 }, { "raposa", 14 }, { "cervo", 3 }, { "vagalume", 1 } } },
}

function C.ninho(id)
	for _, n in ipairs(C.Ninhos) do
		if n.id == id then return n end
	end
	return nil
end

function C.bonus(especie)
	local e = C.Especies[especie]
	return e and C.Raridades[e.raridade].bonus or 0
end

function C.raridade(especie)
	local e = C.Especies[especie]
	return e and C.Raridades[e.raridade]
end

return C
