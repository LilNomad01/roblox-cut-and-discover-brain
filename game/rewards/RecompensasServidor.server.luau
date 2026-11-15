--[[
	ServerScriptService.CorteEDescubra.RecompensasServidor  [Claude 2026-11-11]
	Prêmio diário (sequência de 7 dias), prêmios por tempo jogado na sessão, códigos e bônus de grupo.
	RemoteFunction ReplicatedStorage.RecompensasAcao: "estado" | "diaria" | "tempo" (índice) | "codigo" (texto).
	Tudo validado aqui; os dados persistentes ficam em profile.Recompensas (salvos pelo Profiles).
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Config = require(script.Parent.RecompensasConfig)
local Data = require(script.Parent.RecompensasData)
local Profiles = require(script.Parent.Profiles)
local Economia = require(game.ServerScriptService.Economia)

local remote = Instance.new("RemoteFunction")
remote.Name = "RecompensasAcao"
remote.Parent = RS

local sessao = {} -- [Player] = { inicio = os.clock(), tempo = { [i] = true } }
local ultimo = {}

local function estado(p)
	local prof = Profiles.get(p)
	if not prof then return nil end
	if prof.Recompensas == nil or not Data.valid(prof.Recompensas) then prof.Recompensas = Data.new() end
	return prof.Recompensas
end

local function escala(p)
	return math.max(1, tonumber(p:GetAttribute("Multiplicador")) or 1)
end

local function minutos(p)
	local s = sessao[p]
	return s and (os.clock() - s.inicio) / 60 or 0
end

-- progresso offline: calculado uma vez por sessão a partir do último salvamento do perfil (lastSaveTime)
local function calcularOffline(p)
	local s = sessao[p]
	if not s or s.offlineFeito then return end
	s.offlineFeito = true
	local prof = Profiles.get(p)
	local ultimoSave = prof and tonumber(prof.lastSaveTime) or 0
	if ultimoSave <= 0 then return end -- perfil novo
	local min = (os.time() - ultimoSave) / 60
	if min < Config.Offline.minimoMin then return end
	local limite = min >= Config.Offline.maximoMin
	min = math.min(min, Config.Offline.maximoMin)
	local moedas = math.floor(min * Config.Offline.moedasPorMin * escala(p))
	if moedas <= 0 then return end
	Economia.AddMoedas(p, moedas)
	s.offline = { minutos = math.floor(min), moedas = moedas, limite = limite }
end

local function snapshot(p, r)
	local hoje = Data.hoje()
	local pode, seq = Data.diaria(r, hoje)
	local e = escala(p)
	local dias = {}
	for i, v in ipairs(Config.Diaria) do dias[i] = v * e end
	local tempo = {}
	for i, t in ipairs(Config.Tempo) do
		tempo[i] = { minutos = t.minutos, moedas = t.moedas * e, coletado = sessao[p] and sessao[p].tempo[i] == true or false }
	end
	-- o aviso de progresso offline vai uma vez só, na primeira consulta do cliente
	local offline = sessao[p] and sessao[p].offline
	if sessao[p] then sessao[p].offline = nil end
	return {
		offline = offline,
		diaria = { pode = pode, sequencia = r.sequencia, proxima = seq, indice = Data.indiceDia(pode and seq or r.sequencia, #Config.Diaria), valores = dias },
		tempo = tempo,
		minutos = minutos(p),
		grupo = Config.GrupoId ~= nil,
		bonusGrupo = p:GetAttribute("BonusGrupo") or 0,
	}
end

local function marcarPronto(p)
	if not sessao[p] then sessao[p] = { inicio = os.clock(), tempo = {} } end
	estado(p)
	calcularOffline(p)
	if Config.GrupoId then
		task.spawn(function()
			local ok, dentro = pcall(function() return p:IsInGroup(Config.GrupoId) end)
			if ok and dentro and p.Parent then p:SetAttribute("BonusGrupo", Config.BonusGrupo) end
		end)
	end
end

local function ligar(p)
	if p:GetAttribute("ProfileReady") then marcarPronto(p) end
	p:GetAttributeChangedSignal("ProfileReady"):Connect(function()
		if p:GetAttribute("ProfileReady") then marcarPronto(p) end
	end)
end
Players.PlayerAdded:Connect(ligar)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(ligar, p) end
Players.PlayerRemoving:Connect(function(p) sessao[p] = nil ultimo[p] = nil end)

local function pagar(p, moedas, texto)
	Economia.AddMoedas(p, moedas)
	pcall(Economia.Notificar, p, texto, "ouro")
end

remote.OnServerInvoke = function(p, acao, arg)
	if type(acao) ~= "string" or #acao > 12 then return nil end
	if not p:GetAttribute("ProfileReady") or not Profiles.active(p) then return { erro = "Seu perfil ainda está carregando." } end
	local r = estado(p)
	if not r then return nil end
	if acao ~= "estado" then
		local agora = os.clock()
		if ultimo[p] and agora - ultimo[p] < 0.5 then return { erro = "Calma, um de cada vez!", estado = snapshot(p, r) } end
		ultimo[p] = agora
	end

	if acao == "estado" then
		return { estado = snapshot(p, r) }
	elseif acao == "diaria" then
		local hoje = Data.hoje()
		local pode, seq = Data.diaria(r, hoje)
		if not pode then return { erro = "Você já pegou o prêmio de hoje. Volte amanhã!", estado = snapshot(p, r) } end
		local valor = Config.Diaria[Data.indiceDia(seq, #Config.Diaria)] * escala(p)
		r.ultimoDia = hoje
		r.sequencia = seq
		pagar(p, valor, ("🎁 Prêmio do dia %d: +%d moedas!"):format(seq, valor))
		return { ok = valor, estado = snapshot(p, r) }
	elseif acao == "tempo" then
		local i = tonumber(arg)
		local t = i and Config.Tempo[i]
		local s = sessao[p]
		if not t or not s or i % 1 ~= 0 then return { erro = "Prêmio inválido." } end
		if s.tempo[i] then return { erro = "Você já pegou este prêmio.", estado = snapshot(p, r) } end
		if minutos(p) < t.minutos then return { erro = ("Jogue %d min para liberar."):format(t.minutos), estado = snapshot(p, r) } end
		s.tempo[i] = true
		local valor = t.moedas * escala(p)
		pagar(p, valor, ("⏱️ %d min jogando: +%d moedas!"):format(t.minutos, valor))
		return { ok = valor, estado = snapshot(p, r) }
	elseif acao == "codigo" then
		if type(arg) ~= "string" or #arg < 2 or #arg > 24 then return { erro = "Código inválido.", estado = snapshot(p, r) } end
		local codigo = string.upper((arg:gsub("%s", "")))
		local premio = Config.Codigos[codigo]
		if not premio or (premio.expira and os.time() > premio.expira) then
			return { erro = "Código inválido ou expirado.", estado = snapshot(p, r) }
		end
		if r.codigos[codigo] then return { erro = "Você já usou este código.", estado = snapshot(p, r) } end
		r.codigos[codigo] = true
		pagar(p, premio.moedas, ("🎟️ Código %s: +%d moedas!"):format(codigo, premio.moedas))
		return { ok = premio.moedas, estado = snapshot(p, r) }
	end
	return nil
end
