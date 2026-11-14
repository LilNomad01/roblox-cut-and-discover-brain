--[[
	ServerScriptService.CorteEDescubra.OficinaServidor  [Claude 2026-11-12]
	Raridade das ferramentas manuais (MON-04, parte 2). Regras em Shared.OficinaConfig.
	  * profile.Ferramentas = { version = 1, nivel = { [tipo] = 1..5 }, materiais = { fibra, cristal, po } }
	  * Materiais caem pelos eventos do MissoesSinal (floresta, descoberta, dourado): nenhum gancho novo no GameServer.
	  * Atributos: FerramentasExtras (ids possuídos, lido pelo FerramentasServer.possui), Raridade_<tipo> (a
	    melhor de cada ferramenta, usada ao equipar), BonusFerramenta (grama extra da ferramenta NA MÃO),
	    Mat_fibra / Mat_cristal / Mat_po (para o cliente).
	RemoteFunction ReplicatedStorage.OficinaAcao: "estado" | "evoluir" (tipo).
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Shared.OficinaConfig)
local Sinal = require(script.Parent.MissoesSinal)
local Profiles = require(script.Parent.Profiles)
local Economia = require(game.ServerScriptService.Economia)

local remote = Instance.new("RemoteFunction")
remote.Name = "OficinaAcao"
remote.Parent = RS

local rng = Random.new()
local ultimo = {}

local function dados(p)
	if not p:GetAttribute("ProfileReady") then return nil end
	local prof = Profiles.get(p)
	if not prof then return nil end
	if prof.Ferramentas == nil or not Config.valid(prof.Ferramentas) then
		prof.Ferramentas = { version = 1, nivel = {}, materiais = { fibra = 0, cristal = 0, po = 0 } }
	end
	return prof.Ferramentas
end

local function nivelDe(d, tipo) return d.nivel[tipo] or 1 end

local function aplicarBonus(p, d)
	local tipo = p:GetAttribute("FerramentaAtiva")
	local r = 0
	for _, f in ipairs(Config.Ferramentas) do
		if f.tipo == tipo then r = Config.Raridades[nivelDe(d, tipo)].grama end
	end
	p:SetAttribute("BonusFerramenta", r)
end

local function aplicar(p, d)
	local ids = {}
	for _, f in ipairs(Config.Ferramentas) do
		local n = nivelDe(d, f.tipo)
		for i = 2, n do table.insert(ids, f.tipo .. "_" .. Config.Raridades[i].id) end
		p:SetAttribute("Raridade_" .. f.tipo, Config.Raridades[n].id)
	end
	p:SetAttribute("FerramentasExtras", table.concat(ids, ","))
	for _, m in ipairs(Config.Materiais) do p:SetAttribute("Mat_" .. m.id, d.materiais[m.id] or 0) end
	aplicarBonus(p, d)
end

local function ganhar(p, d, mat, qtd)
	d.materiais[mat] = (d.materiais[mat] or 0) + qtd
	p:SetAttribute("Mat_" .. mat, d.materiais[mat])
end

Sinal.evento:Connect(function(p, tipo, qtd)
	local d = dados(p)
	if not d then return end
	if tipo == "floresta" then
		local n = 0
		for _ = 1, math.floor(tonumber(qtd) or 0) do if rng:NextNumber() < Config.ChanceFibra then n += 1 end end
		if n > 0 then ganhar(p, d, "fibra", n) end
	elseif tipo == "descoberta" then
		ganhar(p, d, "cristal", 1)
		pcall(Economia.Notificar, p, "💎 +1 Cristal do Bosque (use na Oficina do lobby)", "info")
	elseif tipo == "dourado" then
		ganhar(p, d, "po", 1)
	end
end)

local function ligar(p)
	local function pronto()
		local d = dados(p)
		if d then aplicar(p, d) end
	end
	if p:GetAttribute("ProfileReady") then pronto() end
	p:GetAttributeChangedSignal("ProfileReady"):Connect(pronto)
	p:GetAttributeChangedSignal("FerramentaAtiva"):Connect(function()
		local d = dados(p)
		if d then aplicarBonus(p, d) end
	end)
	-- teste no Studio: Player:SetAttribute("OficinaTeste", N) no SERVIDOR dá N de cada material (só com IsStudio)
	if game:GetService("RunService"):IsStudio() then
		p:GetAttributeChangedSignal("OficinaTeste"):Connect(function()
			local n = math.floor(tonumber(p:GetAttribute("OficinaTeste")) or 0)
			local d = dados(p)
			if n > 0 and d then for _, m in ipairs(Config.Materiais) do ganhar(p, d, m.id, n) end end
		end)
	end
end
Players.PlayerAdded:Connect(ligar)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(ligar, p) end
Players.PlayerRemoving:Connect(function(p) ultimo[p] = nil end)

local function snapshot(p, d)
	local lista = {}
	for i, f in ipairs(Config.Ferramentas) do
		local n = nivelDe(d, f.tipo)
		local prox = Config.Raridades[n + 1]
		lista[i] = { tipo = f.tipo, nome = f.nome, icone = f.icone, nivel = n, raridade = Config.Raridades[n].nome,
			grama = Config.Raridades[n].grama, tiles = Config.Raridades[n].tiles,
			proxima = prox and { nome = prox.nome, grama = prox.grama, tiles = prox.tiles, custo = prox.custo } or nil }
	end
	return { ferramentas = lista, materiais = d.materiais, moedas = tonumber(p:GetAttribute("Moedas")) or 0 }
end

remote.OnServerInvoke = function(p, acao, arg)
	if type(acao) ~= "string" then return nil end
	if not Profiles.active(p) then return { erro = "Seu perfil ainda está carregando." } end
	local d = dados(p)
	if not d then return { erro = "Seu perfil ainda está carregando." } end
	if acao == "estado" then return { estado = snapshot(p, d) } end
	if acao ~= "evoluir" then return nil end
	local agora = os.clock()
	if ultimo[p] and agora - ultimo[p] < 0.6 then return { erro = "Calma, um de cada vez!", estado = snapshot(p, d) } end
	ultimo[p] = agora
	local ferr
	for _, f in ipairs(Config.Ferramentas) do if f.tipo == arg then ferr = f end end
	if not ferr then return { erro = "Ferramenta inválida." } end
	local n = nivelDe(d, ferr.tipo)
	local prox = Config.Raridades[n + 1]
	if not prox then return { erro = "Essa ferramenta já é Mitológica!", estado = snapshot(p, d) } end
	local custo = prox.custo
	local moedas = tonumber(p:GetAttribute("Moedas")) or 0
	if moedas < (custo.moedas or 0) then return { erro = ("Faltam %d moedas."):format((custo.moedas or 0) - moedas), estado = snapshot(p, d) } end
	for _, m in ipairs(Config.Materiais) do
		local precisa = custo[m.id] or 0
		if (d.materiais[m.id] or 0) < precisa then
			return { erro = ("Faltam %d %s %s."):format(precisa - (d.materiais[m.id] or 0), m.icone, m.nome), estado = snapshot(p, d) }
		end
	end
	p:SetAttribute("Moedas", moedas - (custo.moedas or 0))
	for _, m in ipairs(Config.Materiais) do d.materiais[m.id] = (d.materiais[m.id] or 0) - (custo[m.id] or 0) end
	d.nivel[ferr.tipo] = n + 1
	aplicar(p, d)
	pcall(Economia.Notificar, p, ("%s %s agora é %s! Grama +%d%% enquanto estiver na mão."):format(ferr.icone, ferr.nome, prox.nome, math.floor(prox.grama * 100 + 0.5)), "ouro")
	return { ok = true, estado = snapshot(p, d) }
end
