--[[
	StarterPlayerScripts.OficinaCliente  [Claude 2026-11-12]
	Oficina de ferramentas (MON-04, parte 2): painel aberto pela bancada do lobby (Lobby.OficinaFerramentas, prompt E).
	Mostra os materiais, cada ferramenta com a raridade atual e o custo da próxima, e o botão EVOLUIR.
	Também mostra "+1 🌿" quando um material cai. Só pede ao servidor (OficinaAcao).
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local PPS = game:GetService("ProximityPromptService")
local Config = require(RS:WaitForChild("Shared"):WaitForChild("OficinaConfig"))
local player = Players.LocalPlayer
local remote = RS:WaitForChild("OficinaAcao")
local okSons, Sons = pcall(function() return require(RS.Shared:WaitForChild("Sons")) end)
local function som(nome) if okSons and Sons then pcall(Sons.tocar, nome, {}) end end

local TINTA = Color3.fromRGB(52, 44, 38)
local PAPEL = Color3.fromRGB(255, 246, 214)
local VERDE = Color3.fromRGB(96, 196, 104)
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
	n = math.floor(n)
	if n >= 1e15 then return string.format("%.0e", n) end
	local s = string.format("%d", n)
	local r = s:reverse():gsub("(%d%d%d)", "%1."):reverse()
	return (r:gsub("^%.", ""))
end
local corRaridade = {}
for _, r in ipairs(Config.Raridades) do corRaridade[r.nome] = r.cor end

---------------------------------------------------------------- painel
local gui = inst("ScreenGui", { Name = "OficinaGui", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 30, Enabled = false, Parent = player:WaitForChild("PlayerGui") })
local fundo = inst("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, Parent = gui })
local painel = inst("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(740, 470), BackgroundColor3 = PAPEL, Parent = gui },
	{ canto(22), borda(4) })
local escala = inst("UIScale", { Parent = painel })
local function ajustarEscala()
	local cam = workspace.CurrentCamera
	local v = cam and cam.ViewportSize or Vector2.new(1280, 720)
	escala.Scale = math.clamp(math.min(v.X / 780, v.Y / 510), 0.45, 1)
end

rotulo({ Text = "🔨 OFICINA DE FERRAMENTAS", Font = Enum.Font.FredokaOne, TextSize = 28, Size = UDim2.new(1, -80, 0, 40), Position = UDim2.fromOffset(20, 10),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })
local fechar = botao("X", Color3.fromRGB(232, 84, 72), { Size = UDim2.fromOffset(44, 44), Position = UDim2.new(1, -58, 0, 14), TextSize = 24, Parent = painel })
local mats = rotulo({ Text = "", TextSize = 17, Size = UDim2.new(1, -40, 0, 26), Position = UDim2.fromOffset(20, 56), TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })
rotulo({ Text = "🌿 cortando na Floresta  ·  💎 abrindo baús e segredos  ·  ✨ cortando tufos dourados", TextSize = 12, TextColor3 = MARROM,
	Size = UDim2.new(1, -40, 0, 16), Position = UDim2.fromOffset(20, 82), TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })

local linha = inst("Frame", { Size = UDim2.new(1, -40, 0, 320), Position = UDim2.fromOffset(20, 106), BackgroundTransparency = 1, Parent = painel },
	{ inst("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder }) })
local cartoes = {}
for i = 1, 3 do
	local c = inst("Frame", { LayoutOrder = i, Size = UDim2.fromOffset(224, 320), BackgroundColor3 = Color3.fromRGB(255, 252, 240), Parent = linha }, { canto(16) })
	local b = borda(3) b.Parent = c
	local titulo = rotulo({ Text = "", Font = Enum.Font.FredokaOne, TextSize = 21, Size = UDim2.new(1, -16, 0, 28), Position = UDim2.fromOffset(8, 8), Parent = c })
	local rar = rotulo({ Text = "", Font = Enum.Font.FredokaOne, TextSize = 20, Size = UDim2.new(1, -16, 0, 26), Position = UDim2.fromOffset(8, 38), Parent = c })
	local efeito = rotulo({ Text = "", TextSize = 13, TextColor3 = Color3.fromRGB(60, 130, 60), TextWrapped = true, Size = UDim2.new(1, -16, 0, 34), Position = UDim2.fromOffset(8, 66), Parent = c })
	local prox = rotulo({ Text = "", TextSize = 14, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -24, 0, 140), Position = UDim2.fromOffset(12, 108), Parent = c })
	local bt = botao("EVOLUIR", CINZA, { Size = UDim2.new(1, -24, 0, 46), Position = UDim2.new(0, 12, 1, -58), TextSize = 20, Parent = c })
	cartoes[i] = { frame = c, borda = b, titulo = titulo, rar = rar, efeito = efeito, prox = prox, bt = bt }
end
local mensagem = rotulo({ Text = "", TextSize = 15, Size = UDim2.new(1, -40, 0, 22), Position = UDim2.new(0, 20, 1, -36), TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })

local estadoAtual, ocupado = nil, false

local function msg(t, erro)
	mensagem.Text = t or ""
	mensagem.TextColor3 = erro and Color3.fromRGB(200, 60, 50) or Color3.fromRGB(60, 140, 60)
end

local function podePagar(e, custo)
	if (e.moedas or 0) < (custo.moedas or 0) then return false end
	for _, m in ipairs(Config.Materiais) do if (e.materiais[m.id] or 0) < (custo[m.id] or 0) then return false end end
	return true
end

local function desenhar()
	local e = estadoAtual
	if not e then return end
	local partes = {}
	for _, m in ipairs(Config.Materiais) do table.insert(partes, ("%s %s: %s"):format(m.icone, m.nome, fmt(e.materiais[m.id] or 0))) end
	mats.Text = table.concat(partes, "   ·   ")
	for i, c in ipairs(cartoes) do
		local f = e.ferramentas[i]
		if f then
			c.titulo.Text = f.icone .. " " .. f.nome
			c.rar.Text = f.raridade
			c.rar.TextColor3 = corRaridade[f.raridade] or TINTA
			c.borda.Color = corRaridade[f.raridade] or TINTA
			c.efeito.Text = f.grama > 0 and ("Na mão: grama +%d%%%s"):format(math.floor(f.grama * 100 + 0.5), f.tiles > 0 and (" · +%d quadrado/golpe"):format(f.tiles) or "")
				or "Sem bônus ainda"
			if f.proxima then
				local custo = f.proxima.custo
				local linhas = { ("Próxima: %s (grama +%d%%)"):format(f.proxima.nome, math.floor(f.proxima.grama * 100 + 0.5)) }
				table.insert(linhas, ((e.moedas >= (custo.moedas or 0)) and "✅ " or "⬜ ") .. "💰 " .. fmt(custo.moedas or 0))
				for _, m in ipairs(Config.Materiais) do
					local precisa = custo[m.id]
					if precisa then
						table.insert(linhas, (((e.materiais[m.id] or 0) >= precisa) and "✅ " or "⬜ ") .. ("%s %s/%s"):format(m.icone, fmt(e.materiais[m.id] or 0), fmt(precisa)))
					end
				end
				c.prox.Text = table.concat(linhas, "\n")
				local pode = podePagar(e, custo)
				c.bt.Text = "EVOLUIR"
				c.bt.BackgroundColor3 = pode and VERDE or CINZA
				c.bt.AutoButtonColor = pode
			else
				c.prox.Text = "Raridade máxima! ✨"
				c.bt.Text = "MÁXIMA"
				c.bt.BackgroundColor3 = CINZA
				c.bt.AutoButtonColor = false
			end
		end
	end
end

local function pedir(acao, arg, cartao)
	if ocupado then return end
	ocupado = true
	local ok, r = pcall(function() return remote:InvokeServer(acao, arg) end)
	ocupado = false
	if not ok or type(r) ~= "table" then msg("Não deu certo agora. Tente de novo.", true) return end
	if r.estado then estadoAtual = r.estado desenhar() end
	if r.erro then msg(r.erro, true) som("Erro") return end
	if r.ok then
		msg("Ferramenta evoluída! Se estiver na mão, ela já trocou.")
		som("Desbloqueio")
		if cartao then
			local s = inst("UIScale", { Scale = 1.1, Parent = cartao.frame })
			TweenService:Create(s, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Scale = 1 }):Play()
			task.delay(0.4, function() s:Destroy() end)
		end
	end
end

for i, c in ipairs(cartoes) do
	c.bt.Activated:Connect(function()
		local f = estadoAtual and estadoAtual.ferramentas[i]
		if f and f.proxima then pedir("evoluir", f.tipo, c) end
	end)
end

local function definirAberto(v) player:SetAttribute("OficinaAberta", v) end
player:GetAttributeChangedSignal("OficinaAberta"):Connect(function()
	local aberto = player:GetAttribute("OficinaAberta") == true
	gui.Enabled = aberto
	if aberto then ajustarEscala() msg("") task.spawn(pedir, "estado") end
end)
fechar.Activated:Connect(function() definirAberto(false) end)
fundo.Activated:Connect(function() definirAberto(false) end)
UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Escape and player:GetAttribute("OficinaAberta") then definirAberto(false) end
end)
for _, nome in ipairs({ "LojaAberta", "MenuJogadorAberto", "SkillTreeOpen", "ForestShopOpen", "PetsAberto", "PremiosAberto", "MissoesAberto", "FamaAberto" }) do
	player:GetAttributeChangedSignal(nome):Connect(function() if player:GetAttribute(nome) then definirAberto(false) end end)
end
PPS.PromptTriggered:Connect(function(prompt)
	if prompt:FindFirstAncestor("OficinaFerramentas") then definirAberto(true) end
end)

---------------------------------------------------------------- "+1 🌿" quando um material cai
local toastGui = inst("ScreenGui", { Name = "MaterialAviso", ResetOnSpawn = false, DisplayOrder = 7, Parent = player.PlayerGui })
local anteriores = {}
for _, m in ipairs(Config.Materiais) do
	local nome = "Mat_" .. m.id
	anteriores[m.id] = player:GetAttribute(nome)
	player:GetAttributeChangedSignal(nome):Connect(function()
		local novo = tonumber(player:GetAttribute(nome)) or 0
		local antes = tonumber(anteriores[m.id])
		anteriores[m.id] = novo
		if antes and novo > antes and not gui.Enabled then
			local t = rotulo({ Text = ("+%d %s"):format(novo - antes, m.icone), Font = Enum.Font.FredokaOne, TextSize = 28, TextColor3 = Color3.new(1, 1, 1),
				TextStrokeColor3 = TINTA, TextStrokeTransparency = 0, AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.62), Size = UDim2.fromOffset(160, 40), Parent = toastGui })
			TweenService:Create(t, TweenInfo.new(1.1), { Position = UDim2.fromScale(0.5, 0.52), TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
			task.delay(1.2, function() t:Destroy() end)
		end
		if gui.Enabled then task.spawn(pedir, "estado") end
	end)
end
