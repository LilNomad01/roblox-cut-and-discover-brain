--[[
	ServerScriptService.CorteEDescubra.EventosServidor  [Claude 2026-11-12]
	Clima e eventos do servidor (PAD-06): de tempos em tempos sorteia um evento (EventosConfig) que vale para
	todos. Publica no Workspace:
	  EventoAtual (id ou ""), EventoFim (GetServerTimeNow), EventoGrama, EventoDouradoMult, EventoRebrota
	Quem usa: Economia.FatorGrama (grama), TufoDourado (dourados), GameServer (rebrota do lote), EventosCliente (faixa e efeitos).
	Teste no Studio: Workspace:SetAttribute("EventoForcar", "chuva") no servidor começa o evento na hora
	(atributo do Workspace mudado por cliente não chega ao servidor, então não é brecha).
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Shared.EventosConfig)
local Economia = require(game.ServerScriptService.Economia)

local rng = Random.new()
local ultimo = nil
local rodando = false

local function limpar()
	workspace:SetAttribute("EventoAtual", "")
	workspace:SetAttribute("EventoFim", 0)
	workspace:SetAttribute("EventoGrama", 1)
	workspace:SetAttribute("EventoDouradoMult", 1)
	workspace:SetAttribute("EventoRebrota", nil)
end

local function anunciar(texto, tipo)
	for _, p in ipairs(Players:GetPlayers()) do pcall(Economia.Notificar, p, texto, tipo) end
end

local function rodar(ev)
	if rodando then return end
	rodando = true
	ultimo = ev.id
	workspace:SetAttribute("EventoGrama", math.clamp(ev.grama or 1, 1, 3))
	workspace:SetAttribute("EventoDouradoMult", math.clamp(ev.dourado or 1, 1, 5))
	workspace:SetAttribute("EventoRebrota", ev.rebrota)
	workspace:SetAttribute("EventoFim", workspace:GetServerTimeNow() + ev.duracao)
	workspace:SetAttribute("EventoAtual", ev.id)
	anunciar(("%s %s começou! %s"):format(ev.icone, ev.nome, ev.texto), "ouro")
	local fim = os.clock() + ev.duracao
	while os.clock() < fim and workspace:GetAttribute("EventoAtual") == ev.id do task.wait(1) end
	limpar()
	anunciar(("%s %s terminou."):format(ev.icone, ev.nome), "info")
	rodando = false
end

local function sortear()
	local opcoes = {}
	for _, e in ipairs(Config.Eventos) do if e.id ~= ultimo then table.insert(opcoes, e) end end
	return opcoes[rng:NextInteger(1, #opcoes)]
end

limpar()

-- teste/admin: só o servidor consegue mudar este atributo
workspace:GetAttributeChangedSignal("EventoForcar"):Connect(function()
	local id = workspace:GetAttribute("EventoForcar")
	if type(id) ~= "string" or id == "" then return end
	workspace:SetAttribute("EventoForcar", nil)
	if id == "parar" then workspace:SetAttribute("EventoAtual", "") return end
	local ev = Config.porId(id)
	if ev then task.spawn(rodar, ev) end
end)

-- novo jogador no meio de um evento recebe o aviso
Players.PlayerAdded:Connect(function(p)
	task.wait(8)
	local ev = Config.porId(workspace:GetAttribute("EventoAtual") or "")
	if ev and p.Parent then pcall(Economia.Notificar, p, ("%s %s acontecendo agora! %s"):format(ev.icone, ev.nome, ev.texto), "ouro") end
end)

task.spawn(function()
	task.wait(Config.PrimeiroEmSeg)
	while true do
		if not rodando then rodar(sortear()) end
		task.wait(rng:NextInteger(Config.IntervaloMinSeg, Config.IntervaloMaxSeg))
	end
end)
