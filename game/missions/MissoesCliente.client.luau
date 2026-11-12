--[[
	StarterPlayerScripts.MissoesCliente  [Claude 2026-11-12]
	Quadro do Jardineiro (PAD-05): botão "📋 Missões" no HUD (bolinha com o número de missões prontas),
	painel com as 3 trilhas, barra de progresso e botão COLETAR, e o rank com o bônus permanente.
	Também abre pelo quadro físico do lobby (Workspace.GameWorld.Lobby.QuadroMissoes, prompt E).
	Só pede ao servidor (MissoesAcao); contas e validação ficam no servidor.
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local remote = RS:WaitForChild("MissoesAcao")
local okSons, Sons = pcall(function() return require(RS:WaitForChild("Shared"):WaitForChild("Sons")) end)
local function som(nome) if okSons and Sons then pcall(Sons.tocar, nome, {}) end end

local TINTA = Color3.fromRGB(52, 44, 38)
local PAPEL = Color3.fromRGB(255, 246, 214)
local VERDE = Color3.fromRGB(96, 196, 104)
local OURO = Color3.fromRGB(255, 200, 60)
local AZUL = Color3.fromRGB(86, 156, 226)
local CINZA = Color3.fromRGB(176, 166, 146)
local MARROM = Color3.fromRGB(110, 96, 74)

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
local function fmt(n)
	local s = tostring(math.floor(n))
	local r = s:reverse():gsub("(%d%d%d)", "%1."):reverse()
	return (r:gsub("^%.", ""))
end

---------------------------------------------------------------- botão no HUD (à esquerda de "🎁 Prêmios", na mesma linha)
local hud = inst("ScreenGui", { Name = "MissoesBotao", ResetOnSpawn = false, DisplayOrder = 5, Parent = player:WaitForChild("PlayerGui") })
local abrir = botao("📋 Missões", AZUL, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -178, 0, 330), Size = UDim2.fromOffset(150, 50), TextSize = 22, Parent = hud })
local ponto = inst("Frame", { Size = UDim2.fromOffset(22, 22), Position = UDim2.new(1, -12, 0, -10), BackgroundColor3 = Color3.fromRGB(232, 64, 56), Visible = false, Parent = abrir },
	{ canto(11), borda(2, Color3.new(1, 1, 1)) })
local pontoTexto = rotulo({ Text = "", TextSize = 13, TextColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1), Parent = ponto })

