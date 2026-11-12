--[[
	StarterPlayerScripts.AmigosCliente  [Claude 2026-11-12]
	Jogar com amigos (PAD-08): selo no HUD, acima de "Missões"/"Prêmios".
	  * sem amigos no servidor: "👥 Convidar amigos" (abre o convite do Roblox; sem prêmio por convidar)
	  * com amigos: "👥 2 amigos aqui · +20% grama" (clicar também abre o convite)
	Lê os atributos AmigosNoServidor/BonusAmigos/AmigosNomes postos pelo AmigosServidor.
]]
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")
local player = Players.LocalPlayer

local TINTA = Color3.fromRGB(52, 44, 38)
local ROXO = Color3.fromRGB(150, 110, 220)
local VERDE = Color3.fromRGB(96, 196, 104)

local hud = Instance.new("ScreenGui")
hud.Name = "AmigosHud"
hud.ResetOnSpawn = false
hud.DisplayOrder = 5
hud.Parent = player:WaitForChild("PlayerGui")

local botao = Instance.new("TextButton")
botao.AnchorPoint = Vector2.new(1, 0)
botao.Position = UDim2.new(1, -18, 0, 280)
botao.Size = UDim2.fromOffset(310, 42)
botao.Font = Enum.Font.FredokaOne
botao.TextSize = 19
botao.TextColor3 = Color3.new(1, 1, 1)
botao.TextStrokeColor3 = TINTA
botao.TextStrokeTransparency = 0.3
botao.AutoButtonColor = true
botao.Parent = hud
Instance.new("UICorner", botao).CornerRadius = UDim.new(0, 12)
local borda = Instance.new("UIStroke")
borda.Thickness = 3
borda.Color = TINTA
borda.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
borda.Parent = botao

local function atualizar()
	local n = tonumber(player:GetAttribute("AmigosNoServidor")) or 0
	local bonus = tonumber(player:GetAttribute("BonusAmigos")) or 0
	if n > 0 then
		botao.Text = ("👥 %d amigo%s aqui · +%d%% grama"):format(n, n > 1 and "s" or "", math.floor(bonus * 100 + 0.5))
		botao.BackgroundColor3 = VERDE
	else
		botao.Text = "👥 Convidar amigos (+10% cada)"
		botao.BackgroundColor3 = ROXO
	end
end
player:GetAttributeChangedSignal("AmigosNoServidor"):Connect(atualizar)
player:GetAttributeChangedSignal("BonusAmigos"):Connect(atualizar)
atualizar()

botao.Activated:Connect(function()
	local ok, pode = pcall(SocialService.CanSendGameInviteAsync, SocialService, player)
	if ok and pode then
		pcall(SocialService.PromptGameInvite, SocialService, player)
	end
end)
