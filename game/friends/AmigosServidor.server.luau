--[[
	ServerScriptService.CorteEDescubra.AmigosServidor  [Claude 2026-11-12]
	Jogar com amigos (PAD-08): cada amigo do Roblox no MESMO servidor dá +10% de grama (até 3 amigos = +30%).
	Atributos no Player:
	  * AmigosNoServidor — quantos amigos estão no servidor (até o teto)
	  * AmigosNomes     — nomes (para o cliente mostrar)
	  * BonusAmigos     — bônus somado pela Economia.FatorGrama
	Avisa quando um amigo entra. O convite (SocialService) é pedido pelo cliente; não há prêmio por convidar.
	Teste no Studio (um jogador só): Player:SetAttribute("AmigoTeste", 2) no SERVIDOR finge 2 amigos.
	Esse atributo só vale com RunService:IsStudio() e cliente não consegue mudá-lo no servidor.
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Economia = require(game.ServerScriptService.Economia)

local BONUS_POR_AMIGO = 0.10
local MAX_AMIGOS = 3

local cache = {} -- [userIdA .. ":" .. userIdB] = boolean

local function chave(a, b)
	local x, y = a.UserId, b.UserId
	if x > y then x, y = y, x end
	return x .. ":" .. y
end

local function saoAmigos(a, b)
	if a.UserId <= 0 or b.UserId <= 0 then return false end
	local k = chave(a, b)
	if cache[k] == nil then
		local ok, sim = pcall(a.IsFriendsWith, a, b.UserId)
		cache[k] = ok and sim == true
	end
	return cache[k]
end

local function recalcular(p)
	if not p.Parent then return end
	local nomes = {}
	for _, o in ipairs(Players:GetPlayers()) do
		if o ~= p and o.Parent and saoAmigos(p, o) then table.insert(nomes, o.DisplayName) end
	end
	local n = #nomes
	if RunService:IsStudio() then
		local teste = math.floor(tonumber(p:GetAttribute("AmigoTeste")) or 0)
		for i = 1, teste do table.insert(nomes, "Amigo de teste " .. i) end
		n += teste
	end
	n = math.clamp(n, 0, MAX_AMIGOS)
	p:SetAttribute("AmigosNoServidor", n)
	p:SetAttribute("AmigosNomes", table.concat(nomes, ", "))
	p:SetAttribute("BonusAmigos", n * BONUS_POR_AMIGO)
end

local function recalcularTodos()
	for _, p in ipairs(Players:GetPlayers()) do task.spawn(recalcular, p) end
end

Players.PlayerAdded:Connect(function(novo)
	novo:GetAttributeChangedSignal("AmigoTeste"):Connect(function() recalcular(novo) end)
	task.wait(3)
	if not novo.Parent then return end
	recalcularTodos()
	for _, o in ipairs(Players:GetPlayers()) do
		if o ~= novo and saoAmigos(novo, o) then
			pcall(Economia.Notificar, o, ("👥 Seu amigo %s entrou! +%d%% de grama enquanto jogarem juntos."):format(novo.DisplayName, BONUS_POR_AMIGO * 100), "sucesso")
			pcall(Economia.Notificar, novo, ("👥 %s está aqui! +%d%% de grama enquanto jogarem juntos."):format(o.DisplayName, BONUS_POR_AMIGO * 100), "sucesso")
		end
	end
end)

Players.PlayerRemoving:Connect(function(saiu)
	task.defer(function()
		for _, p in ipairs(Players:GetPlayers()) do if p ~= saiu then task.spawn(recalcular, p) end end
	end)
end)

for _, p in ipairs(Players:GetPlayers()) do
	p:GetAttributeChangedSignal("AmigoTeste"):Connect(function() recalcular(p) end)
end
recalcularTodos()
