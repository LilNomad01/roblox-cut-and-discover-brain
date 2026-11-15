--[[
	Construtor da região Workspace.GameWorld.Fazenda  [Claude 2026-11-12]
	Rodado UMA vez no Studio (Edit, via MCP execute_luau); o modelo fica salvo no place. Este arquivo é a receita.
	  * Grama: 30 x 11 quadrados (clones do quadrado do lote, com a versão "Cortada"), tom de grama seca.
	  * Cerca de madeira em volta (alguns postes tortos), portão com placa e requisito.
	  * Celeiro vermelho, fardos de feno, trator velho, espantalho, poço e a caçamba (prompt "Vender grama").
	  * Estrada de terra do lobby até o portão, pintada no Terrain (segue o relevo).
]]
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Shared.FazendaConfig)
local GW = workspace.GameWorld
local antigo = GW:FindFirstChild("Fazenda") if antigo then antigo:Destroy() end
local F = Instance.new("Model") F.Name = "Fazenda"
local Y = Config.Centro.Y

local function peca(pai, nome, tam, cf, cor, mat, forma)
	local p = Instance.new("Part")
	p.Name = nome p.Size = tam p.CFrame = cf p.Color = cor p.Material = mat or Enum.Material.Wood
	p.Anchored = true p.TopSurface = Enum.SurfaceType.Smooth p.BottomSurface = Enum.SurfaceType.Smooth
	if forma then p.Shape = forma end
	p.Parent = pai
	return p
end
local MADEIRA = Color3.fromRGB(124, 84, 52)
local ESCURA = Color3.fromRGB(86, 58, 36)
local rng = Random.new(42)

---------------------------------------------------------------- grama
local grama = Instance.new("Folder") grama.Name = "Grama" grama.Parent = F
local molde = GW.Plots.Plot01.GrassVisuals:GetChildren()[1]
local x0 = Config.Centro.X - (Config.CamposX - 1) * Config.Tile / 2
local z0 = Config.Centro.Z - (Config.CamposZ - 1) * Config.Tile / 2
for i = 0, Config.CamposX - 1 do
	for k = 0, Config.CamposZ - 1 do
		local t = molde:Clone()
		t.Name = ("F_%02d_%02d"):format(i + 1, k + 1)
		for nome in pairs(t:GetAttributes()) do t:SetAttribute(nome, nil) end
		local pos = Vector3.new(x0 + i * Config.Tile, Y + t.Size.Y / 2, z0 + k * Config.Tile)
		t.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(rng:NextInteger(0, 3) * 90), 0)
		local tom = rng:NextNumber(-0.06, 0.06)
		t.Color = Color3.new(0.47 + tom, 0.56 + tom, 0.24)
		t.Transparency = 0
		local baixo = t:FindFirstChild("Cortada")
		if baixo then
			baixo.CFrame = CFrame.new(pos.X, Y + baixo.Size.Y / 2, pos.Z)
			baixo.Transparency = 1
		end
		t.Parent = grama
	end
end

---------------------------------------------------------------- cerca
local cerca = Instance.new("Model") cerca.Name = "Cerca" cerca.Parent = F
local xa, xb = x0 - 6, x0 + (Config.CamposX - 1) * Config.Tile + 6
local za, zb = z0 - 6, z0 + (Config.CamposZ - 1) * Config.Tile + 6
local function lado(a, b, fixoZ, fixo, portao)
	local n = math.floor((b - a) / 6)
	for s = 0, n do
		local v = a + s * (b - a) / n
		if not (portao and math.abs(v) < 7) then
			local pos = fixoZ and Vector3.new(v, Y + 2, fixo) or Vector3.new(fixo, Y + 2, v)
			local torto = rng:NextNumber() < 0.15 and math.rad(rng:NextNumber(-18, 18)) or 0
			peca(cerca, "Poste", Vector3.new(0.6, 4, 0.6), CFrame.new(pos) * CFrame.Angles(torto, 0, torto * 0.5), ESCURA)
			if s < n and not (portao and math.abs(v + (b - a) / n / 2) < 7) and rng:NextNumber() > 0.08 then
				local meio = fixoZ and Vector3.new(v + (b - a) / n / 2, Y + 2.6, fixo) or Vector3.new(fixo, Y + 2.6, v + (b - a) / n / 2)
				local comp = (b - a) / n
				local tam = fixoZ and Vector3.new(comp, 0.35, 0.25) or Vector3.new(0.25, 0.35, comp)
				peca(cerca, "Ripa", tam, CFrame.new(meio), MADEIRA)
				peca(cerca, "Ripa", tam, CFrame.new(meio - Vector3.new(0, 1.2, 0)), MADEIRA)
			end
		end
	end
