--[[
	StarterPlayerScripts.ConquistasCliente  [Claude 2026-11-12]
	Conquistas (PAD-07) dentro do Quadro do Jardineiro: botão "🏆 Conquistas" no cabeçalho do painel de missões,
	que troca a vista por uma lista com progresso e prêmio de cada conquista e as estatísticas do jogador.
	Só lê do servidor (ConquistasAcao "estado").
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remote = RS:WaitForChild("ConquistasAcao")

local TINTA = Color3.fromRGB(52, 44, 38)
local PAPEL = Color3.fromRGB(255, 246, 214)
local VERDE = Color3.fromRGB(96, 196, 104)
local OURO = Color3.fromRGB(255, 200, 60)
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
local function fmt(n)
	local s = tostring(math.floor(n))
	local r = s:reverse():gsub("(%d%d%d)", "%1."):reverse()
	return (r:gsub("^%.", ""))
end

-- o painel de missões é criado pelo MissoesCliente
local gui = player:WaitForChild("PlayerGui"):WaitForChild("MissoesGui")
local painel
repeat
	for _, f in ipairs(gui:GetChildren()) do if f:IsA("Frame") then painel = f end end
	if not painel then task.wait(0.5) end
until painel

local botao = inst("TextButton", { Text = "🏆 Conquistas", Font = Enum.Font.FredokaOne, TextSize = 18, TextColor3 = Color3.new(1, 1, 1),
	TextStrokeColor3 = TINTA, TextStrokeTransparency = 0.3, BackgroundColor3 = OURO, AutoButtonColor = true,
	Size = UDim2.fromOffset(150, 40), Position = UDim2.new(1, -226, 0, 16), Parent = painel }, { canto(12), borda(3) })

local vista = inst("Frame", { Name = "ConquistasVista", Visible = false, BackgroundColor3 = PAPEL, BorderSizePixel = 0, ZIndex = 5,
	Size = UDim2.new(1, -24, 1, -70), Position = UDim2.fromOffset(12, 60), Parent = painel }, { canto(14) })
local resumo = rotulo({ Text = "", TextSize = 14, TextColor3 = MARROM, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
	Size = UDim2.new(1, -10, 0, 36), Position = UDim2.fromOffset(4, 0), Parent = vista })
local lista = inst("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 6, ScrollBarThickness = 8, ScrollBarImageColor3 = TINTA,
	Size = UDim2.new(1, 0, 1, -42), Position = UDim2.fromOffset(0, 40), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = vista },
	{ inst("UIGridLayout", { CellSize = UDim2.new(0.5, -8, 0, 62), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })

local linhas = {}
local function linha(i)
	if linhas[i] then return linhas[i] end
	local f = inst("Frame", { LayoutOrder = i, BackgroundColor3 = Color3.fromRGB(255, 252, 240), ZIndex = 6, Parent = lista }, { canto(12) })
	local b = borda(2) b.Parent = f
	local icone = rotulo({ Text = "", TextSize = 28, ZIndex = 7, Size = UDim2.fromOffset(46, 62), Parent = f })
	local nome = rotulo({ Text = "", Font = Enum.Font.FredokaOne, TextSize = 17, ZIndex = 7, TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -54, 0, 22), Position = UDim2.fromOffset(48, 4), Parent = f })
	local desc = rotulo({ Text = "", TextSize = 12, TextColor3 = MARROM, ZIndex = 7, TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -54, 0, 16), Position = UDim2.fromOffset(48, 25), Parent = f })
	local barra = inst("Frame", { BackgroundColor3 = Color3.fromRGB(235, 222, 190), ZIndex = 7, Size = UDim2.new(1, -60, 0, 12), Position = UDim2.fromOffset(48, 44), Parent = f }, { canto(6) })
	local encher = inst("Frame", { BackgroundColor3 = VERDE, ZIndex = 8, Size = UDim2.fromScale(0, 1), Parent = barra }, { canto(6) })
	linhas[i] = { frame = f, borda = b, icone = icone, nome = nome, desc = desc, encher = encher }
	return linhas[i]
end

local function desenhar(r)
	if type(r) ~= "table" or not r.conquistas then return end
	local feitas = 0
	for i, c in ipairs(r.conquistas) do
		local l = linha(i)
		if c.feita then feitas += 1 end
		l.icone.Text = c.feita and c.icone or "🔒"
		l.nome.Text = c.nome
		l.desc.Text = c.feita and ("✓ Feita · %s: %s"):format(c.stat, fmt(c.meta))
			or ("%s: %s / %s · 💰 %s"):format(c.stat, fmt(c.atual), fmt(c.meta), fmt(c.moedas))
		l.encher.Size = UDim2.fromScale(math.clamp(c.atual / c.meta, 0, 1), 1)
		l.encher.BackgroundColor3 = c.feita and OURO or VERDE
		l.borda.Color = c.feita and Color3.fromRGB(214, 160, 30) or TINTA
		l.frame.BackgroundColor3 = c.feita and Color3.fromRGB(255, 240, 190) or Color3.fromRGB(255, 252, 240)
	end
	local s = r.stats or {}
	local function v(k) return s[k] and fmt(s[k].valor) or "0" end
	resumo.Text = ("🏆 %d de %d conquistas  ·  ✂️ %s tufos  ·  ✨ %s dourados  ·  📦 %s baús/segredos  ·  🏡 %s jardins  ·  💰 %s vendas"):format(
		feitas, #r.conquistas, v("cortes"), v("dourados"), v("descobertas"), v("jardins"), v("vendas"))
end

local function mostrar(v)
	vista.Visible = v
	botao.Text = v and "📋 Missões" or "🏆 Conquistas"
	if v then
		task.spawn(function()
			local ok, r = pcall(function() return remote:InvokeServer("estado") end)
			if ok then desenhar(r) end
		end)
	end
end
botao.Activated:Connect(function() mostrar(not vista.Visible) end)
gui:GetPropertyChangedSignal("Enabled"):Connect(function() if not gui.Enabled then mostrar(false) end end)
