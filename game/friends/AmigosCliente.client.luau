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

-- Claude 2026-11-12: botão no HudKit (mesmo estilo e grade da HUD original); o chip mostra o bônus atual
local HudKit = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("HudKit"))
local botao, hudApi = HudKit.botao({ nome = "Amigos", rotulo = "Amigos", icone = "👥", c1 = HudKit.C.Verde1, c2 = HudKit.C.Verde2, ordem = 4, lado = "direita" })

local function atualizar()
	local n = tonumber(player:GetAttribute("AmigosNoServidor")) or 0
	local bonus = tonumber(player:GetAttribute("BonusAmigos")) or 0
	if n > 0 then
		hudApi.chip(("+%d%%"):format(math.floor(bonus * 100 + 0.5)), HudKit.C.Verde1, HudKit.C.Verde2)
	else
		hudApi.chip(nil)
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
