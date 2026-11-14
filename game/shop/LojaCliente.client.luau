--[[
	StarterPlayerScripts.LojaCliente  [Claude 2026-11-14]
	Botão PREMIUM no HUD (HudKit, coluna direita) e painel da loja com Robux:
	  abas Passes / Boosts / Ovos / Itens; preço lido do Roblox (GetProductInfo); item sem id = "Em breve".
	  Ovo pago: lista TODAS as chances (%) antes de comprar. Se o jogador tiver itens aleatórios pagos
	  restritos (PolicyService, decidido no servidor), o ovo some e aparece a compra direta.
	  Botão flutuante "VENDER AQUI" para quem tem a Caçamba de Bolso. Etiqueta [VIP] no chat.
	A compra em si é o prompt oficial do Roblox; a entrega acontece no servidor (LojaServidor).
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TextChatService = game:GetService("TextChatService")
local player = Players.LocalPlayer

local Cfg = require(RS:WaitForChild("Shared"):WaitForChild("LojaConfig"))
local PetsCat = require(RS.Shared:WaitForChild("PetsCatalogo"))
local HudKit = require(RS.Shared:WaitForChild("HudKit"))
local acao = RS:WaitForChild("LojaAcao")

local TINTA = Color3.fromRGB(40, 30, 22)
local PAPEL = Color3.fromRGB(255, 248, 230)
local ROXO = Color3.fromRGB(150, 70, 230)
local VERDE = Color3.fromRGB(70, 180, 80)
local CINZA = Color3.fromRGB(176, 166, 146)
local OURO = Color3.fromRGB(255, 190, 40)

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

---------------------------------------------------------------- botão no HUD
local abrir, hudApi = HudKit.botao({ nome = "Premium", rotulo = "Premium", icone = "💎", c1 = HudKit.C.Roxo1, c2 = HudKit.C.Roxo2, ordem = 5, lado = "direita" })

---------------------------------------------------------------- painel
local gui = inst("ScreenGui", { Name = "LojaPremiumGui", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 31, Enabled = false, Parent = player.PlayerGui })
local fundo = inst("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, Parent = gui })
local painel = inst("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(720, 500), BackgroundColor3 = PAPEL, Parent = gui },
	{ canto(22), borda(4) })
local escala = inst("UIScale", { Parent = painel })
local function ajustarEscala()
	local cam = workspace.CurrentCamera
	local v = cam and cam.ViewportSize or Vector2.new(1280, 720)
	escala.Scale = math.clamp(math.min(v.X / 760, v.Y / 540), 0.45, 1)
end
rotulo({ Text = "💎 LOJA PREMIUM", Font = Enum.Font.FredokaOne, TextSize = 28, Size = UDim2.new(1, -80, 0, 40), Position = UDim2.fromOffset(20, 10),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })
local fechar = botao("X", Color3.fromRGB(232, 84, 72), { Size = UDim2.fromOffset(44, 44), Position = UDim2.new(1, -58, 0, 12), TextSize = 24, Parent = painel })

local abas = inst("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -40, 0, 40), Position = UDim2.fromOffset(20, 58), Parent = painel },
	{ inst("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
local lista = inst("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, -120), Position = UDim2.fromOffset(20, 106),
	CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 8, BorderSizePixel = 0, Parent = painel },
	{ inst("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })

local estado = { passes = {}, restrito = true, boosts = {}, agora = os.time() }
local precos = {} -- [id] = texto
local abaAtual = "Passes"

local function preco(id, tipo)
	if not id then return "Em breve" end
	if precos[id] then return precos[id] end
	task.spawn(function()
		local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, id, tipo)
		-- \u{E002} = ícone do Robux nas fontes do Roblox
		precos[id] = (ok and info and info.PriceInRobux) and ("\u{E002} " .. tostring(info.PriceInRobux)) or "—"
	end)
	return "..."
end

local function limpar()
	for _, c in ipairs(lista:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
end

local function cartao(item, ordem, textoPreco, possui, aoComprar, extraAltura)
	local alto = 86 + (extraAltura or 0)
	local c = inst("Frame", { LayoutOrder = ordem, Size = UDim2.new(1, -12, 0, alto), BackgroundColor3 = Color3.new(1, 1, 1), Parent = lista }, { canto(14), borda(2, CINZA) })
	rotulo({ Text = item.icone, TextSize = 40, Size = UDim2.fromOffset(64, 64), Position = UDim2.fromOffset(10, 11), Parent = c })
	rotulo({ Text = item.nome, Font = Enum.Font.FredokaOne, TextSize = 21, Size = UDim2.new(1, -260, 0, 26), Position = UDim2.fromOffset(84, 10),
		TextXAlignment = Enum.TextXAlignment.Left, Parent = c })
	rotulo({ Text = item.desc, Font = Enum.Font.Gotham, TextSize = 14, TextWrapped = true, Size = UDim2.new(1, -260, 0, 42), Position = UDim2.fromOffset(84, 36),
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = c })
	local cor = possui and VERDE or (item.id and ROXO or CINZA)
	local b = botao(possui and "✓ SEU" or textoPreco, cor, { AnchorPoint = Vector2.new(1, 0), Size = UDim2.fromOffset(150, 46), Position = UDim2.new(1, -14, 0, 20), TextSize = 18, Parent = c })
	b.Activated:Connect(function()
		if possui then return end
		if not item.id then
			b.Text = "Em breve"
			return
		end
		aoComprar()
	end)
	return c
end

local function fimBoost(tipo)
	local fim = tonumber(estado.boosts[tipo]) or 0
	local resta = fim - os.time()
	return resta > 0 and resta or 0
end
local function tempo(seg)
	return ("%d:%02d"):format(math.floor(seg / 60), seg % 60)
end

local desenhar
local function mostrarAba(nome)
	abaAtual = nome
	for _, b in ipairs(abas:GetChildren()) do
		if b:IsA("TextButton") then b.BackgroundColor3 = b.Name == nome and ROXO or CINZA end
	end
	desenhar()
end
for i, nome in ipairs({ "Passes", "Boosts", "Ovos", "Itens" }) do
	local b = botao(nome, CINZA, { Name = nome, LayoutOrder = i, Size = UDim2.fromOffset(150, 38), TextSize = 18, Parent = abas })
	b.Activated:Connect(function() mostrarAba(nome) end)
end

desenhar = function()
	limpar()
	if abaAtual == "Passes" then
		for i, ps in ipairs(Cfg.Passes) do
			cartao(ps, i, preco(ps.id, Enum.InfoType.GamePass), estado.passes[ps.chave] == true, function()
				MarketplaceService:PromptGamePassPurchase(player, ps.id)
			end)
		end
	elseif abaAtual == "Boosts" then
		for i, pr in ipairs(Cfg.Produtos) do
			if pr.boost then
				local resta = fimBoost(pr.boost)
				local item = resta > 0 and setmetatable({ desc = pr.desc .. "  ⏱ Ativo: " .. tempo(resta) }, { __index = pr }) or pr
				cartao(item, i, preco(pr.id, Enum.InfoType.Product), false, function()
					MarketplaceService:PromptProductPurchase(player, pr.id)
				end)
			end
		end
	elseif abaAtual == "Ovos" then
		local ovoP, direto = Cfg.produto("OvoCelestial"), Cfg.produto("FenixGarantida")
		if estado.restrito then
			rotulo({ LayoutOrder = 0, Text = "Ovos pagos não estão disponíveis para a sua conta/região. Você pode comprar um ajudante garantido, sem sorte:",
				Font = Enum.Font.Gotham, TextSize = 15, TextWrapped = true, Size = UDim2.new(1, -12, 0, 44), TextXAlignment = Enum.TextXAlignment.Left, Parent = lista })
		else
			local ovo = PetsCat.OvosRobux.celestial
			local linhas = {}
			for _, ch in ipairs(ovo.chances) do
				local e = PetsCat.Especies[ch[1]]
				local r = PetsCat.raridade(ch[1])
				table.insert(linhas, ("%s %s — %s (+%d%% grama): %s%%"):format(e.icone, e.nome, r.nome, math.floor(r.bonus * 100 + 0.5), tostring(ch[2])))
			end
			local c = cartao(ovoP, 1, preco(ovoP.id, Enum.InfoType.Product), false, function()
				MarketplaceService:PromptProductPurchase(player, ovoP.id)
			end, 22 * #linhas + 30)
			rotulo({ Text = "CHANCES (somam 100%):\n" .. table.concat(linhas, "\n"), Font = Enum.Font.Gotham, TextSize = 15, TextWrapped = true,
				Size = UDim2.new(1, -30, 0, 22 * #linhas + 24), Position = UDim2.fromOffset(84, 82), TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top, Parent = c })
		end
		cartao(direto, 2, preco(direto.id, Enum.InfoType.Product), false, function()
			MarketplaceService:PromptProductPurchase(player, direto.id)
		end)
	elseif abaAtual == "Itens" then
		for i, pr in ipairs(Cfg.Produtos) do
			if pr.materiais then
				cartao(pr, i, preco(pr.id, Enum.InfoType.Product), false, function()
					MarketplaceService:PromptProductPurchase(player, pr.id)
				end)
			end
		end
	end
end

local function sync()
	local ok, r = pcall(acao.InvokeServer, acao, "sync")
	if ok and type(r) == "table" and not r.erro then
		estado.passes = r.passes or {}
		estado.restrito = r.restrito ~= false
		estado.boosts = r.boosts or {}
	end
end

local function abrirPainel()
	sync()
	ajustarEscala()
	gui.Enabled = true
	mostrarAba(abaAtual)
end
abrir.Activated:Connect(abrirPainel)
fechar.Activated:Connect(function() gui.Enabled = false end)
fundo.Activated:Connect(function() gui.Enabled = false end)

-- depois de uma compra, sincroniza e redesenha (os preços que chegaram também)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function() task.wait(1) sync() if gui.Enabled then desenhar() end end)
MarketplaceService.PromptProductPurchaseFinished:Connect(function() task.wait(1.5) sync() if gui.Enabled then desenhar() end end)
task.spawn(function()
	while true do
		task.wait(1)
		if gui.Enabled and (abaAtual == "Boosts" or next(precos) ~= nil) then
			local precisa = false
			for _, c in ipairs(lista:GetDescendants()) do if c:IsA("TextButton") and c.Text == "..." then precisa = true break end end
			if precisa or abaAtual == "Boosts" then desenhar() end
		end
	end
end)

-- chip do botão: boost ativo
local function atualizarChip()
	local ativo = false
	for _, a in ipairs({ "BoostMoedasFim", "BoostGramaFim", "BoostXPFim" }) do
		if (tonumber(player:GetAttribute(a)) or 0) > os.time() then ativo = true end
	end
	hudApi.chip(ativo and "x2" or nil)
end
task.spawn(function() while true do atualizarChip() task.wait(5) end end)

---------------------------------------------------------------- vender de qualquer lugar
local guiVenda = inst("ScreenGui", { Name = "VenderAquiGui", ResetOnSpawn = false, Enabled = false, Parent = player.PlayerGui })
local btVender = botao("📦 VENDER AQUI", OURO, { AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.fromOffset(200, 50), Position = UDim2.new(0.5, 0, 1, -170), TextSize = 20, Parent = guiVenda })
btVender.Activated:Connect(function()
	local ok, r = pcall(acao.InvokeServer, acao, "vender")
	if ok and type(r) == "table" and r.erro then btVender.Text = r.erro task.wait(1.5) btVender.Text = "📦 VENDER AQUI" end
end)
local function atualizarVenda()
	guiVenda.Enabled = player:GetAttribute("VenderQualquerLugar") == true and (tonumber(player:GetAttribute("Saco")) or 0) > 0
end
player:GetAttributeChangedSignal("VenderQualquerLugar"):Connect(atualizarVenda)
player:GetAttributeChangedSignal("Saco"):Connect(atualizarVenda)
atualizarVenda()

---------------------------------------------------------------- etiqueta [VIP] no chat (TextChatService)
pcall(function()
	TextChatService.OnIncomingMessage = function(msg)
		local props = Instance.new("TextChatMessageProperties")
		local autor = msg.TextSource and Players:GetPlayerByUserId(msg.TextSource.UserId)
		if autor and autor:GetAttribute("VIP") then
			props.PrefixText = "<font color='#FFC428'>[VIP]</font> " .. msg.PrefixText
		end
		return props
	end
end)
