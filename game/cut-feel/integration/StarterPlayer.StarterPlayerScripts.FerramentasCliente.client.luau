--[[
	StarterPlayerScripts.FerramentasCliente (LocalScript)
	Barra de ferramentas, teclas (1 unha · 2 enxada · 3 foice · 4 carrinho · F/clique golpe),
	botões no celular, animação dos golpes e leitura da POSIÇÃO REAL DA LÂMINA.
	Durante a janela de contato, as posições dos Attachments LaminaBase/LaminaPonta do modelo
	equipado são amostradas a cada frame:
	  • na Área de Teste, elas cortam a máscara (caminho orgânico, mesmo traço da lâmina);
	  • no lote, vão pro servidor, que valida e corta/recompensa.
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Cfg = require(Shared:WaitForChild("FerramentasConfig"))
local Animador = require(script:WaitForChild("Animador"))
local Barra = require(script:WaitForChild("Barra"))
local okSons, Sons = pcall(function() return require(Shared:WaitForChild("Sons", 5)) end)
-- [Claude 2026-11-10] previsão do corte no lote no instante do contato (Shared.LotCutPreview)
local okPrev, Preview = pcall(function() return require(Shared:WaitForChild("LotCutPreview", 5)) end)
if not okPrev then Preview = nil end

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("FerramentasRemotes")

local function modalAberto()
	return player:GetAttribute("MenuJogadorAberto") == true
		or player:GetAttribute("SkillTreeOpen") == true
		or player:GetAttribute("LojaAberta") == true
end

local golpeando = false
local prontoEm = 0

local function ferramentaEquipada(): (Tool?, string?)
	local char = player.Character
	if not char then return nil end
	for _, t in ipairs(char:GetChildren()) do
		if t:IsA("Tool") and t:GetAttribute("FerramentaManual") then return t, t:GetAttribute("Tipo") end
	end
	return nil
end

local function corteProto(poses)
	local cp = player:FindFirstChild("PlayerScripts") and player.PlayerScripts:FindFirstChild("CutPrototypeClient")
	local ev = cp and cp:FindFirstChild("CorteExterno")
	if ev then ev:Fire(poses) end
end

local function aparas(pos: Vector3, n: number)
	for i = 1, n do
		local p = Instance.new("Part")
		p.Size = Vector3.new(0.12, 0.3, 0.12)
		p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = true, false, false, false, false
		p.Color = Color3.fromRGB(120 + math.random(0, 60), 200 + math.random(0, 40), 80)
		p.Material = Enum.Material.SmoothPlastic
		p.CFrame = CFrame.new(pos) * CFrame.Angles(math.random() * 6, math.random() * 6, 0)
		p.Parent = workspace
		local alvo = pos + Vector3.new(math.random(-15, 15) / 10, 1 + math.random() * 1.2, math.random(-15, 15) / 10)
		game:GetService("TweenService"):Create(p, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ CFrame = CFrame.new(alvo) * CFrame.Angles(math.random() * 6, math.random() * 6, 0), Transparency = 1 }):Play()
		game:GetService("Debris"):AddItem(p, 0.5)
	end
end

local function golpear()
	if golpeando or os.clock() < prontoEm or modalAberto() then return end
	local tool, tipo = ferramentaEquipada()
	local cfg = tipo and Cfg.Manuais[tipo]
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not cfg or not hum or hum.Health <= 0 then return end
	local corpo = tool:FindFirstChild("Corpo")
	local aBase = corpo and corpo:FindFirstChild("LaminaBase")
	local aPonta = corpo and corpo:FindFirstChild("LaminaPonta")
	if not aBase or not aPonta then return end

	golpeando = true
	prontoEm = os.clock() + cfg.cooldown
	Animador.tocar(char, tipo)
	remotes.IniciarGolpe:FireServer(tipo)
	local t0 = os.clock()
	local amostras, poses = {}, {}
	local contato = false
	local previa = Preview and Preview.swing(tipo, cfg, Cfg.MultRaridade[tool:GetAttribute("Raridade")] or 1, char)
	local conn
	conn = RunService.PostSimulation:Connect(function()
		local t = os.clock() - t0
		local _, tipoAgora = ferramentaEquipada()
		if player.Character ~= char or tipoAgora ~= tipo or not aBase.Parent then -- trocou/desequipou: cancela sem cortar
			conn:Disconnect()
			Animador.parar(char)
			golpeando = false
			return
		end
		if t >= cfg.janela[1] and t <= cfg.janela[2] then
			local b, p = aBase.WorldPosition, aPonta.WorldPosition
			if not contato then
				contato = true
				-- Server-confirmed vegetation contact supplies sound and particles.
			end
			table.insert(poses, { base = b, ponta = p })
			if previa then previa.sample(b, p) end
			table.insert(amostras, p)
			table.insert(amostras, b:Lerp(p, 0.5))
			if #poses >= 2 then
				corteProto({ poses[#poses - 1], poses[#poses] }) -- corta a zona de teste no mesmo traço
			end
		elseif t > cfg.janela[2] and contato then
			contato = false
			if #poses == 1 then corteProto({ poses[1], poses[1] }) end
			-- no máx. 30 pontos pro servidor
			local env = {}
			local passo = math.max(1, math.ceil(#amostras / 30))
			for i = 1, #amostras, passo do table.insert(env, amostras[i]) end
			remotes.Golpe:FireServer(tipo, env)
			-- Feedback arrives through Contato only after an eligible hit.
		end
		if t >= cfg.duracao then
			conn:Disconnect()
			golpeando = false
		end
	end)
end

remotes:WaitForChild("Contato").OnClientEvent:Connect(function(tipo, pos, hits)
    local cfg = Cfg.Manuais[tipo]
    if not cfg or typeof(pos) ~= "Vector3" or hits <= 0 then return end
    if Preview and Preview.recentToolFeedback() then return end -- som/aparas já tocaram no contato
    if okSons and Sons then pcall(Sons.tocar, cfg.som, {pos = pos, pitch = cfg.somPitch}) end
    aparas(pos, tipo == "CortadorUnha" and 3 or 6)
end)

local barra
local function escolher(slot: number)
	if modalAberto() then return end
	local char = player.Character
	if char then Animador.parar(char) end
	remotes.Equipar:FireServer(slot)
end

barra = Barra.new(player:WaitForChild("PlayerGui"), escolher, function()
	barra:pulsarAcao()
	golpear()
end)
barra:marcar(player:GetAttribute("FerramentaAtiva"))
player:GetAttributeChangedSignal("FerramentaAtiva"):Connect(function()
	barra:marcar(player:GetAttribute("FerramentaAtiva"))
end)
local function atualizarBarra()
	barra:visivel(not modalAberto())
end
for _, nome in ipairs({ "MenuJogadorAberto", "SkillTreeOpen", "LojaAberta" }) do
	player:GetAttributeChangedSignal(nome):Connect(atualizarBarra)
end
atualizarBarra()

local TECLAS = { [Enum.KeyCode.One] = 1, [Enum.KeyCode.Two] = 2, [Enum.KeyCode.Three] = 3, [Enum.KeyCode.Four] = 4 }
UserInputService.InputBegan:Connect(function(input, processado)
	if processado or UserInputService:GetFocusedTextBox() then return end
	local slot = TECLAS[input.KeyCode]
	if slot then escolher(slot) return end
	if input.KeyCode == Enum.KeyCode.F or input.KeyCode == Enum.KeyCode.ButtonX
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		golpear()
	end
end)

-- todo personagem (o seu e os dos outros) anima quando o servidor marca um golpe
local function acompanhar(plr: Player)
	local function noChar(char: Model)
		Animador.observar(char)
		char:GetAttributeChangedSignal("GolpeSeq"):Connect(function()
			local tipo = char:GetAttribute("GolpeTipo")
			if not tipo then return end
			if plr == player and Animador.tocando(char) then return end -- o seu já começou na hora
			Animador.tocar(char, tipo, math.max(0, workspace:GetServerTimeNow() - (char:GetAttribute("GolpeInicio") or workspace:GetServerTimeNow())))
		end)
	end
	if plr.Character then noChar(plr.Character) end
	plr.CharacterAdded:Connect(noChar)
end
for _, p in ipairs(Players:GetPlayers()) do acompanhar(p) end
Players.PlayerAdded:Connect(acompanhar)
player.CharacterAdded:Connect(function() golpeando = false end)


-- VehicleSeat supplies keyboard, gamepad and mobile steering. Server validates
-- occupant, ownership, packet rate and control bounds before applying movement.
local keys = {}
local stick = Vector2.zero
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and not UserInputService:GetFocusedTextBox() then keys[input.KeyCode] = true end
end)
UserInputService.InputEnded:Connect(function(input) keys[input.KeyCode] = nil end)
UserInputService.InputChanged:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Thumbstick1 then stick = Vector2.new(input.Position.X,input.Position.Y) end
end)
UserInputService.WindowFocusReleased:Connect(function() table.clear(keys) stick = Vector2.zero end)
local driveElapsed = 0
RunService.Heartbeat:Connect(function(dt)
    driveElapsed += dt
    if driveElapsed < 0.1 then return end
    driveElapsed = 0
    local char = player.Character
    local tool = char and char:FindFirstChild("MowerTool")
    local remote = tool and tool:FindFirstChild("ControleVeiculo")
    local seat = tool and tool:FindFirstChildWhichIsA("VehicleSeat", true)
    if remote and seat and seat.Occupant == char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local localMove = seat.CFrame:VectorToObjectSpace(hum.MoveDirection)
        local keyboardForward = (keys[Enum.KeyCode.W] and 1 or 0) - (keys[Enum.KeyCode.S] and 1 or 0)
        local keyboardSteer = (keys[Enum.KeyCode.D] and 1 or 0) - (keys[Enum.KeyCode.A] and 1 or 0)
        local move = Vector3.new(math.abs(keyboardSteer) > 0 and keyboardSteer or (math.abs(stick.X) > .15 and stick.X or localMove.X), 0, math.abs(keyboardForward) > 0 and -keyboardForward or (math.abs(stick.Y) > .15 and -stick.Y or localMove.Z))
        local forward = math.abs(seat.ThrottleFloat) > 0.01 and seat.ThrottleFloat or -move.Z
        local steering = math.abs(seat.SteerFloat) > 0.01 and seat.SteerFloat or move.X
        remote:FireServer(forward, steering)
        if math.abs(forward) > 0.05 then
            local gameRemotes = ReplicatedStorage:FindFirstChild("GameRemotes")
            if gameRemotes then gameRemotes.CutIntent:FireServer() end
        end
    end
end)
