--[[
	ServerScriptService.CorteEDescubra.FazendaServidor  [Claude 2026-11-12]
	Região "Fazenda Abandonada". Regras em Shared.FazendaConfig; cenário em Workspace.GameWorld.Fazenda
	(construído no Edit, receita em game/farm/Fazenda.build.luau).
	  * Corte: a cada 0,1 s, para quem está com o CARRINHO dentro do campo, corta os quadrados perto do trajeto
	    da frente do cortador. Cada quadrado: Economia.CortarGrama (grama normal, XP, missões, conquistas) +
	    grama extra da fazenda + chance de tufo dourado.
	  * Rebrota: cada quadrado volta depois de RebrotaSeg (Chuva de Primavera: RebrotaChuvaSeg).
	  * Acesso: nível 10 ou Fama 1. Quem não tem é levado de volta ao portão com aviso.
	  * Caçamba da fazenda: vende com Economia.Vender.
	Atributo no Player: FazendaLiberada (para o cliente). Teste no Studio: Player:SetAttribute("FazendaTesteBloqueio", true)
	no servidor finge que o jogador não tem acesso.
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(RS.Shared.FazendaConfig)
local ConfigJogo = require(RS.ConfigJogo)
local Economia = require(game.ServerScriptService.Economia)
local TufoDourado = require(script.Parent.TufoDourado)
local Profiles = require(script.Parent.Profiles)

local fazenda = workspace:WaitForChild("GameWorld"):WaitForChild("Fazenda", 30)
if not fazenda then warn("[Fazenda] cenário não encontrado") return end
local pastaGrama = fazenda:WaitForChild("Grama")

---------------------------------------------------------------- quadrados
local tiles = {} -- { part, pos(Vector2), cortadoEm }
for _, t in ipairs(pastaGrama:GetChildren()) do
	if t:IsA("BasePart") then
		table.insert(tiles, { part = t, pos = Vector2.new(t.Position.X, t.Position.Z), cortadoEm = nil })
	end
end

local function setCortado(t, cortado)
	local baixo = t.part:FindFirstChild("Cortada")
	t.part.Transparency = cortado and 1 or 0
	if baixo then baixo.Transparency = cortado and 0 or 1 end
	t.cortadoEm = cortado and os.clock() or nil
end
for _, t in ipairs(tiles) do setCortado(t, false) end

local function distSeg(p, a, b)
	local ab = b - a
	local len2 = ab:Dot(ab)
	local u = len2 > 0 and math.clamp((p - a):Dot(ab) / len2, 0, 1) or 0
	return (p - (a + ab * u)).Magnitude
end

---------------------------------------------------------------- acesso
local function liberada(p)
	if RunService:IsStudio() and p:GetAttribute("FazendaTesteBloqueio") then return false end
	return Config.liberada(p:GetAttribute("Nivel"), p:GetAttribute("FamaEstrelas"))
end

local ultimoAviso = {}
local function avisar(p, texto, tipo)
	local agora = os.clock()
	if ultimoAviso[p] and agora - ultimoAviso[p] < 3 then return end
	ultimoAviso[p] = agora
	pcall(Economia.Notificar, p, texto, tipo)
end

---------------------------------------------------------------- corte pelo carrinho
local ultimaLamina = {}
local acumulado = 0
RunService.Heartbeat:Connect(function(dt)
	acumulado += dt
	if acumulado < 0.1 then return end
	acumulado = 0
	for _, p in ipairs(Players:GetPlayers()) do
		local char = p.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not root or not hum or hum.Health <= 0 or not p:GetAttribute("ProfileReady") then ultimaLamina[p] = nil continue end
		local dentro = Config.dentro(root.Position)
		p:SetAttribute("FazendaLiberada", liberada(p))
		if not dentro then ultimaLamina[p] = nil continue end
		if not liberada(p) then
			ultimaLamina[p] = nil
			char:PivotTo(CFrame.lookAt(Config.PortaoFora, Config.PortaoFora - Vector3.new(0, 0, 10)))
			avisar(p, ("🔒 A Fazenda Abandonada abre no nível %d ou com ⭐ Fama %d."):format(Config.NivelMinimo, Config.FamaMinima), "erro")
			continue
		end
		if p:GetAttribute("FerramentaAtiva") ~= "Cortador" or not Profiles.active(p) then ultimaLamina[p] = nil continue end
		-- frente do cortador: um pouco à frente do jogador, no chão
		local frente = root.Position + root.CFrame.LookVector * 2.5
		local agora2 = Vector2.new(frente.X, frente.Z)
		local antes = ultimaLamina[p]
		if not antes or (antes - agora2).Magnitude > 8 then antes = agora2 end
		ultimaLamina[p] = agora2
		local cortados = 0
		local cheio = false
		for _, t in ipairs(tiles) do
			if cortados >= Config.MaxPorTique then break end
			if not t.cortadoEm and distSeg(t.pos, antes, agora2) <= Config.RaioCorte then
				if Economia.CortarGrama(p) then
					Economia.EncherSaco(p, ConfigJogo.GramaPorPlaca * Config.ExtraGrama)
					setCortado(t, true)
					cortados += 1
					TufoDourado.aoCortarFloresta(p, t.part.Position)
				else
					cheio = true
					break
				end
			end
		end
		if cheio then avisar(p, "Saco cheio! Venda na caçamba da fazenda.", "info") end
	end
end)

---------------------------------------------------------------- rebrota
task.spawn(function()
	while true do
		task.wait(1)
		local espera = workspace:GetAttribute("EventoAtual") == "chuva" and Config.RebrotaChuvaSeg or Config.RebrotaSeg
		local agora = os.clock()
		for _, t in ipairs(tiles) do
			if t.cortadoEm and agora - t.cortadoEm >= espera then setCortado(t, false) end
		end
	end
end)

---------------------------------------------------------------- caçamba
local cacamba = fazenda:FindFirstChild("Cacamba")
local prompt = cacamba and cacamba:FindFirstChildWhichIsA("ProximityPrompt", true)
if prompt then
	prompt.Triggered:Connect(function(p)
		local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if not root or (root.Position - prompt.Parent.WorldPosition).Magnitude > 14 then return end
		Economia.Vender(p)
	end)
end

Players.PlayerRemoving:Connect(function(p) ultimaLamina[p] = nil ultimoAviso[p] = nil end)
print(("[Fazenda] PRONTA: %d quadrados de grama"):format(#tiles))
