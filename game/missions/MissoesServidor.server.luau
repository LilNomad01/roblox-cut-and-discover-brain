--[[
	ServerScriptService.CorteEDescubra.MissoesServidor  [Claude 2026-11-12]
	Quadro do Jardineiro (PAD-05). Conta os eventos do jogo (MissoesSinal), guarda o progresso em
	profile.Missoes (salvo pelo Profiles) e paga a missão quando o jogador pede para coletar.
	RemoteFunction ReplicatedStorage.MissoesAcao: "estado" | "coletar" (número da trilha).
	Atributos no Player:
	  * BonusMissoes  — bônus permanente de grama do rank (a Economia soma na grama de cada tufo)
	  * RankJardineiro — rank atual (número)
	  * MissoesProntas — quantas missões estão prontas para coletar (bolinha no botão)
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Config = require(script.Parent.MissoesConfig)
local Data = require(script.Parent.MissoesData)
local Sinal = require(script.Parent.MissoesSinal)
local Profiles = require(script.Parent.Profiles)
local Economia = require(game.ServerScriptService.Economia)

local remote = Instance.new("RemoteFunction")
remote.Name = "MissoesAcao"
remote.Parent = RS

local ultimo = {}

local function estado(p)
	if not p:GetAttribute("ProfileReady") then return nil end
	local prof = Profiles.get(p)
	if not prof then return nil end
	if prof.Missoes == nil or not Data.valid(prof.Missoes) then prof.Missoes = Data.new() end
	return Data.normalizar(prof.Missoes)
end

local function atual(k, tr)
	local def = Config.Trilhas[k].missoes[tr.i]
	return def, Config.alvo(def, tr.c)
end

local function aplicar(p, m)
	local r = Data.rank(m.selos)
	p:SetAttribute("RankJardineiro", r)
	p:SetAttribute("BonusMissoes", r * Config.BonusPorRank)
	local prontas = 0
	for k, tr in ipairs(m.trilhas) do
		local _, alvo = atual(k, tr)
		if tr.p >= alvo then prontas += 1 end
	end
	p:SetAttribute("MissoesProntas", prontas)
end

local function escala(p)
	return math.max(1, tonumber(p:GetAttribute("Multiplicador")) or 1)
end

local function snapshot(p, m)
	local lista = {}
	for k, tr in ipairs(m.trilhas) do
		local trilha = Config.Trilhas[k]
		local def, alvo = atual(k, tr)
		lista[k] = {
			nome = trilha.nome, icone = trilha.icone, ciclo = tr.c, etapa = tr.i, etapas = #trilha.missoes,
			texto = def.texto:format(alvo), progresso = math.min(tr.p, alvo), alvo = alvo,
			moedas = Config.moedas(def, tr.c) * escala(p), xp = Config.XPBase + 10 * tr.c,
		}
	end
	local r = Data.rank(m.selos)
	return {
		missoes = lista, selos = m.selos, rank = r, nomeRank = Config.nomeRank(r),
		proximoRank = r < Config.RankMax and Config.nomeRank(r + 1) or nil,
		selosNoRank = m.selos - r * Config.SelosPorRank, selosPorRank = Config.SelosPorRank,
		bonus = r * Config.BonusPorRank, bonusProximo = math.min(r + 1, Config.RankMax) * Config.BonusPorRank,
		rankMax = r >= Config.RankMax,
	}
end

-- eventos do jogo
Sinal.evento:Connect(function(p, tipo, qtd)
	local m = estado(p)
	if not m then return end
	if tipo == "venda" then
		-- qtd = fração do saco vendida; só vale se estava pelo menos meio cheio
		if type(qtd) ~= "number" or qtd < Config.VendaMinimaFracao then return end
		qtd = 1
	end
	qtd = math.floor(tonumber(qtd) or 0)
	if qtd <= 0 then return end
	local mudou = false
	for k, tr in ipairs(m.trilhas) do
		local def, alvo = atual(k, tr)
		if def.tipo == tipo and tr.p < alvo then
			tr.p = math.min(alvo, tr.p + qtd)
			mudou = true
			if tr.p >= alvo then
				pcall(Economia.Notificar, p, ("📋 Missão pronta: %s! Abra o quadro de missões para coletar."):format(def.texto:format(alvo)), "sucesso")
			end
		end
	end
	if mudou then aplicar(p, m) end
end)

local function ligar(p)
	local function pronto()
		local m = estado(p)
		if m then aplicar(p, m) end
	end
	if p:GetAttribute("ProfileReady") then pronto() end
	p:GetAttributeChangedSignal("ProfileReady"):Connect(pronto)
end
Players.PlayerAdded:Connect(ligar)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(ligar, p) end
Players.PlayerRemoving:Connect(function(p) ultimo[p] = nil end)

remote.OnServerInvoke = function(p, acao, arg)
	if type(acao) ~= "string" or #acao > 12 then return nil end
	if not Profiles.active(p) then return { erro = "Seu perfil ainda está carregando." } end
	local m = estado(p)
	if not m then return { erro = "Seu perfil ainda está carregando." } end
	if acao == "estado" then
		return { estado = snapshot(p, m) }
	elseif acao == "coletar" then
		local agora = os.clock()
		if ultimo[p] and agora - ultimo[p] < 0.4 then return { erro = "Calma, um de cada vez!", estado = snapshot(p, m) } end
		ultimo[p] = agora
		local k = tonumber(arg)
		local tr = k and k % 1 == 0 and m.trilhas[k]
		if not tr then return { erro = "Missão inválida." } end
		local def, alvo = atual(k, tr)
		if tr.p < alvo then return { erro = "Essa missão ainda não terminou.", estado = snapshot(p, m) } end
		local moedas = Config.moedas(def, tr.c) * escala(p)
		local xp = Config.XPBase + 10 * tr.c
		local rankAntes = Data.rank(m.selos)
		-- avança antes de pagar (nada de pagar duas vezes)
		tr.p = 0
		tr.i += 1
		if tr.i > #Config.Trilhas[k].missoes then tr.i = 1 tr.c += 1 end
		m.selos += 1
		Economia.AddMoedas(p, moedas)
		Economia.AddXP(p, xp)
		aplicar(p, m)
		Sinal.contar(p, "selo", 1) -- [Claude 2026-11-12] conquistas e ranking de selos (EstatisticasServidor)
		local rank = Data.rank(m.selos)
		local subiu = rank > rankAntes
		if subiu then
			pcall(Economia.Notificar, p, ("🏅 Novo rank: %s! Grama +%d%% para sempre."):format(Config.nomeRank(rank), math.floor(rank * Config.BonusPorRank * 100 + 0.5)), "ouro")
		else
			pcall(Economia.Notificar, p, ("📋 Missão concluída: +%d moedas, +%d XP e 1 selo!"):format(moedas, xp), "ouro")
		end
		return { ok = moedas, subiu = subiu, estado = snapshot(p, m) }
	end
	return nil
end
