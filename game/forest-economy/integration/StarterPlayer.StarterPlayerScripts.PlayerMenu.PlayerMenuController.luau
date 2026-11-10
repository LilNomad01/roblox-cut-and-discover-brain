--[[
	PlayerMenu.PlayerMenuController — abre/fecha o Menu do Jogador, navegação por abas,
	responsividade, animações e atalhos.
	Abrir:  tecla M (alterna) • K (vai direto para Habilidades) • Select no controle
	        botão "MENU" no HUD (HUDCortaGrama) • PlayerGui.PlayerMenuGui.Abrir:Fire("Habilidades")
	Fechar: Esc • B no controle • botão X • toque fora do painel • M de novo
	Enquanto aberto: personagem parado, HUDs ocultos, câmera não dá zoom com a roda,
	atributo SkillTreeOpen=true (o GameClient para de cortar) e MenuJogadorAberto=true.
]]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local HapticService = game:GetService("HapticService")

local Theme = require(script.Parent:WaitForChild("Theme"))
local UI = require(script.Parent:WaitForChild("UI"))
local Data = require(script.Parent:WaitForChild("MenuData"))
local C, F, T = Theme.Cor, Theme.Fonte, Theme.Tempo

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ABAS = {
	{ id = "Perfil", nome = "Perfil", icone = "👤", sub = "Seu progresso e estatísticas", mod = "PlayerProfilePanel" },
	{ id = "Habilidades", nome = "Habilidades", icone = "🌳", sub = "Gaste Pontos de Habilidade (PH) na árvore", mod = "SkillsPanel" },
	{ id = "Equipamentos", nome = "Equipamentos", icone = "🧰", sub = "Ferramentas e cortadores", mod = "EquipmentPanel" },
	{ id = "Exploracao", nome = "Exploração", icone = "🗺", sub = "Regiões do mundo", mod = "ExplorationPanel" },
	{ id = "Missoes", nome = "Missões", icone = "📜", sub = "Objetivos que o jogo acompanha", mod = "QuestsPanel" },
	{ id = "Configuracoes", nome = "Configurações", icone = "⚙", sub = "Áudio, câmera e desempenho", mod = "SettingsPanel" },
}
local HUDS = { "GameHUD", "HUDCortaGrama", "SomToggle", "BarraFerramentas", "SkillActionBar", "SkillTreeGui" }

local Controller = {}
local aberto, animando = false, false
local abaAtual = "Perfil"
local paineis = {}
local botoesAba = {}
local hudsOcultos = {}
local compacto = false
local controles
local g = {} -- referências de UI

local function obterControles()
	if controles ~= nil then return controles end
	local ok, mod = pcall(function()
		return require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 5))
	end)
	controles = ok and mod and mod:GetControls() or false
	return controles
end

------------------------------------------------------------------ toast
local toastId = 0
local function toast(texto: string, cor: Color3?)
	toastId += 1
	local meu = toastId
	g.toast.Text = texto
	g.toastSt.Color = cor or C.Verde
	g.toast.Visible = true
	g.toast.Position = UDim2.new(0.5, 0, 1, 10)
	g.toast.TextTransparency = 1
	g.toast.BackgroundTransparency = 1
	UI.tween(g.toast, T.Mola, { Position = UDim2.new(0.5, 0, 1, -16), TextTransparency = 0, BackgroundTransparency = 0.05 })
	task.delay(2.4, function()
		if meu ~= toastId then return end
		UI.tween(g.toast, T.Medio, { TextTransparency = 1, BackgroundTransparency = 1 })
		task.delay(0.25, function() if meu == toastId then g.toast.Visible = false end end)
	end)
end

local function vibrar()
	if player:GetAttribute("VibracaoLigada") == false then return end
	pcall(function()
		local gp = Enum.UserInputType.Gamepad1
		if UserInputService:GetGamepadConnected(gp) and HapticService:IsVibrationSupported(gp)
			and HapticService:IsMotorSupported(gp, Enum.VibrationMotor.Small) then
			HapticService:SetMotor(gp, Enum.VibrationMotor.Small, 0.6)
			task.delay(0.15, function() HapticService:SetMotor(gp, Enum.VibrationMotor.Small, 0) end)
		end
	end)
end

