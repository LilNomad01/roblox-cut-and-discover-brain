--[[
	ServerScriptService.CorteEDescubra.RecompensasConfig  [Claude 2026-11-11]
	Configuração SÓ DO SERVIDOR (os códigos não vão para o cliente).
	  * Diaria: 7 dias em sequência; o valor é multiplicado pelo multiplicador do cortador equipado
	    (assim o prêmio acompanha a fase do jogo). Perder um dia volta para o dia 1.
	  * Tempo: prêmios por tempo jogado NESTA sessão (minutos), também x multiplicador do cortador.
	  * Codigos: nome em MAIÚSCULAS -> recompensa. "expira" (opcional) = os.time() limite. Cada jogador resgata 1 vez.
	    Para criar um código novo: adicione uma linha aqui e publique o jogo.
	  * GrupoId: id do grupo do Roblox do jogo. nil = bônus de grupo desligado (não inventar id).
]]
local C = {}

C.Diaria = { 150, 250, 400, 600, 900, 1300, 2000 }

C.Tempo = {
	{ minutos = 5, moedas = 100 },
	{ minutos = 15, moedas = 250 },
	{ minutos = 30, moedas = 500 },
	{ minutos = 60, moedas = 1000 },
}

C.Codigos = {
	BEMVINDO = { moedas = 500 },
	CORTEEDESCUBRA = { moedas = 1000 },
	FLORESTA = { moedas = 1500 },
}

C.GrupoId = nil -- ex.: 12345678 (preencher com o id real do grupo do jogo)
C.BonusGrupo = 0.10 -- +10% de grama para membros do grupo

-- grama dourada
C.DouradasPorJardim = 2 -- tufos dourados sorteados em cada serviço do lote (64 tufos)
C.ChanceDouradaFloresta = 0.01 -- chance de um corte na floresta ser dourado
C.ValorDourado = 9 -- grama extra (x multiplicadores) paga em moedas na hora
C.XPDourado = 20

return C
