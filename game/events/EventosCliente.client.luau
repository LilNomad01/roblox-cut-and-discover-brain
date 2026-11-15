--[[
	StarterPlayerScripts.EventosCliente  [Claude 2026-11-12]
	Clima e eventos do servidor (PAD-06), só visual:
	  * faixa no alto da tela com ícone, nome, o que o evento faz e o tempo que falta
	  * chuva (gotas em volta da câmera) ou brilho dourado no ar, conforme EventosConfig.efeito
	Lê os atributos EventoAtual/EventoFim do Workspace; não muda iluminação (a transição Vila→Floresta cuida dela).
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Config = require(RS:WaitForChild("Shared"):WaitForChild("EventosConfig"))
local player = Players.LocalPlayer
local okSons, Sons = pcall(function() return require(RS.Shared:WaitForChild("Sons")) end)
local function som(nome) if okSons and Sons then pcall(Sons.tocar, nome, {}) end end

local TINTA = Color3.fromRGB(52, 44, 38)

local function inst(classe, props, filhos)
	local o = Instance.new(classe)
	for k, v in pairs(props) do if k ~= "Parent" then o[k] = v end end
	for _, f in ipairs(filhos or {}) do f.Parent = o end
	if props.Parent then o.Parent = props.Parent end
	return o
end

---------------------------------------------------------------- faixa
local gui = inst("ScreenGui", { Name = "EventoFaixa", ResetOnSpawn = false, DisplayOrder = 6, Enabled = false, Parent = player:WaitForChild("PlayerGui") })
local faixa = inst("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 84), Size = UDim2.fromOffset(440, 62),
	BackgroundColor3 = Color3.fromRGB(86, 156, 226), Parent = gui },
	{ inst("UICorner", { CornerRadius = UDim.new(0, 16) }), inst("UIStroke", { Thickness = 3, Color = TINTA, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }) })
local escala = inst("UIScale", { Parent = faixa })
local titulo = inst("TextLabel", { BackgroundTransparency = 1, Font = Enum.Font.FredokaOne, TextSize = 22, TextColor3 = Color3.new(1, 1, 1),
	TextStrokeColor3 = TINTA, TextStrokeTransparency = 0.2, TextXAlignment = Enum.TextXAlignment.Left,
	Size = UDim2.new(1, -110, 0, 28), Position = UDim2.fromOffset(14, 4), Text = "", Parent = faixa })
local texto = inst("TextLabel", { BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.new(1, 1, 1),
	TextStrokeColor3 = TINTA, TextStrokeTransparency = 0.5, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
	Size = UDim2.new(1, -110, 0, 26), Position = UDim2.fromOffset(14, 32), Text = "", Parent = faixa })
local relogio = inst("TextLabel", { BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.15, Font = Enum.Font.FredokaOne, TextSize = 22,
	TextColor3 = TINTA, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(86, 40), Text = "", Parent = faixa },
	{ inst("UICorner", { CornerRadius = UDim.new(0, 12) }) })

local function ajustarEscala()
	local cam = workspace.CurrentCamera
	local v = cam and cam.ViewportSize or Vector2.new(1280, 720)
	escala.Scale = math.clamp(math.min(v.X / 1000, v.Y / 640), 0.55, 1)
end

---------------------------------------------------------------- efeitos em volta da câmera
local caixa = inst("Part", { Name = "EventoClima", Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, Transparency = 1,
	Size = Vector3.new(70, 1, 70) })
local chuva = inst("ParticleEmitter", { Name = "Chuva", Enabled = false, Texture = "rbxasset://textures/particles/sparkles_main.dds",
	Rate = 420, Lifetime = NumberRange.new(0.9, 1.1), Speed = NumberRange.new(70, 80), EmissionDirection = Enum.NormalId.Bottom,
	Size = NumberSequence.new(0.14), Squash = NumberSequence.new(-2.5), Orientation = Enum.ParticleOrientation.VelocityParallel,
	Color = ColorSequence.new(Color3.fromRGB(190, 220, 255)), Transparency = NumberSequence.new(0.35), LightEmission = 0.2, Parent = caixa })
local brilho = inst("ParticleEmitter", { Name = "Brilho", Enabled = false, Texture = "rbxasset://textures/particles/sparkles_main.dds",
	Rate = 60, Lifetime = NumberRange.new(4, 6), Speed = NumberRange.new(2, 5), EmissionDirection = Enum.NormalId.Bottom, SpreadAngle = Vector2.new(60, 60),
	Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.2, 0.45), NumberSequenceKeypoint.new(1, 0) }),
	Color = ColorSequence.new(Color3.fromRGB(255, 214, 80)), LightEmission = 1, Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-60, 60),
	Parent = caixa })
local conexao = nil

local function efeito(tipo)
	chuva.Enabled = tipo == "chuva"
	brilho.Enabled = tipo == "brilho"
	if tipo and not conexao then
		caixa.Parent = workspace
		conexao = RunService.RenderStepped:Connect(function()
			local cam = workspace.CurrentCamera
			if cam then
				local p = cam.CFrame.Position
				caixa.CFrame = CFrame.new(p.X, p.Y + (tipo == "chuva" and 30 or 14), p.Z)
			end
		end)
	elseif not tipo and conexao then
		conexao:Disconnect()
		conexao = nil
		caixa.Parent = nil
	end
end

---------------------------------------------------------------- estado
local atual = nil
local function atualizar()
	local id = workspace:GetAttribute("EventoAtual")
	local ev = type(id) == "string" and Config.porId(id) or nil
	if ev == atual then return end
	atual = ev
	if not ev then
		gui.Enabled = false
		efeito(nil)
		return
	end
	faixa.BackgroundColor3 = ev.cor
	titulo.Text = ev.icone .. " " .. ev.nome
	texto.Text = ev.texto
	ajustarEscala()
	gui.Enabled = true
	escala.Scale *= 0.5
	TweenService:Create(escala, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = escala.Scale * 2 }):Play()
	efeito(ev.efeito)
	som("Desbloqueio")
end
workspace:GetAttributeChangedSignal("EventoAtual"):Connect(atualizar)
atualizar()

task.spawn(function()
	while true do
		if atual then
			local resta = math.max(0, (workspace:GetAttribute("EventoFim") or 0) - workspace:GetServerTimeNow())
			relogio.Text = ("%d:%02d"):format(math.floor(resta / 60), math.floor(resta % 60))
		end
		task.wait(0.5)
	end
end)
