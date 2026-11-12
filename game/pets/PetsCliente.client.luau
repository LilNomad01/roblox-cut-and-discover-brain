--[[
	StarterPlayerScripts.PetsCliente  [Claude 2026-11-11]
	Painel "Ajudantes do Jardim" (aberto pelo botão PETS do HUD, atributo local PetsAberto) e os ajudantes
	equipados seguindo cada jogador (atributo PetsEquipados, posto pelo servidor). Só visual e pedidos ao
	servidor (PetsAcao); moedas, sorteio e bônus são decididos no servidor.
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Cat = require(RS:WaitForChild("Shared"):WaitForChild("PetsCatalogo"))
local remote = RS:WaitForChild("PetsAcao")
local player = Players.LocalPlayer

local TINTA = Color3.fromRGB(52, 44, 38)
local PAPEL = Color3.fromRGB(255, 246, 214)
local VERDE = Color3.fromRGB(96, 196, 104)
local function rgb(t) return Color3.fromRGB(t[1], t[2], t[3]) end
local function pct(x) return ("+%d%%"):format(math.floor(x * 100 + 0.5)) end

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
	local b = inst("TextButton", props, { canto(12), borda(3) })
	return b
end

---------------------------------------------------------------- painel
local gui = inst("ScreenGui", { Name = "PetsGui", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 30, Enabled = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = player:WaitForChild("PlayerGui") })
local fundo = inst("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.5, Parent = gui })
local painel = inst("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(760, 470),
	BackgroundColor3 = PAPEL, Parent = gui }, { canto(22), borda(4) })
local escala = inst("UIScale", { Parent = painel })
local function ajustarEscala()
	local cam = workspace.CurrentCamera
	local v = cam and cam.ViewportSize or Vector2.new(1280, 720)
	escala.Scale = math.clamp(math.min(v.X / 800, v.Y / 520), 0.45, 1)
end
ajustarEscala()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(ajustarEscala) end

rotulo({ Text = "🐾 AJUDANTES DO JARDIM", Font = Enum.Font.FredokaOne, TextSize = 30, Size = UDim2.new(1, -80, 0, 40),
	Position = UDim2.fromOffset(20, 10), TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })
local status = rotulo({ Text = "", TextSize = 16, Size = UDim2.new(1, -80, 0, 22), Position = UDim2.fromOffset(22, 48),
	TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(96, 82, 60), Parent = painel })
local fechar = botao("X", Color3.fromRGB(232, 84, 72), { Size = UDim2.fromOffset(44, 44), Position = UDim2.new(1, -58, 0, 14), TextSize = 24, Parent = painel })

-- coluna dos ninhos
local colNinhos = inst("ScrollingFrame", { Size = UDim2.new(0, 268, 1, -150), Position = UDim2.fromOffset(18, 82), BackgroundTransparency = 1,
	ScrollBarThickness = 6, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, Parent = painel },
	{ inst("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }) })
rotulo({ Text = "Ninhos usam só moedas ganhas jogando. As chances de cada ajudante estão em cada ninho.", TextSize = 12,
	Font = Enum.Font.GothamMedium, TextWrapped = true, Size = UDim2.new(0, 268, 0, 44), Position = UDim2.new(0, 18, 1, -62),
	TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(110, 96, 74), Parent = painel })

-- inventário
local topoInv = inst("Frame", { Size = UDim2.new(1, -324, 0, 40), Position = UDim2.fromOffset(304, 82), BackgroundTransparency = 1, Parent = painel })
local contagem = rotulo({ Text = "", TextSize = 16, Size = UDim2.new(1, -170, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = topoInv })
local btMelhores = botao("Equipar melhores", VERDE, { Size = UDim2.fromOffset(160, 36), Position = UDim2.new(1, -160, 0, 2), TextSize = 16, Parent = topoInv })
local grade = inst("ScrollingFrame", { Size = UDim2.new(1, -324, 1, -186), Position = UDim2.fromOffset(304, 128), BackgroundColor3 = Color3.fromRGB(245, 232, 196),
	ScrollBarThickness = 6, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, Parent = painel },
	{ canto(14), inst("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingTop = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
		inst("UIGridLayout", { CellSize = UDim2.fromOffset(102, 124), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
local vazio = rotulo({ Text = "Nenhum ajudante ainda. Choque um ninho!", TextSize = 16, Size = UDim2.new(1, -324, 0, 30),
	Position = UDim2.fromOffset(304, 200), TextColor3 = Color3.fromRGB(130, 112, 84), Parent = painel })
local mensagem = rotulo({ Text = "", TextSize = 15, Size = UDim2.new(1, -324, 0, 40), Position = UDim2.new(0, 304, 1, -52),
	TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })

-- revelação do ninho
local revela = inst("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(340, 250),
	BackgroundColor3 = PAPEL, Visible = false, ZIndex = 20, Parent = painel }, { canto(22) })
local revelaBorda = borda(6) revelaBorda.Parent = revela
local revelaEscala = inst("UIScale", { Parent = revela })
local revelaIcone = rotulo({ Text = "", TextSize = 86, Size = UDim2.new(1, 0, 0, 110), Position = UDim2.fromOffset(0, 10), ZIndex = 21, Parent = revela })
local revelaNome = rotulo({ Text = "", Font = Enum.Font.FredokaOne, TextSize = 28, Size = UDim2.new(1, 0, 0, 34), Position = UDim2.fromOffset(0, 124), ZIndex = 21, Parent = revela })
local revelaRar = rotulo({ Text = "", Font = Enum.Font.FredokaOne, TextSize = 20, Size = UDim2.new(1, 0, 0, 26), Position = UDim2.fromOffset(0, 160),
	TextStrokeTransparency = 0.2, TextStrokeColor3 = TINTA, ZIndex = 21, Parent = revela })
local revelaBonus = rotulo({ Text = "", TextSize = 18, Size = UDim2.new(1, 0, 0, 24), Position = UDim2.fromOffset(0, 192), ZIndex = 21, Parent = revela })

---------------------------------------------------------------- estado e desenho
local estadoAtual = { pets = {}, equipados = 0, bonus = 0 }
local confirmarSoltar = nil
local ocupado = false

local function mostrarMensagem(t, erro)
	mensagem.Text = t or ""
	mensagem.TextColor3 = erro and Color3.fromRGB(196, 60, 48) or Color3.fromRGB(70, 130, 70)
end

local cartoes = {}
local function redesenhar()
	for _, c in ipairs(cartoes) do c:Destroy() end
	table.clear(cartoes)
	local lista = table.clone(estadoAtual.pets)
	table.sort(lista, function(a, b)
		if a.equipado ~= b.equipado then return a.equipado end
		local ra, rb = Cat.raridade(a.especie).ordem, Cat.raridade(b.especie).ordem
		if ra ~= rb then return ra > rb end
		return tonumber(a.id) < tonumber(b.id)
	end)
	for i, pet in ipairs(lista) do
		local esp = Cat.Especies[pet.especie]
		local rar = Cat.raridade(pet.especie)
		local card = inst("TextButton", { Text = "", AutoButtonColor = true, LayoutOrder = i, BackgroundColor3 = Color3.fromRGB(255, 252, 240), Parent = grade },
			{ canto(14) })
		local b = borda(pet.equipado and 4 or 3, pet.equipado and VERDE or rgb(rar.cor)) b.Parent = card
		rotulo({ Text = esp.icone, TextSize = 44, Size = UDim2.new(1, 0, 0, 54), Position = UDim2.fromOffset(0, 4), Parent = card })
		rotulo({ Text = esp.nome, TextSize = 13, TextScaled = false, TextWrapped = true, Size = UDim2.new(1, -6, 0, 30), Position = UDim2.fromOffset(3, 56), Parent = card })
		rotulo({ Text = rar.nome, Font = Enum.Font.FredokaOne, TextSize = 14, TextColor3 = rgb(rar.cor), TextStrokeColor3 = TINTA, TextStrokeTransparency = 0.4,
			Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, 86), Parent = card })
		rotulo({ Text = pct(rar.bonus) .. " grama", TextSize = 12, Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, 104), Parent = card })
		if pet.equipado then
			local tag = rotulo({ Text = "EQUIPADO", Font = Enum.Font.FredokaOne, TextSize = 11, TextColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0,
				Size = UDim2.fromOffset(70, 18), Position = UDim2.fromOffset(4, 4), Parent = card })
			tag.BackgroundColor3 = VERDE
			canto(9).Parent = tag
		end
		local lixo = botao(confirmarSoltar == pet.id and "Soltar?" or "X", Color3.fromRGB(200, 90, 80),
			{ Size = UDim2.fromOffset(confirmarSoltar == pet.id and 58 or 24, 22), Position = UDim2.new(1, confirmarSoltar == pet.id and -62 or -28, 0, 4), TextSize = 13, ZIndex = 3, Parent = card })
		local function pedir(acao, arg)
			if ocupado then return end
			ocupado = true
			local ok, r = pcall(function() return remote:InvokeServer(acao, arg) end)
			ocupado = false
			if not ok or type(r) ~= "table" then mostrarMensagem("Não deu certo. Tente de novo.", true) return end
			if r.estado then estadoAtual = r.estado end
			mostrarMensagem(r.erro, r.erro ~= nil)
			redesenhar()
		end
		card.Activated:Connect(function() confirmarSoltar = nil pedir("equipar", pet.id) end)
		lixo.Activated:Connect(function()
			if confirmarSoltar == pet.id then confirmarSoltar = nil pedir("soltar", pet.id)
			else confirmarSoltar = pet.id redesenhar() end
		end)
		table.insert(cartoes, card)
	end
	vazio.Visible = #lista == 0
	contagem.Text = ("Ajudantes: %d/%d · equipados %d/%d"):format(#lista, Cat.MaxInventario, estadoAtual.equipados, Cat.MaxEquipados)
	status.Text = ("Bônus de grama dos equipados: %s  ·  Moedas: %s"):format(pct(estadoAtual.bonus or 0), tostring(player:GetAttribute("Moedas") or 0))
end

local function revelar(especie)
	local esp = Cat.Especies[especie]
	local rar = Cat.raridade(especie)
	revelaIcone.Text = esp.icone
	revelaNome.Text = esp.nome
	revelaRar.Text = rar.nome:upper()
	revelaRar.TextColor3 = rgb(rar.cor)
	revelaBonus.Text = pct(rar.bonus) .. " de grama por tufo"
	revelaBorda.Color = rgb(rar.cor)
	revela.Visible = true
	revelaEscala.Scale = 0.3
	TweenService:Create(revelaEscala, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	task.delay(2.4, function() revela.Visible = false end)
end
revela.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then revela.Visible = false end
end)

-- cartões dos ninhos
for i, ninho in ipairs(Cat.Ninhos) do
	local linhas = {}
	for _, c in ipairs(ninho.chances) do
		local e = Cat.Especies[c[1]]
		table.insert(linhas, ("%s %s (%s) %d%%"):format(e.icone, e.nome, Cat.raridade(c[1]).nome, c[2]))
	end
	local card = inst("Frame", { LayoutOrder = i, Size = UDim2.new(1, -8, 0, 64 + #linhas * 16 + 44), BackgroundColor3 = Color3.fromRGB(255, 252, 240) },
		{ canto(14), borda(3) })
	rotulo({ Text = "🥚 " .. ninho.nome, Font = Enum.Font.FredokaOne, TextSize = 20, Size = UDim2.new(1, -16, 0, 26), Position = UDim2.fromOffset(10, 6),
		TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
	rotulo({ Text = "💰 " .. ninho.preco .. " moedas", TextSize = 15, Size = UDim2.new(1, -16, 0, 20), Position = UDim2.fromOffset(10, 32),
		TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(176, 120, 20), Parent = card })
	rotulo({ Text = "Chances:\n" .. table.concat(linhas, "\n"), TextSize = 12, Font = Enum.Font.GothamMedium, TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -16, 0, 16 + #linhas * 16),
		Position = UDim2.fromOffset(10, 54), Parent = card })
	local b = botao("CHOCAR", VERDE, { Size = UDim2.new(1, -20, 0, 34), Position = UDim2.new(0, 10, 1, -42), TextSize = 18, Parent = card })
	b.Activated:Connect(function()
		if ocupado then return end
		ocupado = true
		local ok, r = pcall(function() return remote:InvokeServer("chocar", ninho.id) end)
		ocupado = false
		if not ok or type(r) ~= "table" then mostrarMensagem("Não deu certo. Tente de novo.", true) return end
		if r.estado then estadoAtual = r.estado end
		if r.novo then
			local esp = Cat.Especies[r.novo.especie]
			mostrarMensagem(("Você chocou: %s!"):format(esp.nome), false)
			revelar(r.novo.especie)
		else
			mostrarMensagem(r.erro, true)
		end
		redesenhar()
	end)
	card.Parent = colNinhos
end

btMelhores.Activated:Connect(function()
	if ocupado then return end
	ocupado = true
	local ok, r = pcall(function() return remote:InvokeServer("melhores") end)
	ocupado = false
	if ok and type(r) == "table" then
		if r.estado then estadoAtual = r.estado end
		mostrarMensagem(r.erro or "Os 3 melhores ajudantes estão equipados.", r.erro ~= nil)
		redesenhar()
	end
end)

---------------------------------------------------------------- abrir e fechar
local function sincronizar()
	local ok, r = pcall(function() return remote:InvokeServer("sync") end)
	if ok and type(r) == "table" and r.estado then estadoAtual = r.estado end
	redesenhar()
end
local function definirAberto(aberto)
	player:SetAttribute("PetsAberto", aberto)
end
player:GetAttributeChangedSignal("PetsAberto"):Connect(function()
	local aberto = player:GetAttribute("PetsAberto") == true
	gui.Enabled = aberto
	if aberto then
		confirmarSoltar = nil
		mostrarMensagem("")
		revela.Visible = false
		ajustarEscala()
		task.spawn(sincronizar)
	end
end)
fechar.Activated:Connect(function() definirAberto(false) end)
fundo.Activated:Connect(function() definirAberto(false) end)
UIS.InputBegan:Connect(function(input, processado)
	if input.KeyCode == Enum.KeyCode.Escape and player:GetAttribute("PetsAberto") then definirAberto(false) end
end)
-- outra janela abriu: fecha esta (uma janela por vez)
for _, nome in ipairs({ "LojaAberta", "MenuJogadorAberto", "SkillTreeOpen", "ForestShopOpen", "PremiosAberto" }) do
	player:GetAttributeChangedSignal(nome):Connect(function()
		if player:GetAttribute(nome) then definirAberto(false) end
	end)
end
player:GetAttributeChangedSignal("Moedas"):Connect(function() if gui.Enabled then redesenhar() end end)

---------------------------------------------------------------- ajudantes seguindo os jogadores
local pasta = Instance.new("Folder")
pasta.Name = "AjudantesSeguindo"
pasta.Parent = workspace

local function peca(m, nome, size, cf, cor, material, shape)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame, p.Color = nome, size, cf, cor
	p.Material = material or Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery, p.CastShadow = true, false, false, false, false
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = m
	return p
end
local BALL = Enum.PartType.Ball
local PRETO = Color3.fromRGB(30, 28, 26)

-- cada ajudante é montado em volta da origem e guardado com o deslocamento de cada peça
local function construir(especie)
	local e = Cat.Especies[especie]
	local cor = rgb(e.cor)
	local m = Instance.new("Model")
	m.Name = "Ajudante_" .. especie
	local O = CFrame.new()
	local corpo = peca(m, "Corpo", Vector3.new(1.3, 1.05, 1.4), O, cor, Enum.Material.SmoothPlastic, BALL)
	local cabeca = peca(m, "Cabeca", Vector3.new(0.95, 0.95, 0.95), O * CFrame.new(0, 0.45, -0.7), cor, Enum.Material.SmoothPlastic, BALL)
	for _, s in ipairs({ -1, 1 }) do
		peca(m, "Olho", Vector3.new(0.16, 0.2, 0.1), O * CFrame.new(s * 0.2, 0.55, -1.12), PRETO, Enum.Material.SmoothPlastic, BALL)
	end
	if especie == "joaninha" then
		cabeca.Color = PRETO
		for _, o in ipairs({ { -0.35, 0.3, 0.1 }, { 0.35, 0.35, -0.1 }, { 0, 0.5, 0.35 }, { 0.3, 0.2, 0.45 } }) do
			peca(m, "Pinta", Vector3.new(0.28, 0.12, 0.28), O * CFrame.new(o[1], o[2], o[3]), PRETO, Enum.Material.SmoothPlastic, BALL)
		end
	elseif especie == "minhoca" then
		corpo.Size = Vector3.new(0.8, 0.7, 0.8)
		for i = 1, 3 do peca(m, "Gomo", Vector3.new(0.75, 0.65, 0.75), O * CFrame.new(0, -0.1, 0.55 * i), cor, Enum.Material.SmoothPlastic, BALL) end
	elseif especie == "coelho" then
		for _, s in ipairs({ -1, 1 }) do
			peca(m, "Orelha", Vector3.new(0.22, 0.9, 0.16), O * CFrame.new(s * 0.22, 1.25, -0.65) * CFrame.Angles(0, 0, math.rad(-s * 10)), cor)
			peca(m, "OrelhaDentro", Vector3.new(0.1, 0.65, 0.05), O * CFrame.new(s * 0.22, 1.25, -0.74) * CFrame.Angles(0, 0, math.rad(-s * 10)), Color3.fromRGB(246, 170, 180))
		end
		peca(m, "Rabo", Vector3.new(0.45, 0.45, 0.45), O * CFrame.new(0, 0.1, 0.75), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, BALL)
	elseif especie == "ourico" then
		for i = 0, 7 do
			local a = i * math.pi / 4
			peca(m, "Espinho", Vector3.new(0.35, 0.35, 0.35), O * CFrame.new(math.cos(a) * 0.45, 0.42 + (i % 2) * 0.1, math.sin(a) * 0.45 + 0.15), Color3.fromRGB(96, 70, 50), Enum.Material.SmoothPlastic, BALL)
		end
		peca(m, "Nariz", Vector3.new(0.18, 0.18, 0.18), O * CFrame.new(0, 0.4, -1.18), PRETO, Enum.Material.SmoothPlastic, BALL)
	elseif especie == "toupeira" then
		peca(m, "Nariz", Vector3.new(0.3, 0.26, 0.26), O * CFrame.new(0, 0.38, -1.2), Color3.fromRGB(246, 150, 166), Enum.Material.SmoothPlastic, BALL)
		for _, s in ipairs({ -1, 1 }) do peca(m, "Pata", Vector3.new(0.4, 0.15, 0.3), O * CFrame.new(s * 0.6, -0.25, -0.6), Color3.fromRGB(246, 180, 186)) end
	elseif especie == "sapo" then
		for _, s in ipairs({ -1, 1 }) do
			peca(m, "OlhoGrande", Vector3.new(0.42, 0.42, 0.42), O * CFrame.new(s * 0.28, 0.95, -0.7), cor, Enum.Material.SmoothPlastic, BALL)
			peca(m, "Pupila", Vector3.new(0.18, 0.18, 0.12), O * CFrame.new(s * 0.28, 0.98, -0.9), PRETO, Enum.Material.SmoothPlastic, BALL)
		end
		peca(m, "Barriga", Vector3.new(1.0, 0.7, 0.4), O * CFrame.new(0, -0.05, -0.5), Color3.fromRGB(220, 236, 170), Enum.Material.SmoothPlastic, BALL)
	elseif especie == "coruja" then
		for _, s in ipairs({ -1, 1 }) do
			peca(m, "Disco", Vector3.new(0.38, 0.38, 0.1), O * CFrame.new(s * 0.22, 0.55, -1.1), Color3.fromRGB(255, 220, 110), Enum.Material.SmoothPlastic, BALL)
			peca(m, "Tufo", Vector3.new(0.18, 0.4, 0.15), O * CFrame.new(s * 0.32, 1.0, -0.7) * CFrame.Angles(0, 0, math.rad(-s * 20)), cor)
			peca(m, "Asa", Vector3.new(0.18, 0.75, 0.9), O * CFrame.new(s * 0.68, 0, 0), Color3.fromRGB(140, 104, 70), Enum.Material.SmoothPlastic, BALL)
		end
		peca(m, "Bico", Vector3.new(0.14, 0.18, 0.14), O * CFrame.new(0, 0.4, -1.18), Color3.fromRGB(240, 170, 60))
	elseif especie == "raposa" then
		for _, s in ipairs({ -1, 1 }) do
			local w = Instance.new("WedgePart")
			w.Size = Vector3.new(0.12, 0.45, 0.35)
			w.CFrame = O * CFrame.new(s * 0.26, 1.02, -0.7)
			w.Color = cor
			w.Anchored, w.CanCollide, w.CanTouch, w.CanQuery, w.CastShadow = true, false, false, false, false
			w.Parent = m
		end
		peca(m, "Focinho", Vector3.new(0.4, 0.3, 0.45), O * CFrame.new(0, 0.32, -1.1), Color3.fromRGB(250, 246, 236), Enum.Material.SmoothPlastic, BALL)
		peca(m, "Cauda", Vector3.new(0.55, 0.55, 1.1), O * CFrame.new(0, 0.25, 1.0) * CFrame.Angles(math.rad(-25), 0, 0), cor, Enum.Material.SmoothPlastic, BALL)
		peca(m, "PontaCauda", Vector3.new(0.4, 0.4, 0.4), O * CFrame.new(0, 0.5, 1.45), Color3.fromRGB(250, 246, 236), Enum.Material.SmoothPlastic, BALL)
	elseif especie == "cervo" then
		for _, s in ipairs({ -1, 1 }) do
			peca(m, "Chifre", Vector3.new(0.1, 0.7, 0.1), O * CFrame.new(s * 0.25, 1.2, -0.65) * CFrame.Angles(0, 0, math.rad(-s * 18)), Color3.fromRGB(220, 200, 160))
			peca(m, "Galho", Vector3.new(0.08, 0.35, 0.08), O * CFrame.new(s * 0.38, 1.35, -0.65) * CFrame.Angles(0, 0, math.rad(-s * 60)), Color3.fromRGB(220, 200, 160))
			peca(m, "MusgoChifre", Vector3.new(0.22, 0.22, 0.22), O * CFrame.new(s * 0.32, 1.5, -0.65), Color3.fromRGB(110, 180, 90), Enum.Material.Grass, BALL)
		end
		for i = 1, 3 do peca(m, "Musgo", Vector3.new(0.4, 0.25, 0.4), O * CFrame.new((i - 2) * 0.35, 0.5, 0.2), Color3.fromRGB(100, 170, 84), Enum.Material.Grass, BALL) end
	elseif especie == "vagalume" then
		corpo.Material = Enum.Material.Neon
		local luz = Instance.new("PointLight") luz.Color = cor luz.Brightness = 1.4 luz.Range = 10 luz.Parent = corpo
		for _, s in ipairs({ -1, 1 }) do
			local asa = peca(m, "Asa", Vector3.new(0.9, 0.08, 0.6), O * CFrame.new(s * 0.7, 0.55, 0) * CFrame.Angles(0, 0, math.rad(s * 20)), Color3.fromRGB(220, 240, 255), Enum.Material.Glass)
			asa.Transparency = 0.4
		end
		peca(m, "Coroa", Vector3.new(0.5, 0.18, 0.5), O * CFrame.new(0, 0.98, -0.7), Color3.fromRGB(255, 210, 70), Enum.Material.Metal)
	end
	-- deslocamentos relativos ao corpo (para mover tudo com um CFrame só)
	local partes = {}
	for _, p in ipairs(m:GetChildren()) do
		if p:IsA("BasePart") then table.insert(partes, { p = p, off = p.CFrame }) end
	end
	m.Parent = pasta
	return { model = m, partes = partes, cf = nil, voa = especie == "vagalume" or especie == "coruja" }
end

local seguindo = {} -- [Player] = { chave = "a,b", lista = { ajudantes } }
local VAGAS = { Vector3.new(-3, 0, 3.2), Vector3.new(3, 0, 3.2), Vector3.new(0, 0, 5) }
local RAIO = 160

local function limpar(plr)
	local s = seguindo[plr]
	if s then for _, a in ipairs(s.lista) do a.model:Destroy() end end
	seguindo[plr] = nil
end
Players.PlayerRemoving:Connect(limpar)

RunService.RenderStepped:Connect(function(dt)
	local cam = workspace.CurrentCamera
	local t = os.clock()
	for _, plr in ipairs(Players:GetPlayers()) do
		local chave = plr:GetAttribute("PetsEquipados") or ""
		local char = plr.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local longe = not root or not cam or (root.Position - cam.CFrame.Position).Magnitude > RAIO
		local s = seguindo[plr]
		if chave == "" or longe then
			if s then limpar(plr) end
			continue
		end
		if not s or s.chave ~= chave then
			limpar(plr)
			s = { chave = chave, lista = {} }
			for esp in string.gmatch(chave, "[^,]+") do
				if Cat.Especies[esp] and #s.lista < Cat.MaxEquipados then table.insert(s.lista, construir(esp)) end
			end
			seguindo[plr] = s
		end
		local base = root.CFrame
		local chao = root.Position.Y - 2.2
		for i, a in ipairs(s.lista) do
			local vaga = VAGAS[i] or Vector3.new(0, 0, 3 + i)
			local alvoPos = base:PointToWorldSpace(vaga)
			local altura = a.voa and (chao + 2.6 + math.sin(t * 2 + i) * 0.35) or (chao + 0.55 + math.abs(math.sin(t * 6 + i)) * 0.35)
			local alvo = CFrame.lookAt(Vector3.new(alvoPos.X, altura, alvoPos.Z), Vector3.new(alvoPos.X, altura, alvoPos.Z) + base.LookVector)
			a.cf = a.cf and a.cf:Lerp(alvo, math.min(1, dt * 8)) or alvo
			for _, pp in ipairs(a.partes) do pp.p.CFrame = a.cf * pp.off end
		end
	end
end)