------------------------------------------------------------------ abas
local ctx
local function painel(id: string)
	if paineis[id] then return paineis[id] end
	local info
	for _, a in ipairs(ABAS) do if a.id == id then info = a end end
	local holder = UI.new("Frame", { Name = "Aba_" .. id, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		Visible = false, Parent = g.conteudo })
	-- Erro em uma aba NÃO pode deixar o menu todo vazio nem derrubar o controlador.
	local ok, p = pcall(function()
		local mod = require(script.Parent:WaitForChild(info.mod, 8))
		return mod.new(holder, ctx)
	end)
	if not ok then
		warn("[PlayerMenu] Erro ao criar a aba " .. id .. ": " .. tostring(p))
		holder:ClearAllChildren()
		UI.titulo({ Text = "NÃO FOI POSSÍVEL ABRIR " .. string.upper(info.nome), TextSize = 20,
			Position = UDim2.fromOffset(20, 22), Size = UDim2.new(1, -40, 0, 36), Parent = holder })
		UI.texto({ Text = "A interface encontrou um erro. Veja a mensagem [PlayerMenu] no Output do Studio.",
			TextSize = 14, Position = UDim2.fromOffset(20, 68), Size = UDim2.new(1, -40, 0, 70), Parent = holder })
		p = { holder = holder, mostrar = function() end, esconder = function() end }
	else
		p.holder = holder
		if p.layout then
			local okLayout, erroLayout = pcall(function() p:layout(compacto) end)
			if not okLayout then warn("[PlayerMenu] layout de " .. id .. ": " .. tostring(erroLayout)) end
		end
	end
	paineis[id] = p
	return p
end

local function selecionarAba(id: string, semAnim: boolean?)
	local info
	for _, a in ipairs(ABAS) do if a.id == id then info = a end end
	if not info then return end
	for aid, panel in pairs(paineis) do
		if panel and panel.holder and aid ~= id then
			panel.holder.Visible = false
			if panel.esconder then panel:esconder() end
		end
	end
	abaAtual = id
	g.titulo.Text = info.icone .. "  " .. string.upper(info.nome)
	g.sub.Text = info.sub
	for aid, b in pairs(botoesAba) do
		local sel = aid == id
		UI.tween(b, T.Rapido, { BackgroundTransparency = sel and 0 or 1 })
		b.Rotulo.TextColor3 = sel and C.Texto or C.Suave
		b.Icone.TextColor3 = sel and C.Ouro or C.Suave
	end
	local b = botoesAba[id]
	if b then
		UI.tween(g.indicador, semAnim and TweenInfo.new(0) or T.Mola,
			{ Position = UDim2.fromOffset(0, b.AbsolutePosition.Y - g.listaAbas.AbsolutePosition.Y + 8) })
	end
	local p = painel(id)
	p.holder.Visible = true
	if not semAnim then
		p.holder.Position = UDim2.fromOffset(18, 0)
		UI.tween(p.holder, T.Medio, { Position = UDim2.fromOffset(0, 0) })
	end
	if p.mostrar then
		local okMostrar, erroMostrar = pcall(function() p:mostrar() end)
		if not okMostrar then warn("[PlayerMenu] Falha ao mostrar " .. id .. ": " .. tostring(erroMostrar)) end
	end
end

------------------------------------------------------------------ layout responsivo
local function relayout()
	local abs = g.gui.AbsoluteSize
	if abs.X < 10 then return end
	local novoCompacto = abs.Y < 560 or abs.X < 940
	local w = math.min(abs.X - (novoCompacto and 16 or 48), 1140)
	local h = math.min(abs.Y - (novoCompacto and 12 or 48), 720)
	g.painel.Size = UDim2.fromOffset(w, h)
	local larg = novoCompacto and 64 or 196
	g.lateral.Size = UDim2.new(0, larg, 1, 0)
	g.direita.Position = UDim2.fromOffset(larg, 0)
	g.direita.Size = UDim2.new(1, -larg, 1, 0)
	g.logo.Visible = not novoCompacto
	g.logoMini.Visible = novoCompacto
	g.dicaTeclas.Visible = not novoCompacto
	g.listaAbas.Position = UDim2.fromOffset(0, novoCompacto and 56 or 96)
	for _, b in pairs(botoesAba) do
		b.Rotulo.Visible = not novoCompacto
		b.Icone.Position = novoCompacto and UDim2.new(0.5, -14, 0, 0) or UDim2.fromOffset(16, 0)
		b.Size = UDim2.new(1, -16, 0, novoCompacto and 44 or 46)
	end
	g.cab.Size = UDim2.new(1, 0, 0, novoCompacto and 44 or 62)
	g.sub.Visible = not novoCompacto
	g.titulo.TextSize = novoCompacto and 18 or 24
	g.conteudo.Position = UDim2.fromOffset(novoCompacto and 10 or 20, novoCompacto and 48 or 70)
	g.conteudo.Size = UDim2.new(1, novoCompacto and -20 or -40, 1, novoCompacto and -58 or -88)
	if novoCompacto ~= compacto then
		compacto = novoCompacto
		for _, p in pairs(paineis) do if p.layout then p:layout(compacto) end end
	end
	task.defer(function()
		local b = botoesAba[abaAtual]
		if b then g.indicador.Position = UDim2.fromOffset(0, b.AbsolutePosition.Y - g.listaAbas.AbsolutePosition.Y + 8) end
	end)
