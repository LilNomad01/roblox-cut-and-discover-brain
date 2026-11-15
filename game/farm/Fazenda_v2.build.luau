--[[
	Fazenda — revisão de modelagem com as referências do brain 21  [Claude 2026-11-12]
	Rodado UMA vez no Studio (Edit) DEPOIS de Fazenda.build.luau. Troca/ajusta peças do cenário:
	  * Celeiro: telhado GAMBREL (duas águas quebradas: parte baixa íngreme, alta suave), acabamento BRANCO nas
	    quinas e beirais, portas duplas com "X" branco, porta do palheiro no frontão, cata-vento no cume
	  * Fardos redondos: medida real 4x5 pés (4,4 x 5,4 studs) x 0,8 = 3,6 de largura x 4,4 de diâmetro,
	    deitados (eixo na horizontal, como ficam no campo)
	  * Poço: telhado de duas águas, sarilho com manivela, corda e balde
	  * Cerca: 3 ripas por vão (cerca rural de 3 trilhos)
	  * Caçamba: laterais INCLINADAS (topo maior que o fundo, como a caçamba de entulho real)
]]
local F = workspace.GameWorld.Fazenda
local Y = 2.8
local function peca(pai, nome, tam, cf, cor, mat, forma, classe)
	local p = Instance.new(classe or "Part")
	p.Name = nome p.Size = tam p.CFrame = cf p.Color = cor p.Material = mat or Enum.Material.Wood
	p.Anchored = true p.TopSurface = Enum.SurfaceType.Smooth p.BottomSurface = Enum.SurfaceType.Smooth
	if forma then p.Shape = forma end
	p.Parent = pai
	return p
end
local BRANCO = Color3.fromRGB(240, 236, 226)
local VERMELHO = Color3.fromRGB(158, 46, 38)
local TELHA = Color3.fromRGB(64, 62, 66)
local ESCURA = Color3.fromRGB(86, 58, 36)
local MADEIRA = Color3.fromRGB(124, 84, 52)

---------------------------------------------------------------- celeiro gambrel
local antigo = F:FindFirstChild("Celeiro") if antigo then antigo:Destroy() end
local cel = Instance.new("Model") cel.Name = "Celeiro" cel.Parent = F
-- base: frente (portas) virada para o campo (-X); comprimento ao longo de Z
local cb = CFrame.lookAt(Vector3.new(94, Y, 274), Vector3.new(0, Y, 274))
local L, C, H = 18, 22, 10 -- largura (frente), comprimento (fundo), altura da parede
local function parede(nome, tam, off) return peca(cel, nome, tam, cb * off, VERMELHO, Enum.Material.WoodPlanks) end
parede("Lateral", Vector3.new(0.8, H, C), CFrame.new(-L / 2, H / 2, C / 2))
parede("Lateral", Vector3.new(0.8, H, C), CFrame.new(L / 2, H / 2, C / 2))
parede("Fundo", Vector3.new(L, H, 0.8), CFrame.new(0, H / 2, C))
parede("FrenteE", Vector3.new(5, H, 0.8), CFrame.new(-6.5, H / 2, 0))
parede("FrenteD", Vector3.new(5, H, 0.8), CFrame.new(6.5, H / 2, 0))
parede("FrenteTopo", Vector3.new(8, 2, 0.8), CFrame.new(0, H - 1, 0))
-- portas duplas abertas com X branco
for _, lado in ipairs({ -1, 1 }) do
	local pcf = cb * CFrame.new(lado * 4, 0, 0) * CFrame.Angles(0, math.rad(lado * 55), 0) * CFrame.new(-lado * 2, 4, -0.2)
	local porta = peca(cel, "Porta", Vector3.new(4, 8, 0.35), pcf, VERMELHO, Enum.Material.WoodPlanks)
	peca(cel, "PortaMoldura", Vector3.new(4.1, 0.35, 0.4), pcf * CFrame.new(0, 3.85, -0.05), BRANCO, Enum.Material.WoodPlanks)
	peca(cel, "PortaMoldura", Vector3.new(4.1, 0.35, 0.4), pcf * CFrame.new(0, -3.85, -0.05), BRANCO, Enum.Material.WoodPlanks)
	peca(cel, "PortaMoldura", Vector3.new(0.35, 8, 0.4), pcf * CFrame.new(1.9, 0, -0.05), BRANCO, Enum.Material.WoodPlanks)
	peca(cel, "PortaMoldura", Vector3.new(0.35, 8, 0.4), pcf * CFrame.new(-1.9, 0, -0.05), BRANCO, Enum.Material.WoodPlanks)
	local diag = math.sqrt(3.4 ^ 2 + 7.4 ^ 2)
	local ang = math.atan2(7.4, 3.4)
	peca(cel, "PortaX", Vector3.new(diag, 0.35, 0.4), pcf * CFrame.new(0, 0, -0.05) * CFrame.Angles(0, 0, ang), BRANCO, Enum.Material.WoodPlanks)
	peca(cel, "PortaX", Vector3.new(diag, 0.35, 0.4), pcf * CFrame.new(0, 0, -0.05) * CFrame.Angles(0, 0, -ang), BRANCO, Enum.Material.WoodPlanks)
	porta.CanCollide = false
