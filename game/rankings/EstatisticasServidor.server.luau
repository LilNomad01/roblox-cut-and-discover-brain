--[[
	ServerScriptService.CorteEDescubra.EstatisticasServidor  [Claude 2026-11-12]
	Rankings globais e conquistas (PAD-07).
	  * Estatísticas para sempre em profile.Estatisticas (salvas pelo Profiles), contadas pelo MissoesSinal:
	    cortes, dourados, descobertas, jardins, vendas. "selos" é lido de profile.Missoes.selos.
	  * Conquistas (Shared.ConquistasConfig): ao bater a meta paga moedas x cortador, avisa e, se houver
	    BadgeId configurado, entrega o badge. Guardadas em profile.Conquistas = { [id] = true }.
	  * Rankings globais: OrderedDataStore por estatística (sufixo _Studio no Studio, para não misturar com o
	    jogo publicado). Grava o valor de cada jogador de tempos em tempos e ao sair; lê o top 10 e escreve no
	    quadro do lobby (Workspace.GameWorld.Lobby.QuadroRanking).
	RemoteFunction ReplicatedStorage.ConquistasAcao: "estado".
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local DSS = game:GetService("DataStoreService")
local BadgeService = game:GetService("BadgeService")
local Config = require(RS.Shared.ConquistasConfig)
local Data = require(script.Parent.EstatisticasData)
local Sinal = require(script.Parent.MissoesSinal)
local Profiles = require(script.Parent.Profiles)
local Economia = require(game.ServerScriptService.Economia)

local remote = Instance.new("RemoteFunction")
remote.Name = "ConquistasAcao"
remote.Parent = RS

---------------------------------------------------------------- dados do jogador
local function perfil(p)
	if not p:GetAttribute("ProfileReady") then return nil end
	local prof = Profiles.get(p)
	if not prof then return nil end
	if prof.Estatisticas == nil or not Data.valid(prof.Estatisticas) then prof.Estatisticas = Data.new() end
	if prof.Conquistas == nil or not Data.validConquistas(prof.Conquistas) then prof.Conquistas = {} end
	return prof
end

local function valor(prof, stat)
	if stat == "selos" then return prof.Missoes and tonumber(prof.Missoes.selos) or 0 end
	return prof.Estatisticas[stat] or 0
end

local function escala(p)
	return math.max(1, tonumber(p:GetAttribute("Multiplicador")) or 1)
end

local function checar(p, prof)
	for _, c in ipairs(Config.Conquistas) do
		if not prof.Conquistas[c.id] and valor(prof, c.stat) >= c.meta then
			prof.Conquistas[c.id] = true
			local moedas = c.moedas * escala(p)
			Economia.AddMoedas(p, moedas)
			pcall(Economia.Notificar, p, ("🏆 Conquista: %s %s! +%d moedas"):format(c.icone, c.nome, moedas), "ouro")
			if c.BadgeId then
				task.spawn(function() pcall(BadgeService.AwardBadge, BadgeService, p.UserId, c.BadgeId) end)
			end
		end
	end
	local feitas = 0
	for _ in pairs(prof.Conquistas) do feitas += 1 end
	p:SetAttribute("ConquistasFeitas", feitas)
end

local MAPA = { corte = "cortes", dourado = "dourados", descoberta = "descobertas", jardim = "jardins" }
Sinal.evento:Connect(function(p, tipo, qtd)
	local prof = perfil(p)
	if not prof then return end
	local stat = MAPA[tipo]
	if stat then
		local n = math.floor(tonumber(qtd) or 0)
		if n <= 0 then return end
		prof.Estatisticas[stat] = math.min((prof.Estatisticas[stat] or 0) + n, 1e12)
	elseif tipo == "venda" then
		prof.Estatisticas.vendas = (prof.Estatisticas.vendas or 0) + 1
	elseif tipo ~= "selo" then
		return
	end
	checar(p, prof)
end)

local function ligar(p)
	local function pronto()
		local prof = perfil(p)
		if prof then checar(p, prof) end
	end
	if p:GetAttribute("ProfileReady") then pronto() end
	p:GetAttributeChangedSignal("ProfileReady"):Connect(pronto)
end
Players.PlayerAdded:Connect(ligar)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(ligar, p) end

remote.OnServerInvoke = function(p, acao)
	if acao ~= "estado" then return nil end
	local prof = perfil(p)
	if not prof then return { erro = "Seu perfil ainda está carregando." } end
	local lista = {}
	for i, c in ipairs(Config.Conquistas) do
		lista[i] = { id = c.id, nome = c.nome, icone = c.icone, stat = Config.Stats[c.stat], meta = c.meta,
			atual = math.min(valor(prof, c.stat), c.meta), feita = prof.Conquistas[c.id] == true, moedas = c.moedas * escala(p) }
	end
	local stats = {}
	for k, nome in pairs(Config.Stats) do stats[k] = { nome = nome, valor = valor(prof, k) } end
	return { conquistas = lista, stats = stats }
end

---------------------------------------------------------------- rankings globais
local sufixo = RunService:IsStudio() and "_Studio" or ""
local stores = {}
for _, r in ipairs(Config.Rankings) do
	local ok, st = pcall(DSS.GetOrderedDataStore, DSS, "CorteEDescubra_Rank_" .. r.stat .. "_v1" .. sufixo)
	if ok then stores[r.stat] = st end
end
local gravado = {} -- [userId][stat] = último valor gravado

local function gravar(p)
	local prof = Profiles.get(p)
	if not prof or not prof.Estatisticas then return end
	local uid = p.UserId
	if uid <= 0 then return end -- jogadores de teste local (ids negativos) não entram no ranking
	gravado[uid] = gravado[uid] or {}
	for stat, st in pairs(stores) do
		local v = math.floor(valor(prof, stat))
		if v > 0 and v ~= gravado[uid][stat] then
			local ok = pcall(function()
				st:UpdateAsync(tostring(uid), function(antigo) return math.max(tonumber(antigo) or 0, v) end)
			end)
			if ok then gravado[uid][stat] = v end
		end
	end
end

local nomes = {}
local function nome(uid)
	if nomes[uid] then return nomes[uid] end
	local p = Players:GetPlayerByUserId(uid)
	if p then nomes[uid] = p.DisplayName return nomes[uid] end
	local ok, n = pcall(Players.GetNameFromUserIdAsync, Players, uid)
	nomes[uid] = ok and n or ("Jogador " .. uid)
	return nomes[uid]
end

local function fmt(n)
	local s = tostring(math.floor(n))
	local r = s:reverse():gsub("(%d%d%d)", "%1."):reverse()
	return (r:gsub("^%.", ""))
end

local function quadro()
	local lobby = workspace:FindFirstChild("GameWorld") and workspace.GameWorld:FindFirstChild("Lobby")
	local q = lobby and lobby:FindFirstChild("QuadroRanking")
	return q and q:FindFirstChild("Painel", true)
end

local function atualizarQuadro()
	local painel = quadro()
	local gui = painel and painel:FindFirstChildOfClass("SurfaceGui")
	if not gui then return end
	for i, r in ipairs(Config.Rankings) do
		local col = gui:FindFirstChild("Col" .. i, true)
		local st = stores[r.stat]
		if col then
			local titulo = col:FindFirstChild("Titulo")
			if titulo then titulo.Text = r.titulo end
			local linhas = {}
			if st then
				local ok, pagina = pcall(function() return st:GetSortedAsync(false, Config.RankingTop):GetCurrentPage() end)
				if ok then linhas = pagina end
			end
			for k = 1, Config.RankingTop do
				local l = col:FindFirstChild("L" .. k)
				if l then
					local e = linhas[k]
					if e then
						local medalha = k == 1 and "🥇" or k == 2 and "🥈" or k == 3 and "🥉" or (k .. ".")
						l.Text = ("%s %s — %s"):format(medalha, nome(tonumber(e.key) or 0), fmt(e.value))
					else
						l.Text = k == 1 and (st and "Ninguém ainda. Seja o primeiro!" or "Ranking indisponível") or ""
					end
				end
			end
		end
	end
end

Players.PlayerRemoving:Connect(function(p) task.spawn(gravar, p) end)
game:BindToClose(function()
	for _, p in ipairs(Players:GetPlayers()) do task.spawn(gravar, p) end
	task.wait(2)
end)

task.spawn(function()
	task.wait(15)
	local proximaGravacao = 0
	while true do
		if os.clock() >= proximaGravacao then
			for _, p in ipairs(Players:GetPlayers()) do gravar(p) end
			proximaGravacao = os.clock() + Config.RankingGravarSeg
		end
		atualizarQuadro()
		task.wait(Config.RankingAtualizarSeg)
	end
end)
