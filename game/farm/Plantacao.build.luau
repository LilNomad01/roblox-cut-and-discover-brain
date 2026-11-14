--[[
	Fazenda: plantação atrás da cerca norte  [Claude 2026-11-13, MOD-02]
	Rodado UMA vez no Studio (Edit). Cria workspace.GameWorld.Fazenda.Plantacao, só decoração:
	tudo ancorado, sem colisão e sem consulta (não atrapalha o corte nem os raycasts).
	Área livre conferida: x -60..60, z 296..306, chão do Terrain em y 2,8.
	  * Milharal (x -55..-7): 3 leiras de terra, pés de milho com folhas caídas, espiga e pendão;
	    altura variando entre 3,4 e 4,6 (milho real ~2,5 m; no jogo o personagem tem ~5 studs).
	  * Abóboras (x 7..55): 3 leiras com ramas (folhas redondas), abóboras de tamanhos diferentes e talo.
	Semente fixa: o resultado é sempre o mesmo.
]]
local Fazenda = workspace.GameWorld.Fazenda
local velho = Fazenda:FindFirstChild("Plantacao")
if velho then velho:Destroy() end

local rng = Random.new(20261113)
local Y0 = 2.8
local TERRA = Color3.fromRGB(105, 74, 48)
local CAULE = Color3.fromRGB(96, 150, 62)
local FOLHA = Color3.fromRGB(78, 140, 55)

local raiz = Instance.new("Model")
raiz.Name = "Plantacao"

local function peca(pai, nome, tam, cf, cor, mat, forma)
	local p = Instance.new("Part")
	p.Name = nome
	p.Size = tam
	p.CFrame = cf
	p.Color = cor
	p.Material = mat or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if forma then p.Shape = forma end
	p.Parent = pai
	return p
end

local LEIRAS_Z = { 298, 300.5, 303 }

---------------------------------------------------------------- milharal
local milho = Instance.new("Model") milho.Name = "Milharal" milho.Parent = raiz
for _, z in ipairs(LEIRAS_Z) do
	peca(milho, "Leira", Vector3.new(50, 0.4, 1.3), CFrame.new(-31, Y0 + 0.15, z), TERRA, Enum.Material.Ground)
	for x = -55, -7, 2.5 do
		local px, pz = x + rng:NextNumber(-0.4, 0.4), z + rng:NextNumber(-0.2, 0.2)
		local h = rng:NextNumber(3.4, 4.6)
		local base = Y0 + 0.35
		local giro = rng:NextNumber(0, math.pi * 2)
		peca(milho, "Caule", Vector3.new(0.22, h, 0.22), CFrame.new(px, base + h / 2, pz) * CFrame.Angles(0, giro, 0), CAULE)
		-- duas folhas compridas caídas, em lados opostos
		for i, lado in ipairs({ 1, -1 }) do
			local altura = base + h * (i == 1 and 0.45 or 0.65)
			local cf = CFrame.new(px, altura, pz) * CFrame.Angles(0, giro + (lado > 0 and 0 or math.pi), 0)
				* CFrame.new(0, 0, -0.75) * CFrame.Angles(math.rad(-35), 0, 0)
			peca(milho, "Folha", Vector3.new(0.35, 0.05, 1.6), cf, FOLHA)
		end
		-- espiga presa no caule
		peca(milho, "Espiga", Vector3.new(0.32, 0.8, 0.32),
			CFrame.new(px, base + h * 0.55, pz) * CFrame.Angles(0, giro + math.pi / 2, 0) * CFrame.new(0, 0, -0.25) * CFrame.Angles(math.rad(-20), 0, 0),
			Color3.fromRGB(232, 205, 110))
		-- pendão no topo
		peca(milho, "Pendao", Vector3.new(0.12, 0.7, 0.12), CFrame.new(px, base + h + 0.3, pz) * CFrame.Angles(math.rad(rng:NextNumber(-12, 12)), giro, 0), Color3.fromRGB(210, 180, 110))
	end
end

---------------------------------------------------------------- abóboras
local abob = Instance.new("Model") abob.Name = "Aboboras" abob.Parent = raiz
for _, z in ipairs(LEIRAS_Z) do
	peca(abob, "Leira", Vector3.new(50, 0.4, 1.6), CFrame.new(31, Y0 + 0.15, z), TERRA, Enum.Material.Ground)
	local x = 7 + rng:NextNumber(0, 1.5)
	while x < 55 do
		local pz = z + rng:NextNumber(-0.3, 0.3)
		-- rama: 2 ou 3 folhas redondas deitadas
		for _ = 1, rng:NextInteger(2, 3) do
			local d = rng:NextNumber(1.1, 1.6)
			peca(abob, "FolhaRama", Vector3.new(0.08, d, d),
				CFrame.new(x + rng:NextNumber(-1, 1), Y0 + 0.4, pz + rng:NextNumber(-0.5, 0.5)) * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(rng:NextNumber(-0.25, 0.25), 0, 0),
				FOLHA, Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
		end
		if rng:NextNumber() < 0.8 then
			local d = rng:NextNumber(1.1, 1.9)
			local laranja = Color3.fromRGB(rng:NextInteger(220, 240), rng:NextInteger(105, 135), 30)
			peca(abob, "Abobora", Vector3.new(d, d, d), CFrame.new(x, Y0 + 0.35 + d * 0.42, pz), laranja, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
			peca(abob, "Talo", Vector3.new(0.16, 0.4, 0.16), CFrame.new(x, Y0 + 0.35 + d * 0.92, pz) * CFrame.Angles(0, 0, math.rad(rng:NextNumber(-20, 20))), Color3.fromRGB(70, 95, 40))
		end
		x += rng:NextNumber(2.8, 4)
	end
end

raiz.Parent = Fazenda
local n = 0
for _, d in ipairs(raiz:GetDescendants()) do if d:IsA("BasePart") then n += 1 end end
return "pecas=" .. n
