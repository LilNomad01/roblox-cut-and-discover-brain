--[[
	ReplicatedStorage.Shared.FamaConfig  [Claude 2026-11-12]
	"Fama de Jardineiro" — renascimento (MON-05). Lido pelo servidor (FamaServidor) e pelo cliente (FamaCliente).
	Requisito para ganhar uma estrela: ter comprado o Imperial GX e ter pelo menos custo(estrelas) moedas.
	Ao renascer: moedas viram 0, cortadores voltam ao Básico e o saco esvazia.
	Fica: nível e XP, ajudantes, habilidades, segredos, missões, conquistas, estatísticas e mochilas.
	Cada estrela dá +BonusPorEstrela de grama para sempre (atributo BonusFama, somado na Economia.FatorGrama).
]]
local C = {}

C.CortadorExigido = "Imperial" -- Id em ConfigJogo.Itens (Imperial GX)
C.CustoBase = 200000
C.CustoCrescimento = 1.6 -- custo da próxima estrela = CustoBase * 1,6^estrelas
C.BonusPorEstrela = 0.25 -- +25% de grama por estrela
C.MaxEstrelas = 20 -- teto do bônus: +500%

C.Titulos = { "Jardineiro Famoso", "Estrela do Bairro", "Celebridade Verde", "Ícone do Gramado", "Lenda Dourada" }

function C.custo(estrelas)
	return math.floor(C.CustoBase * C.CustoCrescimento ^ estrelas / 1000 + 0.5) * 1000
end

function C.titulo(estrelas)
	if estrelas <= 0 then return "Sem fama ainda" end
	return C.Titulos[math.min(estrelas, #C.Titulos)]
end

function C.valid(t)
	return type(t) == "table" and t.version == 1 and type(t.estrelas) == "number" and t.estrelas == t.estrelas
		and t.estrelas >= 0 and t.estrelas <= C.MaxEstrelas and t.estrelas % 1 == 0
end

return C
