--[[
	ServerScriptService.CorteEDescubra.CabanaDetalhes  [Claude 2026-11-11]
	Decora a Cabana Esquecida (CabanaDoGuardiao, montada pelo GameServer.forestCabin + ForestScenery):
	  * por fora: janelas com luz âmbar, porta entreaberta, telhadinho da varanda com lanterna pendurada
	    (substitui o cubo amarelo que flutuava), fumaça na chaminé, trepadeiras, musgo, flores nas floreiras,
	    lenha empilhada, cerca velha e caminho de pedras até a varanda;
	  * por dentro: lareira acesa, mesa com vela e livro, cadeira, estante, cama de palha, tapete, barris,
	    caixotes e mapa na parede.
	Só decoração: nenhuma recompensa, prompt ou mecânica nova. Sem IDs de asset (Fire/Smoke/luzes nativas).
	Chamado uma vez depois de Art.polish, quando a cabana já está completa.
]]
local D = {}

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local WOOD = rgb(112, 84, 56)
local DARK = rgb(66, 50, 36)
local STONE = rgb(122, 120, 112)
local WARM = rgb(255, 196, 112)

local function part(parent, name, size, cf, color, material, collide, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.Wood
	if shape then p.Shape = shape end
	p.Anchored = true
	p.CanCollide = collide == true
	p.CanTouch = false
	p.CanQuery = false
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local CYL, BALL = Enum.PartType.Cylinder, Enum.PartType.Ball
local VERTICAL = CFrame.Angles(0, 0, math.pi / 2) -- eixo do cilindro na vertical

local function luz(p, color, brightness, range, shadows)
	local l = Instance.new("PointLight")
	l.Color, l.Brightness, l.Range, l.Shadows = color, brightness, range, shadows == true
	l.Parent = p
	return l
end

-- altura do terreno (ignora a própria cabana e a grama)
local function chao(x, z, ignore, fallback)
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	rp.FilterDescendantsInstances = ignore
	local hit = workspace:Raycast(Vector3.new(x, 80, z), Vector3.new(0, -160, 0), rp)
	return hit and hit.Position.Y or fallback
end

function D.decorate(root)
	local cabin = root and root:FindFirstChild("CabanaDoGuardiao", true)
	if not cabin or cabin:GetAttribute("CabanaDecorada") then return end
	local base = cabin:FindFirstChild("Fundacao")
	if not base then return end
	cabin:SetAttribute("CabanaDecorada", true)
	local x, z = base.Position.X, base.Position.Z -- centro (-108, -346)
	local g = base.Position.Y - 1 -- forestGroundY
	-- o terreno da floresta fica um pouco acima da fundação: tira o terreno de dentro da cabana
	-- e assenta o piso de tábuas por cima, senão a grama do terreno aparece no chão do cômodo
	local soloRp = RaycastParams.new()
	soloRp.FilterType = Enum.RaycastFilterType.Include
	soloRp.FilterDescendantsInstances = { workspace.Terrain }
	local soloHit = workspace:Raycast(Vector3.new(base.Position.X, 60, base.Position.Z), Vector3.new(0, -120, 0), soloRp)
	local baseTopo = base.Position.Y + base.Size.Y / 2
	pcall(function()
		workspace.Terrain:FillBlock(CFrame.new(base.Position.X, baseTopo + 2.5, base.Position.Z), Vector3.new(19.5, 5, 15.5), Enum.Material.Air)
	end)
	local piso = math.max(baseTopo, soloHit and soloHit.Position.Y or baseTopo) + .25
	local deco = Instance.new("Model")
	deco.Name = "DetalhesDaCabana"
	deco.Parent = cabin
	local ignorar = { cabin, root:FindFirstChild("MatagalCortavel") }

	---------------------------------------------------------------- por fora
	-- janelas acesas (âmbar) em vez de vidro liso
	for _, j in ipairs(cabin:GetChildren()) do
		if j.Name == "Janela" and j:IsA("BasePart") then
			j.Color = WARM
			j.Material = Enum.Material.Neon
			j.Transparency = .35
		end
	end
	-- porta entreaberta (dobradiça na borda esquerda do vão)
	local porta = cabin:FindFirstChild("Porta")
	if porta then
		local hinge = porta.CFrame * CFrame.new(-porta.Size.X / 2, 0, 0)
		porta.CFrame = hinge * CFrame.Angles(0, math.rad(-62), 0) * CFrame.new(porta.Size.X / 2, 0, 0)
		part(deco, "Macaneta", Vector3.new(.25, .25, .25), porta.CFrame * CFrame.new(porta.Size.X / 2 - .5, 0, .25), rgb(196, 160, 82), Enum.Material.Metal, false, BALL)
	end
	-- telhadinho da varanda apoiado nos pilares (ForestScenery colocou os pilares em z=-330)
	local frente = z + 9 -- fachada
	local beiral = z + 16.3
	local tl = part(deco, "TelhadoVaranda", Vector3.new(23.5, .45, beiral - frente + 1),
		CFrame.new(x, g + 9.55, (frente + beiral) / 2) * CFrame.Angles(math.rad(9), 0, 0), rgb(125, 72, 50), Enum.Material.Wood, false)
	for i = 0, 7 do
		part(deco, "TelhaVaranda", Vector3.new(23.6, .14, 1.05), tl.CFrame * CFrame.new(0, .28, -tl.Size.Z / 2 + .55 + i * 1.0),
			rgb(70 + i * 3, 84 + i * 2, 66), Enum.Material.Slate, false)
	end
	part(deco, "VigaVaranda", Vector3.new(23.5, .5, .5), CFrame.new(x, g + 8.85, beiral - .4), DARK, Enum.Material.Wood, false)
	-- lanterna pendurada (o cubo antigo some; a luz passa para a lanterna)
	local velha = cabin:FindFirstChild("LanternaAntiga")
	local lx, lz = -114.5, beiral - .4
	if velha then
		velha.Transparency = 1
		for _, l in ipairs(velha:GetChildren()) do if l:IsA("Light") then l:Destroy() end end
	end
	part(deco, "CorrenteLanterna", Vector3.new(.08, 1.1, .08), CFrame.new(lx, g + 8.05, lz), rgb(60, 60, 62), Enum.Material.Metal, false)
	part(deco, "TampaLanterna", Vector3.new(.95, .3, .95), CFrame.new(lx, g + 7.4, lz), rgb(48, 46, 44), Enum.Material.Metal, false)
	part(deco, "FundoLanterna", Vector3.new(.85, .18, .85), CFrame.new(lx, g + 6.15, lz), rgb(48, 46, 44), Enum.Material.Metal, false)
	for _, o in ipairs({ { -.4, -.4 }, { .4, -.4 }, { -.4, .4 }, { .4, .4 } }) do
		part(deco, "HasteLanterna", Vector3.new(.09, 1.15, .09), CFrame.new(lx + o[1], g + 6.78, lz + o[2]), rgb(48, 46, 44), Enum.Material.Metal, false)
	end
	local vidro = part(deco, "LuzLanterna", Vector3.new(.6, .95, .6), CFrame.new(lx, g + 6.78, lz), WARM, Enum.Material.Neon, false)
	vidro.Transparency = .1
	luz(vidro, WARM, 1.3, 16, true)
	-- fumaça na chaminé
	local chamine = cabin:FindFirstChild("Chamine")
	if chamine then
		local topo = part(deco, "BocaChamine", Vector3.new(2.2, .4, 2.2), chamine.CFrame * CFrame.new(0, chamine.Size.Y / 2 + .2, 0), rgb(40, 38, 36), Enum.Material.Slate, false)
		local s = Instance.new("Smoke")
		s.Color, s.Opacity, s.RiseVelocity, s.Size, s.TimeScale = rgb(205, 205, 200), .12, 3.5, 1.6, .6
		s.Parent = topo
	end
	-- trepadeiras nos cantos da fachada e sobre a porta
	local rng = Random.new(3461)
	local verdes = { rgb(68, 130, 62), rgb(88, 150, 70), rgb(56, 112, 58), rgb(104, 160, 78) }
	local function trepadeira(px, pz, y0, y1, amplitude)
		local y = y0
		while y < y1 do
			local dx = math.sin(y * 1.7) * amplitude
			local s = rng:NextNumber(.45, .8)
			part(deco, "Trepadeira", Vector3.new(s, s, s * .6), CFrame.new(px + dx, y, pz), verdes[rng:NextInteger(1, #verdes)], Enum.Material.Grass, false, BALL)
			y += rng:NextNumber(.35, .55)
		end
	end
	trepadeira(x - 10.4, frente + .35, g + 1.6, g + 9.4, .35)
	trepadeira(x + 10.4, frente + .35, g + 1.6, g + 7.2, .3)
	for i = 0, 10 do -- cortina de folhas no alto da porta
		local s = rng:NextNumber(.45, .75)
		part(deco, "Trepadeira", Vector3.new(s, s, s * .6), CFrame.new(x - 5.4 + i * .5, g + 8.7 - math.abs(math.sin(i)) * .5, frente + .35), verdes[rng:NextInteger(1, #verdes)], Enum.Material.Grass, false, BALL)
	end
	-- musgo no telhado
	for _, t in ipairs(cabin:GetChildren()) do
		if t.Name == "TelhaMusgosa" and rng:NextNumber() < .22 then
			local m = part(deco, "Musgo", Vector3.new(1.4, .5, 1.4), t.CFrame * CFrame.new(rng:NextNumber(-.5, .5), .18, rng:NextNumber(-.6, .6)), verdes[rng:NextInteger(1, #verdes)], Enum.Material.Grass, false, BALL)
			m.CastShadow = false
		end
	end
	-- flores nas floreiras
	local cores = { rgb(255, 150, 190), rgb(255, 221, 94), rgb(191, 147, 228), rgb(255, 255, 240) }
	for _, f in ipairs(cabin:GetChildren()) do
		if f.Name == "Floreira" and f:IsA("BasePart") then
			for i = 1, 7 do
				local fx = f.Position.X - 1.6 + (i - 1) * .53
				part(deco, "FolhaFloreira", Vector3.new(.5, .5, .5), CFrame.new(fx, f.Position.Y + .45, f.Position.Z), verdes[(i % 4) + 1], Enum.Material.Grass, false, BALL)
				if i % 2 == 1 then
					part(deco, "FlorFloreira", Vector3.new(.38, .38, .38), CFrame.new(fx, f.Position.Y + .85, f.Position.Z - .1), cores[(i % 4) + 1], Enum.Material.SmoothPlastic, false, BALL)
				end
			end
		end
	end
	-- lenha empilhada na lateral direita
	local lenhaX = x + 12
	for row = 0, 2 do
		for i = 0, 4 - row do
			local lz2 = z - 4 + i * .72 + row * .36
			local tora = part(deco, "Lenha", Vector3.new(2.6, .66, .66), CFrame.new(lenhaX, g + 1.35 + row * .58, lz2) * CFrame.Angles(0, 0, 0), rgb(118 + rng:NextInteger(-12, 12), 82, 54), Enum.Material.Wood, true, CYL)
			part(deco, "PontaLenha", Vector3.new(.06, .6, .6), tora.CFrame * CFrame.new(1.3, 0, 0), rgb(196, 160, 110), Enum.Material.Wood, false, CYL)
		end
	end
	part(deco, "Machadinha", Vector3.new(.16, 1.6, .16), CFrame.new(lenhaX - 1.6, g + 1.6, z + 1.2) * CFrame.Angles(0, 0, math.rad(25)), rgb(140, 98, 60), Enum.Material.Wood, false)
	-- cerca velha (alguns sarrafos caídos), dos dois lados do quintal
	local function cerca(x0, z0, x1, z1, quebrada)
		local a, b = Vector3.new(x0, 0, z0), Vector3.new(x1, 0, z1)
		local n = math.max(1, math.floor((b - a).Magnitude / 3.2))
		for i = 0, n do
			local p = a:Lerp(b, i / n)
			local y = chao(p.X, p.Z, ignorar, g)
			part(deco, "PosteCerca", Vector3.new(.4, 2.6, .4), CFrame.new(p.X, y + 1.1, p.Z) * CFrame.Angles(0, 0, math.rad(rng:NextNumber(-6, 6))), DARK, Enum.Material.Wood, true)
		end
		for i = 0, n - 1 do
			local p0, p1 = a:Lerp(b, i / n), a:Lerp(b, (i + 1) / n)
			local mid = (p0 + p1) / 2
			local len = (p1 - p0).Magnitude
			local y = chao(mid.X, mid.Z, ignorar, g)
			for _, h in ipairs({ 1.0, 1.9 }) do
				if quebrada and i == 1 and h == 1.9 then
					part(deco, "SarrafoCaido", Vector3.new(len, .22, .3), CFrame.new(mid.X, y + .15, mid.Z) * CFrame.lookAt(Vector3.zero, (p1 - p0)).Rotation * CFrame.Angles(0, math.rad(90), math.rad(8)), rgb(98, 76, 52), Enum.Material.Wood, false)
				else
					part(deco, "SarrafoCerca", Vector3.new(.3, .22, len), CFrame.lookAt(Vector3.new(mid.X, y + h, mid.Z), Vector3.new(p1.X, y + h, p1.Z)), rgb(98, 76, 52), Enum.Material.Wood, false)
				end
			end
		end
	end
	cerca(x - 12.5, frente + 1, x - 12.5, frente + 13, true)
	cerca(x + 12.5, frente + 9, x + 12.5, frente + 14, false)
	-- caminho de pedras da escada da varanda até a trilha
	local inicio, fim = Vector3.new(-111, 0, -325), Vector3.new(-90, 0, -318)
	for i = 0, 7 do
		local p = inicio:Lerp(fim, i / 7) + Vector3.new(rng:NextNumber(-.5, .5), 0, math.sin(i * .9) * .9)
		local y = chao(p.X, p.Z, ignorar, g)
		local s = rng:NextNumber(1.5, 2.1)
		part(deco, "PedraCaminho", Vector3.new(.3, s, s * rng:NextNumber(.75, 1)), CFrame.new(p.X, y + .08, p.Z) * CFrame.Angles(0, rng:NextNumber(0, math.pi), 0) * VERTICAL,
			rgb(150, 148, 138):Lerp(rgb(118, 128, 108), rng:NextNumber()), Enum.Material.Slate, false, CYL)
	end

	for _, ez in ipairs({ frente - .5, z - 8.5 }) do
		for _, lado in ipairs({ -1, 1 }) do
			local w = Instance.new("WedgePart")
			w.Name = "Empena"
			w.Size = Vector3.new(.9, 4.1, 10.5)
			w.CFrame = CFrame.new(x + lado * 5.25, g + 9 + 2.05, ez) * CFrame.Angles(0, lado * -math.pi / 2, 0)
			w.Color = rgb(96, 74, 50)
			w.Material = Enum.Material.WoodPlanks
			w.Anchored, w.CanCollide, w.CanTouch, w.CanQuery = true, false, false, false
			w.Parent = deco
		end
	end
	---------------------------------------------------------------- por dentro
	-- tábuas do piso e tapete
	for i = 0, 9 do
		part(deco, "TabuaPiso", Vector3.new(20.6, .5, 1.62), CFrame.new(x, piso - .25, z - 7.5 + i * 1.66), rgb(126 - (i % 2) * 10, 92 - (i % 2) * 6, 60), Enum.Material.Wood, false)
	end
	part(deco, "Tapete", Vector3.new(6.4, .06, 4.4), CFrame.new(x - 2, piso + .1, z + 1.5), rgb(158, 58, 48), Enum.Material.Fabric, false)
	part(deco, "BordaTapete", Vector3.new(5.6, .07, 3.6), CFrame.new(x - 2, piso + .12, z + 1.5), rgb(224, 170, 82), Enum.Material.Fabric, false)
	part(deco, "MeioTapete", Vector3.new(4.8, .08, 2.8), CFrame.new(x - 2, piso + .14, z + 1.5), rgb(158, 58, 48), Enum.Material.Fabric, false)
	-- lareira de pedra na parede do fundo, embaixo da chaminé
	local fx = chamine and chamine.Position.X or x + 5
	local fundo = z - 8 -- face interna da parede do fundo
	part(deco, "Lareira", Vector3.new(5.2, 4.6, 1.8), CFrame.new(fx, piso + 2.3, fundo + .9), STONE, Enum.Material.Cobblestone, true)
	part(deco, "BocaLareira", Vector3.new(2.8, 2.2, .6), CFrame.new(fx, piso + 1.1, fundo + 1.55), rgb(30, 24, 20), Enum.Material.Slate, false)
	part(deco, "PrateleiraLareira", Vector3.new(5.8, .35, 2.1), CFrame.new(fx, piso + 4.7, fundo + .95), DARK, Enum.Material.Wood, false)
	part(deco, "ColunaChamine", Vector3.new(2.6, piso + 9.6 - (piso + 4.9), 1.6), CFrame.new(fx, (piso + 4.9 + g + 9.6) / 2, fundo + .8), STONE, Enum.Material.Cobblestone, false)
	for i = -1, 1, 2 do
		part(deco, "TicaoLareira", Vector3.new(1.6, .35, .35), CFrame.new(fx + i * .35, piso + .35, fundo + 1.95) * CFrame.Angles(0, math.rad(i * 30), 0), rgb(88, 58, 38), Enum.Material.Wood, false, CYL)
	end
	local brasa = part(deco, "Brasa", Vector3.new(1.4, .25, .7), CFrame.new(fx, piso + .2, fundo + 1.95), rgb(255, 120, 40), Enum.Material.Neon, false)
	local fogo = Instance.new("Fire")
	fogo.Size, fogo.Heat, fogo.Color, fogo.SecondaryColor = 2.4, 4, rgb(255, 150, 60), rgb(255, 80, 30)
	fogo.Parent = brasa
	luz(brasa, rgb(255, 150, 80), 1.6, 18, true)
	part(deco, "Panela", Vector3.new(.9, .7, .9), CFrame.new(fx + 1.8, piso + 4.95, fundo + 1), rgb(52, 50, 48), Enum.Material.Metal, false, CYL).CFrame *= VERTICAL
	-- mesa com vela, livro aberto e caneca
	local mx, mz = x + 2.5, z + 2.6
	part(deco, "TampoMesa", Vector3.new(4.2, .3, 2.6), CFrame.new(mx, piso + 2.65, mz), rgb(136, 96, 60), Enum.Material.Wood, true)
	for _, o in ipairs({ { -1.8, -1 }, { 1.8, -1 }, { -1.8, 1 }, { 1.8, 1 } }) do
		part(deco, "PeMesa", Vector3.new(.3, 2.5, .3), CFrame.new(mx + o[1], piso + 1.25, mz + o[2]), DARK, Enum.Material.Wood, true)
	end
	part(deco, "PratoVela", Vector3.new(.08, .6, .6), CFrame.new(mx + 1.2, piso + 2.84, mz - .4) * VERTICAL, rgb(176, 150, 92), Enum.Material.Metal, false, CYL)
	local vela = part(deco, "Vela", Vector3.new(.5, .28, .28), CFrame.new(mx + 1.2, piso + 3.1, mz - .4) * VERTICAL, rgb(246, 238, 214), Enum.Material.SmoothPlastic, false, CYL)
	local chama = part(deco, "Chama", Vector3.new(.16, .26, .16), CFrame.new(mx + 1.2, piso + 3.48, mz - .4), WARM, Enum.Material.Neon, false, BALL)
	luz(chama, WARM, .9, 10)
	for _, s in ipairs({ -1, 1 }) do
		part(deco, "PaginaLivro", Vector3.new(.75, .05, 1.05), CFrame.new(mx - .7 + s * .37, piso + 2.86, mz + .1) * CFrame.Angles(0, 0, math.rad(-s * 6)), rgb(240, 228, 196), Enum.Material.SmoothPlastic, false)
	end
	part(deco, "CapaLivro", Vector3.new(1.6, .04, 1.15), CFrame.new(mx - .7, piso + 2.82, mz + .1), rgb(110, 54, 40), Enum.Material.Fabric, false)
	local caneca = part(deco, "Caneca", Vector3.new(.5, .42, .42), CFrame.new(mx + .4, piso + 3.05, mz + .7) * VERTICAL, rgb(118, 150, 170), Enum.Material.SmoothPlastic, false, CYL)
	-- cadeira
	local cx, cz = mx, mz + 2.1
	part(deco, "AssentoCadeira", Vector3.new(1.6, .25, 1.6), CFrame.new(cx, piso + 1.6, cz), rgb(128, 90, 56), Enum.Material.Wood, true)
	part(deco, "EncostoCadeira", Vector3.new(1.6, 1.9, .22), CFrame.new(cx, piso + 2.65, cz + .7), rgb(128, 90, 56), Enum.Material.Wood, false)
	for _, o in ipairs({ { -.65, -.65 }, { .65, -.65 }, { -.65, .65 }, { .65, .65 } }) do
		part(deco, "PeCadeira", Vector3.new(.2, 1.5, .2), CFrame.new(cx + o[1], piso + .75, cz + o[2]), DARK, Enum.Material.Wood, false)
	end
	-- estante com livros na parede esquerda
	local ex, ez = x - 9.6, z - 1.5
	part(deco, "Estante", Vector3.new(1.3, 6.2, 4.2), CFrame.new(ex, piso + 3.1, ez), DARK, Enum.Material.Wood, true)
	local livros = { rgb(150, 52, 44), rgb(52, 92, 140), rgb(70, 120, 66), rgb(196, 150, 60), rgb(110, 70, 130), rgb(214, 196, 160) }
	for shelf = 0, 2 do
		local y0 = piso + 1.0 + shelf * 1.9
		part(deco, "PrateleiraEstante", Vector3.new(1.35, .15, 4.0), CFrame.new(ex + .05, y0 - .1, ez), rgb(96, 70, 46), Enum.Material.Wood, false)
		local zz = ez - 1.75
		while zz < ez + 1.6 do
			local w = rng:NextNumber(.22, .38)
			local h = rng:NextNumber(.95, 1.45)
			part(deco, "Livro", Vector3.new(.9, h, w), CFrame.new(ex + .35, y0 + h / 2, zz + w / 2) * CFrame.Angles(rng:NextNumber() < .15 and math.rad(14) or 0, 0, 0), livros[rng:NextInteger(1, #livros)], Enum.Material.SmoothPlastic, false)
			zz += w + .04
			if rng:NextNumber() < .12 then zz += .5 end
		end
	end
	-- cama de palha no canto do fundo à esquerda
	local bx, bz = x - 7.6, z - 5.3
	part(deco, "EstradoCama", Vector3.new(3.4, .8, 5.6), CFrame.new(bx, piso + .4, bz), DARK, Enum.Material.Wood, true)
	part(deco, "ColchaoPalha", Vector3.new(3.1, .55, 5.3), CFrame.new(bx, piso + 1.05, bz), rgb(222, 196, 120), Enum.Material.Fabric, false)
	part(deco, "Cobertor", Vector3.new(3.2, .3, 3.2), CFrame.new(bx, piso + 1.35, bz + 1), rgb(76, 116, 84), Enum.Material.Fabric, false)
	part(deco, "Travesseiro", Vector3.new(2.2, .45, 1.1), CFrame.new(bx, piso + 1.5, bz - 2), rgb(238, 232, 212), Enum.Material.Fabric, false)
	-- barris e caixotes no canto da frente à direita
	for i, o in ipairs({ { 8.2, 6.4 }, { 6.9, 6.8 } }) do
		local b = part(deco, "Barril", Vector3.new(2.2, 1.6, 1.6), CFrame.new(x + o[1], piso + 1.1, z + o[2]) * VERTICAL, rgb(132, 92, 56), Enum.Material.Wood, true, CYL)
		for _, dy in ipairs({ -.6, .6 }) do
			part(deco, "AroBarril", Vector3.new(.12, 1.68, 1.68), CFrame.new(x + o[1], piso + 1.1 + dy, z + o[2]) * VERTICAL, rgb(70, 70, 72), Enum.Material.Metal, false, CYL)
		end
	end
	part(deco, "Caixote", Vector3.new(1.8, 1.6, 1.8), CFrame.new(x + 8.4, piso + .8, z + 3.8) * CFrame.Angles(0, math.rad(12), 0), rgb(150, 112, 70), Enum.Material.WoodPlanks, true)
	part(deco, "Caixote", Vector3.new(1.3, 1.1, 1.3), CFrame.new(x + 8.3, piso + 2.15, z + 3.7) * CFrame.Angles(0, math.rad(-8), 0), rgb(160, 120, 76), Enum.Material.WoodPlanks, false)
	-- mapa antigo na parede direita (só decoração)
	local wx = x + 10.5 - .55 -- face interna da parede direita
	part(deco, "MapaParede", Vector3.new(.08, 2.6, 3.4), CFrame.new(wx, piso + 4.4, z - 1), rgb(236, 214, 160), Enum.Material.SmoothPlastic, false)
	for i = 1, 4 do
		part(deco, "TracoMapa", Vector3.new(.04, .07, rng:NextNumber(1, 2.4)), CFrame.new(wx - .05, piso + 3.6 + i * .38, z - 1 + rng:NextNumber(-.5, .5)) * CFrame.Angles(math.rad(rng:NextNumber(-25, 25)), 0, 0), rgb(120, 92, 60), Enum.Material.SmoothPlastic, false)
	end
	part(deco, "XisMapa", Vector3.new(.04, .5, .1), CFrame.new(wx - .06, piso + 4.9, z - .1) * CFrame.Angles(math.rad(45), 0, 0), rgb(196, 50, 40), Enum.Material.SmoothPlastic, false)
	part(deco, "XisMapa", Vector3.new(.04, .5, .1), CFrame.new(wx - .06, piso + 4.9, z - .1) * CFrame.Angles(math.rad(-45), 0, 0), rgb(196, 50, 40), Enum.Material.SmoothPlastic, false)
	-- luz quente geral do cômodo
	local teto = part(deco, "LuzInterna", Vector3.new(.2, .2, .2), CFrame.new(x - 1, g + 8.2, z), WARM, Enum.Material.SmoothPlastic, false)
	teto.Transparency = 1
	luz(teto, WARM, .9, 20)
	return deco
end

return D