end
lado(xa, xb, true, za, true)
lado(xa, xb, true, zb, false)
lado(za, zb, false, xa, false)
lado(za, zb, false, xb, false)
for _, p in ipairs(cerca:GetChildren()) do p.CanCollide = false end -- cerca é cenário: ninguém fica preso

---------------------------------------------------------------- portão
local portao = Instance.new("Model") portao.Name = "Portao" portao.Parent = F
for _, x in ipairs({ -7, 7 }) do peca(portao, "Pilar", Vector3.new(1.2, 10, 1.2), CFrame.new(x, Y + 5, za), ESCURA) end
local placa = peca(portao, "Placa", Vector3.new(14, 2.2, 0.4), CFrame.new(0, Y + 9, za - 0.2), Color3.fromRGB(255, 214, 120), Enum.Material.WoodPlanks)
local function texto(parte, face, t, cor)
	local sg = Instance.new("SurfaceGui") sg.Face = face sg.CanvasSize = Vector2.new(700, 110) sg.LightInfluence = 1 sg.Parent = parte
	local l = Instance.new("TextLabel") l.BackgroundTransparency = 1 l.Size = UDim2.fromScale(1, 1) l.Font = Enum.Font.FredokaOne l.TextScaled = true
	l.TextColor3 = cor or Color3.fromRGB(52, 44, 38) l.Text = t l.Parent = sg
end
texto(placa, Enum.NormalId.Front, "🌾 FAZENDA ABANDONADA")
texto(placa, Enum.NormalId.Back, "🌾 FAZENDA ABANDONADA")
local req = peca(portao, "Requisito", Vector3.new(6, 1.6, 0.3), CFrame.new(-11, Y + 3, za - 1) * CFrame.Angles(0, 0, math.rad(-4)), Color3.fromRGB(240, 230, 200), Enum.Material.WoodPlanks)
peca(portao, "PostePlaca", Vector3.new(0.4, 3, 0.4), CFrame.new(-11, Y + 1.5, za - 0.8), ESCURA)
texto(req, Enum.NormalId.Front, ("🔒 Nível %d ou ⭐ Fama %d"):format(Config.NivelMinimo, Config.FamaMinima))
texto(req, Enum.NormalId.Back, ("🔒 Nível %d ou ⭐ Fama %d"):format(Config.NivelMinimo, Config.FamaMinima))

