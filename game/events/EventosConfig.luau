--[[
	ReplicatedStorage.Shared.EventosConfig  [Claude 2026-11-12]
	Clima e eventos do servidor (PAD-06). Um evento por vez, para TODOS os jogadores do servidor.
	O servidor (EventosServidor) sorteia e publica em atributos do Workspace; o cliente (EventosCliente)
	só lê estes textos e cores para a faixa e os efeitos. Nada aqui é segredo.
	Efeitos possíveis de cada evento:
	  * grama    — multiplica toda a grama cortada (Economia.FatorGrama)
	  * dourado  — multiplica os tufos dourados por jardim e a chance de dourado na floresta (TufoDourado)
	  * rebrota  — segundos para a grama do lote voltar depois do jardim completo (GameServer; normal = 20)
]]
local C = {}

C.PrimeiroEmSeg = 240 -- primeiro evento 4 min depois de o servidor abrir
C.IntervaloMinSeg = 420 -- entre um evento e outro: 7 a 11 min
C.IntervaloMaxSeg = 660

C.Eventos = {
	{
		id = "chuva", nome = "Chuva de Primavera", icone = "🌧️", duracao = 180,
		texto = "A grama do jardim volta em 5 s e há 2× mais tufos dourados!",
		rebrota = 5, dourado = 2, grama = 1,
		cor = Color3.fromRGB(86, 156, 226), efeito = "chuva",
	},
	{
		id = "dobro", nome = "Hora do Dobro", icone = "⏰", duracao = 180,
		texto = "Toda grama cortada vale 2×!",
		grama = 2, dourado = 1,
		cor = Color3.fromRGB(232, 120, 60), efeito = nil,
	},
	{
		id = "vento", nome = "Vento Dourado", icone = "✨", duracao = 150,
		texto = "3× mais tufos dourados no jardim e na floresta!",
		dourado = 3, grama = 1,
		cor = Color3.fromRGB(240, 186, 40), efeito = "brilho",
	},
}

function C.porId(id)
	for _, e in ipairs(C.Eventos) do if e.id == id then return e end end
	return nil
end

return C
