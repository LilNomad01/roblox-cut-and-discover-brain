--[[
	ReplicatedStorage.Shared.LotCutPreview (ModuleScript, só CLIENTE) — Claude, 2026-11-10
	Previsão local do corte da grama do LOTE, usada pelo carrinho (LotCutFeel) e pelas
	ferramentas manuais (FerramentasCliente):
	- predict(tile): a grama alta abaixa na hora (clone local), a "Cortada" aparece já,
	  aparas e som; confirma quando o servidor mostra a "Cortada"; se não confirmar a tempo,
	  a grama volta (recusa);
	- swing(...): acompanha um golpe manual quadro a quadro e prevê no instante do contato,
	  com a mesma regra do servidor (GameServer CortarPorLamina + FerramentasServer).
	O servidor continua decidindo corte, saco, XP e moedas. Nada aqui replica.
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sons = require(script.Parent:WaitForChild("Sons"))

local P = {}
P.HALF = 2 -- meio quadrado do lote (4x4 studs)
P.level, P.finished = 1, false
P.dano = {} -- [tile] = dano local previsto pelas ferramentas manuais (espelha s.job.dano)

local SHRINK_TIME = 0.16
local player = Players.LocalPlayer
local pending = {} -- [tile] = { t, timeout, stub }
local plot = nil
local lastToolFeedback = -100

task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("GameRemotes")
	remotes:WaitForChild("StateSync").OnClientEvent:Connect(function(state)
		if type(state) ~= "table" then return end
		P.level = tonumber(state.level) or P.level
		P.finished = state.finished == true
		if state.count == 0 then table.clear(P.dano) end -- novo serviço: dano zerado no servidor
	end)
end)

-- aparas: um emissor local reposicionado a cada uso
local fxAttachment = Instance.new("Attachment")
fxAttachment.Name = "LotCutPreviewFX"
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

function P.burst(pos: Vector3, n: number)
	fxAttachment.WorldPosition = pos
	clippings:Emit(n)
end

function P.findPlot()
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

-- zona (BasePart) e pasta de quadrados do lote do jogador
function P.lot()
	local p = P.findPlot()
	return p and p:FindFirstChild("GrassZone01"), p and p:FindFirstChild("GrassVisuals")
end

function P.center(row: number, col: number): Vector2
	return Vector2.new(-18 + col * 4, -18 + row * 4)
end

function P.tile(visuals: Instance, row: number, col: number)
	return visuals:FindFirstChild(string.format("Grass_%02d_%02d", row, col))
end

-- distância do segmento a-b (XZ local do lote) até a área do quadrado de centro c e meia-largura half
function P.distQuadrado(c: Vector2, a: Vector2, b: Vector2, half: number): number
	local best = math.huge
	for i = 0, 5 do
		local q = a:Lerp(b, i / 5)
		local dx = math.max(math.abs(q.X - c.X) - half, 0)
		local dy = math.max(math.abs(q.Y - c.Y) - half, 0)
		best = math.min(best, math.sqrt(dx * dx + dy * dy))
	end
	return best
end

function P.serverCut(tile): boolean
	local low = tile:FindFirstChild("Cortada")
	return low ~= nil and low.Transparency < 0.5
end

function P.isPending(tile): boolean
	return pending[tile] ~= nil
end

function P.canCut(): boolean
	return not P.finished and (player:GetAttribute("Saco") or 0) < (player:GetAttribute("SacoMax") or 1)
end

local function bareClone(part)
	local c = part:Clone()
	for _, child in ipairs(c:GetChildren()) do child:Destroy() end
	c.Anchored, c.CanCollide, c.CanQuery, c.CanTouch = true, false, false, false
	return c
end

local function clearPending(tile, rolledBack: boolean)
	local p = pending[tile]
	if not p then return end
	pending[tile] = nil
	if p.stub then p.stub:Destroy() end
	tile.LocalTransparencyModifier = 0
	if rolledBack then P.dano[tile] = nil end
end

-- opts: timeout (s), sound (nome em AudioConfig.SFX ou false), pitch, clippings (n)
function P.predict(tile, opts)
	opts = opts or {}
	local low = tile:FindFirstChild("Cortada")
	if not low or pending[tile] or P.serverCut(tile) then return false end
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
	local stub = bareClone(low)
	stub.Transparency = 0
	stub.Parent = workspace.CurrentCamera
	pending[tile] = { t = os.clock(), timeout = opts.timeout or 0.8, stub = stub }
	P.burst(tile.Position + Vector3.new(0, 0.6, 0), opts.clippings or 10)
	if opts.sound ~= false then
		Sons.tocar(opts.sound or "Corte", { pos = tile.Position, pitch = opts.pitch or (0.9 + math.random() * 0.25), volume = 0.8 })
	end
	return true
end

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for tile, p in pairs(pending) do
		if not tile.Parent then
			if p.stub then p.stub:Destroy() end
			pending[tile] = nil
		elseif P.serverCut(tile) then
			clearPending(tile, false) -- o servidor já mostra a grama cortada
		elseif now - p.t > p.timeout then
			clearPending(tile, true) -- recusado: a grama volta
		end
	end
end)