end

------------------------------------------------------------------ abrir / fechar
local function bloquearCamera(_, estado)
	return Enum.ContextActionResult.Sink
end

function Controller.abrir(aba: string?)
    local forest = playerGui:FindFirstChild("ForestCommerceUI")
    local close = forest and forest:FindFirstChild("Close")
    if close then close:Fire() end
	if aba then abaAtual = aba end
	-- Ao migrar da loja externa para o menu, feche a loja primeiro.
	local hud = playerGui:FindFirstChild("HUDCortaGrama")
	local fecharLoja = hud and hud:FindFirstChild("FecharLoja")
	if fecharLoja and fecharLoja:IsA("BindableEvent") then fecharLoja:Fire() end
	if aberto then
		selecionarAba(abaAtual)
		return
	end
	if animando then return end
	aberto = true
	player:SetAttribute("MenuJogadorAberto", true)
	player:SetAttribute("SkillTreeOpen", true)
	for _, nome in ipairs(HUDS) do
		local h = playerGui:FindFirstChild(nome)
		if h and h:IsA("ScreenGui") and h.Enabled then
			hudsOcultos[h] = true
			h.Enabled = false
		end
	end
	local ctl = obterControles()
	if ctl then pcall(function() ctl:Disable() end) end
	ContextActionService:BindActionAtPriority("PlayerMenuSink", bloquearCamera, false, 3000,
		Enum.KeyCode.I, Enum.KeyCode.O) -- não bloquear scroll dos painéis de Perfil/Config

	g.fundoGui.Enabled = true
	g.gui.Enabled = true
	g.dim.BackgroundTransparency = 1
	UI.tween(g.dim, T.Medio, { BackgroundTransparency = 0.38 })
	g.escala.Scale = 0.9
	UI.tween(g.escala, T.Abrir, { Scale = 1 })
	local blur = Lighting:FindFirstChild("PlayerMenuBlur")
	if not blur then
		blur = Instance.new("BlurEffect")
		blur.Name = "PlayerMenuBlur"
		blur.Size = 0
		blur.Parent = Lighting
	end
	blur.Enabled = true
	UI.tween(blur, T.Medio, { Size = player:GetAttribute("QualidadeSimples") and 0 or 12 })
	UI.som("Abrir")
	relayout()
	selecionarAba(abaAtual, true)
	if UserInputService.GamepadEnabled then
		task.defer(function() GuiService.SelectedObject = botoesAba[abaAtual] end)
	end
end

function Controller.fechar()
	if not aberto or animando then return end
	aberto = false
	animando = true
	UI.som("Fechar")
	local p = paineis[abaAtual]
	if p and p.esconder then p:esconder() end
	UI.tween(g.dim, T.Fechar, { BackgroundTransparency = 1 })
	UI.tween(g.escala, T.Fechar, { Scale = 0.92 })
	local blur = Lighting:FindFirstChild("PlayerMenuBlur")
	if blur then UI.tween(blur, T.Fechar, { Size = 0 }) end
	task.delay(0.17, function()
		g.gui.Enabled = false
		g.fundoGui.Enabled = false
		if blur then blur.Enabled = false end
		animando = false
	end)
	for h in pairs(hudsOcultos) do if h.Parent then h.Enabled = true end end
	table.clear(hudsOcultos)
	local ctl = obterControles()
	if ctl then pcall(function() ctl:Enable() end) end
	ContextActionService:UnbindAction("PlayerMenuSink")
	player:SetAttribute("MenuJogadorAberto", false)
	player:SetAttribute("SkillTreeOpen", false)
	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(g.gui) then GuiService.SelectedObject = nil end
end