end
-- quinas brancas
for _, x in ipairs({ -L / 2, L / 2 }) do for _, z in ipairs({ 0, C }) do
	peca(cel, "Quina", Vector3.new(1, H, 1), cb * CFrame.new(x, H / 2, z), BRANCO, Enum.Material.WoodPlanks)
end end
-- telhado gambrel: parte baixa (60 graus) e alta (25 graus), dos dois lados, ao longo do comprimento
local baixoLen, baixoAng = 5.2, math.rad(60)
local altoLen, altoAng = 6.4, math.rad(25)
for _, lado in ipairs({ -1, 1 }) do
	local x1 = lado * L / 2
	local yb = H + math.sin(baixoAng) * baixoLen / 2
	local xb = x1 - lado * math.cos(baixoAng) * baixoLen / 2
	peca(cel, "TelhadoBaixo", Vector3.new(baixoLen, 0.6, C + 1.6), cb * CFrame.new(xb, yb, C / 2) * CFrame.Angles(0, 0, -lado * baixoAng), TELHA, Enum.Material.CorrodedMetal)
	local xq = x1 - lado * math.cos(baixoAng) * baixoLen
	local yq = H + math.sin(baixoAng) * baixoLen
	local xa = xq - lado * math.cos(altoAng) * altoLen / 2
	local ya = yq + math.sin(altoAng) * altoLen / 2
	peca(cel, "TelhadoAlto", Vector3.new(altoLen, 0.6, C + 1.6), cb * CFrame.new(xa, ya, C / 2) * CFrame.Angles(0, 0, -lado * altoAng), TELHA, Enum.Material.CorrodedMetal)
end
-- frontões (frente e fundo) preenchendo o gambrel com cunhas
local yq = H + math.sin(baixoAng) * baixoLen
local wq = L - 2 * math.cos(baixoAng) * baixoLen
local yTopo = yq + math.sin(altoAng) * (wq / 2) / math.cos(altoAng)
for _, z in ipairs({ 0, C }) do
	peca(cel, "Fronton", Vector3.new(wq, yq - H, 0.8), cb * CFrame.new(0, (H + yq) / 2, z), VERMELHO, Enum.Material.WoodPlanks)
	for _, lado in ipairs({ -1, 1 }) do
		local w = Instance.new("WedgePart") w.Name = "FrontonCunha" w.Anchored = true w.Material = Enum.Material.WoodPlanks w.Color = VERMELHO
		w.Size = Vector3.new(0.8, yTopo - yq, wq / 2)
		w.CFrame = cb * CFrame.new(lado * wq / 4, (yq + yTopo) / 2, z) * CFrame.Angles(0, math.rad(-lado * 90), 0) -- lado alto no meio
		w.Parent = cel
	end
	-- cunhas da parte baixa
	for _, lado in ipairs({ -1, 1 }) do
		local w = Instance.new("WedgePart") w.Name = "FrontonCunhaBaixa" w.Anchored = true w.Material = Enum.Material.WoodPlanks w.Color = VERMELHO
		local larg = (L - wq) / 2
		w.Size = Vector3.new(0.8, yq - H, larg)
		w.CFrame = cb * CFrame.new(lado * (wq / 2 + larg / 2), (H + yq) / 2, z) * CFrame.Angles(0, math.rad(-lado * 90), 0)
		w.Parent = cel
	end
