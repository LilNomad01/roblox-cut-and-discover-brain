--[[
	ReplicatedStorage.Shared.FazendaConfig  [Claude 2026-11-12]
	Região nova "Fazenda Abandonada" (brain 19, item 3), ao norte do lobby. Lido pelo servidor (FazendaServidor)
	e pelo cliente (FazendaCliente).
	  * Campo de grama alta compartilhado (todos veem o mesmo) com CamposX x CamposZ quadrados de 4 studs.
	  * Só o CARRINHO corta aqui (as ferramentas manuais cortam o lote e a floresta).
	  * Grama da fazenda vale mais: cada quadrado dá a grama normal + ExtraGrama x a normal.
	  * Cada quadrado volta a crescer RebrotaSeg depois (na Chuva de Primavera, RebrotaChuvaSeg).
	  * Tufo dourado: mesma chance e prêmio da floresta (TufoDourado.aoCortarFloresta).
	  * Entrada: nível NivelMinimo OU Fama FamaMinima.
]]
local C = {}

C.Centro = Vector3.new(0, 2.8, 268) -- centro do campo, na altura do chão
C.CamposX = 30 -- quadrados no eixo X (30 x 4 = 120 studs)
C.CamposZ = 11 -- quadrados no eixo Z (11 x 4 = 44 studs)
C.Tile = 4

-- área da região (quem está dentro precisa ter acesso)
C.Limites = { min = Vector3.new(-100, -20, 243), max = Vector3.new(112, 80, 306) } -- começa logo depois do portão (z 242)
C.PortaoFora = Vector3.new(0, 6, 226) -- onde volta quem ainda não tem acesso

C.NivelMinimo = 10
C.FamaMinima = 1

C.ExtraGrama = 1.0 -- +100%: grama da fazenda vale 2x
C.RebrotaSeg = 45
C.RebrotaChuvaSeg = 12
C.RaioCorte = 3.2 -- alcance do carrinho em volta da lâmina
C.MaxPorTique = 6 -- quadrados por tique (0,1 s)

function C.dentro(pos)
	local a, b = C.Limites.min, C.Limites.max
	return pos.X >= a.X and pos.X <= b.X and pos.Z >= a.Z and pos.Z <= b.Z and pos.Y >= a.Y and pos.Y <= b.Y
end

function C.liberada(nivel, fama)
	return (tonumber(nivel) or 1) >= C.NivelMinimo or (tonumber(fama) or 0) >= C.FamaMinima
end

return C
