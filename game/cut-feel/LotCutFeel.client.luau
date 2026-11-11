--[[
	LotCutFeel (LocalScript) — Claude, 2026-11-10
	Corte do carrinho no LOTE mais fluido, só no cliente deste jogador:
	- previsão: o quadrado que a lâmina atravessa abaixa na hora, sem esperar o servidor;
	- confirmação: quando o servidor mostra a grama cortada ("Cortada"), a previsão vira estado real;
	- recusa: se o servidor não confirmar em CONFIRM_TIMEOUT (saco cheio, parou, etc.), a grama volta;
	- feedback: aparas e som "Corte" no instante do corte.
	Usa a MESMA regra do servidor (GameServer, CutIntent): trajeto da lâmina, alcance
	LOT_CUT_REACH + (largura-1)*2 e orçamento de largura por intervalo (acumula até 3x).
	O servidor continua decidindo corte, saco, XP e moedas. Nada aqui replica.
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("GameConfig"))
local Sons = require(Shared:WaitForChild("Sons"))
local remotes = ReplicatedStorage:WaitForChild("GameRemotes")

local player = Players.LocalPlayer

local LOT_CUT_REACH = 0 -- igual ao servidor: largura 1 = só o quadrado sob o centro da lâmina
local HALF = 2 -- meio quadrado (4x4 studs)
-- Perto da divisa entre quadrados, cliente e servidor podem escolher lados diferentes
-- (a posição da lâmina difere um pouco). Ali o cliente não prevê; o servidor decide.
local EDGE_MARGIN = 0.4
local CONFIRM_TIMEOUT = 0.8
local SHRINK_TIME = 0.16

local level, finished = 1, false
local plot: Model? = nil
local pending: { [BasePart]: { t: number, stub: BasePart? } } = {}
local tokens, tokenClock = nil :: number?, nil :: number?
local lastBlade: Vector2? = nil

remotes:WaitForChild("StateSync").OnClientEvent:Connect(function(state)
	if type(state) ~= "table" then return end
	level = tonumber(state.level) or level
	finished = state.finished == true
end)

-- aparas: um emissor local, reposicionado a cada corte
local fxAttachment = Instance.new("Attachment")
fxAttachment.Name = "LotCutFeelFX"
fxAttachment.Parent = workspace.Terrain
local clippings = Instance.new("ParticleEmitter")
clippings.Name = "AparasCorte"
clippings.Texture = "rbxasset://textures/particles/sparkles_main.dds"
clippings.Color = ColorSequence.new(Color3.fromRGB(150, 215, 90), Color3.fromRGB(86, 158, 52))
clippings.LightInfluence = 1
clippings.Size = NumberSequence.new(0.28, 0.08)
clippings.Squash = NumberSequence.new(0.6)
clippings.Lifetime = NumberRange.new(0.35, 0.65)
clippings.Speed = NumberRange.new(5, 9)
clippings.SpreadAngle = Vector2.new(55, 55)
clippings.EmissionDirection = Enum.NormalId.Top
clippings.Acceleration = Vector3.new(0, -30, 0)
clippings.RotSpeed = NumberRange.new(-360, 360)
clippings.Rate = 0
clippings.Parent = fxAttachment

local function findPlot(): Model?
	if plot and plot.Parent and plot:GetAttribute("OwnerUserId") == player.UserId then return plot end
	plot = nil
	local world = workspace:FindFirstChild("GameWorld")
	local plots = world and world:FindFirstChild("Plots")
	if not plots then return nil end
	for _, candidate in ipairs(plots:GetChildren()) do
		if candidate:GetAttribute("OwnerUserId") == player.UserId then
			plot = candidate
			break
		end
	end
	return plot
end

-- distância do segmento a-b (XZ local do lote) até a área do quadrado com centro c
local function distQuadrado(c: Vector2, a: Vector2, b: Vector2): number
	local best = math.huge
	for i = 0, 5 do
		local q = a:Lerp(b, i / 5)
		local dx = math.max(math.abs(q.X - c.X) - (HALF - EDGE_MARGIN), 0)
		local dy = math.max(math.abs(q.Y - c.Y) - (HALF - EDGE_MARGIN), 0)
		best = math.min(best, math.sqrt(dx * dx + dy * dy))
	end
	return best
end

local function serverCut(tile: BasePart): boolean
	local low = tile:FindFirstChild("Cortada")
	return low ~= nil and (low :: BasePart).Transparency < 0.5
end

local function clearPending(tile: BasePart)
	local p = pending[tile]
	if not p then return end
	pending[tile] = nil
	if p.stub then p.stub:Destroy() end
	tile.LocalTransparencyModifier = 0
end

local function bareClone(part: BasePart): BasePart
	local c = part:Clone()
	for _, child in ipairs(c:GetChildren()) do child:Destroy() end
	c.Anchored, c.CanCollide, c.CanQuery, c.CanTouch = true, false, false, false
	return c
end

local function predict(tile: BasePart)
	local low = tile:FindFirstChild("Cortada") :: BasePart?
	if not low then return end
	-- grama alta "abaixa" (clone local), a original fica oculta só aqui
	local ghost = bareClone(tile)
	ghost.Parent = workspace.CurrentCamera
	local size = ghost.Size
	local shrunk = Vector3.new(size.X * 0.92, size.Y * 0.12, size.Z * 0.92)
	TweenService:Create(ghost, TweenInfo.new(SHRINK_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = shrunk,
		CFrame = ghost.CFrame * CFrame.new(0, -(size.Y - shrunk.Y) / 2, 0),
	}):Play()
	task.delay(SHRINK_TIME + 0.02, function() ghost:Destroy() end)
	tile.LocalTransparencyModifier = 1
	-- grama cortada aparece já, até o servidor confirmar
	local stub = bareClone(low)
	stub.Transparency = 0
	stub.Parent = workspace.CurrentCamera
	pending[tile] = { t = os.clock(), stub = stub }
	fxAttachment.WorldPosition = tile.Position + Vector3.new(0, 0.6, 0)
	clippings:Emit(10)
	Sons.tocar("Corte", { pos = tile.Position, pitch = 0.9 + math.random() * 0.25, volume = 0.8 })
end

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for tile, p in pairs(pending) do
		if not tile.Parent then
			if p.stub then p.stub:Destroy() end
			pending[tile] = nil
		elseif serverCut(tile) then
			clearPending(tile) -- o servidor já mostra a grama cortada
		elseif now - p.t > CONFIRM_TIMEOUT then
			clearPending(tile) -- recusado: a grama volta
		end
	end

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local tool = char and char:FindFirstChild("MowerTool")
	local moving = hum ~= nil and hum.Health > 0 and hum.MoveDirection.Magnitude > 0.05
	if not tool or not moving or finished or player:GetAttribute("SkillTreeOpen")
		or (player:GetAttribute("Saco") or 0) >= (player:GetAttribute("SacoMax") or 1) then
		lastBlade, tokens, tokenClock = nil, nil, nil
		return
	end
	local p = findPlot()
	local zone = p and p:FindFirstChild("GrassZone01") :: BasePart?
	local visuals = p and p:FindFirstChild("GrassVisuals")
	local blade = tool:FindFirstChild("Lamina", true)
	if not zone or not visuals or not blade or not blade:IsA("BasePart") then return end
	local lp = zone.CFrame:PointToObjectSpace(blade.Position)
	if math.abs(lp.X) > 18 or math.abs(lp.Z) > 18 or math.abs(lp.Y) > 7 then
		lastBlade = nil
		return
	end
	local settings = Config.Levels[level] or Config.Levels[1]
	local width = settings.Width
	tokens = math.min((tokens or width) + (now - (tokenClock or now)) / settings.Interval * width, width * 3)
	tokenClock = now
	local here = Vector2.new(lp.X, lp.Z)
	local prev = lastBlade
	if not prev or (prev - here).Magnitude > 8 then prev = here end
	lastBlade = here
	if (tokens :: number) < 1 then return end
	local reach = LOT_CUT_REACH + (width - 1) * 2
	local candidates = {}
	for row = 1, 8 do
		for col = 1, 8 do
			local c = Vector2.new(-18 + col * 4, -18 + row * 4)
			if distQuadrado(c, prev, here) <= reach then
				local tile = visuals:FindFirstChild(string.format("Grass_%02d_%02d", row, col))
				if tile and tile:IsA("BasePart") and not pending[tile] and not serverCut(tile)
					and tile:FindFirstChild("Cortada") then
					table.insert(candidates, { tile = tile, d = (c - prev).Magnitude })
				end
			end
		end
	end
	table.sort(candidates, function(a, b) return a.d < b.d end)
	for _, cand in ipairs(candidates) do
		if (tokens :: number) < 1 then break end
		tokens = (tokens :: number) - 1
		predict(cand.tile)
	end
end)
