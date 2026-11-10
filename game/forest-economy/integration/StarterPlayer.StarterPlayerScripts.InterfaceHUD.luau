--[[
	InterfaceHUD (LocalScript)
	Local: StarterPlayer > StarterPlayerScripts > InterfaceHUD

	Cria TODA a interface por código (sem imagens pra subir):
	  • Nível + barra de XP (topo esquerdo)
	  • Contador de moedas (topo direito), moedas voando até ele, "+N" flutuante
	  • Barra do saco de grama (embaixo), aviso pulsando quando enche
	  • Menu lateral (Loja, Upgrades, Pets, Config)
	  • Loja de cortadores com cards
	  • Notificações (toasts)
	  • Tela de LEVEL UP com raios girando, confete e recompensa

	Ela só LÊ atributos do Player (Moedas, Nivel, XP, XPMax, Saco, SacoMax, Cortador, Comprados).
	Quem muda os valores é o servidor (ServerScriptService > Economia).
	Outros LocalScripts podem mostrar notificação com:
	  PlayerGui.HUDCortaGrama.Notificar:Fire("Texto", "sucesso")
	E ouvir os botões do menu com:
	  PlayerGui.HUDCortaGrama.BotaoClicado.Event:Connect(function(nome) ... end)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Config = require(ReplicatedStorage:WaitForChild("ConfigJogo"))

---------------------------------------------------------------------
-- TEMA
---------------------------------------------------------------------
local FONTE = Enum.Font.FredokaOne
local FONTE2 = Enum.Font.GothamBlack

local C = {
	Painel = Color3.fromRGB(28, 42, 32),
	Card = Color3.fromRGB(40, 60, 46),
	Contorno = Color3.fromRGB(12, 22, 14),
	Branco = Color3.new(1, 1, 1),
	Cinza = Color3.fromRGB(165, 165, 165),
	Ouro1 = Color3.fromRGB(255, 221, 74),
	Ouro2 = Color3.fromRGB(255, 152, 24),
	OuroBorda = Color3.fromRGB(140, 72, 8),
	XP1 = Color3.fromRGB(170, 245, 80),
	XP2 = Color3.fromRGB(52, 186, 72),
	Saco1 = Color3.fromRGB(110, 225, 255),
	Saco2 = Color3.fromRGB(40, 130, 235),
	Cheio1 = Color3.fromRGB(255, 120, 100),
	Cheio2 = Color3.fromRGB(215, 38, 56),
	Verde1 = Color3.fromRGB(120, 230, 90),
	Verde2 = Color3.fromRGB(36, 160, 70),
	Vermelho1 = Color3.fromRGB(255, 110, 110),
	Vermelho2 = Color3.fromRGB(200, 40, 60),
	Roxo1 = Color3.fromRGB(230, 140, 255),
	Roxo2 = Color3.fromRGB(130, 50, 220),
}

-- Coloque IDs de som aqui (ex.: "rbxassetid://123456"). Vazio = sem som.
local SONS = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("AudioConfig")).SFX -- IDs reais num lugar so

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------
local function make(class: string, props: { [any]: any })
	local inst = Instance.new(class)
	local parent = nil
	for k, v in props do
		if type(k) == "number" then
			v.Parent = inst
		elseif k == "Parent" then
			parent = v
		else
			(inst :: any)[k] = v
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local CENTRO = Vector2.new(0.5, 0.5)

local function corner()
	return make("UICorner", { CornerRadius = UDim.new(1, 0) })
end

local function cantos(px: number)
	return make("UICorner", { CornerRadius = UDim.new(0, px) })
end

local function borda(cor: Color3?, esp: number?, transp: number?)
	return make("UIStroke", {
		Color = cor or C.Contorno,
		Thickness = esp or 3,
		Transparency = transp or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		LineJoinMode = Enum.LineJoinMode.Round,
	})
end

local function contornoTexto(cor: Color3?, esp: number?)
	return make("UIStroke", {
		Color = cor or C.Contorno,
		Thickness = esp or 2.5,
		LineJoinMode = Enum.LineJoinMode.Round,
	})
end

local function grad(c1: Color3, c2: Color3, rot: number?)
	return make("UIGradient", { Color = ColorSequence.new(c1, c2), Rotation = rot or 90 })
end

local function texto(props: { [any]: any })
	props.BackgroundTransparency = 1
	props.Font = props.Font or FONTE
	props.TextColor3 = props.TextColor3 or C.Branco
	if props.TextScaled == nil then
		props.TextScaled = true
	end
	return make("TextLabel", props)
end

local function tween(obj: Instance, t: number, props: { [string]: any }, estilo: Enum.EasingStyle?, dir: Enum.EasingDirection?, atraso: number?)
	local tw = TweenService:Create(
		obj,
		TweenInfo.new(t, estilo or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out, 0, false, atraso or 0),
		props
	)
	tw:Play()
	return tw
end

local function pulso(escala: UIScale, forca: number?)
	local t = tween(escala, 0.07, { Scale = forca or 1.15 })
	t.Completed:Connect(function()
		tween(escala, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
	end)
end

-- Some com todos os elementos de um grupo (fade out)
local function sumir(raiz: Instance, t: number)
	local lista = raiz:GetDescendants()
	table.insert(lista, raiz)
	for _, o in lista do
		if o:IsA("GuiObject") then
			local props: { [string]: any } = { BackgroundTransparency = 1 }
			if o:IsA("TextLabel") or o:IsA("TextButton") then
				props.TextTransparency = 1
			end
			tween(o, t, props)
		elseif o:IsA("UIStroke") then
			tween(o, t, { Transparency = 1 })
		end
	end
end

local function formatar(n: number): string
	n = math.floor(n + 0.5)
	if math.abs(n) < 1000 then
		return tostring(n)
	end
	local sufixos = { "K", "M", "B", "T", "Qa" }
	local i = 0
	local v = n
	while math.abs(v) >= 1000 and i < #sufixos do
		v /= 1000
		i += 1
	end
	local s
	if math.abs(v) < 10 then
		s = string.format("%.2f", math.floor(v * 100) / 100)
	elseif math.abs(v) < 100 then
		s = string.format("%.1f", math.floor(v * 10) / 10)
	else
		s = tostring(math.floor(v))
	end
	if string.find(s, ".", 1, true) then
		s = string.gsub(s, "0+$", "")
		s = string.gsub(s, "%.$", "")
	end
	return s .. sufixos[i]
end

---------------------------------------------------------------------
-- RAIZ + ESCALA RESPONSIVA (PC / celular)
---------------------------------------------------------------------
local gui = make("ScreenGui", {
	Name = "HUDCortaGrama",
	DisplayOrder = 14, -- loja original acima da hotbar; menu do jogador fica em 30
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

local function som(nome: string)
	local id = SONS[nome]
	if id and id ~= "" then
		local s = make("Sound", { SoundId = id, Volume = 0.6, Parent = gui })
		s:Play()
		Debris:AddItem(s, 6)
	end
end

local function escalaAtual(): number
	local vp = workspace.CurrentCamera.ViewportSize
	return math.clamp(math.min(vp.X / 1600, vp.Y / 900), 0.5, 1.15)
end

local escalas: { UIScale } = {}
local function novaEscala(pai: Instance)
	local s = make("UIScale", { Scale = escalaAtual(), Parent = pai })
	table.insert(escalas, s)
	return s
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	local e = escalaAtual()
	for _, s in escalas do
		s.Scale = e
	end
end)

local function animarBotao(b: GuiButton)
	local esc = make("UIScale", { Parent = b })
	b.MouseEnter:Connect(function()
		tween(esc, 0.15, { Scale = 1.07 }, Enum.EasingStyle.Back)
	end)
	b.MouseLeave:Connect(function()
		tween(esc, 0.15, { Scale = 1 })
	end)
	b.MouseButton1Down:Connect(function()
		tween(esc, 0.08, { Scale = 0.92 })
	end)
	b.MouseButton1Up:Connect(function()
		tween(esc, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
	end)
	b.Activated:Connect(function()
		som("Clique")
	end)
	return esc
end

---------------------------------------------------------------------
-- ÍCONE DE MOEDA (feito só com Frames)
---------------------------------------------------------------------
local function iconeMoeda(tam: number, pai: Instance?)
	local m = make("Frame", {
		Name = "Moeda",
		Size = UDim2.fromOffset(tam, tam),
		AnchorPoint = CENTRO,
		BackgroundColor3 = C.Branco,
		corner(),
		grad(C.Ouro1, C.Ouro2, 90),
		borda(C.OuroBorda, math.max(1.5, tam / 16)),
	})
	make("Frame", {
		Size = UDim2.fromScale(0.66, 0.66),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = CENTRO,
		BackgroundColor3 = C.Branco,
		Parent = m,
		corner(),
		grad(C.Ouro2, C.Ouro1, 90),
		borda(C.OuroBorda, math.max(1, tam / 32), 0.4),
	})
	texto({
		Text = "$",
		Size = UDim2.fromScale(0.52, 0.52),
		Position = UDim2.fromScale(0.5, 0.52),
		AnchorPoint = CENTRO,
		TextColor3 = Color3.fromRGB(255, 248, 210),
		Parent = m,
		contornoTexto(C.OuroBorda, math.max(1, tam / 26)),
	})
	make("Frame", {
		Size = UDim2.fromScale(0.22, 0.13),
		Position = UDim2.fromScale(0.3, 0.24),
		AnchorPoint = CENTRO,
		Rotation = -35,
		BackgroundColor3 = C.Branco,
		BackgroundTransparency = 0.3,
		Parent = m,
		corner(),
	})
	m.Parent = pai
	return m
end

---------------------------------------------------------------------
-- BARRA (XP / Saco)
---------------------------------------------------------------------
local function barra(props: { [string]: any })
	local fundo = make("Frame", {
		Name = props.Name,
		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint or Vector2.zero,
		BackgroundColor3 = Color3.fromRGB(14, 22, 16),
		BackgroundTransparency = 0.1,
		Parent = props.Parent,
		corner(),
		borda(C.Contorno, 3.5),
	})
	local area = make("Frame", {
		Size = UDim2.new(1, -8, 1, -8),
		Position = UDim2.fromOffset(4, 4),
		BackgroundTransparency = 1,
		Parent = fundo,
	})
	local fill = make("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = C.Branco,
		Parent = area,
		corner(),
	})
	local g = grad(props.C1, props.C2, 90)
	g.Parent = fill
	make("Frame", {
		Name = "Brilho",
		Size = UDim2.new(1, -12, 0.32, 0),
		Position = UDim2.new(0, 6, 0.12, 0),
		BackgroundColor3 = C.Branco,
		BackgroundTransparency = 0.6,
		Parent = fill,
		corner(),
	})
	local lbl = texto({
		Size = UDim2.new(1, -24, 0.72, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = CENTRO,
		Text = "",
		Parent = fundo,
		contornoTexto(C.Contorno, 2.5),
	})
	return fundo, fill, lbl, g
end

---------------------------------------------------------------------
-- TOPO ESQUERDO: NÍVEL + XP
---------------------------------------------------------------------
local topoEsq = make("Frame", {
	Name = "Nivel",
	Position = UDim2.fromOffset(18, 70),
	Size = UDim2.fromOffset(400, 100),
	BackgroundTransparency = 1,
	Parent = gui,
})
novaEscala(topoEsq)

local _, xpFill, xpTexto = barra({
	Name = "BarraXP",
	Size = UDim2.fromOffset(300, 40),
	Position = UDim2.new(0, 72, 0.5, 2),
	AnchorPoint = Vector2.new(0, 0.5),
	C1 = C.XP1,
	C2 = C.XP2,
	Parent = topoEsq,
})

local badge = make("Frame", {
	Name = "Badge",
	Size = UDim2.fromOffset(94, 94),
	Position = UDim2.new(0, 47, 0.5, 0),
	AnchorPoint = CENTRO,
	BackgroundColor3 = C.Branco,
	Parent = topoEsq,
	corner(),
	grad(C.XP1, C.XP2, 90),
	borda(C.Contorno, 4.5),
})
local badgeEscala = make("UIScale", { Parent = badge })
make("Frame", {
	Size = UDim2.fromScale(0.8, 0.8),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = CENTRO,
	BackgroundTransparency = 1,
	Parent = badge,
	corner(),
	borda(C.Branco, 2.5, 0.5),
})
local nivelTexto = texto({
	Text = "1",
	Size = UDim2.fromScale(0.62, 0.48),
	Position = UDim2.fromScale(0.5, 0.46),
	AnchorPoint = CENTRO,
	Parent = badge,
	contornoTexto(C.Contorno, 3.5),
})
local tagNivel = make("Frame", {
	Size = UDim2.fromOffset(72, 26),
	Position = UDim2.new(0.5, 0, 1, -4),
	AnchorPoint = CENTRO,
	BackgroundColor3 = C.Branco,
	Parent = badge,
	corner(),
	grad(C.Ouro1, C.Ouro2, 90),
	borda(C.Contorno, 3),
})
texto({
	Text = "NÍVEL",
	Size = UDim2.fromScale(0.82, 0.72),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = CENTRO,
	Parent = tagNivel,
	contornoTexto(C.OuroBorda, 1.8),
})

---------------------------------------------------------------------
-- TOPO DIREITO: MOEDAS
---------------------------------------------------------------------
local topoDir = make("Frame", {
	Name = "Moedas",
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -18, 0, 76),
	Size = UDim2.fromOffset(300, 74),
	BackgroundTransparency = 1,
	Parent = gui,
})
novaEscala(topoDir)

local grupoMoeda = make("Frame", {
	Size = UDim2.fromScale(1, 1),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = CENTRO,
	BackgroundTransparency = 1,
	Parent = topoDir,
})
local bumpMoeda = make("UIScale", { Parent = grupoMoeda })

make("Frame", {
	Name = "Pilula",
	Size = UDim2.new(1, -34, 1, -14),
	Position = UDim2.new(1, 0, 0.5, 0),
	AnchorPoint = Vector2.new(1, 0.5),
	BackgroundColor3 = C.Painel,
	BackgroundTransparency = 0.05,
	Parent = grupoMoeda,
	corner(),
	borda(C.Contorno, 3.5),
	grad(C.Branco, C.Cinza, 90),
})
local moedaIcone = iconeMoeda(78, grupoMoeda)
moedaIcone.Position = UDim2.new(0, 36, 0.5, 0)
local tamMoedaIcone = moedaIcone.Size

local moedasTexto = texto({
	Text = "0",
	Size = UDim2.new(1, -150, 0, 42),
	Position = UDim2.new(0, 84, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = grupoMoeda,
	contornoTexto(C.Contorno, 3),
})

local botaoMais = make("TextButton", {
	Name = "Mais",
	Text = "",
	AutoButtonColor = false,
	Size = UDim2.fromOffset(42, 42),
	Position = UDim2.new(1, -10, 0.5, 0),
	AnchorPoint = Vector2.new(1, 0.5),
	BackgroundColor3 = C.Branco,
	Parent = grupoMoeda,
	corner(),
	grad(C.Verde1, C.Verde2, 90),
	borda(C.Contorno, 3),
})
texto({
	Text = "+",
	Size = UDim2.fromScale(0.8, 0.8),
	Position = UDim2.fromScale(0.5, 0.47),
	AnchorPoint = CENTRO,
	Parent = botaoMais,
	contornoTexto(C.Contorno, 2.5),
})
animarBotao(botaoMais)

---------------------------------------------------------------------
-- EMBAIXO: SACO DE GRAMA
---------------------------------------------------------------------
local base = make("Frame", {
	Name = "Saco",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -22),
	Size = UDim2.fromOffset(460, 76),
	BackgroundTransparency = 1,
	Parent = gui,
})
novaEscala(base)

local _, sacoFill, sacoTexto, sacoGrad = barra({
	Name = "BarraSaco",
	Size = UDim2.new(1, -44, 0, 42),
	Position = UDim2.new(1, 0, 0.5, 0),
	AnchorPoint = Vector2.new(1, 0.5),
	C1 = C.Saco1,
	C2 = C.Saco2,
	Parent = base,
})

local sacoIcone = make("Frame", {
	Size = UDim2.fromOffset(74, 74),
	Position = UDim2.new(0, 37, 0.5, 0),
	AnchorPoint = CENTRO,
	BackgroundColor3 = C.Branco,
	Parent = base,
	corner(),
	borda(C.Contorno, 4.5),
})
local sacoIconeGrad = grad(C.Saco1, C.Saco2, 90)
sacoIconeGrad.Parent = sacoIcone
local sacoEscala = make("UIScale", { Parent = sacoIcone })
texto({
	Text = "🌿",
	Size = UDim2.fromScale(0.6, 0.6),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = CENTRO,
	Parent = sacoIcone,
})

local avisoCheio = make("Frame", {
	Size = UDim2.fromOffset(310, 38),
	Position = UDim2.new(0.5, 22, 0, -20),
	AnchorPoint = CENTRO,
	Visible = false,
	BackgroundColor3 = C.Branco,
	Parent = base,
	corner(),
	grad(C.Cheio1, C.Cheio2, 90),
	borda(C.Contorno, 3.5),
})
local avisoEscala = make("UIScale", { Parent = avisoCheio })
texto({
	Text = "SACO CHEIO! VÁ VENDER",
	Size = UDim2.new(1, -24, 0.66, 0),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = CENTRO,
	Parent = avisoCheio,
	contornoTexto(C.Contorno, 2.5),
})

---------------------------------------------------------------------
-- NOTIFICAÇÕES (toasts)
---------------------------------------------------------------------
local toasts = make("Frame", {
	Name = "Notificacoes",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 150),
	Size = UDim2.fromOffset(700, 320),
	BackgroundTransparency = 1,
	Parent = gui,
	make("UIListLayout", {
		Padding = UDim.new(0, 10),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
})
novaEscala(toasts)

local TIPOS = {
	sucesso = { C.Verde1, C.Verde2 },
	erro = { C.Vermelho1, C.Vermelho2 },
	info = { C.Saco1, C.Saco2 },
	ouro = { C.Ouro1, C.Ouro2 },
}
local ordemToast = 0

local function notificar(msg: string, tipo: string?)
	local cores = TIPOS[tipo or "info"] or TIPOS.info
	if tipo == "erro" then
		som("Erro")
	end
	ordemToast += 1
	local largura = TextService:GetTextSize(msg, 26, FONTE, Vector2.new(2000, 60)).X + 60
	local caixa = make("Frame", {
		LayoutOrder = ordemToast,
		Size = UDim2.fromOffset(largura, 52),
		BackgroundTransparency = 1,
		Parent = toasts,
	})
	local pill = make("Frame", {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = CENTRO,
		BackgroundColor3 = C.Branco,
		Parent = caixa,
		corner(),
		grad(cores[1], cores[2], 90),
		borda(C.Contorno, 3.5),
	})
	local esc = make("UIScale", { Scale = 0.3, Parent = pill })
	texto({
		Text = msg,
		TextScaled = false,
		TextSize = 26,
		Size = UDim2.fromScale(1, 1),
		Parent = pill,
		contornoTexto(C.Contorno, 2.5),
	})
	tween(esc, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)

	-- no máximo 4 na tela
	local filhos = {}
	for _, f in toasts:GetChildren() do
		if f:IsA("Frame") then
			table.insert(filhos, f)
		end
	end
	if #filhos > 4 then
		table.sort(filhos, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)
		filhos[1]:Destroy()
	end

	task.delay(2.4, function()
		if not caixa.Parent then
			return
		end
		sumir(pill, 0.35)
		tween(pill, 0.35, { Position = UDim2.new(0.5, 0, 0.5, -18) })
		task.wait(0.4)
		caixa:Destroy()
	end)
end

local eventoNotificar = make("BindableEvent", { Name = "Notificar", Parent = gui })
eventoNotificar.Event:Connect(notificar)
task.spawn(function()
	local ev = ReplicatedStorage:WaitForChild("NotificarHUD", 30)
	if ev then
		ev.OnClientEvent:Connect(notificar)
	end
end)

---------------------------------------------------------------------
-- EFEITOS: texto flutuante e moedas voando
---------------------------------------------------------------------
local efeitos = make("Frame", {
	Name = "Efeitos",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	ZIndex = 100,
	Parent = gui,
})

local function textoFlutuante(msg: string, cor: Color3, pai: Instance, pos: UDim2)
	local st = contornoTexto(C.Contorno, 3)
	local l = texto({
		Text = msg,
		Size = UDim2.fromOffset(200, 38),
		Position = pos,
		AnchorPoint = CENTRO,
		TextColor3 = cor,
		ZIndex = 10,
		Parent = pai,
		st,
	})
	local esc = make("UIScale", { Scale = 0.4, Parent = l })
	tween(esc, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
	tween(l, 0.9, { Position = pos - UDim2.fromOffset(0, 44), TextTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0.35)
	tween(st, 0.9, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0.35)
	Debris:AddItem(l, 1.4)
end

local function centroDe(obj: GuiObject): Vector2
	return obj.AbsolutePosition + obj.AbsoluteSize / 2
end

local function pontoInicial(): Vector2
	local cam = workspace.CurrentCamera
	local char = player.Character
	local raiz = char and char:FindFirstChild("HumanoidRootPart")
	if raiz then
		local p, naTela = cam:WorldToViewportPoint((raiz :: BasePart).Position)
		if naTela then
			return Vector2.new(p.X, p.Y)
		end
	end
	return cam.ViewportSize / 2
end

local girando = false
local function girarMoeda()
	if girando then
		return
	end
	girando = true
	local t = tween(moedaIcone, 0.09, { Size = UDim2.fromOffset(6, tamMoedaIcone.Y.Offset) }, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	t.Completed:Connect(function()
		local t2 = tween(moedaIcone, 0.12, { Size = tamMoedaIcone }, Enum.EasingStyle.Sine)
		t2.Completed:Connect(function()
			girando = false
		end)
	end)
end

local function voarMoedas(qtd: number, aoChegar: (number) -> ())
	local inicio = pontoInicial()
	local esc = escalaAtual()
	local chegaram = 0
	for i = 1, qtd do
		local m = iconeMoeda(math.floor(40 * esc), efeitos)
		m.Position = UDim2.fromOffset(inicio.X, inicio.Y)
		m.Rotation = math.random(-40, 40)
		local ang = math.random() * math.pi * 2
		local raio = math.random(50, 140) * esc
		local meio = inicio + Vector2.new(math.cos(ang), math.sin(ang)) * raio
		local t1 = tween(m, 0.35, { Position = UDim2.fromOffset(meio.X, meio.Y) }, Enum.EasingStyle.Back)
		t1.Completed:Connect(function()
			task.wait((i - 1) * 0.05)
			local alvo = centroDe(moedaIcone)
			local t2 = tween(m, 0.5, {
				Position = UDim2.fromOffset(alvo.X, alvo.Y),
				Size = UDim2.fromOffset(30 * esc, 30 * esc),
				Rotation = 0,
			}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			t2.Completed:Connect(function()
				m:Destroy()
				chegaram += 1
				aoChegar(chegaram)
			end)
		end)
	end
end

---------------------------------------------------------------------
-- LEVEL UP
---------------------------------------------------------------------
local levelUpAtivo: { overlay: Frame, conn: RBXScriptConnection }? = nil

local function fecharLevelUp(obj)
	obj.conn:Disconnect()
	obj.overlay:Destroy()
	if levelUpAtivo == obj then
		levelUpAtivo = nil
	end
end

local function mostrarLevelUp(nivel: number, recompensa: number)
	if levelUpAtivo then
		fecharLevelUp(levelUpAtivo)
	end
	som("LevelUp")
	local esc = escalaAtual()
	local vp = workspace.CurrentCamera.ViewportSize
	local cy = 0.46

	local overlay = make("Frame", {
		Name = "LevelUp",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(6, 12, 8),
		BackgroundTransparency = 1,
		ZIndex = 50,
		Parent = gui,
	})
	tween(overlay, 0.25, { BackgroundTransparency = 0.4 })

	local centro = make("Frame", {
		Size = UDim2.fromOffset(680, 680),
		Position = UDim2.fromScale(0.5, cy),
		AnchorPoint = CENTRO,
		BackgroundTransparency = 1,
		Parent = overlay,
	})
	local escCentro = make("UIScale", { Scale = 0, Parent = centro })
	tween(escCentro, 0.6, { Scale = esc }, Enum.EasingStyle.Back)

	-- raios girando
	local raios = make("Frame", {
		Size = UDim2.fromOffset(660, 660),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = CENTRO,
		BackgroundTransparency = 1,
		Parent = centro,
	})
	local transpRaio = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.28, 0.6),
		NumberSequenceKeypoint.new(0.5, 0.2),
		NumberSequenceKeypoint.new(0.72, 0.6),
		NumberSequenceKeypoint.new(1, 1),
	})
	for i = 0, 7 do
		make("Frame", {
			Size = UDim2.new(0, 64, 1, 0),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = CENTRO,
			Rotation = i * 22.5,
			BackgroundColor3 = if i % 2 == 0 then C.Ouro1 else Color3.fromRGB(255, 245, 190),
			BorderSizePixel = 0,
			Parent = raios,
			make("UIGradient", { Rotation = 90, Transparency = transpRaio }),
		})
	end
	local conn = RunService.RenderStepped:Connect(function(dt)
		raios.Rotation = (raios.Rotation + dt * 28) % 360
	end)

	-- brilho pulsando
	local brilho = make("Frame", {
		Size = UDim2.fromOffset(300, 300),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = CENTRO,
		BackgroundColor3 = C.Ouro1,
		BackgroundTransparency = 0.55,
		Parent = centro,
		corner(),
	})
	local escBrilho = make("UIScale", { Parent = brilho })
	TweenService:Create(escBrilho, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Scale = 1.12 }):Play()

	-- medalha do nível
	local medalha = make("Frame", {
		Size = UDim2.fromOffset(210, 210),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = CENTRO,
		BackgroundColor3 = C.Branco,
		Parent = centro,
		corner(),
		grad(C.XP1, C.XP2, 90),
		borda(C.Contorno, 8),
	})
	make("Frame", {
		Size = UDim2.fromScale(0.82, 0.82),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = CENTRO,
		BackgroundTransparency = 1,
		Parent = medalha,
		corner(),
		borda(C.Branco, 4, 0.45),
	})
	make("Frame", {
		Size = UDim2.fromScale(0.34, 0.14),
		Position = UDim2.fromScale(0.3, 0.22),
		AnchorPoint = CENTRO,
		Rotation = -35,
		BackgroundColor3 = C.Branco,
		BackgroundTransparency = 0.5,
		Parent = medalha,
		corner(),
	})
	local numero = texto({
		Text = tostring(nivel - 1),
		Size = UDim2.fromScale(0.72, 0.56),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = CENTRO,
		Parent = medalha,
		contornoTexto(C.Contorno, 6),
	})
	local escNumero = make("UIScale", { Parent = numero })
	task.delay(0.5, function()
		numero.Text = tostring(nivel)
		escNumero.Scale = 1.8
		tween(escNumero, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)
	end)

	-- título
	local titulo = texto({
		Text = "LEVEL UP!",
		Size = UDim2.fromOffset(640, 118),
		Position = UDim2.new(0.5, 0, 0.5, -190),
		AnchorPoint = CENTRO,
		Rotation = -4,
		Parent = centro,
		grad(Color3.fromRGB(255, 245, 160), C.Ouro2, 90),
		contornoTexto(C.Contorno, 7),
	})
	local escTitulo = make("UIScale", { Scale = 0, Parent = titulo })
	tween(escTitulo, 0.6, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0.15)

	local sub = texto({
		Text = "VOCÊ CHEGOU AO NÍVEL " .. nivel,
		Size = UDim2.fromOffset(600, 46),
		Position = UDim2.new(0.5, 0, 0.5, 150),
		AnchorPoint = CENTRO,
		Parent = centro,
		contornoTexto(C.Contorno, 4),
	})
	local escSub = make("UIScale", { Scale = 0, Parent = sub })
	tween(escSub, 0.4, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0.45)

	if recompensa > 0 then
		local pil = make("Frame", {
			Size = UDim2.fromOffset(260, 66),
			Position = UDim2.new(0.5, 0, 0.5, 222),
			AnchorPoint = CENTRO,
			BackgroundColor3 = C.Painel,
			Parent = centro,
			corner(),
			borda(C.Contorno, 4),
			grad(C.Branco, C.Cinza, 90),
		})
		local escPil = make("UIScale", { Scale = 0, Parent = pil })
		tween(escPil, 0.4, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0.7)
		local ic = iconeMoeda(58, pil)
		ic.Position = UDim2.new(0, 34, 0.5, 0)
		texto({
			Text = "+" .. formatar(recompensa),
			Size = UDim2.new(1, -90, 0.66, 0),
			Position = UDim2.new(0, 72, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = C.Ouro1,
			Parent = pil,
			contornoTexto(C.Contorno, 3.5),
		})
	end

	-- confete
	local CORES = { C.Ouro1, C.XP1, C.Saco1, C.Cheio1, C.Roxo1, C.Branco }
	local origem = Vector2.new(vp.X / 2, vp.Y * cy)
	for _ = 1, 70 do
		local c = make("Frame", {
			Size = UDim2.fromOffset(math.random(8, 14) * esc, math.random(14, 22) * esc),
			Position = UDim2.fromOffset(origem.X, origem.Y),
			AnchorPoint = CENTRO,
			Rotation = math.random(0, 360),
			BackgroundColor3 = CORES[math.random(#CORES)],
			BorderSizePixel = 0,
			Parent = overlay,
			cantos(2),
		})
		local ang = math.random() * math.pi * 2
		local dist = math.random(140, math.floor(math.max(vp.X * 0.5, 200)))
		local alvo = origem + Vector2.new(math.cos(ang) * dist, math.sin(ang) * dist * 0.6 - 140 * esc)
		local t1 = tween(c, math.random(45, 75) / 100, {
			Position = UDim2.fromOffset(alvo.X, alvo.Y),
			Rotation = c.Rotation + math.random(-180, 180),
		}, Enum.EasingStyle.Quart)
		t1.Completed:Connect(function()
			tween(c, math.random(150, 240) / 100, {
				Position = UDim2.fromOffset(alvo.X + math.random(-90, 90), vp.Y + 60),
				Rotation = c.Rotation + math.random(-540, 540),
			}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		end)
	end

	local obj = { overlay = overlay, conn = conn }
	levelUpAtivo = obj
	task.delay(3.1, function()
		if levelUpAtivo ~= obj then
			return
		end
		sumir(overlay, 0.45)
		tween(escCentro, 0.45, { Scale = esc * 1.15 })
		task.wait(0.5)
		fecharLevelUp(obj)
	end)
end

---------------------------------------------------------------------
-- LOJA
---------------------------------------------------------------------
-- Loja mantida como a única interface de compra, agora com camada EXCLUSIVA.
-- Não muda economia, ids de compra, nem as abas do Menu do Jogador.
local lojaGui = make("ScreenGui", {
    Name = "LojaCortadoresGui", DisplayOrder = 80, ResetOnSpawn = false,
    IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = playerGui,
})
local lojaRaiz = make("Frame", {
	Name = "LojaRaiz",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Visible = false,
	ZIndex = 40,
	Parent = lojaGui,
})
local lojaFundo = make("TextButton", {
	Text = "",
	AutoButtonColor = false,
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 1,
	Parent = lojaRaiz,
})
local loja = make("Frame", {
	Name = "Loja",
	Active = true,
	Size = UDim2.fromOffset(760, 520),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = CENTRO,
	BackgroundColor3 = C.Painel,
	Parent = lojaRaiz,
	cantos(30),
	borda(C.Contorno, 5),
	grad(Color3.fromRGB(45, 72, 50), Color3.fromRGB(20, 37, 30), 90),
})
local escLoja = make("UIScale", { Parent = loja })
local function escalaLojaAtual()
    local vp = workspace.CurrentCamera.ViewportSize
    -- Encaixar no viewport preservando tamanhos internos e sem cortar os controles.
    return math.max(0.30, math.min((vp.X - 24) / 760, (vp.Y - 34) / 520, 1.10))
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if lojaRaiz.Visible then escLoja.Scale = escalaLojaAtual() end
end)

local fita = make("Frame", {
	Size = UDim2.fromOffset(270, 62),
    Position = UDim2.new(0.5, 0, 0, 12),
    AnchorPoint = Vector2.new(0.5, 0),
	BackgroundColor3 = C.Branco,
	Parent = loja,
	cantos(22),
	grad(C.Ouro1, C.Ouro2, 90),
	borda(C.Contorno, 4.5),
})
texto({
	Text = "🛒 LOJA",
	Size = UDim2.new(1, -40, 0.7, 0),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = CENTRO,
	Parent = fita,
	contornoTexto(C.Contorno, 3.5),
})

local fechar = make("TextButton", {
	Text = "",
	AutoButtonColor = false,
	Size = UDim2.fromOffset(52, 52),
    Position = UDim2.new(1, -14, 0, 16),
    AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = C.Branco,
	Parent = loja,
	cantos(18),
	grad(C.Vermelho1, C.Vermelho2, 90),
	borda(C.Contorno, 4.5),
})
texto({
	Text = "X",
	Size = UDim2.fromScale(0.6, 0.6),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = CENTRO,
	Parent = fechar,
	contornoTexto(C.Contorno, 3),
})
animarBotao(fechar)

local lista = make("ScrollingFrame", {
	Size = UDim2.new(1, -36, 1, -116),
    Position = UDim2.new(0.5, 0, 0, 98),
    AnchorPoint = Vector2.new(0.5, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 8,
	ScrollBarImageColor3 = C.XP1,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	Parent = loja,
	make("UIGridLayout", {
		CellSize = UDim2.fromOffset(164, 252),
		CellPadding = UDim2.fromOffset(14, 16),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
	make("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 12),
	}),
})

type Cartao = { item: any, grad: UIGradient, lbl: TextLabel, ic: Frame }
local cartoes: { [string]: Cartao } = {}

for ordem, item in Config.Itens do
	local card = make("Frame", {
		Name = item.Id,
		LayoutOrder = ordem,
		BackgroundColor3 = C.Card,
		Parent = lista,
		cantos(20),
		borda(C.Contorno, 3.5),
	})
	local topo = make("Frame", {
		Size = UDim2.new(1, -14, 0, 108),
		Position = UDim2.fromOffset(7, 7),
		BackgroundColor3 = C.Branco,
		Parent = card,
		cantos(15),
		grad(item.Cor1, item.Cor2, 90),
	})
	make("Frame", {
		Size = UDim2.new(1, -16, 0.3, 0),
		Position = UDim2.fromOffset(8, 6),
		BackgroundColor3 = C.Branco,
		BackgroundTransparency = 0.75,
		Parent = topo,
		cantos(10),
	})
	texto({
		Text = item.Icone,
		Size = UDim2.fromScale(0.6, 0.68),
		Position = UDim2.fromScale(0.5, 0.52),
		AnchorPoint = CENTRO,
		Parent = topo,
	})
	texto({
		Text = item.Nome,
		Size = UDim2.new(1, -14, 0, 26),
		Position = UDim2.new(0.5, 0, 0, 132),
		AnchorPoint = CENTRO,
		Parent = card,
		contornoTexto(C.Contorno, 2.5),
	})
	texto({
		Text = item.Descricao,
		Font = FONTE2,
		TextColor3 = Color3.fromRGB(190, 235, 190),
		Size = UDim2.new(1, -18, 0, 20),
		Position = UDim2.new(0.5, 0, 0, 162),
		AnchorPoint = CENTRO,
		Parent = card,
	})
	local botao = make("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, -18, 0, 48),
		Position = UDim2.new(0.5, 0, 1, -10),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = C.Branco,
		Parent = card,
		cantos(15),
		borda(C.Contorno, 3.5),
	})
	local gBotao = grad(C.Verde1, C.Verde2, 90)
	gBotao.Parent = botao
	local ic = iconeMoeda(30, botao)
	ic.Position = UDim2.new(0, 24, 0.5, 0)
	local lbl = texto({
		Text = formatar(item.Preco),
		Size = UDim2.new(1, -54, 0.6, 0),
		Position = UDim2.new(0, 44, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Parent = botao,
		contornoTexto(C.Contorno, 2.5),
	})
	animarBotao(botao)
	botao.Activated:Connect(function()
		local ev = ReplicatedStorage:FindFirstChild("ComprarItem")
		if ev then
			ev:FireServer(item.Id)
		else
			notificar("Loja indisponível (falta o servidor)", "erro")
		end
	end)
	cartoes[item.Id] = { item = item, grad = gBotao, lbl = lbl, ic = ic }
end

local function estiloBotao(c: Cartao, msg: string, comMoeda: boolean, c1: Color3, c2: Color3)
	c.lbl.Text = msg
	c.ic.Visible = comMoeda
	if comMoeda then
		c.lbl.Size = UDim2.new(1, -54, 0.6, 0)
		c.lbl.Position = UDim2.new(0, 44, 0.5, 0)
		c.lbl.AnchorPoint = Vector2.new(0, 0.5)
	else
		c.lbl.Size = UDim2.new(1, -20, 0.6, 0)
		c.lbl.Position = UDim2.fromScale(0.5, 0.5)
		c.lbl.AnchorPoint = CENTRO
	end
	c.grad.Color = ColorSequence.new(c1, c2)
end

local function atualizarLoja()
	local lista = player:GetAttribute("Comprados") or ""
	local tem = {}
	for id in string.gmatch(lista, "[^,]+") do
		tem[id] = true
	end
	local equipado = player:GetAttribute("Cortador")
	local moedas = player:GetAttribute("Moedas") or 0
	for id, c in cartoes do
		if equipado == id then
			estiloBotao(c, "EQUIPADO", false, Color3.fromRGB(160, 160, 178), Color3.fromRGB(100, 100, 122))
		elseif tem[id] then
			estiloBotao(c, "EQUIPAR", false, C.Saco1, C.Saco2)
		elseif moedas >= c.item.Preco then
			estiloBotao(c, formatar(c.item.Preco), true, C.Verde1, C.Verde2)
		else
			estiloBotao(c, formatar(c.item.Preco), true, C.Vermelho1, C.Vermelho2)
		end
	end
end

local lojaAberta = false
player:SetAttribute("LojaAberta", false)
local function abrirLoja()
    local forest = player.PlayerGui:FindFirstChild("ForestCommerceUI")
    local close = forest and forest:FindFirstChild("Close")
    if close then close:Fire(true) end
	if lojaAberta then
		return
	end
	lojaAberta = true
	player:SetAttribute("LojaAberta", true)
	atualizarLoja()
	lojaRaiz.Visible = true
	lojaFundo.BackgroundTransparency = 1
	tween(lojaFundo, 0.25, { BackgroundTransparency = 0.45 })
	escLoja.Scale = 0.90 * escalaLojaAtual()
    tween(escLoja, 0.30, { Scale = escalaLojaAtual() }, Enum.EasingStyle.Back)
end

local function fecharLoja()
	if not lojaAberta then
		return
	end
	lojaAberta = false
	player:SetAttribute("LojaAberta", false)
	tween(lojaFundo, 0.2, { BackgroundTransparency = 1 })
	local t = tween(escLoja, 0.22, { Scale = 0.90 * escalaLojaAtual() }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	t.Completed:Connect(function()
		if not lojaAberta then
			lojaRaiz.Visible = false
		end
	end)
end

fechar.Activated:Connect(fecharLoja)
make("BindableEvent", { Name = "AbrirLoja", Parent = gui }).Event:Connect(abrirLoja)
make("BindableEvent", { Name = "FecharLoja", Parent = gui }).Event:Connect(fecharLoja)
lojaFundo.Activated:Connect(fecharLoja)
for _, nome in { "Moedas", "Cortador", "Comprados" } do
	player:GetAttributeChangedSignal(nome):Connect(function()
		if lojaAberta then
			atualizarLoja()
		end
	end)
end

---------------------------------------------------------------------
-- MENU LATERAL
---------------------------------------------------------------------
local menu = make("Frame", {
	Name = "Menu",
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 18, 0.5, 30),
	Size = UDim2.fromOffset(86, 440),
	BackgroundTransparency = 1,
	Parent = gui,
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
})
novaEscala(menu)

local BotaoClicado = make("BindableEvent", { Name = "BotaoClicado", Parent = gui })

local function botaoMenu(nome: string, icone: string, c1: Color3, c2: Color3, ordem: number, acao: (() -> ())?)
	local b = make("TextButton", {
		Name = nome,
		LayoutOrder = ordem,
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(80, 80),
		BackgroundColor3 = C.Branco,
		Parent = menu,
		cantos(24),
        grad(c1:Lerp(Color3.new(1,1,1), 0.08), c2, 90),
        borda(C.Contorno, 4),
	})
	make("Frame", {
		Size = UDim2.new(1, -14, 0.3, 0),
		Position = UDim2.fromOffset(7, 6),
		BackgroundColor3 = C.Branco,
		BackgroundTransparency = 0.72,
		Parent = b,
		cantos(14),
	})
	texto({
		Text = icone,
		Size = UDim2.fromScale(0.56, 0.5),
		Position = UDim2.fromScale(0.5, 0.4),
		AnchorPoint = CENTRO,
		Parent = b,
	})
	texto({
		Text = string.upper(nome),
		Size = UDim2.new(0.92, 0, 0, 19),
		Position = UDim2.new(0.5, 0, 1, -15),
		AnchorPoint = CENTRO,
		Parent = b,
		contornoTexto(C.Contorno, 2.2),
	})
    -- Acabamento em relevo com a mesma linguagem colorida da HUD original.
    local aro = make("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1.5,
        Transparency = 0.52, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = b })
    b.MouseEnter:Connect(function() tween(aro, 0.14, { Transparency = 0.16 }) end)
    b.MouseLeave:Connect(function() tween(aro, 0.16, { Transparency = 0.52 }) end)
    animarBotao(b)
    b.Activated:Connect(function()
        BotaoClicado:Fire(nome)
		if acao then
			acao()
		end
	end)
	return b
end

local function emBreve()
	notificar("🚧 Em breve!", "info")
end

-- [PlayerMenu] botão do Menu do Jogador (abre PlayerGui.PlayerMenuGui) — adicionado em 08/11/2026
local function abrirMenuJogador(aba: string)
	-- O controlador do menu carrega em outro LocalScript; o primeiro clique não pode ser perdido.
	task.spawn(function()
		local mg = playerGui:FindFirstChild("PlayerMenuGui") or playerGui:WaitForChild("PlayerMenuGui", 8)
		local ev = mg and (mg:FindFirstChild("Abrir") or mg:WaitForChild("Abrir", 3))
		if ev and ev:IsA("BindableEvent") then
			ev:Fire(aba)
		else
			warn("[CorteDescubra/UI] PlayerMenuGui não carregou; confira erros no Output.")
			notificar("Menu indisponível. Verifique o Output do Studio.", "erro")
		end
	end)
end
botaoMenu("Menu", "📖", Color3.fromRGB(120, 235, 160), Color3.fromRGB(30, 150, 90), 0, function() abrirMenuJogador("Perfil") end)
botaoMenu("Loja", "🛒", C.Ouro1, C.Ouro2, 1, abrirLoja)
botaoMenu("Upgrades", "⚡", C.Saco1, C.Saco2, 2, function() abrirMenuJogador("Equipamentos") end)
botaoMenu("Pets", "🐾", Color3.fromRGB(255, 130, 190), Color3.fromRGB(220, 60, 140), 3, emBreve)
botaoMenu("Config", "⚙️", Color3.fromRGB(180, 180, 200), Color3.fromRGB(110, 110, 135), 4, function() abrirMenuJogador("Configuracoes") end)

botaoMais.Activated:Connect(function()
	BotaoClicado:Fire("ComprarMoedas")
	emBreve()
end)

---------------------------------------------------------------------
-- LIGAÇÃO COM OS ATRIBUTOS DO PLAYER
---------------------------------------------------------------------
local pronto = false -- evita animação de moedas/level up no momento em que o jogador entra
task.delay(2, function()
	pronto = true
end)

-- MOEDAS
local function attr(nome: string, padrao: any)
	local v = player:GetAttribute(nome)
	if v == nil then
		return padrao
	end
	return v
end

local moedasAtuais = attr("Moedas", 0)
local valorMostrado = make("NumberValue", { Value = moedasAtuais, Parent = script })
moedasTexto.Text = formatar(moedasAtuais)
valorMostrado.Changed:Connect(function(v)
	moedasTexto.Text = formatar(v)
end)

local tweenContador: Tween? = nil
local function animarContador(alvo: number, dur: number)
	if tweenContador then
		tweenContador:Cancel()
	end
	tweenContador = tween(valorMostrado, dur, { Value = alvo }, Enum.EasingStyle.Quad)
end

player:GetAttributeChangedSignal("Moedas"):Connect(function()
	local novo = attr("Moedas", 0)
	local delta = novo - moedasAtuais
	moedasAtuais = novo
	if not pronto then
		valorMostrado.Value = novo
		return
	end
	if delta > 0 then
		local n = math.clamp(math.floor(math.log10(delta + 1) * 3) + 2, 3, 12)
		voarMoedas(n, function(k)
			pulso(bumpMoeda, 1.1)
			girarMoeda()
			som("Moeda")
			if k == 1 then
				animarContador(moedasAtuais, 0.8)
				textoFlutuante("+" .. formatar(delta), C.Ouro1, topoDir, UDim2.new(0.5, 20, 1, 16))
			end
		end)
	elseif delta < 0 then
		animarContador(novo, 0.45)
		textoFlutuante("-" .. formatar(-delta), C.Vermelho1, topoDir, UDim2.new(0.5, 20, 1, 16))
		moedasTexto.TextColor3 = C.Vermelho1
		tween(moedasTexto, 0.6, { TextColor3 = C.Branco })
	end
end)

-- XP / NÍVEL
local animandoNivel = false
local function atualizarXP(instantaneo: boolean)
	local xp = attr("XP", 0)
	local mx = math.max(attr("XPMax", 1), 1)
	local p = math.clamp(xp / mx, 0, 1)
	xpTexto.Text = formatar(xp) .. " / " .. formatar(mx) .. " XP"
	if instantaneo then
		xpFill.Size = UDim2.fromScale(p, 1)
	else
		tween(xpFill, 0.35, { Size = UDim2.fromScale(p, 1) })
	end
end

player:GetAttributeChangedSignal("XP"):Connect(function()
	if not animandoNivel then
		atualizarXP(false)
	end
end)
player:GetAttributeChangedSignal("XPMax"):Connect(function()
	if not animandoNivel then
		atualizarXP(false)
	end
end)

local nivelAtual = attr("Nivel", 1)
nivelTexto.Text = tostring(nivelAtual)
player:GetAttributeChangedSignal("Nivel"):Connect(function()
	local novo = attr("Nivel", 1)
	local antigo = nivelAtual
	nivelAtual = novo
	nivelTexto.Text = tostring(novo)
	if not pronto or novo <= antigo then
		atualizarXP(true)
		return
	end
	-- barra enche até o fim, zera e vai pro valor novo
	animandoNivel = true
	local t = tween(xpFill, 0.3, { Size = UDim2.fromScale(1, 1) })
	t.Completed:Connect(function()
		xpFill.Size = UDim2.fromScale(0, 1)
		animandoNivel = false
		atualizarXP(false)
	end)
	pulso(badgeEscala, 1.35)
	local recompensa = 0
	for n = antigo + 1, novo do
		recompensa += Config.RecompensaNivel(n)
	end
	mostrarLevelUp(novo, recompensa)
end)

-- SACO
local sacoCheio = false
local sacoAnterior = attr("Saco", 0)
local pulsoAviso: Tween? = nil

local function atualizarSaco(instantaneo: boolean)
	local s = attr("Saco", 0)
	local m = math.max(attr("SacoMax", 1), 1)
	local p = math.clamp(s / m, 0, 1)
	sacoTexto.Text = "🎒 " .. formatar(s) .. " / " .. formatar(m)
	if instantaneo then
		sacoFill.Size = UDim2.fromScale(p, 1)
	else
		tween(sacoFill, 0.25, { Size = UDim2.fromScale(p, 1) })
		if s > sacoAnterior then
			pulso(sacoEscala, 1.12)
		end
	end
	sacoAnterior = s

	local cheio = s >= m
	if cheio == sacoCheio then
		return
	end
	sacoCheio = cheio
	local c1 = if cheio then C.Cheio1 else C.Saco1
	local c2 = if cheio then C.Cheio2 else C.Saco2
	sacoGrad.Color = ColorSequence.new(c1, c2)
	sacoIconeGrad.Color = ColorSequence.new(c1, c2)
	avisoCheio.Visible = cheio
	if pulsoAviso then
		pulsoAviso:Cancel()
		pulsoAviso = nil
	end
	if cheio then
		avisoEscala.Scale = 0
		local pop = tween(avisoEscala, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
		pop.Completed:Connect(function(estado)
			if estado == Enum.PlaybackState.Completed and sacoCheio then
				pulsoAviso = TweenService:Create(
					avisoEscala,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{ Scale = 1.08 }
				)
				pulsoAviso:Play()
			end
		end)
		if not instantaneo then
			notificar("🎒 Saco cheio! Vá vender a grama", "erro")
		end
	end
end

player:GetAttributeChangedSignal("Saco"):Connect(function()
	atualizarSaco(false)
end)
player:GetAttributeChangedSignal("SacoMax"):Connect(function()
	atualizarSaco(false)
end)

-- estado inicial
atualizarXP(true)
atualizarSaco(true)