end
-- porta do palheiro no frontão da frente, com moldura branca e X
local pal = peca(cel, "PortaPalheiro", Vector3.new(3.4, 3.4, 0.3), cb * CFrame.new(0, yq + 0.6, -0.5), VERMELHO, Enum.Material.WoodPlanks)
peca(cel, "PalheiroMoldura", Vector3.new(4, 0.35, 0.35), pal.CFrame * CFrame.new(0, 1.85, -0.1), BRANCO, Enum.Material.WoodPlanks)
peca(cel, "PalheiroMoldura", Vector3.new(4, 0.35, 0.35), pal.CFrame * CFrame.new(0, -1.85, -0.1), BRANCO, Enum.Material.WoodPlanks)
peca(cel, "PalheiroX", Vector3.new(4.6, 0.3, 0.35), pal.CFrame * CFrame.new(0, 0, -0.1) * CFrame.Angles(0, 0, math.rad(45)), BRANCO, Enum.Material.WoodPlanks)
peca(cel, "PalheiroX", Vector3.new(4.6, 0.3, 0.35), pal.CFrame * CFrame.new(0, 0, -0.1) * CFrame.Angles(0, 0, math.rad(-45)), BRANCO, Enum.Material.WoodPlanks)
-- feno saindo do palheiro e cata-vento
peca(cel, "FenoPalheiro", Vector3.new(2.6, 0.8, 1.2), pal.CFrame * CFrame.new(0, -1.3, -0.5), Color3.fromRGB(214, 180, 90), Enum.Material.Grass)
peca(cel, "Haste", Vector3.new(0.2, 3, 0.2), cb * CFrame.new(0, yTopo + 1.5, C / 2), Color3.fromRGB(60, 60, 64), Enum.Material.Metal)
peca(cel, "Galo", Vector3.new(1.4, 0.9, 0.15), cb * CFrame.new(0, yTopo + 3.2, C / 2), Color3.fromRGB(60, 60, 64), Enum.Material.Metal)

---------------------------------------------------------------- fardos redondos (medida real x 0,8, deitados)
for _, f in ipairs(F:GetChildren()) do
	if f.Name == "Feno" and f:IsA("BasePart") then
		local pos = f.Position
		f.Size = Vector3.new(3.6, 4.4, 4.4)
		f.CFrame = CFrame.new(pos.X, Y + 2.2, pos.Z) * CFrame.Angles(0, math.rad((pos.X * 7 + pos.Z * 3) % 90), 0) -- eixo do cilindro (X) na horizontal
		f.Color = Color3.fromRGB(206, 172, 86)
	end
end
-- a pilha de dois fardos virou fardo no chão (o de cima caía para fora)
for _, f in ipairs(F:GetChildren()) do
	if f.Name == "Feno" and f:IsA("BasePart") and f.Position.Y > Y + 3 then f.CFrame = CFrame.new(82, Y + 2.2, 258) end
end

