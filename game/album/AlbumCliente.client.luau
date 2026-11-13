--[[
	StarterPlayerScripts.AlbumCliente  [Claude 2026-11-12]
	Álbum de coleções: botão "📖 ÁLBUM" na coluna da esquerda (abaixo de CONFIG) e painel com 4 páginas
	(abas), cada uma com a grade de itens: os que o jogador já tem aparecem coloridos, os que faltam como "❓".
	Só lê do servidor (AlbumAcao "estado").
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local remote = RS:WaitForChild("AlbumAcao")

local TINTA = Color3.fromRGB(52, 44, 38)
local PAPEL = Color3.fromRGB(255, 246, 214)
local MARROM = Color3.fromRGB(110, 96, 74)
local VERDE = Color3.fromRGB(96, 196, 104)
local OURO = Color3.fromRGB(255, 200, 60)

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

---------------------------------------------------------------- botão na coluna da esquerda (Claude 2026-11-12: dentro do menu da HUD original, via HudKit)
local HudKit = require(RS:WaitForChild("Shared"):WaitForChild("HudKit"))
local abrir = HudKit.botao({ nome = "Album", rotulo = "Álbum", icone = "📒", c1 = HudKit.C.Roxo1, c2 = HudKit.C.Roxo2, ordem = 10, lado = "esquerda" })

---------------------------------------------------------------- painel
local gui = inst("ScreenGui", { Name = "AlbumGui", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 30, Enabled = false, Parent = player.PlayerGui })
local fundo = inst("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, Parent = gui })
local painel = inst("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(740, 480), BackgroundColor3 = PAPEL, Parent = gui },
	{ canto(22), borda(4) })
local escala = inst("UIScale", { Parent = painel })
local function ajustarEscala()
	local cam = workspace.CurrentCamera
	local v = cam and cam.ViewportSize or Vector2.new(1280, 720)
	escala.Scale = math.clamp(math.min(v.X / 780, v.Y / 520), 0.45, 1)
end

rotulo({ Text = "📖 ÁLBUM DO JARDINEIRO", Font = Enum.Font.FredokaOne, TextSize = 28, Size = UDim2.new(1, -80, 0, 40), Position = UDim2.fromOffset(20, 10),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })
local fechar = botao("X", Color3.fromRGB(232, 84, 72), { Size = UDim2.fromOffset(44, 44), Position = UDim2.new(1, -58, 0, 14), TextSize = 24, Parent = painel })
local resumo = rotulo({ Text = "", TextSize = 14, TextColor3 = Color3.fromRGB(60, 130, 60), Size = UDim2.new(1, -40, 0, 20), Position = UDim2.fromOffset(20, 50),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })

local abas = inst("Frame", { Size = UDim2.new(1, -40, 0, 42), Position = UDim2.fromOffset(20, 74), BackgroundTransparency = 1, Parent = painel },
	{ inst("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
local cabecalho = rotulo({ Text = "", Font = Enum.Font.FredokaOne, TextSize = 19, Size = UDim2.new(1, -40, 0, 26), Position = UDim2.fromOffset(20, 122),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })
local grade = inst("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 8, ScrollBarImageColor3 = TINTA,
	Size = UDim2.new(1, -40, 1, -166), Position = UDim2.fromOffset(20, 152), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = painel },
	{ inst("UIGridLayout", { CellSize = UDim2.fromOffset(128, 92), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })

local dadosAtuais, paginaAtual, botoesAba = nil, 1, {}

local function desenharPagina()
	local d = dadosAtuais
	if not d then return end
	for _, c in ipairs(grade:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	local pg = d.paginas[paginaAtual]
	if not pg then return end
	for i, b in ipairs(botoesAba) do
		local p = d.paginas[i]
		b.BackgroundColor3 = i == paginaAtual and OURO or (p and p.completa and VERDE or Color3.fromRGB(176, 166, 146))
		b.Text = p and ("%s %d/%d"):format(p.icone, p.n, p.total) or ""
	end
	cabecalho.Text = pg.completa and ("%s %s · ✅ completa (+%d%% de grama)"):format(pg.icone, pg.nome, math.floor(d.bonusPorPagina * 100 + 0.5))
		or ("%s %s · %d/%d · ao completar: 💰 %s e +%d%% de grama para sempre"):format(pg.icone, pg.nome, pg.n, pg.total, fmt(pg.moedas), math.floor(d.bonusPorPagina * 100 + 0.5))
	for i, it in ipairs(pg.itens) do
		local f = inst("Frame", { LayoutOrder = i, BackgroundColor3 = it.tem and Color3.fromRGB(255, 252, 240) or Color3.fromRGB(226, 216, 196), Parent = grade }, { canto(12) })
		borda(2, it.tem and TINTA or Color3.fromRGB(170, 158, 136)).Parent = f
		rotulo({ Text = it.tem and it.icone or "❓", TextSize = 30, Size = UDim2.new(1, 0, 0, 44), Position = UDim2.fromOffset(0, 4), Parent = f })
		rotulo({ Text = it.tem and it.nome or "???", TextSize = 12, TextWrapped = true, TextColor3 = it.tem and TINTA or MARROM,
			Size = UDim2.new(1, -8, 0, 40), Position = UDim2.fromOffset(4, 48), Parent = f })
	end
end

for i = 1, 4 do
	local b = botao("", Color3.fromRGB(176, 166, 146), { LayoutOrder = i, Size = UDim2.fromOffset(166, 40), TextSize = 17, Parent = abas })
	b.Activated:Connect(function() paginaAtual = i desenharPagina() end)
	botoesAba[i] = b
end

local function carregar()
	local ok, r = pcall(function() return remote:InvokeServer("estado") end)
	if not ok or type(r) ~= "table" or not r.paginas then return end
	dadosAtuais = r
	local completas = 0
	for _, p in ipairs(r.paginas) do if p.completa then completas += 1 end end
	resumo.Text = ("%d de %d páginas completas · grama +%d%% para sempre"):format(completas, #r.paginas, math.floor((r.bonus or 0) * 100 + 0.5))
	desenharPagina()
end

local function definirAberto(v) player:SetAttribute("AlbumAberto", v) end
player:GetAttributeChangedSignal("AlbumAberto"):Connect(function()
	local aberto = player:GetAttribute("AlbumAberto") == true
	gui.Enabled = aberto
	if aberto then ajustarEscala() task.spawn(carregar) end
end)
abrir.Activated:Connect(function() definirAberto(not player:GetAttribute("AlbumAberto")) end)
fechar.Activated:Connect(function() definirAberto(false) end)
fundo.Activated:Connect(function() definirAberto(false) end)
UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Escape and player:GetAttribute("AlbumAberto") then definirAberto(false) end
end)
for _, nome in ipairs({ "LojaAberta", "MenuJogadorAberto", "SkillTreeOpen", "ForestShopOpen", "PetsAberto", "PremiosAberto", "MissoesAberto", "FamaAberto", "OficinaAberta" }) do
	player:GetAttributeChangedSignal(nome):Connect(function() if player:GetAttribute(nome) then definirAberto(false) end end)
end