--[[ Golpe manual. Espelha o servidor:
	- FerramentasServer: amostras só na janela; segmento inválido se algum ponto estiver além de
	  cfg.alcance (plano), fora de -6..3 em Y relativo ao root ou atrás do personagem;
	- GameServer CortarPorLamina: quadrado tocado se a linha da lâmina passar a cfg.largura/2 da
	  área do quadrado; no máximo cfg.maxTiles tocados por golpe, NA ORDEM DO TOQUE; dano += forca
	  (x raridade); corta quando dano >= 0.999.
	Margem de 0.3 stud na borda do quadrado: perto da divisa o cliente não prevê.
]]
local TOOL_EDGE_MARGIN = 0.3
local TOOL_TIMEOUT = 1.0

function P.recentToolFeedback(): boolean
	return os.clock() - lastToolFeedback < 1.0
end

function P.swing(tipo: string, cfg, mult: number, char: Model)
	local root = char:FindFirstChild("HumanoidRootPart")
	local zone, visuals = P.lot()
	if not root or not zone or not visuals then return nil end
	local touched, nTouched, feedback = {}, 0, false
	local forestState = { touched = {}, n = 0 } -- golpes na floresta (P.forestTool, registrado pelo ForestGrassClient)
	local prevBase, prevTip = nil, nil
	local self = {}

	local function valid(pt: Vector3): boolean
		local v = pt - root.Position
		local flat = Vector3.new(v.X, 0, v.Z)
		if flat.Magnitude > cfg.alcance or v.Y < -6 or v.Y > 3 then return false end
		if flat.Magnitude > 1 and flat:Dot(root.CFrame.LookVector) < 0 then return false end
		return true
	end

	local function test(base: Vector3, tip: Vector3)
		if nTouched >= cfg.maxTiles or not valid(base) or not valid(tip) then return end
		if P.forestTool and player:GetAttribute("RegiaoAtual") == "Floresta Esquecida" then
			if P.forestTool(base, tip, cfg, mult, forestState) and not feedback then
				feedback = true
				lastToolFeedback = os.clock()
			end
			return
		end
		local la, lb = zone.CFrame:PointToObjectSpace(base), zone.CFrame:PointToObjectSpace(tip)
		if math.abs(la.Y) > 7 or math.abs(lb.Y) > 7 then return end
		local a, b = Vector2.new(la.X, la.Z), Vector2.new(lb.X, lb.Z)
		local hits = {}
		for row = 1, 8 do
			for col = 1, 8 do
				local c = P.center(row, col)
				if P.distQuadrado(c, a, b, P.HALF - TOOL_EDGE_MARGIN) <= cfg.largura / 2 then
					local tile = P.tile(visuals, row, col)
					if tile and not touched[tile] and not P.serverCut(tile) and not pending[tile] then
						table.insert(hits, { tile = tile, d = (c - (a + b) / 2).Magnitude })
					end
				end
			end
		end
		table.sort(hits, function(x, y) return x.d < y.d end)
		for _, h in ipairs(hits) do
			if nTouched >= cfg.maxTiles then break end
			nTouched += 1
			touched[h.tile] = true
			if not feedback then
				feedback = true
				lastToolFeedback = os.clock()
				Sons.tocar(cfg.som or "Corte", { pos = h.tile.Position, pitch = cfg.somPitch })
			end
			P.dano[h.tile] = (P.dano[h.tile] or 0) + cfg.forca * mult
			if P.dano[h.tile] >= 0.999 and P.canCut() then
				P.predict(h.tile, { timeout = TOOL_TIMEOUT, sound = false, clippings = tipo == "CortadorUnha" and 6 or 10 })
			else
				P.burst(h.tile.Position + Vector3.new(0, 0.6, 0), 3) -- acertou, mas ainda não cortou
			end
		end
	end

	-- chamada a cada quadro da janela com as posições reais da lâmina (LaminaBase/LaminaPonta)
	function self.sample(base: Vector3, tip: Vector3)
		if prevBase then
			for i = 1, 2 do -- sub-amostra entre quadros (o servidor amostra a ~90 Hz)
				local f = i / 3
				test(prevBase:Lerp(base, f), prevTip:Lerp(tip, f))
			end
		end
		test(base, tip)
		prevBase, prevTip = base, tip
	end

	return self
end

return P
