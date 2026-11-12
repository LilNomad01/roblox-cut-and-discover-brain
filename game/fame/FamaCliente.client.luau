--[[
	StarterPlayerScripts.FamaCliente  [Claude 2026-11-12]
	"Fama de Jardineiro" (MON-05): botão "⭐ Fama" no HUD (aparece quando o jogador tem o Mega Cortador ou o
	Imperial GX, ou já tem estrelas) e painel com o que se ganha, o que se perde, o que fica e o botão RENASCER
	(pede confirmação com um segundo clique). Só pede ao servidor (FamaAcao).
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local remote = RS:WaitForChild("FamaAcao")
local okSons, Sons = pcall(function() return require(RS:WaitForChild("Shared"):WaitForChild("Sons")) end)
local function som(nome) if okSons and Sons then pcall(Sons.tocar, nome, {}) end end

local TINTA = Color3.fromRGB(52, 44, 38)
local PAPEL = Color3.fromRGB(255, 246, 214)
local OURO = Color3.fromRGB(255, 200, 60)
local VERDE = Color3.fromRGB(96, 196, 104)
local VERMELHO = Color3.fromRGB(232, 84, 72)
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
local function fmt(n)
	local s = tostring(math.floor(n))
	local r = s:reverse():gsub("(%d%d%d)", "%1."):reverse()
	return (r:gsub("^%.", ""))
end

---------------------------------------------------------------- botão no HUD (acima do selo de amigos)
local hud = inst("ScreenGui", { Name = "FamaBotao", ResetOnSpawn = false, DisplayOrder = 5, Parent = player:WaitForChild("PlayerGui") })
local abrir = botao("⭐ Fama", OURO, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -18, 0, 228), Size = UDim2.fromOffset(310, 44),
	TextSize = 20, Visible = false, Parent = hud })

local function possui(id)
	local lista = player:GetAttribute("Comprados") or ""
	return string.find("," .. lista .. ",", "," .. id .. ",", 1, true) ~= nil
end
local function atualizarBotao()
	local n = tonumber(player:GetAttribute("FamaEstrelas")) or 0
	abrir.Visible = n > 0 or possui("Mega") or possui("Imperial")
	abrir.Text = n > 0 and ("⭐ Fama %d · +%d%% grama"):format(n, math.floor((tonumber(player:GetAttribute("BonusFama")) or 0) * 100 + 0.5))
		or (possui("Imperial") and "⭐ Fama: você pode renascer!" or "⭐ Fama de Jardineiro")
end
for _, a in ipairs({ "FamaEstrelas", "BonusFama", "Comprados" }) do player:GetAttributeChangedSignal(a):Connect(atualizarBotao) end
atualizarBotao()

