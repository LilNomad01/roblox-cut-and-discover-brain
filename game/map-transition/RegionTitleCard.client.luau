--[[
	RegionTitleCard (LocalScript) — Claude, 2026-11-10
	Cartão de região ao cruzar o portal Vila ↔ Floresta Esquecida (atributo RegiaoAtual, definido pelo
	servidor). Mesmo estilo do aviso "PASSAGEM DESCOBERTA": faixa dourada, texto verde-escuro FredokaOne
	e contorno escuro. Substitui o antigo aviso de texto do servidor. Só visual, só local.
]]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local okSons, Sons = pcall(function() return require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Sons", 5)) end)

local player = Players.LocalPlayer
local REGIOES = {
	["Floresta Esquecida"] = { titulo = "FLORESTA ESQUECIDA", sub = "Corte o matagal e procure segredos", cor = Color3.fromRGB(244, 211, 123) },
	["Vila"] = { titulo = "VILA", sub = "De volta ao seu jardim", cor = Color3.fromRGB(176, 228, 132) },
}

local gui = Instance.new("ScreenGui")
gui.Name = "RegionTitleCard"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 40
gui.Parent = player:WaitForChild("PlayerGui")

local faixa = Instance.new("Frame")
faixa.Name = "Faixa"
faixa.AnchorPoint = Vector2.new(0.5, 0.5)
faixa.Position = UDim2.fromScale(0.5, 0.24)
faixa.Size = UDim2.fromOffset(0, 74)
faixa.BackgroundColor3 = Color3.fromRGB(244, 211, 123)
faixa.ClipsDescendants = true
faixa.Visible = false
faixa.Parent = gui
local canto = Instance.new("UICorner") canto.CornerRadius = UDim.new(0, 18) canto.Parent = faixa
local borda = Instance.new("UIStroke") borda.Thickness = 3 borda.Color = Color3.fromRGB(54, 77, 49) borda.Parent = faixa

local titulo = Instance.new("TextLabel")
titulo.Name = "Titulo"
titulo.BackgroundTransparency = 1
titulo.Position = UDim2.new(0, 16, 0, 6)
titulo.Size = UDim2.new(1, -32, 0, 40)
titulo.Font = Enum.Font.FredokaOne
titulo.TextScaled = true
titulo.TextColor3 = Color3.fromRGB(61, 78, 54)
titulo.Parent = faixa
local sub = Instance.new("TextLabel")
sub.Name = "Sub"
sub.BackgroundTransparency = 1
sub.Position = UDim2.new(0, 16, 0, 46)
sub.Size = UDim2.new(1, -32, 0, 20)
sub.Font = Enum.Font.GothamBold
sub.TextScaled = true
sub.TextColor3 = Color3.fromRGB(78, 96, 66)
sub.Parent = faixa

local seq = 0
local function mostrar(regiao: string)
	local info = REGIOES[regiao]
	if not info then return end
	seq += 1
	local meu = seq
	titulo.Text, sub.Text = info.titulo, info.sub
	faixa.BackgroundColor3 = info.cor
	local largura = math.clamp(workspace.CurrentCamera.ViewportSize.X * 0.46, 300, 560)
	faixa.Visible = true
	faixa.Size = UDim2.fromOffset(0, 74)
	faixa.BackgroundTransparency = 0
	titulo.TextTransparency, sub.TextTransparency, borda.Transparency = 0, 0, 0
	TweenService:Create(faixa, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(largura, 74) }):Play()
	if okSons and Sons then pcall(Sons.tocar, "Whoosh", { pitch = 0.8, volume = 0.5 }) end
	task.delay(2.6, function()
		if meu ~= seq then return end
		local info2 = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(faixa, info2, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(titulo, info2, { TextTransparency = 1 }):Play()
		TweenService:Create(sub, info2, { TextTransparency = 1 }):Play()
		TweenService:Create(borda, info2, { Transparency = 1 }):Play()
		task.delay(0.5, function() if meu == seq then faixa.Visible = false end end)
	end)
end

local anterior = player:GetAttribute("RegiaoAtual")
player:GetAttributeChangedSignal("RegiaoAtual"):Connect(function()
	local atual = player:GetAttribute("RegiaoAtual")
	-- a primeira definição (ao entrar no jogo, sempre "Vila") não mostra cartão
	if anterior ~= nil and atual ~= anterior then mostrar(atual) end
	anterior = atual
end)
