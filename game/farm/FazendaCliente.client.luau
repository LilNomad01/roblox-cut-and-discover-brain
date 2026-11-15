--[[
	StarterPlayerScripts.FazendaCliente  [Claude 2026-11-12]
	Região "Fazenda Abandonada": ao entrar na área mostra o nome da região e a regra principal
	("só o carrinho corta aqui · grama vale 2×"); sem acesso, mostra o requisito.
	Só visual; quem decide o acesso e o corte é o FazendaServidor.
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Config = require(RS:WaitForChild("Shared"):WaitForChild("FazendaConfig"))
local player = Players.LocalPlayer

local TINTA = Color3.fromRGB(52, 44, 38)
local gui = Instance.new("ScreenGui")
gui.Name = "FazendaTitulo"
gui.ResetOnSpawn = false
gui.DisplayOrder = 6
gui.Parent = player:WaitForChild("PlayerGui")

local titulo = Instance.new("TextLabel")
titulo.AnchorPoint = Vector2.new(0.5, 0)
titulo.Position = UDim2.new(0.5, 0, 0, 150)
titulo.Size = UDim2.fromOffset(600, 50)
titulo.BackgroundTransparency = 1
titulo.Font = Enum.Font.FredokaOne
titulo.TextSize = 40
titulo.TextColor3 = Color3.fromRGB(255, 226, 140)
titulo.TextStrokeColor3 = TINTA
titulo.TextStrokeTransparency = 0
titulo.TextTransparency = 1
titulo.Text = "🌾 FAZENDA ABANDONADA"
titulo.Parent = gui
local sub = titulo:Clone()
sub.Position = UDim2.new(0.5, 0, 0, 198)
sub.TextSize = 20
sub.TextColor3 = Color3.new(1, 1, 1)
sub.Text = ""
sub.Parent = gui

local function mostrar(texto)
	sub.Text = texto
	for _, l in ipairs({ titulo, sub }) do
		l.TextTransparency, l.TextStrokeTransparency = 0, 0
	end
	task.delay(3.5, function()
		for _, l in ipairs({ titulo, sub }) do
			TweenService:Create(l, TweenInfo.new(1), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		end
	end)
end

local dentroAntes = false
task.spawn(function()
	while true do
		task.wait(0.5)
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local dentro = root ~= nil and Config.dentro(root.Position)
		if dentro and not dentroAntes then
			if player:GetAttribute("FazendaLiberada") then
				mostrar("Só o carrinho corta aqui · a grama vale 2× · caçamba ao lado do celeiro")
			else
				mostrar(("🔒 Abre no nível %d ou com ⭐ Fama %d"):format(Config.NivelMinimo, Config.FamaMinima))
			end
		end
		dentroAntes = dentro
	end
end)