---------------------------------------------------------------- poço com telhado e sarilho
local poco = F:FindFirstChild("Poco")
if poco then
	for _, c in ipairs(poco:GetChildren()) do if c.Name == "Teto" then c:Destroy() end end
	local pb = CFrame.new(-86, Y, 268)
	for _, lado in ipairs({ -1, 1 }) do
		peca(poco, "Telhado", Vector3.new(5.6, 0.3, 2.2), pb * CFrame.new(0, 6.6, lado * 0.9) * CFrame.Angles(math.rad(lado * 35), 0, 0), Color3.fromRGB(120, 60, 40), Enum.Material.WoodPlanks)
	end
	peca(poco, "Sarilho", Vector3.new(4.4, 0.5, 0.5), pb * CFrame.new(0, 4.6, 0), MADEIRA, Enum.Material.Wood, Enum.PartType.Cylinder)
	peca(poco, "Manivela", Vector3.new(0.2, 1.1, 0.2), pb * CFrame.new(2.4, 4.3, 0), Color3.fromRGB(70, 70, 74), Enum.Material.Metal)
	peca(poco, "Pega", Vector3.new(0.6, 0.2, 0.2), pb * CFrame.new(2.6, 3.8, 0), MADEIRA)
	peca(poco, "Corda", Vector3.new(0.1, 1.6, 0.1), pb * CFrame.new(0, 3.6, 0), Color3.fromRGB(190, 170, 120), Enum.Material.Fabric)
	peca(poco, "Balde", Vector3.new(0.8, 0.8, 0.8), pb * CFrame.new(0, 2.6, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(150, 150, 156), Enum.Material.Metal, Enum.PartType.Cylinder)
end

---------------------------------------------------------------- cerca: 3 ripas
local cerca = F:FindFirstChild("Cerca")
if cerca then
	local novas = {}
	for _, r in ipairs(cerca:GetChildren()) do
		if r.Name == "Ripa" and math.abs(r.Position.Y - (Y + 2.6)) < 0.05 then
			local n = r:Clone() n.CFrame = r.CFrame + Vector3.new(0, 0.95, 0) table.insert(novas, n)
		end
	end
	for _, n in ipairs(novas) do n.Parent = cerca end
end

---------------------------------------------------------------- caçamba com laterais inclinadas
local cac = F:FindFirstChild("Cacamba")
if cac then
	local corpo = cac:FindFirstChild("Corpo")
	local cc = CFrame.new(76, Y, 250) * CFrame.Angles(0, math.rad(-90), 0)
	local AMARELO = Color3.fromRGB(232, 182, 38)
	-- o "Corpo" vira o fundo (mantém o prompt de venda)
	corpo.Size = Vector3.new(4.8, 0.6, 3.6)
	corpo.CFrame = cc * CFrame.new(0, 0.3, 0)
	for _, lado in ipairs({ -1, 1 }) do
		-- pontas inclinadas (topo 7,2 x fundo 4,8: inclinação de 1,2 por lado em 2,8 de altura)
		local ang = math.atan2(1.2, 2.8)
		peca(cac, "Ponta", Vector3.new(0.3, 3.05, 3.6), cc * CFrame.new(lado * 3.0, 1.75, 0) * CFrame.Angles(0, 0, -lado * ang), AMARELO, Enum.Material.Metal)
		peca(cac, "Lado", Vector3.new(6.2, 2.8, 0.3), cc * CFrame.new(0, 1.7, lado * 1.8), AMARELO, Enum.Material.Metal)
		peca(cac, "Gancho", Vector3.new(0.3, 0.8, 0.8), cc * CFrame.new(lado * 2.2, 2.4, lado * 2.0), Color3.fromRGB(70, 70, 74), Enum.Material.Metal, Enum.PartType.Cylinder)
	end
	peca(cac, "Faixa", Vector3.new(6.3, 0.35, 3.75), cc * CFrame.new(0, 2.9, 0), Color3.fromRGB(50, 50, 54), Enum.Material.Metal)
	local g = cac:FindFirstChild("Grama")
	if g then g.Size = Vector3.new(6, 0.6, 3.3) g.CFrame = cc * CFrame.new(0, 2.6, 0) end
	local placa = cac:FindFirstChild("Placa")
	if placa then placa.CFrame = cc * CFrame.new(0, 4.6, -2.1) end
end