function Controller.alternar(aba: string?)
	if aberto and (aba == nil or aba == abaAtual) then Controller.fechar() else Controller.abrir(aba) end
end

------------------------------------------------------------------ construção
local function construir()
	local velho = playerGui:FindFirstChild("PlayerMenuGui")
	if velho then velho:Destroy() end
	local velhoF = playerGui:FindFirstChild("PlayerMenuFundo")
	if velhoF then velhoF:Destroy() end

	-- fundo escuro em tela cheia (inclui a barra do topo)
	local fundoGui = UI.new("ScreenGui", { Name = "PlayerMenuFundo", ResetOnSpawn = false, IgnoreGuiInset = true,
		DisplayOrder = 29, Enabled = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = playerGui })
	g.fundoGui = fundoGui
	local dim = UI.new("TextButton", { Name = "Fora", Text = "", AutoButtonColor = false, Modal = true,
		BackgroundColor3 = Color3.fromRGB(4, 8, 10), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = fundoGui })
	UI.new("UIScale", { Parent = dim })
	g.dim = dim
	dim.Activated:Connect(function() Controller.fechar() end)

	local gui = UI.new("ScreenGui", { Name = "PlayerMenuGui", ResetOnSpawn = false, IgnoreGuiInset = false,
		DisplayOrder = 30, Enabled = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = playerGui })
	pcall(function() gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets end)
	g.gui = gui
	local ev = UI.new("BindableEvent", { Name = "Abrir", Parent = gui })
	ev.Event:Connect(function(aba) Controller.abrir(type(aba) == "string" and aba or nil) end)
	local evAlt = UI.new("BindableEvent", { Name = "Alternar", Parent = gui })
	evAlt.Event:Connect(function(aba) Controller.alternar(type(aba) == "string" and aba or nil) end)

	local painelF = UI.new("Frame", { Name = "Painel", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(900, 600), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Active = true, Parent = gui })
	g.painel = painelF
	UI.canto(20).Parent = painelF
	UI.contorno(Color3.fromRGB(90, 130, 120), 1.5, 0.35).Parent = painelF
	UI.grad(C.Fundo2, C.Fundo1, 100).Parent = painelF
	g.escala = UI.new("UIScale", { Name = "Abrir", Parent = painelF })
	-- brilho verde no topo
	local brilho = UI.new("Frame", { BackgroundColor3 = C.Verde, BackgroundTransparency = 0.88, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 120), ZIndex = 1, Parent = painelF })
	UI.canto(20).Parent = brilho
	UI.new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(0, 1), Parent = brilho })

	-- lateral
	local lateral = UI.new("Frame", { Name = "Lateral", BackgroundColor3 = C.Lateral, BackgroundTransparency = 0.15,
		Size = UDim2.new(0, 196, 1, 0), BorderSizePixel = 0, ZIndex = 2, Parent = painelF })
	UI.canto(20).Parent = lateral
	g.lateral = lateral
	g.logo = UI.titulo({ Text = "CORTE &\nDESCUBRA", TextSize = 22, TextColor3 = C.Verde, Position = UDim2.fromOffset(18, 16),
		Size = UDim2.new(1, -30, 0, 56), TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 3, Parent = lateral })
	UI.contorno(Color3.fromRGB(10, 40, 20), 2, 0).Parent = g.logo
	g.logo:FindFirstChildOfClass("UIStroke").ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	g.logoMini = UI.titulo({ Text = "🌿", TextSize = 26, Size = UDim2.new(1, 0, 0, 48), TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 3, Visible = false, Parent = lateral })

	local listaAbas = UI.new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 96), Size = UDim2.new(1, 0, 1, -150),
		ZIndex = 3, Parent = lateral })
	g.listaAbas = listaAbas
	UI.lista(6, false, Enum.HorizontalAlignment.Center).Parent = listaAbas
	g.indicador = UI.new("Frame", { BackgroundColor3 = C.Verde, BorderSizePixel = 0, Size = UDim2.fromOffset(4, 30),
		ZIndex = 6, Parent = lateral })
	UI.canto(2).Parent = g.indicador
	for i, a in ipairs(ABAS) do
		local b = UI.botao({ Name = a.id, Text = "", Cor = C.CardClaro, SemContorno = true, Raio = 12, LayoutOrder = i,
			Size = UDim2.new(1, -16, 0, 46), BackgroundTransparency = 1, ZIndex = 4, Parent = listaAbas })
		b.SelectionImageObject = nil
		UI.texto({ Name = "Icone", Text = a.icone, TextSize = 20, Font = F.Forte, Size = UDim2.fromOffset(28, 46),
			Position = UDim2.fromOffset(16, 0), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = C.Suave, ZIndex = 5, Parent = b })
		UI.titulo({ Name = "Rotulo", Text = a.nome, TextSize = 16, Position = UDim2.fromOffset(52, 0), Size = UDim2.new(1, -56, 1, 0),
			TextColor3 = C.Suave, ZIndex = 5, Parent = b })
		b.Activated:Connect(function() selecionarAba(a.id) end)
		botoesAba[a.id] = b
	end
	g.dicaTeclas = UI.texto({ Text = "M abre/fecha  •  K árvore  •  Esc fecha", TextSize = 10, TextColor3 = C.Apagado,
		AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 16, 1, -14), Size = UDim2.new(1, -24, 0, 28), ZIndex = 3, Parent = lateral })

	-- lado direito: cabeçalho + conteúdo
	local direita = UI.new("Frame", { Name = "Direita", BackgroundTransparency = 1, Position = UDim2.fromOffset(196, 0),
		Size = UDim2.new(1, -196, 1, 0), ZIndex = 2, Parent = painelF })
	g.direita = direita
	local cab = UI.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 62), ZIndex = 3, Parent = direita })
	g.cab = cab
	g.titulo = UI.titulo({ Text = "", TextSize = 24, Position = UDim2.fromOffset(20, 10), Size = UDim2.new(1, -90, 0, 30), ZIndex = 3, Parent = cab })
	g.sub = UI.texto({ Text = "", TextSize = 12, TextColor3 = C.Suave, Position = UDim2.fromOffset(20, 40), Size = UDim2.new(1, -90, 0, 16),
		ZIndex = 3, Parent = cab })
	local fechar = UI.botao({ Name = "Fechar", Text = "X", Font = F.Titulo, TextSize = 20, Cor = C.Card, Raio = 12, AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 10), Size = UDim2.fromOffset(38, 38), ZIndex = 4, Som = false, Parent = cab })
	fechar.Activated:Connect(function() Controller.fechar() end)
	g.conteudo = UI.new("Frame", { Name = "Conteudo", BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 70),
		Size = UDim2.new(1, -40, 1, -88), ClipsDescendants = true, ZIndex = 3, Parent = direita })

	-- toast
	g.toast = UI.texto({ Text = "", TextSize = 14, Font = F.Forte, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -16),
		Size = UDim2.fromOffset(0, 40), AutomaticSize = Enum.AutomaticSize.X, TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundColor3 = C.Lateral, BackgroundTransparency = 1, Visible = false, ZIndex = 60, TextWrapped = false, Parent = painelF })
	UI.canto(14).Parent = g.toast
	UI.pad(18, 0).Parent = g.toast
	g.toastSt = UI.contorno(C.Verde, 2, 0)
	g.toastSt.Parent = g.toast

	gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() if aberto then relayout() end end)