---------------------------------------------------------------- celeiro
local celeiro = Instance.new("Model") celeiro.Name = "Celeiro" celeiro.Parent = F
local cb = CFrame.new(92, Y, 274) * CFrame.Angles(0, math.rad(-90), 0)
local VERMELHO = Color3.fromRGB(150, 48, 40)
peca(celeiro, "Parede", Vector3.new(22, 12, 1), cb * CFrame.new(0, 6, 9), VERMELHO, Enum.Material.WoodPlanks)
peca(celeiro, "Parede", Vector3.new(22, 12, 1), cb * CFrame.new(0, 6, -9), VERMELHO, Enum.Material.WoodPlanks)
peca(celeiro, "Parede", Vector3.new(1, 12, 18), cb * CFrame.new(11, 6, 0), VERMELHO, Enum.Material.WoodPlanks)
peca(celeiro, "ParedeFrente", Vector3.new(1, 12, 5), cb * CFrame.new(-11, 6, 6.5), VERMELHO, Enum.Material.WoodPlanks)
peca(celeiro, "ParedeFrente", Vector3.new(1, 12, 5), cb * CFrame.new(-11, 6, -6.5), VERMELHO, Enum.Material.WoodPlanks)
peca(celeiro, "Porta", Vector3.new(0.5, 9, 4), cb * CFrame.new(-11.6, 4.5, 2.2) * CFrame.Angles(0, math.rad(35), 0), Color3.fromRGB(110, 40, 34), Enum.Material.WoodPlanks)
peca(celeiro, "FrisoBranco", Vector3.new(1.2, 0.6, 18), cb * CFrame.new(-11.2, 9.5, 0), Color3.fromRGB(235, 230, 220), Enum.Material.WoodPlanks)
local telhado = Color3.fromRGB(70, 66, 64)
peca(celeiro, "Telhado", Vector3.new(24, 0.8, 11), cb * CFrame.new(0, 14.5, 4.6) * CFrame.Angles(math.rad(32), 0, 0), telhado, Enum.Material.CorrodedMetal)
peca(celeiro, "Telhado", Vector3.new(24, 0.8, 11), cb * CFrame.new(0, 14.5, -4.6) * CFrame.Angles(math.rad(-32), 0, 0), telhado, Enum.Material.CorrodedMetal)
local cume = Instance.new("WedgePart") cume.Name = "Oitao" cume.Anchored = true cume.Size = Vector3.new(1, 5, 9) cume.Color = VERMELHO cume.Material = Enum.Material.WoodPlanks
cume.CFrame = cb * CFrame.new(-11, 14.5, 4.5) cume.Parent = celeiro
local cume2 = cume:Clone() cume2.CFrame = cb * CFrame.new(-11, 14.5, -4.5) * CFrame.Angles(0, math.rad(180), 0) cume2.Parent = celeiro

---------------------------------------------------------------- fardos, trator, espantalho, poço
local feno = Color3.fromRGB(214, 180, 90)
for i, pos in ipairs({ Vector3.new(76, Y, 262), Vector3.new(79, Y, 263), Vector3.new(77.5, Y + 2.4, 262.5), Vector3.new(80, Y, 290), Vector3.new(-84, Y, 254) }) do
	local f = peca(F, "Feno", Vector3.new(4, 2.4, 2.4), CFrame.new(pos + Vector3.new(0, 1.2, 0)) * CFrame.Angles(0, math.rad(rng:NextInteger(0, 90)), math.rad(90)), feno, Enum.Material.Grass, Enum.PartType.Cylinder)
	f.Size = Vector3.new(3, 3.4, 3.4)
end
local trator = Instance.new("Model") trator.Name = "TratorVelho" trator.Parent = F
local tb = CFrame.new(-84, Y, 284) * CFrame.Angles(0, math.rad(20), 0)
local FERRUGEM = Color3.fromRGB(140, 76, 44)
peca(trator, "Corpo", Vector3.new(4, 2.4, 7), tb * CFrame.new(0, 2.6, 0), FERRUGEM, Enum.Material.CorrodedMetal)
peca(trator, "Cabine", Vector3.new(3.4, 3, 3), tb * CFrame.new(0, 5.2, 1.4), FERRUGEM, Enum.Material.CorrodedMetal)
peca(trator, "Chamine", Vector3.new(0.5, 2.4, 0.5), tb * CFrame.new(0.9, 5, -2.2), Color3.fromRGB(50, 46, 44), Enum.Material.Metal)
for _, w in ipairs({ { -2.4, 2.2, 2.4, 4.4 }, { 2.4, 2.2, 2.4, 4.4 }, { -2.2, 1.3, -2.4, 2.6 }, { 2.2, 1.3, -2.4, 2.6 } }) do
	peca(trator, "Roda", Vector3.new(1, w[4], w[4]), tb * CFrame.new(w[1], w[2], w[3]), Color3.fromRGB(40, 38, 36), Enum.Material.Rubber, Enum.PartType.Cylinder)
