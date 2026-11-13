--[[
	StarterPlayerScripts.RecompensasCliente  [Claude 2026-11-11]
	  * botão "🎁 Prêmios" (canto direito) com bolinha vermelha quando há algo para pegar
	  * painel: prêmio diário (7 dias), prêmios por tempo jogado e campo de código
	  * grama dourada: brilho nos tufos dourados do lote e explosão dourada + "+N moedas" quando alguém corta um
	Só pedidos ao servidor (RecompensasAcao) e efeitos visuais; valores e validação ficam no servidor.
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local remote = RS:WaitForChild("RecompensasAcao")
local fxRemote = RS:WaitForChild("TufoDouradoFX")
local okSons, Sons = pcall(function() return require(RS:WaitForChild("Shared"):WaitForChild("Sons")) end)
local function som(nome, pos) if okSons and Sons then pcall(Sons.tocar, nome, { pos = pos }) end end

local TINTA = Color3.fromRGB(52, 44, 38)
local PAPEL = Color3.fromRGB(255, 246, 214)
local VERDE = Color3.fromRGB(96, 196, 104)
local OURO = Color3.fromRGB(255, 200, 60)
local CINZA = Color3.fromRGB(176, 166, 146)

local function inst(classe, props, filhos)
	local o = Instance.new(classe)
	for k, v in pairs(props) do if k ~= "Parent" then o[k] = v end end
	for _, f in ipairs(filhos or {}) do f.Parent = o end
	if props.Parent then o.Parent = props.Parent end
	return o
end
local function canto(r) return inst("UICorner", { CornerRadius = UDim.new(0, r) }) end
local function borda(t, c) return inst("UIStroke", { Thickness = t, Color = c or TINTA, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }) end
local function rotulo(props)
	if props.BackgroundTransparency == nil then props.BackgroundTransparency = 1 end
	props.TextColor3 = props.TextColor3 or TINTA
	props.Font = props.Font or Enum.Font.GothamBold
	return inst("TextLabel", props)
end
local function botao(texto, cor, props)
	props.Text = texto
	props.BackgroundColor3 = cor
	props.AutoButtonColor = true
	props.Font = props.Font or Enum.Font.FredokaOne
	props.TextColor3 = Color3.new(1, 1, 1)
	props.TextStrokeColor3 = TINTA
	props.TextStrokeTransparency = 0.3
	return inst("TextButton", props, { canto(12), borda(3) })
end

---------------------------------------------------------------- botão no HUD (Claude 2026-11-12: HudKit, mesmo estilo e grade da HUD original)
local HudKit = require(RS:WaitForChild("Shared"):WaitForChild("HudKit"))
local abrir, hudApi = HudKit.botao({ nome = "Premios", rotulo = "Prêmios", icone = "🎁", c1 = HudKit.C.Vermelho1, c2 = HudKit.C.Vermelho2, ordem = 1, lado = "direita" })

---------------------------------------------------------------- painel
local gui = inst("ScreenGui", { Name = "PremiosGui", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 30, Enabled = false, Parent = player.PlayerGui })
local fundo = inst("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, Parent = gui })
local painel = inst("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(720, 450), BackgroundColor3 = PAPEL, Parent = gui },
	{ canto(22), borda(4) })
local escala = inst("UIScale", { Parent = painel })
local function ajustarEscala()
	local cam = workspace.CurrentCamera
	local v = cam and cam.ViewportSize or Vector2.new(1280, 720)
	escala.Scale = math.clamp(math.min(v.X / 760, v.Y / 500), 0.45, 1)
end
ajustarEscala()

rotulo({ Text = "🎁 PRÊMIOS", Font = Enum.Font.FredokaOne, TextSize = 30, Size = UDim2.new(1, -80, 0, 40), Position = UDim2.fromOffset(20, 10),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })
local fechar = botao("X", Color3.fromRGB(232, 84, 72), { Size = UDim2.fromOffset(44, 44), Position = UDim2.new(1, -58, 0, 14), TextSize = 24, Parent = painel })

-- diária
rotulo({ Text = "Prêmio diário", Font = Enum.Font.FredokaOne, TextSize = 22, Size = UDim2.new(1, -40, 0, 26), Position = UDim2.fromOffset(20, 58),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })
local seqTexto = rotulo({ Text = "", TextSize = 14, Size = UDim2.new(1, -40, 0, 18), Position = UDim2.fromOffset(20, 84), TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = Color3.fromRGB(110, 96, 74), Parent = painel })
local linhaDias = inst("Frame", { Size = UDim2.new(1, -40, 0, 84), Position = UDim2.fromOffset(20, 106), BackgroundTransparency = 1, Parent = painel },
	{ inst("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
local cartaoDia = {}
for i = 1, 7 do
	local c = inst("Frame", { LayoutOrder = i, Size = UDim2.fromOffset(84, 84), BackgroundColor3 = Color3.fromRGB(255, 252, 240), Parent = linhaDias }, { canto(12) })
	local b = borda(3) b.Parent = c
	rotulo({ Text = "Dia " .. i, Font = Enum.Font.FredokaOne, TextSize = 16, Size = UDim2.new(1, 0, 0, 22), Position = UDim2.fromOffset(0, 4), Parent = c })
	rotulo({ Text = i == 7 and "🏆" or "💰", TextSize = 24, Size = UDim2.new(1, 0, 0, 28), Position = UDim2.fromOffset(0, 26), Parent = c })
	local v = rotulo({ Text = "", TextSize = 13, Size = UDim2.new(1, 0, 0, 18), Position = UDim2.fromOffset(0, 60), Parent = c })
	cartaoDia[i] = { frame = c, borda = b, valor = v }
end
local btDiaria = botao("PEGAR PRÊMIO DE HOJE", VERDE, { Size = UDim2.fromOffset(260, 40), Position = UDim2.fromOffset(20, 198), TextSize = 18, Parent = painel })

-- tempo jogado
rotulo({ Text = "Tempo jogando agora", Font = Enum.Font.FredokaOne, TextSize = 22, Size = UDim2.new(1, -40, 0, 26), Position = UDim2.fromOffset(20, 250),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })
local minTexto = rotulo({ Text = "", TextSize = 14, Size = UDim2.new(0, 300, 0, 18), Position = UDim2.new(1, -320, 0, 256), TextXAlignment = Enum.TextXAlignment.Right,
	TextColor3 = Color3.fromRGB(110, 96, 74), Parent = painel })
local linhaTempo = inst("Frame", { Size = UDim2.new(1, -40, 0, 70), Position = UDim2.fromOffset(20, 280), BackgroundTransparency = 1, Parent = painel },
	{ inst("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }) })
local cartaoTempo = {}
for i = 1, 4 do
	local b = botao("", CINZA, { LayoutOrder = i, Size = UDim2.fromOffset(160, 64), TextSize = 16, TextWrapped = true, Parent = linhaTempo })
	cartaoTempo[i] = b
end

-- códigos
rotulo({ Text = "Código", Font = Enum.Font.FredokaOne, TextSize = 22, Size = UDim2.fromOffset(100, 26), Position = UDim2.fromOffset(20, 368),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })
local caixa = inst("TextBox", { PlaceholderText = "Digite um código", Text = "", ClearTextOnFocus = false, Font = Enum.Font.GothamBold, TextSize = 18,
	TextColor3 = TINTA, BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromOffset(300, 40), Position = UDim2.fromOffset(110, 362), Parent = painel },
	{ canto(10), borda(3) })
local btCodigo = botao("RESGATAR", OURO, { Size = UDim2.fromOffset(140, 40), Position = UDim2.fromOffset(422, 362), TextSize = 18, Parent = painel })
local mensagem = rotulo({ Text = "", TextSize = 15, Size = UDim2.new(1, -40, 0, 22), Position = UDim2.new(0, 20, 1, -34), TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })

---------------------------------------------------------------- aviso de progresso offline
local avisoGui = inst("ScreenGui", { Name = "OfflineAviso", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 35, Enabled = false, Parent = player.PlayerGui })
local avisoCard = inst("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.45), Size = UDim2.fromOffset(460, 230), BackgroundColor3 = PAPEL, Parent = avisoGui },
	{ canto(22), borda(4) })
local avisoEscala = inst("UIScale", { Parent = avisoCard })
rotulo({ Text = "🌱 Bem-vindo de volta!", Font = Enum.Font.FredokaOne, TextSize = 30, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.fromOffset(0, 16), Parent = avisoCard })
local avisoTexto = rotulo({ Text = "", TextSize = 17, TextWrapped = true, Size = UDim2.new(1, -40, 0, 70), Position = UDim2.fromOffset(20, 62), Parent = avisoCard })
local avisoMoedas = rotulo({ Text = "", Font = Enum.Font.FredokaOne, TextSize = 32, TextColor3 = Color3.fromRGB(214, 150, 20), TextStrokeColor3 = TINTA,
	TextStrokeTransparency = 0.5, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.fromOffset(0, 128), Parent = avisoCard })
local avisoOk = botao("COLETAR", VERDE, { AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.fromOffset(180, 42), Position = UDim2.new(0.5, 0, 1, -56), TextSize = 20, Parent = avisoCard })
avisoOk.Activated:Connect(function() avisoGui.Enabled = false som("Moeda") end)
local function mostrarOffline(o)
	if type(o) ~= "table" then return end
	local h, m = math.floor(o.minutos / 60), o.minutos % 60
	local tempo = h > 0 and ("%dh %02dmin"):format(h, m) or ("%d min"):format(m)
	avisoTexto.Text = ("Enquanto você esteve fora (%s), o seu jardim continuou rendendo.%s"):format(tempo, o.limite and " (máximo de 4 h)" or "")
	avisoMoedas.Text = ("+%d moedas"):format(o.moedas)
	avisoGui.Enabled = true
	avisoEscala.Scale = 0.4
	TweenService:Create(avisoEscala, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end

---------------------------------------------------------------- estado
local estadoAtual = nil
local ocupado = false

local function msg(t, erro)
	mensagem.Text = t or ""
	mensagem.TextColor3 = erro and Color3.fromRGB(196, 60, 48) or Color3.fromRGB(70, 130, 70)
end

local function desenhar()
	local e = estadoAtual
	if not e then return end
	local d = e.diaria
	seqTexto.Text = d.pode and ("Sequência: %d dia(s). Pegue hoje para ir ao dia %d!"):format(d.sequencia, d.proxima)
		or ("Sequência: %d dia(s). Volte amanhã para continuar!"):format(d.sequencia)
	for i, c in ipairs(cartaoDia) do
		c.valor.Text = "+" .. tostring(d.valores[i] or 0)
		local atual = i == d.indice
		c.borda.Color = atual and (d.pode and OURO or VERDE) or TINTA
		c.borda.Thickness = atual and 5 or 3
		c.frame.BackgroundColor3 = atual and Color3.fromRGB(255, 240, 190) or Color3.fromRGB(255, 252, 240)
	end
	btDiaria.Text = d.pode and "PEGAR PRÊMIO DE HOJE" or "VOLTE AMANHÃ"
	btDiaria.BackgroundColor3 = d.pode and VERDE or CINZA
	minTexto.Text = ("Nesta sessão: %d min"):format(math.floor(e.minutos))
	local algo = d.pode
	for i, t in ipairs(e.tempo) do
		local b = cartaoTempo[i]
		if t.coletado then
			b.Text = ("%d min\n✔ pego"):format(t.minutos)
			b.BackgroundColor3 = CINZA
		elseif e.minutos >= t.minutos then
			b.Text = ("%d min\nPEGAR +%d"):format(t.minutos, t.moedas)
			b.BackgroundColor3 = VERDE
			algo = true
		else
			b.Text = ("%d min\n+%d (faltam %d)"):format(t.minutos, t.moedas, math.ceil(t.minutos - e.minutos))
			b.BackgroundColor3 = CINZA
		end
	end
	hudApi.badge(algo and "!" or nil)
end

local function pedir(acao, arg)
	if ocupado then return end
	ocupado = true
	local ok, r = pcall(function() return remote:InvokeServer(acao, arg) end)
	ocupado = false
	if not ok or type(r) ~= "table" then msg("Não deu certo. Tente de novo.", true) return end
	if r.estado then estadoAtual = r.estado mostrarOffline(r.estado.offline) end
	if r.ok then
		msg(("+%d moedas!"):format(r.ok), false)
		som("Moeda")
	elseif r.erro then
		msg(r.erro, true)
	end
	desenhar()
	return r
end

btDiaria.Activated:Connect(function() pedir("diaria") end)
for i, b in ipairs(cartaoTempo) do b.Activated:Connect(function() pedir("tempo", i) end) end
local function resgatar()
	local r = pedir("codigo", caixa.Text)
	if r and r.ok then caixa.Text = "" end
end
btCodigo.Activated:Connect(resgatar)
caixa.FocusLost:Connect(function(enter) if enter then resgatar() end end)

local function definirAberto(v) player:SetAttribute("PremiosAberto", v) end
player:GetAttributeChangedSignal("PremiosAberto"):Connect(function()
	local aberto = player:GetAttribute("PremiosAberto") == true
	gui.Enabled = aberto
	if aberto then
		ajustarEscala()
		msg("")
		task.spawn(pedir, "estado")
	end
end)
abrir.Activated:Connect(function() definirAberto(not player:GetAttribute("PremiosAberto")) end)
fechar.Activated:Connect(function() definirAberto(false) end)
fundo.Activated:Connect(function() definirAberto(false) end)
UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Escape and player:GetAttribute("PremiosAberto") then definirAberto(false) end
end)
for _, nome in ipairs({ "LojaAberta", "MenuJogadorAberto", "SkillTreeOpen", "ForestShopOpen", "PetsAberto", "MissoesAberto", "FamaAberto", "OficinaAberta", "AlbumAberto" }) do
	player:GetAttributeChangedSignal(nome):Connect(function() if player:GetAttribute(nome) then definirAberto(false) end end)
end

-- atualiza a bolinha e o tempo de tempos em tempos
task.spawn(function()
	repeat task.wait(1) until player:GetAttribute("ProfileReady")
	while true do
		local ok, r = pcall(function() return remote:InvokeServer("estado") end)
		if ok and type(r) == "table" and r.estado then estadoAtual = r.estado mostrarOffline(r.estado.offline) desenhar() end
		task.wait(gui.Enabled and 5 or 30)
	end
end)

---------------------------------------------------------------- grama dourada
local BRILHO = "rbxasset://textures/particles/sparkles_main.dds"
local function brilhoNoTile(tile)
	if tile:FindFirstChild("BrilhoDourado") then return end
	local a = Instance.new("Attachment")
	a.Name = "BrilhoDourado"
	a.Position = Vector3.new(0, 1, 0)
	a.Parent = tile
	local e = Instance.new("ParticleEmitter")
	e.Texture = BRILHO
	e.Color = ColorSequence.new(OURO)
	e.LightEmission = 1
	e.LightInfluence = 0
	e.Brightness = 3
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(0.5, 0.55), NumberSequenceKeypoint.new(1, 0) })
	e.Lifetime = NumberRange.new(0.8, 1.4)
	e.Rate = 9
	e.Speed = NumberRange.new(0.6, 1.6)
	e.SpreadAngle = Vector2.new(40, 40)
	e.EmissionDirection = Enum.NormalId.Top
	e.Parent = a
	local luz = Instance.new("PointLight")
	luz.Color = OURO luz.Brightness = 1.2 luz.Range = 7
	luz.Parent = a
	-- tom dourado local na grama do tufo
	if tile:IsA("BasePart") then
		a:SetAttribute("CorOriginal", tile.Color)
		tile.Color = Color3.fromRGB(240, 196, 64)
	end
end
local function tirarBrilho(tile)
	local a = tile:FindFirstChild("BrilhoDourado")
	if a then
		local cor = a:GetAttribute("CorOriginal")
		if cor and tile:IsA("BasePart") then tile.Color = cor end
		a:Destroy()
	end
end
local function vigiarTile(tile)
	if not tile:IsA("BasePart") then return end
	local function atualizar()
		if tile:GetAttribute("Dourado") then brilhoNoTile(tile) else tirarBrilho(tile) end
	end
	tile:GetAttributeChangedSignal("Dourado"):Connect(atualizar)
	atualizar()
end
local function vigiarLotes()
	local mundo = workspace:WaitForChild("GameWorld", 60)
	local plots = mundo and mundo:WaitForChild("Plots", 60)
	if not plots then return end
	local function plot(p)
		local gv = p:WaitForChild("GrassVisuals", 30)
		if not gv then return end
		for _, t in ipairs(gv:GetChildren()) do vigiarTile(t) end
		gv.ChildAdded:Connect(vigiarTile)
	end
	for _, p in ipairs(plots:GetChildren()) do task.spawn(plot, p) end
	plots.ChildAdded:Connect(function(p) task.spawn(plot, p) end)
end
task.spawn(vigiarLotes)

-- explosão dourada + texto flutuante "+N"
local fxPasta = Instance.new("Folder") fxPasta.Name = "DouradoFX_Local" fxPasta.Parent = workspace
fxRemote.OnClientEvent:Connect(function(quem, pos, moedas)
	if typeof(pos) ~= "Vector3" then return end
	local cam = workspace.CurrentCamera
	if cam and (cam.CFrame.Position - pos).Magnitude > 200 then return end
	local p = Instance.new("Part")
	p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.Transparency, p.Size = true, false, false, false, 1, Vector3.one
	p.CFrame = CFrame.new(pos + Vector3.new(0, 1.5, 0))
	p.Parent = fxPasta
	local e = Instance.new("ParticleEmitter")
	e.Texture = BRILHO
	e.Color = ColorSequence.new(OURO)
	e.LightEmission = 1 e.LightInfluence = 0 e.Brightness = 4
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0) })
	e.Lifetime = NumberRange.new(0.8, 1.4)
	e.Speed = NumberRange.new(10, 18)
	e.SpreadAngle = Vector2.new(60, 60)
	e.Acceleration = Vector3.new(0, -26, 0)
	e.EmissionDirection = Enum.NormalId.Top
	e.Rate = 0
	e.Parent = p
	e:Emit(40)
	if quem == player then
		som("Desbloqueio", pos)
		local b = Instance.new("BillboardGui")
		b.Size = UDim2.fromOffset(260, 60) b.StudsOffset = Vector3.new(0, 2, 0) b.AlwaysOnTop = false b.LightInfluence = 0 b.MaxDistance = 120
		b.Adornee = p
		local t = rotulo({ Text = ("✨ TUFO DOURADO! +%d"):format(moedas or 0), Font = Enum.Font.FredokaOne, TextSize = 28, TextColor3 = OURO,
			TextStrokeColor3 = TINTA, TextStrokeTransparency = 0, Size = UDim2.fromScale(1, 1), Parent = b })
		b.Parent = p
		TweenService:Create(b, TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { StudsOffset = Vector3.new(0, 6, 0) }):Play()
		TweenService:Create(t, TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	end
	game:GetService("Debris"):AddItem(p, 2.5)
end)
