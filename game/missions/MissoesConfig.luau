--[[
	ServerScriptService.CorteEDescubra.MissoesConfig  [Claude 2026-11-12]
	Quadro do Jardineiro (PAD-05): 3 trilhas de missões que nunca acabam. Cada trilha passa pelas suas
	missões em ordem; depois da última, volta à primeira num "ciclo" mais difícil e que paga mais.
	  * tipo: evento contado (ver MissoesSinal): corte, floresta, jardim, dourado, descoberta, venda, ninho
	  * alvo: quantidade no ciclo 0. cresce = "x" -> alvo * (1 + ciclo);  "+" -> alvo + ciclo
	  * moedas: prêmio base, x (1 + 0,5 * ciclo) x multiplicador do cortador equipado
	Toda missão concluída também dá 1 SELO. A cada SelosPorRank selos o jogador sobe de rank, e cada rank
	dá +BonusPorRank de grama PARA SEMPRE (atributo BonusMissoes, somado na Economia), até RankMax.
]]
local C = {}

C.Trilhas = {
	{
		nome = "Jardim", icone = "🌱",
		missoes = {
			{ tipo = "corte", alvo = 150, cresce = "x", moedas = 150, texto = "Corte %d tufos de grama" },
			{ tipo = "jardim", alvo = 2, cresce = "+", moedas = 200, texto = "Complete %d jardins do seu lote" },
			{ tipo = "dourado", alvo = 3, cresce = "+", moedas = 250, texto = "Corte %d tufos dourados" },
		},
	},
	{
		nome = "Floresta", icone = "🌲",
		missoes = {
			{ tipo = "floresta", alvo = 100, cresce = "x", moedas = 200, texto = "Corte %d tufos na Floresta" },
			{ tipo = "descoberta", alvo = 1, cresce = "+", moedas = 250, texto = "Abra %d baú(s) ou segredo(s)" },
			{ tipo = "floresta", alvo = 300, cresce = "x", moedas = 350, texto = "Corte %d tufos na Floresta" },
		},
	},
	{
		nome = "Negócios", icone = "💰",
		missoes = {
			{ tipo = "venda", alvo = 3, cresce = "+", moedas = 150, texto = "Venda o saco %d vezes (pelo menos meio cheio)" },
			{ tipo = "ninho", alvo = 1, cresce = "+", moedas = 250, texto = "Choque %d ninho(s) de ajudante" },
			{ tipo = "venda", alvo = 6, cresce = "x", moedas = 300, texto = "Venda o saco %d vezes (pelo menos meio cheio)" },
		},
	},
}

C.XPBase = 30 -- + 10 por ciclo
C.SelosPorRank = 3
C.BonusPorRank = 0.03 -- +3% de grama por rank
C.RankMax = 20 -- teto: +60%
C.VendaMinimaFracao = 0.5 -- venda só conta com o saco pelo menos meio cheio

C.Ranks = { "Aprendiz", "Ajudante", "Podador", "Jardineiro", "Paisagista", "Mestre Jardineiro", "Guardião do Bosque", "Lenda da Floresta" }

function C.nomeRank(r)
	return C.Ranks[r + 1] or (C.Ranks[#C.Ranks] .. " " .. (r - #C.Ranks + 2))
end

function C.alvo(def, ciclo)
	if def.cresce == "+" then return def.alvo + ciclo end
	return def.alvo * (1 + ciclo)
end

function C.moedas(def, ciclo)
	return math.floor(def.moedas * (1 + 0.5 * ciclo))
end

return C
