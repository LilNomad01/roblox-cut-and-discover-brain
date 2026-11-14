--[[
	ForestSecretPromptClient (LocalScript) — Claude, 2026-11-10
	Esconde, so para este jogador, o prompt de segredos da floresta que ele ja coletou.
	Apenas visual: quem decide a recompensa e o servidor (GameServer.forestAddSecret).
	O servidor publica os ids coletados em Player:GetAttribute("ForestClaimedSecrets")
	e marca cada prompt com o atributo "ForestSecretId".
]]
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local claimed: { [string]: boolean } = {}
local shown: { [ProximityPrompt]: boolean } = {}

local function parse()
	claimed = {}
	for id in string.gmatch(player:GetAttribute("ForestClaimedSecrets") or "", "[^,]+") do
		claimed[id] = true
	end
end

local function apply(prompt: ProximityPrompt)
	local id = prompt:GetAttribute("ForestSecretId")
	if type(id) == "string" and claimed[id] then
		prompt.Enabled = false
	end
end

ProximityPromptService.PromptShown:Connect(function(prompt)
	shown[prompt] = true
	apply(prompt)
end)
ProximityPromptService.PromptHidden:Connect(function(prompt)
	shown[prompt] = nil
end)
player:GetAttributeChangedSignal("ForestClaimedSecrets"):Connect(function()
	parse()
	for prompt in pairs(shown) do
		apply(prompt)
	end
end)
parse()