end

------------------------------------------------------------------ atalhos
local function atalhos()
	UserInputService.InputBegan:Connect(function(input, processado)
		local k = input.KeyCode
		if k == Enum.KeyCode.Escape or k == Enum.KeyCode.ButtonB then
			if aberto then Controller.fechar() end
			return
		end
		if UserInputService:GetFocusedTextBox() then return end
		if k == Enum.KeyCode.ButtonSelect then Controller.alternar() return end
		if processado then return end
		if k == Enum.KeyCode.M then
			Controller.alternar()
		elseif k == Enum.KeyCode.K then
			-- Uma só árvore: a aba Habilidades do menu principal.
			Controller.alternar("Habilidades")
		end
	end)
end

function Controller.iniciar()
	ctx = {
		Data = Data,
		toast = toast,
		vibrar = vibrar,
		fechar = function() Controller.fechar() end,
		abrirAba = function(id) selecionarAba(id) end,
		abrirLoja = function()
			Controller.fechar()
			task.delay(0.2, function()
				local hud = playerGui:FindFirstChild("HUDCortaGrama")
				local ev = hud and hud:FindFirstChild("AbrirLoja")
				if ev then ev:Fire() end
			end)
		end,
	}
	Data.iniciar()
	construir()
	atalhos()
	player.CharacterAdded:Connect(function()
		-- respawn: o menu sobrevive (ResetOnSpawn=false); se estava aberto, fecha limpo
		if aberto then Controller.fechar() end
	end)
end

return Controller