---------------------------------------------------------------- painel
local gui = inst("ScreenGui", { Name = "MissoesGui", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 30, Enabled = false, Parent = player.PlayerGui })
local fundo = inst("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, Parent = gui })
local painel = inst("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(720, 470), BackgroundColor3 = PAPEL, Parent = gui },
	{ canto(22), borda(4) })
local escala = inst("UIScale", { Parent = painel })
local function ajustarEscala()
	local cam = workspace.CurrentCamera
	local v = cam and cam.ViewportSize or Vector2.new(1280, 720)
	escala.Scale = math.clamp(math.min(v.X / 760, v.Y / 520), 0.45, 1)
end
ajustarEscala()

rotulo({ Text = "📋 QUADRO DO JARDINEIRO", Font = Enum.Font.FredokaOne, TextSize = 30, Size = UDim2.new(1, -80, 0, 40), Position = UDim2.fromOffset(20, 10),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })
local fechar = botao("X", Color3.fromRGB(232, 84, 72), { Size = UDim2.fromOffset(44, 44), Position = UDim2.new(1, -58, 0, 14), TextSize = 24, Parent = painel })

-- rank
local caixaRank = inst("Frame", { Size = UDim2.new(1, -40, 0, 74), Position = UDim2.fromOffset(20, 60), BackgroundColor3 = Color3.fromRGB(255, 236, 170), Parent = painel },
	{ canto(14), borda(3) })
local rankNome = rotulo({ Text = "", Font = Enum.Font.FredokaOne, TextSize = 22, Size = UDim2.new(0.6, 0, 0, 28), Position = UDim2.fromOffset(14, 6),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = caixaRank })
local rankBonus = rotulo({ Text = "", TextSize = 15, TextColor3 = Color3.fromRGB(60, 130, 60), Size = UDim2.new(0.4, -14, 0, 28), Position = UDim2.new(0.6, 0, 0, 6),
	TextXAlignment = Enum.TextXAlignment.Right, Parent = caixaRank })
local barraRank = inst("Frame", { Size = UDim2.new(1, -28, 0, 22), Position = UDim2.fromOffset(14, 40), BackgroundColor3 = Color3.fromRGB(235, 222, 190), Parent = caixaRank },
	{ canto(11), borda(2) })
local encherRank = inst("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = OURO, Parent = barraRank }, { canto(11) })
local textoRank = rotulo({ Text = "", TextSize = 13, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = barraRank })

-- 3 cartões
local linha = inst("Frame", { Size = UDim2.new(1, -40, 0, 270), Position = UDim2.fromOffset(20, 146), BackgroundTransparency = 1, Parent = painel },
	{ inst("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder }) })
local cartoes = {}
for k = 1, 3 do
	local c = inst("Frame", { LayoutOrder = k, Size = UDim2.fromOffset(217, 270), BackgroundColor3 = Color3.fromRGB(255, 252, 240), Parent = linha }, { canto(16) })
	local b = borda(3) b.Parent = c
	local titulo = rotulo({ Text = "", Font = Enum.Font.FredokaOne, TextSize = 22, Size = UDim2.new(1, -16, 0, 28), Position = UDim2.fromOffset(8, 8), Parent = c })
	local etapa = rotulo({ Text = "", TextSize = 12, TextColor3 = MARROM, Size = UDim2.new(1, -16, 0, 16), Position = UDim2.fromOffset(8, 36), Parent = c })
	local texto = rotulo({ Text = "", TextSize = 17, TextWrapped = true, Size = UDim2.new(1, -20, 0, 64), Position = UDim2.fromOffset(10, 58), Parent = c })
	local barra = inst("Frame", { Size = UDim2.new(1, -24, 0, 24), Position = UDim2.fromOffset(12, 128), BackgroundColor3 = Color3.fromRGB(235, 222, 190), Parent = c },
		{ canto(12), borda(2) })
	local encher = inst("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = VERDE, Parent = barra }, { canto(12) })
	local num = rotulo({ Text = "", TextSize = 13, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = barra })
	local premio = rotulo({ Text = "", TextSize = 14, TextWrapped = true, TextColor3 = Color3.fromRGB(170, 116, 10), Size = UDim2.new(1, -16, 0, 40), Position = UDim2.fromOffset(8, 160), Parent = c })
	local bt = botao("COLETAR", VERDE, { Size = UDim2.new(1, -24, 0, 44), Position = UDim2.new(0, 12, 1, -56), TextSize = 20, Parent = c })
	cartoes[k] = { frame = c, borda = b, titulo = titulo, etapa = etapa, texto = texto, encher = encher, num = num, premio = premio, bt = bt }
end
local mensagem = rotulo({ Text = "", TextSize = 15, Size = UDim2.new(1, -40, 0, 22), Position = UDim2.new(0, 20, 1, -38), TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })

---------------------------------------------------------------- estado
local estadoAtual = nil
local ocupado = false

local function msg(t, erro)
	mensagem.Text = t or ""
	mensagem.TextColor3 = erro and Color3.fromRGB(200, 60, 50) or Color3.fromRGB(60, 140, 60)
end

local function desenhar()
	local e = estadoAtual
	if not e then return end
	rankNome.Text = ("🏅 %s  ·  %d selos"):format(e.nomeRank, e.selos)
	if e.rankMax then
		rankBonus.Text = ("Grama +%d%% para sempre (máximo)"):format(math.floor(e.bonus * 100 + 0.5))
		encherRank.Size = UDim2.fromScale(1, 1)
		textoRank.Text = "Rank máximo!"
	else
		rankBonus.Text = ("Grama +%d%% para sempre"):format(math.floor(e.bonus * 100 + 0.5))
		encherRank.Size = UDim2.fromScale(e.selosNoRank / e.selosPorRank, 1)
		textoRank.Text = ("%d/%d selos para %s (+%d%%)"):format(e.selosNoRank, e.selosPorRank, e.proximoRank, math.floor(e.bonusProximo * 100 + 0.5))
	end
	for k, c in ipairs(cartoes) do
		local m = e.missoes[k]
		if m then
			local pronta = m.progresso >= m.alvo
			c.titulo.Text = m.icone .. " " .. m.nome
			c.etapa.Text = ("Missão %d de %d  ·  Ciclo %d"):format(m.etapa, m.etapas, m.ciclo + 1)
			c.texto.Text = m.texto
			c.encher.Size = UDim2.fromScale(math.clamp(m.progresso / m.alvo, 0, 1), 1)
			c.num.Text = ("%s / %s"):format(fmt(m.progresso), fmt(m.alvo))
			c.premio.Text = ("Prêmio: 💰 %s  ·  ⭐ %d XP  ·  1 selo"):format(fmt(m.moedas), m.xp)
			c.bt.Text = pronta and "COLETAR" or "EM ANDAMENTO"
			c.bt.BackgroundColor3 = pronta and VERDE or CINZA
			c.bt.AutoButtonColor = pronta
			c.borda.Color = pronta and Color3.fromRGB(60, 160, 70) or TINTA
			c.borda.Thickness = pronta and 4 or 3
		end
	end
end

local function pedir(acao, arg)
	if ocupado then return end
	ocupado = true
	local ok, r = pcall(function() return remote:InvokeServer(acao, arg) end)
	ocupado = false
	if not ok or type(r) ~= "table" then msg("Não deu certo agora. Tente de novo.", true) return end
	if r.estado then estadoAtual = r.estado desenhar() end
	if r.erro then msg(r.erro, true) som("Erro") return end
	if r.ok then
		msg(r.subiu and ("🏅 Novo rank: %s!"):format(estadoAtual.nomeRank) or ("+%s moedas e 1 selo!"):format(fmt(r.ok)))
		som(r.subiu and "Desbloqueio" or "Moeda")
		local alvo = cartoes[arg]
		if alvo then
			local s = inst("UIScale", { Scale = 1.08, Parent = alvo.frame })
			TweenService:Create(s, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
			task.delay(0.35, function() s:Destroy() end)
		end
	end
end

for k, c in ipairs(cartoes) do
	c.bt.Activated:Connect(function()
		local m = estadoAtual and estadoAtual.missoes[k]
		if m and m.progresso >= m.alvo then pedir("coletar", k) end
	end)
end

local function definirAberto(v) player:SetAttribute("MissoesAberto", v) end
player:GetAttributeChangedSignal("MissoesAberto"):Connect(function()
	local aberto = player:GetAttribute("MissoesAberto") == true
	gui.Enabled = aberto
	if aberto then
		ajustarEscala()
		msg("")
		painel.Position = UDim2.fromScale(0.5, 0.55)
		TweenService:Create(painel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Position = UDim2.fromScale(0.5, 0.5) }):Play()
		task.spawn(pedir, "estado")
	end
end)
abrir.Activated:Connect(function() definirAberto(not player:GetAttribute("MissoesAberto")) end)
fechar.Activated:Connect(function() definirAberto(false) end)
fundo.Activated:Connect(function() definirAberto(false) end)
UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Escape and player:GetAttribute("MissoesAberto") then definirAberto(false) end
end)
-- uma janela por vez
for _, nome in ipairs({ "LojaAberta", "MenuJogadorAberto", "SkillTreeOpen", "ForestShopOpen", "PetsAberto", "PremiosAberto", "FamaAberto" }) do
	player:GetAttributeChangedSignal(nome):Connect(function() if player:GetAttribute(nome) then definirAberto(false) end end)
end

-- bolinha com o número de missões prontas
local function atualizarPonto()
	local n = tonumber(player:GetAttribute("MissoesProntas")) or 0
	ponto.Visible = n > 0
	pontoTexto.Text = tostring(n)
	if gui.Enabled then task.spawn(pedir, "estado") end
end
player:GetAttributeChangedSignal("MissoesProntas"):Connect(atualizarPonto)
atualizarPonto()

-- progresso ao vivo com o painel aberto
task.spawn(function()
	while true do
		task.wait(1.5)
		if gui.Enabled and not ocupado then pedir("estado") end
	end
end)

-- quadro físico no lobby (com StreamingEnabled o prompt pode chegar depois; por isso o evento global)
game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt)
	if prompt:FindFirstAncestor("QuadroMissoes") then definirAberto(true) end
end)
