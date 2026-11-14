--[[
	ReplicatedStorage.Shared.ConquistasConfig  [Claude 2026-11-12]
	Conquistas e rankings (PAD-07). Lido pelo servidor (EstatisticasServidor) e pelo cliente (ConquistasCliente).
	  * Stats: contadores para sempre do jogador (profile.Estatisticas), alimentados pelo MissoesSinal.
	  * Conquistas: meta numa estatística -> prêmio em moedas (x multiplicador do cortador) uma vez só.
	    BadgeId = nil: o jogo não tem badges criados; quando o dono criar um badge no Creator Hub, coloque o id
	    aqui e o servidor entrega o badge junto (BadgeService:AwardBadge). Não inventar ids.
	  * Rankings: estatísticas com placar global (OrderedDataStore) no quadro do lobby.
]]
local C = {}

C.Stats = {
	cortes = "Tufos cortados",
	dourados = "Tufos dourados",
	descobertas = "Baús e segredos",
	jardins = "Jardins completos",
	vendas = "Vendas",
	selos = "Selos de missão",
}

C.Conquistas = {
	{ id = "corte1", stat = "cortes", meta = 100, nome = "Primeiros Passos", icone = "🌱", moedas = 100 },
	{ id = "corte2", stat = "cortes", meta = 1000, nome = "Mão na Grama", icone = "✂️", moedas = 400 },
	{ id = "corte3", stat = "cortes", meta = 10000, nome = "Cortador de Elite", icone = "🚜", moedas = 2000 },
	{ id = "corte4", stat = "cortes", meta = 100000, nome = "Lenda do Gramado", icone = "👑", moedas = 10000 },
	{ id = "jardim1", stat = "jardins", meta = 1, nome = "Jardim Novinho", icone = "🏡", moedas = 100 },
	{ id = "jardim2", stat = "jardins", meta = 10, nome = "Paisagista", icone = "🌷", moedas = 600 },
	{ id = "jardim3", stat = "jardins", meta = 50, nome = "Jardineiro do Bairro", icone = "🏘️", moedas = 3000 },
	{ id = "dourado1", stat = "dourados", meta = 1, nome = "Brilhou!", icone = "✨", moedas = 100 },
	{ id = "dourado2", stat = "dourados", meta = 25, nome = "Caçador de Ouro", icone = "🌟", moedas = 800 },
	{ id = "dourado3", stat = "dourados", meta = 100, nome = "Midas do Jardim", icone = "🏆", moedas = 4000 },
	{ id = "desc1", stat = "descobertas", meta = 1, nome = "O Que Tem Aqui?", icone = "📦", moedas = 100 },
	{ id = "desc2", stat = "descobertas", meta = 10, nome = "Explorador", icone = "🧭", moedas = 800 },
	{ id = "desc3", stat = "descobertas", meta = 30, nome = "Caçador de Tesouros", icone = "💎", moedas = 3000 },
	{ id = "selo1", stat = "selos", meta = 3, nome = "Ajudante Oficial", icone = "📋", moedas = 200 },
	{ id = "selo2", stat = "selos", meta = 15, nome = "Mestre das Missões", icone = "🏅", moedas = 1500 },
}

for _, c in ipairs(C.Conquistas) do c.BadgeId = nil end -- preencher com ids reais quando existirem

C.Rankings = {
	{ stat = "cortes", titulo = "✂️ Mais tufos cortados" },
	{ stat = "descobertas", titulo = "📦 Mais baús e segredos" },
	{ stat = "selos", titulo = "📋 Mais selos de missão" },
}
C.RankingTop = 10
C.RankingAtualizarSeg = 120 -- lê o top 10 a cada 2 min
C.RankingGravarSeg = 180 -- grava o valor de cada jogador a cada 3 min (e ao sair)

function C.porId(id)
	for _, c in ipairs(C.Conquistas) do if c.id == id then return c end end
	return nil
end

return C