---------------------------------------------------------------- painel
local gui = inst("ScreenGui", { Name = "FamaGui", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 30, Enabled = false, Parent = player.PlayerGui })
local fundo = inst("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, Parent = gui })
local painel = inst("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(600, 430), BackgroundColor3 = PAPEL, Parent = gui },
	{ canto(22), borda(4) })
local escala = inst("UIScale", { Parent = painel })
local function ajustarEscala()
	local cam = workspace.CurrentCamera
	local v = cam and cam.ViewportSize or Vector2.new(1280, 720)
	escala.Scale = math.clamp(math.min(v.X / 640, v.Y / 470), 0.45, 1)
end

rotulo({ Text = "⭐ FAMA DE JARDINEIRO", Font = Enum.Font.FredokaOne, TextSize = 28, Size = UDim2.new(1, -80, 0, 40), Position = UDim2.fromOffset(20, 10),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })
local fechar = botao("X", VERMELHO, { Size = UDim2.fromOffset(44, 44), Position = UDim2.new(1, -58, 0, 14), TextSize = 24, Parent = painel })

local caixa = inst("Frame", { Size = UDim2.new(1, -40, 0, 70), Position = UDim2.fromOffset(20, 60), BackgroundColor3 = Color3.fromRGB(255, 236, 170), Parent = painel },
	{ canto(14), borda(3) })
local estrelas = rotulo({ Text = "", Font = Enum.Font.FredokaOne, TextSize = 24, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.fromOffset(12, 6),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = caixa })
local bonus = rotulo({ Text = "", TextSize = 15, TextColor3 = Color3.fromRGB(60, 130, 60), Size = UDim2.new(1, -20, 0, 22), Position = UDim2.fromOffset(12, 38),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = caixa })

rotulo({ Text = "Para a próxima estrela:", Font = Enum.Font.FredokaOne, TextSize = 19, Size = UDim2.new(1, -40, 0, 24), Position = UDim2.fromOffset(20, 142),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })
local req1 = rotulo({ Text = "", TextSize = 16, Size = UDim2.new(1, -40, 0, 22), Position = UDim2.fromOffset(28, 168), TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })
local req2 = rotulo({ Text = "", TextSize = 16, Size = UDim2.new(1, -40, 0, 22), Position = UDim2.fromOffset(28, 192), TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })

rotulo({ Text = "❌ Você perde: moedas, cortadores (volta ao Básico) e a grama do saco.", TextSize = 14, TextWrapped = true, TextColor3 = Color3.fromRGB(180, 60, 50),
	Size = UDim2.new(1, -40, 0, 36), Position = UDim2.fromOffset(20, 226), TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })
rotulo({ Text = "✅ Você mantém: nível, ajudantes, habilidades, segredos, missões, conquistas e mochilas.", TextSize = 14, TextWrapped = true,
	TextColor3 = Color3.fromRGB(50, 130, 60), Size = UDim2.new(1, -40, 0, 36), Position = UDim2.fromOffset(20, 262), TextXAlignment = Enum.TextXAlignment.Left, Parent = painel })

local btRenascer = botao("RENASCER COM FAMA", CINZA, { AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.fromOffset(320, 52), Position = UDim2.new(0.5, 0, 0, 310), TextSize = 22, Parent = painel })
local mensagem = rotulo({ Text = "", TextSize = 15, Size = UDim2.new(1, -40, 0, 22), Position = UDim2.new(0, 20, 1, -40), Parent = painel })

local estadoAtual, confirmando, ocupado = nil, false, false

local function desenhar()
	local e = estadoAtual
	if not e then return end
	estrelas.Text = (e.estrelas > 0 and string.rep("⭐", math.min(e.estrelas, 10)) .. "  " or "") .. ("Fama %d · %s"):format(e.estrelas, e.titulo)
	bonus.Text = e.maximo and ("Grama +%d%% para sempre (máximo)"):format(math.floor(e.bonus * 100 + 0.5))
		or ("Grama +%d%% para sempre  →  com a próxima estrela: +%d%% (%s)"):format(math.floor(e.bonus * 100 + 0.5), math.floor(e.bonusProximo * 100 + 0.5), e.proximoTitulo)
	req1.Text = (e.temCortador and "✅ " or "⬜ ") .. "Ter comprado o " .. e.nomeCortador
	req2.Text = (e.moedas >= e.custo and "✅ " or "⬜ ") .. ("Ter %s moedas (você tem %s)"):format(fmt(e.custo), fmt(e.moedas))
	btRenascer.BackgroundColor3 = e.pode and (confirmando and VERMELHO or OURO) or CINZA
	btRenascer.AutoButtonColor = e.pode
	btRenascer.Text = e.maximo and "FAMA MÁXIMA!" or (confirmando and "TEM CERTEZA? CLIQUE DE NOVO" or "RENASCER COM FAMA")
end

local function msg(t, erro)
	mensagem.Text = t or ""
	mensagem.TextColor3 = erro and Color3.fromRGB(200, 60, 50) or Color3.fromRGB(60, 140, 60)
end

local function pedir(acao)
	if ocupado then return end
	ocupado = true
	local ok, r = pcall(function() return remote:InvokeServer(acao) end)
	ocupado = false
	if not ok or type(r) ~= "table" then msg("Não deu certo agora. Tente de novo.", true) return end
	if r.estado then estadoAtual = r.estado end
	confirmando = false
	desenhar()
	if r.erro then msg(r.erro, true) som("Erro") return end
	if r.ok then
		msg(("⭐ Fama %d! Bom recomeço!"):format(estadoAtual.estrelas))
		som("Desbloqueio")
		local s = inst("UIScale", { Scale = 1.15, Parent = caixa })
		TweenService:Create(s, TweenInfo.new(0.5, Enum.EasingStyle.Back), { Scale = 1 }):Play()
		task.delay(0.6, function() s:Destroy() end)
	end
end

btRenascer.Activated:Connect(function()
	if not estadoAtual or not estadoAtual.pode then
		if estadoAtual and not estadoAtual.maximo then msg("Ainda faltam requisitos.", true) end
		return
	end
	if not confirmando then
		confirmando = true
		desenhar()
		msg("Isso zera suas moedas e cortadores. Clique de novo para confirmar.", true)
		task.delay(4, function() if confirmando then confirmando = false desenhar() msg("") end end)
		return
	end
	pedir("renascer")
end)

local function definirAberto(v) player:SetAttribute("FamaAberto", v) end
player:GetAttributeChangedSignal("FamaAberto"):Connect(function()
	local aberto = player:GetAttribute("FamaAberto") == true
	gui.Enabled = aberto
	if aberto then
		ajustarEscala()
		confirmando = false
		msg("")
		task.spawn(pedir, "estado")
	end
end)
abrir.Activated:Connect(function() definirAberto(not player:GetAttribute("FamaAberto")) end)
fechar.Activated:Connect(function() definirAberto(false) end)
fundo.Activated:Connect(function() definirAberto(false) end)
UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Escape and player:GetAttribute("FamaAberto") then definirAberto(false) end
end)
for _, nome in ipairs({ "LojaAberta", "MenuJogadorAberto", "SkillTreeOpen", "ForestShopOpen", "PetsAberto", "PremiosAberto", "MissoesAberto", "OficinaAberta", "AlbumAberto" }) do
	player:GetAttributeChangedSignal(nome):Connect(function() if player:GetAttribute(nome) then definirAberto(false) end end)
end
