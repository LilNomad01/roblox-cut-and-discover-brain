--[[
	ServerScriptService.CorteEDescubra.TufoDourado  [Claude 2026-11-11]
	Grama dourada (variante rara). Chamado pelo GameServer:
	  * sortearLote(s): ao começar um serviço, marca N tufos do lote como dourados (atributo Dourado no tile;
	    o cliente mostra o brilho)
	  * aoCortarLote(player, s, id, tile): se o tufo cortado era dourado, paga o prêmio
	  * aoCortarFloresta(player, pos): chance de um corte na floresta sair dourado
	Prêmio: ValorDourado x multiplicador do cortador x (1 + ajudantes + grupo) em grama, pago direto em MOEDAS
	(preço de venda da grama), para não se perder com o saco cheio; e um pouco de XP.
]]
local RS = game:GetService("ReplicatedStorage")
local Config = require(script.Parent.RecompensasConfig)
local MissoesSinal = require(script.Parent.MissoesSinal) -- Claude 2026-11-12: Quadro do Jardineiro
local ConfigJogo = require(RS.ConfigJogo)
local Economia = require(game.ServerScriptService.Economia)

local M = {}
local rng = Random.new()

local fx = Instance.new("RemoteEvent")
fx.Name = "TufoDouradoFX"
fx.Parent = RS

local function premiar(player, pos)
	local mult = Economia.FatorGrama(player) -- Claude 2026-11-12: mesmo fator da grama (inclui rank, amigos e evento)
	local moedas = math.floor(Config.ValorDourado * mult * ConfigJogo.PrecoGrama + 0.5)
	Economia.AddMoedas(player, moedas)
	Economia.AddXP(player, Config.XPDourado)
	MissoesSinal.contar(player, "dourado", 1)
	fx:FireAllClients(player, pos, moedas)
end

function M.sortearLote(s)
	if not s or not s.job or not s.plot then return end
	local tiles = s.plot.GrassVisuals:GetChildren()
	for _, t in ipairs(tiles) do t:SetAttribute("Dourado", nil) end
	s.job.douradas = {}
	local livres = {}
	for id = 1, 64 do table.insert(livres, id) end
	local eventoMult = math.clamp(tonumber(workspace:GetAttribute("EventoDouradoMult")) or 1, 1, 5) -- Claude 2026-11-12: eventos
	for _ = 1, math.min(Config.DouradasPorJardim * eventoMult, #livres) do
		local id = table.remove(livres, rng:NextInteger(1, #livres))
		s.job.douradas[id] = true
		local row, col = math.floor((id - 1) / 8) + 1, (id - 1) % 8 + 1
		local tile = s.plot.GrassVisuals:FindFirstChild(string.format("Grass_%02d_%02d", row, col))
		if tile then tile:SetAttribute("Dourado", true) end
	end
end

function M.aoCortarLote(player, s, id, tile)
	if not s or not s.job or not s.job.douradas or not s.job.douradas[id] then return end
	s.job.douradas[id] = nil
	if tile then tile:SetAttribute("Dourado", nil) end
	premiar(player, tile and tile.Position or nil)
end

function M.aoCortarFloresta(player, pos)
	local eventoMult = math.clamp(tonumber(workspace:GetAttribute("EventoDouradoMult")) or 1, 1, 5) -- Claude 2026-11-12: eventos
	if rng:NextNumber() < Config.ChanceDouradaFloresta * eventoMult then premiar(player, pos) end
end

return M
