--[[
	StarterPlayerScripts.GramaPackCliente  [Claude 2026-11-13]
	Pedido do usuário: "deixe toda a grama como a da área de teste".
	A área de teste (CutPrototypeZone) e a Floresta já usam os tufos do Grass Pack (Blender):
	ReplicatedStorage.GramaAssets.GrassPack.Grass_<A01..A06>_<TALL|SHORT|STUBBLE>.
	Os 4 lotes e a Fazenda ainda usavam um tufo antigo por quadrado de 4x4 (MeshPart + filho "Cortada").

	Este script troca SÓ O VISUAL, no cliente:
	  * esconde localmente (LocalTransparencyModifier) o tufo antigo e a "Cortada" de cada quadrado;
	  * põe 9 tufos do Grass Pack no quadrado, mesma escala da área de teste (0,9–1,1);
	  * estado vem do servidor, sem lógica nova:
	      quadrado inteiro (Transparency 0)               -> TALL
	      cortado (Transparency 1)                         -> SHORT
	      corte rente (atributo AlturaOriginal na Cortada) -> STUBBLE
	  * ao cortar: o TALL achata e some (0,16 s) e o SHORT aparece; ao rebrotar, o TALL cresce de volta;
	  * grama perto da câmera fica translúcida, como na área de teste (não esconde o personagem).
	O corte, o saco, as moedas, as missões e a rebrota continuam 100% no servidor (GameServer / FazendaServidor).
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local pack = ReplicatedStorage:WaitForChild("GramaAssets"):WaitForChild("GrassPack")
local TUFOS = { "A01", "A02", "A03", "A04", "A05", "A06" }
local ESTADOS = { "TALL", "SHORT", "STUBBLE" }
for _, id in ipairs(TUFOS) do
	for _, e in ipairs(ESTADOS) do
		if not pack:FindFirstChild("Grass_" .. id .. "_" .. e) then
			warn("[GramaPack] falta Grass_" .. id .. "_" .. e .. "; grama antiga mantida")
			return
		end
	end
end

local CFG = {
	PorLado = 3, -- 3x3 tufos por quadrado de 4x4 (passo ~1,33; a área de teste usa 1,5)
	Jitter = 0.35,
	EscalaMin = 0.9, -- igual à área de teste (GrassConfig.Visual.EscalaPackMin/Max)
	EscalaMax = 1.1,
	Largura = 1.15, -- um pouco mais largo, para fechar o quadrado sem buracos
	TempoAchatar = 0.16,
	TempoCrescer = 0.35,
	FadeRaio = 3.5, -- igual GrassConfig.Visual.FadeCameraRaio / FadeCameraValor
	FadeValor = 0.75,
}

local pasta = Instance.new("Folder")
pasta.Name = "GramaPackLocal"
pasta.Parent = workspace

local registros = {} -- quadrado (BasePart) -> registro
local porHash = {} -- célula de 4 studs -> { registros }

local function hash01(x: number, z: number, k: number): number
	local v = math.sin(x * 12.9898 + z * 78.233 + k * 37.719) * 43758.5453
	return v - math.floor(v)
end

local function tom(x: number, z: number): Color3
	-- mesma ideia da floresta: manchas suaves de verde
	local m = math.clamp(0.5 + math.noise(x * 0.021, z * 0.021) * 1.4, 0, 1)
	return Color3.fromRGB(105, 172, 66):Lerp(Color3.fromRGB(155, 202, 89), m)
end

local raioParams = RaycastParams.new()
raioParams.FilterType = Enum.RaycastFilterType.Include
local function atualizarFiltro()
	local lista = { workspace.Terrain }
	local plots = workspace:FindFirstChild("GameWorld") and workspace.GameWorld:FindFirstChild("Plots")
	if plots then
		for _, p in ipairs(plots:GetChildren()) do
			local l = p:FindFirstChild("Lawn")
			if l then table.insert(lista, l) end
		end
	end
	raioParams.FilterDescendantsInstances = lista
end

local function estadoDe(quad: BasePart): number
	if quad.Transparency < 0.5 then return 1 end
	local c = quad:FindFirstChild("Cortada")
	if c and c:GetAttribute("AlturaOriginal") ~= nil then return 3 end
	return 2
end

local function criarTufo(r, i: number, estado: number): BasePart
	local t = r.tufos[i]
	local molde = pack["Grass_" .. t.id .. "_" .. ESTADOS[estado]]
	local p = molde:Clone()
	p.Name = "Tufo"
	p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = true, false, false, false, false
	p.Size = Vector3.new(molde.Size.X * t.s * CFG.Largura, molde.Size.Y * t.s, molde.Size.Z * t.s * CFG.Largura)
	p.Color = t.cor
	p.CFrame = CFrame.new(t.x, r.y - 0.08 + p.Size.Y / 2, t.z) * CFrame.Angles(0, t.rot, 0)
	p.Parent = pasta
	return p
end

local function aplicar(r, animar: boolean)
	local novo = estadoDe(r.quad)
	if novo == r.estado then return end
	local antigo = r.estado
	r.estado = novo
	for i, t in ipairs(r.tufos) do
		local velho = t.part
		local p = criarTufo(r, i, novo)
		t.part = p
		if animar and velho then
			if novo > antigo then
				-- corte: o tufo velho achata e some; o novo aparece
				local h = velho.Size.Y
				TweenService:Create(velho, TweenInfo.new(CFG.TempoAchatar, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Size = Vector3.new(velho.Size.X, 0.12, velho.Size.Z),
					CFrame = velho.CFrame * CFrame.new(0, -h * 0.45, 0) * CFrame.Angles(0.28, 0, 0.12),
					Transparency = 1,
				}):Play()
				task.delay(CFG.TempoAchatar + 0.05, function() velho:Destroy() end)
			else
				-- rebrota: o novo cresce a partir do chão
				velho:Destroy()
				local alvoSize, alvoCF = p.Size, p.CFrame
				p.Size = Vector3.new(alvoSize.X, alvoSize.Y * 0.2, alvoSize.Z)
				p.CFrame = alvoCF * CFrame.new(0, -alvoSize.Y * 0.4, 0)
				TweenService:Create(p, TweenInfo.new(CFG.TempoCrescer, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = alvoSize, CFrame = alvoCF }):Play()
			end
		elseif velho then
			velho:Destroy()
		end
	end
end

local function esconderAntigo(quad: BasePart)
	quad.LocalTransparencyModifier = 1
	local c = quad:FindFirstChild("Cortada")
	if c and c:IsA("BasePart") then c.LocalTransparencyModifier = 1 end
end

local function registrar(quad: Instance)
	if not quad:IsA("BasePart") or registros[quad] then return end
	if not quad:FindFirstChild("Cortada") then
		-- a "Cortada" pode chegar depois (streaming)
		local con
		con = quad.ChildAdded:Connect(function(c)
			if c.Name == "Cortada" then con:Disconnect() registrar(quad) end
		end)
		return
	end
	local pos = quad.Position
	local hit = workspace:Raycast(pos + Vector3.new(0, 8, 0), Vector3.new(0, -16, 0), raioParams)
	local y = hit and hit.Position.Y or (pos.Y - quad.Size.Y / 2 + 0.4)
	local lado = math.max(quad.Size.X, quad.Size.Z)
	local passo = lado / CFG.PorLado
	local r = { quad = quad, y = y, tufos = {}, estado = 0, cons = {} }
	local k = 0
	for ix = 1, CFG.PorLado do
		for iz = 1, CFG.PorLado do
			k += 1
			local x = pos.X - lado / 2 + passo * (ix - 0.5) + (hash01(pos.X, pos.Z, k) - 0.5) * 2 * CFG.Jitter
			local z = pos.Z - lado / 2 + passo * (iz - 0.5) + (hash01(pos.Z, pos.X, k + 9) - 0.5) * 2 * CFG.Jitter
			table.insert(r.tufos, {
				x = x, z = z,
				id = TUFOS[1 + math.floor(hash01(x, z, 3) * #TUFOS) % #TUFOS],
				s = CFG.EscalaMin + (CFG.EscalaMax - CFG.EscalaMin) * hash01(x, z, 5),
				rot = hash01(x, z, 7) * math.pi * 2,
				cor = tom(x, z),
			})
		end
	end
	registros[quad] = r
	local hk = math.floor(pos.X / 4) * 4096 + math.floor(pos.Z / 4)
	porHash[hk] = porHash[hk] or {}
	table.insert(porHash[hk], r)
	r.hk = hk
	esconderAntigo(quad)
	aplicar(r, false)
	table.insert(r.cons, quad:GetPropertyChangedSignal("Transparency"):Connect(function() aplicar(r, true) end))
	local c = quad:FindFirstChild("Cortada")
	if c then
		table.insert(r.cons, c:GetAttributeChangedSignal("AlturaOriginal"):Connect(function() aplicar(r, true) end))
		table.insert(r.cons, c:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
			if c.LocalTransparencyModifier < 1 then c.LocalTransparencyModifier = 1 end
		end))
	end
	table.insert(r.cons, quad:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
		if quad.LocalTransparencyModifier < 1 then quad.LocalTransparencyModifier = 1 end
	end))
	table.insert(r.cons, quad.AncestryChanged:Connect(function(_, pai)
		if pai then return end
		-- saiu do mundo (streaming ou reconstrução): limpa os tufos dele
		for _, cn in ipairs(r.cons) do cn:Disconnect() end
		for _, t in ipairs(r.tufos) do if t.part then t.part:Destroy() end end
		registros[quad] = nil
		local l = porHash[r.hk]
		if l then
			local i = table.find(l, r)
			if i then table.remove(l, i) end
		end
	end))
end

local function vigiarPasta(f: Instance)
	for _, q in ipairs(f:GetChildren()) do task.spawn(registrar, q) end
	f.ChildAdded:Connect(function(q) task.defer(registrar, q) end)
end

local function vigiarPlot(plot: Instance)
	local gv = plot:WaitForChild("GrassVisuals", 30)
	if gv then vigiarPasta(gv) end
end

task.spawn(function()
	local mundo = workspace:WaitForChild("GameWorld", 60)
	if not mundo then return end
	local plots = mundo:WaitForChild("Plots", 60)
	atualizarFiltro()
	if plots then
		for _, p in ipairs(plots:GetChildren()) do task.spawn(vigiarPlot, p) end
		plots.ChildAdded:Connect(function(p) atualizarFiltro() task.spawn(vigiarPlot, p) end)
	end
	local fazenda = mundo:WaitForChild("Fazenda", 60)
	local grama = fazenda and fazenda:WaitForChild("Grama", 60)
	if grama then vigiarPasta(grama) end
end)

-- grama perto da câmera fica translúcida (como na área de teste), checado 10x por segundo
local translucidos = {}
local acum = 0
RunService.RenderStepped:Connect(function(dt)
	acum += dt
	if acum < 0.1 then return end
	acum = 0
	local cam = workspace.CurrentCamera
	if not cam then return end
	local c = cam.CFrame.Position
	-- alvo = personagem (ou o foco da câmera): a grama no caminho câmera -> personagem fica translúcida
	local char = Players.LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local alvo = root and root.Position or cam.Focus.Position
	local seg = Vector3.new(alvo.X - c.X, 0, alvo.Z - c.Z)
	local comp = seg.Magnitude
	local dir = comp > 0.01 and seg / comp or Vector3.zero
	local agora = {}
	local vistos = {}
	local passos = math.clamp(math.ceil(comp / 3), 1, 12)
	for s = 0, passos do
		local q = c + dir * (comp * s / passos)
		local cx, cz = math.floor(q.X / 4), math.floor(q.Z / 4)
		for dx = -1, 1 do
			for dz = -1, 1 do
				local hk = (cx + dx) * 4096 + (cz + dz)
				local l = not vistos[hk] and porHash[hk]
				vistos[hk] = true
				if l then
					for _, r in ipairs(l) do
						for _, t in ipairs(r.tufos) do
							local p = t.part
							if p and c.Y < r.y + p.Size.Y + 2 then
								-- distância do tufo ao segmento câmera -> personagem (no plano)
								local v = Vector3.new(t.x - c.X, 0, t.z - c.Z)
								local proj = math.clamp(v:Dot(dir), 0, comp)
								local d = (v - dir * proj).Magnitude
								if d < CFG.FadeRaio or v.Magnitude < CFG.FadeRaio then
									agora[p] = true
									p.LocalTransparencyModifier = CFG.FadeValor
								end
							end
						end
					end
				end
			end
		end
	end
	for p in pairs(translucidos) do
		if not agora[p] and p.Parent then p.LocalTransparencyModifier = 0 end
	end
	translucidos = agora
end)
