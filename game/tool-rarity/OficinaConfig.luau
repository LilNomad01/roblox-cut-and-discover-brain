--[[
	ReplicatedStorage.Shared.OficinaConfig  [Claude 2026-11-12]
	Raridade das ferramentas manuais (MON-04, parte 2). Lido pelo servidor (OficinaServidor) e pelo cliente (OficinaCliente).
	Cada ferramenta (Unha, Enxada, Foice) sobe Comum -> Incomum -> Raro -> Lendário -> Mitológico na Oficina do lobby,
	pagando moedas + materiais achados jogando:
	  🌿 fibra  — chance em cada tufo cortado na Floresta
	  💎 cristal — cada baú ou segredo aberto (lote ou floresta)
	  ✨ po     — cada tufo dourado cortado
	Efeito da raridade enquanto a ferramenta está NA MÃO: grama extra (BonusFerramenta, na Economia.FatorGrama)
	e quadrados extras por golpe (FerramentasServer). O modelo 3D de cada raridade já existe em
	ServerStorage.GameAssets.Ferramentas.
]]
local C = {}

C.Ferramentas = {
	{ tipo = "CortadorUnha", nome = "Cortador de Unha", icone = "✂️" },
	{ tipo = "Enxada", nome = "Enxada", icone = "⛏️" },
	{ tipo = "Foice", nome = "Foice", icone = "🌾" },
}

C.Raridades = {
	{ id = "Comum", nome = "Comum", cor = Color3.fromRGB(170, 170, 170), grama = 0, tiles = 0 },
	{ id = "Incomum", nome = "Incomum", cor = Color3.fromRGB(90, 200, 100), grama = 0.10, tiles = 0,
		custo = { moedas = 500, fibra = 15 } },
	{ id = "Raro", nome = "Raro", cor = Color3.fromRGB(70, 140, 240), grama = 0.25, tiles = 1,
		custo = { moedas = 5000, fibra = 50, cristal = 3 } },
	{ id = "Lendario", nome = "Lendário", cor = Color3.fromRGB(240, 170, 40), grama = 0.50, tiles = 1,
		custo = { moedas = 40000, fibra = 120, cristal = 8, po = 10 } },
	{ id = "Mitologico", nome = "Mitológico", cor = Color3.fromRGB(200, 90, 240), grama = 1.0, tiles = 2,
		custo = { moedas = 250000, fibra = 300, cristal = 15, po = 30 } },
}

C.Materiais = {
	{ id = "fibra", nome = "Fibra da Floresta", icone = "🌿" },
	{ id = "cristal", nome = "Cristal do Bosque", icone = "💎" },
	{ id = "po", nome = "Pó Dourado", icone = "✨" },
}

C.ChanceFibra = 0.04 -- por tufo cortado na Floresta (~1 fibra a cada 25 tufos)

local indice = {}
for i, r in ipairs(C.Raridades) do indice[r.id] = i end
function C.indice(raridade) return indice[raridade] end

function C.valid(t)
	if type(t) ~= "table" or t.version ~= 1 or type(t.nivel) ~= "table" or type(t.materiais) ~= "table" then return false end
	for k, v in pairs(t.nivel) do
		if type(k) ~= "string" or type(v) ~= "number" or v % 1 ~= 0 or v < 1 or v > #C.Raridades then return false end
	end
	for k, v in pairs(t.materiais) do
		if type(k) ~= "string" or #k > 16 or type(v) ~= "number" or v ~= v or v % 1 ~= 0 or v < 0 or v > 1e9 then return false end
	end
	return true
end

return C
