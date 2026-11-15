--[[
	LotCutFeel (LocalScript) — Claude, 2026-11-10
	Corte do CARRINHO no lote mais fluido, só no cliente deste jogador. Prevê na hora os
	quadrados que a lâmina atravessa (visual em ReplicatedStorage.Shared.LotCutPreview) com a
	MESMA regra do servidor (GameServer lotMowerCut): trajeto da lâmina, faixa
	LOT_CUT_REACH + (largura-1)*2 e orçamento de largura por intervalo (acumula até 3x).
	O servidor continua decidindo corte, saco, XP e moedas. Nada aqui replica.
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("GameConfig"))
local Preview = require(Shared:WaitForChild("LotCutPreview"))

local player = Players.LocalPlayer

local LOT_CUT_REACH = 0 -- igual ao servidor: largura 1 = só o quadrado sob o centro da lâmina
-- Perto da divisa entre quadrados, cliente e servidor podem escolher lados diferentes
-- (a posição da lâmina difere um pouco). Ali o cliente não prevê; o servidor decide.
local EDGE_MARGIN = 0.4

local tokens, tokenClock = nil, nil
local lastBlade = nil

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local tool = char and char:FindFirstChild("MowerTool")
	local moving = hum ~= nil and hum.Health > 0 and hum.MoveDirection.Magnitude > 0.05
	if not tool or not moving or player:GetAttribute("SkillTreeOpen") or not Preview.canCut() then
		lastBlade, tokens, tokenClock = nil, nil, nil
		return
	end
	local zone, visuals = Preview.lot()
	local blade = tool:FindFirstChild("Lamina", true)
	if not zone or not visuals or not blade or not blade:IsA("BasePart") then return end
	local lp = zone.CFrame:PointToObjectSpace(blade.Position)
	if math.abs(lp.X) > 18 or math.abs(lp.Z) > 18 or math.abs(lp.Y) > 7 then
		lastBlade = nil
		return
	end
	local settings = Config.Levels[Preview.level] or Config.Levels[1]
	local width = settings.Width
	tokens = math.min((tokens or width) + (now - (tokenClock or now)) / settings.Interval * width, width * 3)
	tokenClock = now
	local here = Vector2.new(lp.X, lp.Z)
	local prev = lastBlade
	if not prev or (prev - here).Magnitude > 8 then prev = here end
	lastBlade = here
	if tokens < 1 then return end
	local reach = LOT_CUT_REACH + (width - 1) * 2
	local candidates = {}
	for row = 1, 8 do
		for col = 1, 8 do
			local c = Preview.center(row, col)
			if Preview.distQuadrado(c, prev, here, Preview.HALF - EDGE_MARGIN) <= reach then
				local tile = Preview.tile(visuals, row, col)
				if tile and tile:IsA("BasePart") and not Preview.isPending(tile) and not Preview.serverCut(tile)
					and tile:FindFirstChild("Cortada") then
					table.insert(candidates, { tile = tile, d = (c - prev).Magnitude })
				end
			end
		end
	end
	table.sort(candidates, function(a, b) return a.d < b.d end)
	for _, cand in ipairs(candidates) do
		if tokens < 1 then break end
		tokens -= 1
		Preview.predict(cand.tile)
	end
end)