end
local esp = Instance.new("Model") esp.Name = "Espantalho" esp.Parent = F
local eb = CFrame.new(-36, Y, 268)
peca(esp, "Haste", Vector3.new(0.5, 7, 0.5), eb * CFrame.new(0, 3.5, 0), ESCURA)
peca(esp, "Bracos", Vector3.new(5, 0.4, 0.4), eb * CFrame.new(0, 5.4, 0), ESCURA)
peca(esp, "Camisa", Vector3.new(2.2, 2.4, 1), eb * CFrame.new(0, 4.8, 0), Color3.fromRGB(70, 110, 170), Enum.Material.Fabric)
peca(esp, "Cabeca", Vector3.new(1.6, 1.6, 1.6), eb * CFrame.new(0, 6.9, 0), feno, Enum.Material.Fabric, Enum.PartType.Ball)
peca(esp, "Chapeu", Vector3.new(0.5, 2.6, 2.6), eb * CFrame.new(0, 7.7, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(150, 110, 60), Enum.Material.Fabric, Enum.PartType.Cylinder)
for _, p in ipairs(esp:GetChildren()) do p.CanCollide = false end
local poco = Instance.new("Model") poco.Name = "Poco" poco.Parent = F
local pb = CFrame.new(-86, Y, 268)
peca(poco, "Borda", Vector3.new(2.4, 4.6, 4.6), pb * CFrame.new(0, 1.2, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(130, 126, 120), Enum.Material.Cobblestone, Enum.PartType.Cylinder)
for _, x in ipairs({ -2, 2 }) do peca(poco, "Pilar", Vector3.new(0.4, 4, 0.4), pb * CFrame.new(x, 4, 0), ESCURA) end
peca(poco, "Teto", Vector3.new(5, 0.4, 3), pb * CFrame.new(0, 6.2, 0), Color3.fromRGB(110, 60, 40), Enum.Material.WoodPlanks)

---------------------------------------------------------------- caçamba da fazenda
local cac = Instance.new("Model") cac.Name = "Cacamba" cac.Parent = F
local cc = CFrame.new(76, Y, 250) * CFrame.Angles(0, math.rad(-90), 0)
local corpo = peca(cac, "Corpo", Vector3.new(6, 3, 4), cc * CFrame.new(0, 1.5, 0), Color3.fromRGB(230, 180, 40), Enum.Material.Metal)
peca(cac, "Grama", Vector3.new(5.4, 0.4, 3.4), cc * CFrame.new(0, 3, 0), Color3.fromRGB(110, 150, 60), Enum.Material.Grass)
local at = Instance.new("Attachment") at.Name = "Prompt" at.Position = Vector3.new(0, 1.6, 0) at.Parent = corpo
local pr = Instance.new("ProximityPrompt") pr.ActionText = "Vender grama" pr.ObjectText = "Caçamba da fazenda"
pr.KeyboardKeyCode = Enum.KeyCode.E pr.GamepadKeyCode = Enum.KeyCode.ButtonX pr.HoldDuration = 0.2 pr.MaxActivationDistance = 10 pr.RequiresLineOfSight = false pr.Parent = at
local vend = peca(cac, "Placa", Vector3.new(5, 1.2, 0.2), cc * CFrame.new(0, 4.6, -2.1), Color3.fromRGB(255, 214, 120), Enum.Material.WoodPlanks)
texto(vend, Enum.NormalId.Front, "💰 VENDER")
texto(vend, Enum.NormalId.Back, "💰 VENDER")

F.ModelStreamingMode = Enum.ModelStreamingMode.Default
F:SetAttribute("Autor", "Claude 2026-11-12 regiao Fazenda")
F.Parent = GW

---------------------------------------------------------------- estrada de terra (pinta o Terrain)
local T = workspace.Terrain
local trechos = { { Vector3.new(18, 0, 86), Vector3.new(18, 0, 140) }, { Vector3.new(18, 0, 140), Vector3.new(0, 0, 168) }, { Vector3.new(0, 0, 168), Vector3.new(0, 0, za - 2) } }
for _, tr in ipairs(trechos) do
	local a, b = tr[1], tr[2]
	local passos = math.ceil((b - a).Magnitude / 4)
	for s = 0, passos do
		local p = a:Lerp(b, s / passos)
		local reg = Region3.new(Vector3.new(p.X - 5, -10, p.Z - 5), Vector3.new(p.X + 5, 40, p.Z + 5)):ExpandToGrid(4)
		for _, m in ipairs({ Enum.Material.Grass, Enum.Material.LeafyGrass }) do T:ReplaceMaterial(reg, 4, m, Enum.Material.Ground) end
	end
end
