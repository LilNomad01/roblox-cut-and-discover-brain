--[[
	Construtor dos cortadores em peças  [Claude 2026-11-12]
	Pedido do usuário: "Remodel in Studio". As malhas do Elétrico, Turbo e Trator não carregam ("Failed to load
	mesh asset") e Off-Road, Colheitadeira e Imperial não tinham modelo (o jogo usava o MowerLv antigo).
	Rodado UMA vez no Studio (Edit). Os modelos antigos vão para ServerStorage.CortadoresBackup_20261112.
	Referências (brain 21): cortador de empurrar com roda traseira maior que a dianteira e guidão subindo ~45°,
	saco coletor atrás; trator com roda traseira ~1,6x a dianteira, capô na frente e plataforma de corte embaixo;
	colheitadeira com plataforma/molinete na frente, cabine alta, tanque em cima e tubo de descarga dobrado ao lado.
	Convenções que o jogo usa (GameServer.equip / MowerMount):
	  * frente = -Z do pivô; o chão fica 0,8 abaixo do pivô
	  * empurrar: peça "Guidao" (a caixa dela define onde as mãos seguram) e "Lamina" (posição da lâmina)
	  * dirigível (atributo Veiculo=true): chassi "Carroceria" (colide), rodas "Roda*" (colidem), VehicleSeat
]]
local Mowers = game.ServerStorage.GameAssets.Mowers
local bk = game.ServerStorage:FindFirstChild("CortadoresBackup_20261112") or Instance.new("Folder")
bk.Name = "CortadoresBackup_20261112"
bk.Parent = game.ServerStorage

local PRETO = Color3.fromRGB(34, 34, 38)
local CINZA = Color3.fromRGB(150, 152, 158)
local CROMO = Color3.fromRGB(205, 208, 214)
local OURO = Color3.fromRGB(240, 196, 60)

local function novoModelo(nome)
	local antigo = Mowers:FindFirstChild(nome)
	if antigo then
		local b = bk:FindFirstChild(nome)
		if b then b:Destroy() end
		antigo.Parent = bk
	end
	local m = Instance.new("Model")
	m.Name = nome
	return m
end

local P0 = CFrame.new(0, 1000, 0) -- constrói longe do mapa e depois guarda no ServerStorage
local function peca(m, nome, tam, off, cor, mat, forma, classe)
	local p = Instance.new(classe or "Part")
	p.Name = nome
	p.Size = tam
	p.CFrame = P0 * off
	p.Color = cor
	p.Material = mat or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if forma then p.Shape = forma end
	p.Parent = m
	return p
end
local function roda(m, nome, x, y, z, diam, larg, corAro)
	local r = peca(m, nome, Vector3.new(larg, diam, diam), CFrame.new(x, y, z), PRETO, Enum.Material.Rubber, Enum.PartType.Cylinder)
	peca(m, nome .. "Aro", Vector3.new(larg + 0.04, diam * 0.5, diam * 0.5), CFrame.new(x, y, z), corAro or CINZA, Enum.Material.Metal, Enum.PartType.Cylinder)
	return r
end
local function finalizar(m)
	m.WorldPivot = P0
	m:SetAttribute("Autor", "Claude 2026-11-12 cortadores em pecas")
	m.Parent = Mowers
	return m
end

---------------------------------------------------------------- cortador de empurrar
-- base comum: deck, saia, 4 rodas (traseira maior), guidão a ~45° com manopla, saco coletor, lâmina
local function empurrar(nome, c1, c2, extra)
	local m = novoModelo(nome)
	local deck = peca(m, "Carcaca", Vector3.new(2.46, 0.46, 2.96), CFrame.new(0, -0.14, -0.03), c2)
	peca(m, "Tampa", Vector3.new(2.2, 0.2, 2.6), CFrame.new(0, 0.18, -0.05), c1)
	local saia = Instance.new("WedgePart")
	saia.Name = "SaiaFrente" saia.Anchored = true saia.CanCollide = false saia.Color = c2 saia.Material = Enum.Material.SmoothPlastic
	saia.Size = Vector3.new(2.46, 0.46, 0.5) saia.CFrame = P0 * CFrame.new(0, -0.14, -1.76) * CFrame.Angles(0, math.rad(180), 0) saia.Parent = m
	peca(m, "Lamina", Vector3.new(1.94, 0.1, 0.36), CFrame.new(0, -0.31, -0.18), CINZA, Enum.Material.Metal)
	roda(m, "RodaFrenteEsq", -1.33, -0.38, -1.15, 0.84, 0.32)
	roda(m, "RodaFrenteDir", 1.33, -0.38, -1.15, 0.84, 0.32)
	roda(m, "RodaTrasEsq", -1.35, -0.25, 1.15, 1.1, 0.36)
	roda(m, "RodaTrasDir", 1.35, -0.25, 1.15, 1.1, 0.36)
	-- guidão: duas hastes subindo para trás e a barra da manopla onde as mãos ficam (y 2,47, z 2,51)
	local base = Vector3.new(0, 0.15, 1.25)
	local topo = Vector3.new(0, 2.45, 2.5)
	local dir = (topo - base)
	local comp = dir.Magnitude
	local ang = math.atan2(dir.Z, dir.Y)
	for _, x in ipairs({ -0.85, 0.85 }) do
		peca(m, "Haste", Vector3.new(0.14, comp, 0.14), CFrame.new(x, (base.Y + topo.Y) / 2, (base.Z + topo.Z) / 2) * CFrame.Angles(ang, 0, 0), PRETO, Enum.Material.Metal)
	end
	peca(m, "Manopla", Vector3.new(1.9, 0.2, 0.2), CFrame.new(0, topo.Y, topo.Z) * CFrame.Angles(0, 0, math.rad(90)), PRETO, Enum.Material.Rubber, Enum.PartType.Cylinder)
	peca(m, "Gatilho", Vector3.new(1.2, 0.08, 0.3), CFrame.new(0, topo.Y - 0.2, topo.Z - 0.15), c2, Enum.Material.Metal)
	-- caixa invisível que o MowerMount usa para achar a manopla (mesma medida do modelo original)
	local g = peca(m, "Guidao", Vector3.new(2.04, 2.57, 2.55), CFrame.new(0, 1.29, 1.44), c1)
	g.Transparency = 1
	-- saco coletor atrás, entre as hastes
	peca(m, "SacoColetor", Vector3.new(1.5, 1.0, 1.15), CFrame.new(0, 0.55, 1.75) * CFrame.Angles(math.rad(-12), 0, 0), Color3.fromRGB(60, 90, 60), Enum.Material.Fabric)
	peca(m, "SacoAro", Vector3.new(1.6, 0.14, 0.14), CFrame.new(0, 1.05, 1.3), PRETO, Enum.Material.Metal)
	if extra then extra(m, c1, c2) end
	return finalizar(m)
end

-- Elétrico: bateria com raio, sem escapamento, faixa ciano
empurrar("Cortador_Eletrico", Color3.fromRGB(110, 225, 255), Color3.fromRGB(40, 120, 235), function(m, c1, c2)
	peca(m, "Motor", Vector3.new(1.3, 0.75, 1.1), CFrame.new(0, 0.66, -0.35), Color3.fromRGB(235, 240, 248))
	peca(m, "Bateria", Vector3.new(0.9, 0.3, 0.7), CFrame.new(0, 1.18, -0.35), PRETO)
	peca(m, "Raio", Vector3.new(0.18, 0.5, 0.06), CFrame.new(0.05, 0.7, -0.93) * CFrame.Angles(0, 0, math.rad(-20)), Color3.fromRGB(255, 226, 60), Enum.Material.Neon)
	peca(m, "Raio2", Vector3.new(0.18, 0.35, 0.06), CFrame.new(-0.08, 0.5, -0.93) * CFrame.Angles(0, 0, math.rad(25)), Color3.fromRGB(255, 226, 60), Enum.Material.Neon)
	peca(m, "Led", Vector3.new(0.3, 0.12, 0.12), CFrame.new(0, 1.18, -0.75), Color3.fromRGB(90, 255, 140), Enum.Material.Neon)
end)

-- Turbo: motor grande, dois escapamentos cromados, faixa de corrida e aerofólio
empurrar("Cortador_Turbo", Color3.fromRGB(255, 190, 70), Color3.fromRGB(240, 100, 20), function(m, c1, c2)
	peca(m, "Motor", Vector3.new(1.45, 0.9, 1.3), CFrame.new(0, 0.75, -0.3), Color3.fromRGB(50, 50, 56), Enum.Material.Metal)
	peca(m, "Tampa2", Vector3.new(1.2, 0.25, 1.0), CFrame.new(0, 1.3, -0.3), c2)
	for _, x in ipairs({ -0.55, 0.55 }) do
		peca(m, "Escape", Vector3.new(0.9, 0.22, 0.22), CFrame.new(x, 1.1, 0.45) * CFrame.Angles(0, math.rad(90), math.rad(35)), CROMO, Enum.Material.Metal, Enum.PartType.Cylinder)
	end
	peca(m, "Faixa", Vector3.new(0.4, 0.22, 2.62), CFrame.new(0, 0.2, -0.05), Color3.new(1, 1, 1))
	peca(m, "Aerofolio", Vector3.new(2.3, 0.1, 0.45), CFrame.new(0, 0.95, 1.05) * CFrame.Angles(math.rad(-10), 0, 0), PRETO)
	for _, x in ipairs({ -0.9, 0.9 }) do peca(m, "AerofolioPe", Vector3.new(0.1, 0.55, 0.1), CFrame.new(x, 0.62, 1.05), PRETO) end
end)

---------------------------------------------------------------- dirigíveis
-- chassi "Carroceria" (colide) + rodas "Roda*" (colidem, encostam no chão a -0,8) + banco + volante + lâmina
local function dirigivel(nome, o)
	local m = novoModelo(nome)
	local s = o.escala or 1
	local function V(x, y, z) return Vector3.new(x * s, y * s, z * s) end
	local function C(x, y, z) return CFrame.new(x * s, y * s, z * s) end
	local rT, rF = 1.0 * (o.rodaT or 1), 0.62 * (o.rodaF or 1) -- raio traseiro ~1,6x o dianteiro
	local chao = -0.8
	local car = peca(m, "Carroceria", V(2.4, 1.0, 4.0), C(0, chao / s + rF + 0.45, 0.1), o.c2)
	car.CanCollide = true
	-- capô na frente, com grade e faróis
	local capo = peca(m, "Capo", V(2.0, 1.0, 1.7), C(0, chao / s + rF + 1.1, -1.05), o.c1)
	peca(m, "Grade", V(1.6, 0.7, 0.08), C(0, chao / s + rF + 1.05, -1.93), PRETO, Enum.Material.DiamondPlate)
	for _, x in ipairs({ -0.75, 0.75 }) do
		peca(m, "Farol", V(0.32, 0.32, 0.12), C(x, chao / s + rF + 1.3, -1.92), Color3.fromRGB(255, 248, 210), Enum.Material.Neon, Enum.PartType.Cylinder).CFrame = P0 * C(x, chao / s + rF + 1.3, -1.92) * CFrame.Angles(0, math.rad(90), 0)
	end
	-- banco, encosto e volante
	local yBanco = chao / s + rF + 1.15
	peca(m, "Banco", V(1.3, 0.3, 1.0), C(0, yBanco, 0.95), PRETO, Enum.Material.Fabric)
	peca(m, "Encosto", V(1.3, 1.0, 0.25), C(0, yBanco + 0.55, 1.45) * CFrame.Angles(math.rad(-10), 0, 0), PRETO, Enum.Material.Fabric)
	peca(m, "Coluna", V(0.15, 0.9, 0.15), C(0, yBanco + 0.3, -0.05) * CFrame.Angles(math.rad(-35), 0, 0), PRETO, Enum.Material.Metal)
	peca(m, "Volante", V(0.12, 0.85, 0.85), C(0, yBanco + 0.72, -0.3) * CFrame.Angles(math.rad(-35), 0, 0) * CFrame.Angles(0, 0, math.rad(90)), PRETO, Enum.Material.Rubber, Enum.PartType.Cylinder)
	local seat = Instance.new("VehicleSeat")
	seat.Name = "AssentoMotorista" seat.Size = V(1.3, 0.3, 1.0) seat.Transparency = 1 seat.Anchored = true seat.CanCollide = false
	seat.CFrame = P0 * C(0, yBanco + 0.05, 0.95) seat.Parent = m
	-- rodas: traseiras grandes, dianteiras pequenas
	local largT, largF = 0.7 * (o.largRoda or 1), 0.45 * (o.largRoda or 1)
	for _, lado in ipairs({ -1, 1 }) do
		roda(m, lado < 0 and "RodaTrasEsq" or "RodaTrasDir", lado * 1.45 * s, (chao / s + rT) * s, 1.2 * s, 2 * rT * s, largT * s, o.aro)
		roda(m, lado < 0 and "RodaFrenteEsq" or "RodaFrenteDir", lado * 1.25 * s, (chao / s + rF) * s, -1.3 * s, 2 * rF * s, largF * s, o.aro)
		-- para-lama sobre a roda traseira
		peca(m, "ParaLama", V(largT + 0.15, 0.15, 2 * rT * 0.9), C(lado * 1.45, chao / s + 2 * rT + 0.1, 1.2), o.c1)
	end
	-- plataforma de corte (deck) embaixo, com a lâmina
	peca(m, "Deck", V(2.6, 0.3, 1.3), C(0, chao / s + 0.3, -0.2), o.deck or CINZA, Enum.Material.Metal)
	peca(m, "Lamina", V(2.3, 0.08, 0.4), C(0, chao / s + 0.15, -0.2), CROMO, Enum.Material.Metal)
	if o.extra then o.extra(m, V, C, chao / s, rT, rF) end
	m:SetAttribute("Veiculo", true)
	m.PrimaryPart = car
	finalizar(m)
	m.WorldPivot = P0
	return m
end

-- Mini Trator (verde, clássico de jardim)
dirigivel("Cortador_Trator", { c1 = Color3.fromRGB(120, 210, 70), c2 = Color3.fromRGB(36, 140, 60), aro = Color3.fromRGB(250, 214, 60) })

-- Trator Off-Road: cáqui, pneus grandes com cravos, santo-antônio e faróis no teto
dirigivel("Cortador_OffRoad", { c1 = Color3.fromRGB(208, 178, 104), c2 = Color3.fromRGB(120, 92, 50), escala = 1.15, rodaT = 1.15, rodaF = 1.15, largRoda = 1.3,
	aro = Color3.fromRGB(60, 60, 64), deck = Color3.fromRGB(80, 80, 84),
	extra = function(m, V, C, chao, rT, rF)
		for _, x in ipairs({ -0.75, 0.75 }) do
			peca(m, "SantoAntonio", V(0.15, 2.2, 0.15), C(x, chao + rF + 2.1, 1.65), PRETO, Enum.Material.Metal)
		end
		peca(m, "SantoAntonioTopo", V(1.65, 0.15, 0.15), C(0, chao + rF + 3.2, 1.65), PRETO, Enum.Material.Metal)
		for _, x in ipairs({ -0.5, 0.5 }) do
			peca(m, "FarolTeto", V(0.3, 0.25, 0.2), C(x, chao + rF + 3.35, 1.6), Color3.fromRGB(255, 240, 190), Enum.Material.Neon)
		end
		-- cravos nos pneus traseiros
		for _, lado in ipairs({ -1, 1 }) do
			for i = 0, 7 do
				local a = math.rad(i * 45)
				peca(m, "Cravo", V(0.95, 0.18, 0.3), C(lado * 1.45, chao + rT + math.cos(a) * rT, 1.2 + math.sin(a) * rT) * CFrame.Angles(-a, 0, 0), PRETO, Enum.Material.Rubber)
			end
		end
	end })

-- Colheitadeira: amarela, plataforma com molinete na frente, cabine alta envidraçada, tanque e tubo de descarga
dirigivel("Cortador_Colheitadeira", { c1 = Color3.fromRGB(255, 220, 110), c2 = Color3.fromRGB(220, 160, 40), escala = 1.25, rodaT = 0.75, rodaF = 1.35,
	aro = Color3.fromRGB(60, 60, 64), deck = Color3.fromRGB(220, 160, 40),
	extra = function(m, V, C, chao, rT, rF)
		local amarelo = Color3.fromRGB(240, 190, 50)
		-- plataforma de corte larga na frente (header) e molinete
		peca(m, "Plataforma", V(3.6, 0.5, 1.1), C(0, chao + 0.4, -2.55), amarelo, Enum.Material.Metal)
		peca(m, "PlataformaFundo", V(3.6, 0.9, 0.15), C(0, chao + 0.85, -2.05), amarelo, Enum.Material.Metal)
		-- molinete deitado ao longo da plataforma (o eixo do cilindro já é o X)
		peca(m, "Molinete", V(3.4, 0.9, 0.9), C(0, chao + 1.25, -2.65), Color3.fromRGB(200, 60, 40), Enum.Material.Metal, Enum.PartType.Cylinder).Transparency = 0.35
		for i = 0, 3 do
			local a = math.rad(i * 90)
			peca(m, "Pente", V(3.4, 0.08, 0.08), C(0, chao + 1.25 + math.cos(a) * 0.5, -2.65 + math.sin(a) * 0.5), Color3.fromRGB(240, 240, 240), Enum.Material.Metal)
		end
		for _, x in ipairs({ -1.8, 1.8 }) do peca(m, "PontaDivisora", V(0.15, 0.6, 1.2), C(x, chao + 0.5, -2.55), amarelo, Enum.Material.Metal) end
		-- cabine alta envidraçada sobre o banco
		peca(m, "Cabine", V(1.6, 1.5, 1.5), C(0, chao + rF + 2.4, 0.6), Color3.fromRGB(150, 210, 240), Enum.Material.Glass).Transparency = 0.45
		peca(m, "CabineTeto", V(1.8, 0.2, 1.7), C(0, chao + rF + 3.2, 0.6), Color3.fromRGB(240, 240, 240))
		-- tanque de grãos atrás e tubo de descarga dobrado ao lado
		peca(m, "Tanque", V(2.2, 1.1, 1.5), C(0, chao + rF + 2.0, 2.0), amarelo, Enum.Material.Metal)
		peca(m, "TuboBase", V(0.35, 1.6, 0.35), C(1.25, chao + rF + 2.2, 2.3), CINZA, Enum.Material.Metal, Enum.PartType.Cylinder).CFrame = P0 * C(1.25, chao + rF + 2.2, 2.3) * CFrame.Angles(0, 0, math.rad(90))
		peca(m, "Tubo", V(2.4, 0.3, 0.3), C(1.25, chao + rF + 3.0, 1.2) * CFrame.Angles(0, math.rad(90), math.rad(-8)), CINZA, Enum.Material.Metal, Enum.PartType.Cylinder)
	end })

-- Imperial GX: azul real com frisos dourados, coroa no capô, diamante e aros dourados
dirigivel("Cortador_Imperial", { c1 = Color3.fromRGB(110, 210, 255), c2 = Color3.fromRGB(50, 80, 210), escala = 1.2, aro = OURO, deck = Color3.fromRGB(40, 50, 90),
	extra = function(m, V, C, chao, rT, rF)
		peca(m, "FrisoCapo", V(2.05, 0.12, 1.75), C(0, chao + rF + 1.62, -1.05), OURO, Enum.Material.Metal)
		peca(m, "FrisoLado", V(2.45, 0.15, 4.05), C(0, chao + rF + 0.95, 0.1), OURO, Enum.Material.Metal)
		peca(m, "CoroaBase", V(0.9, 0.25, 0.5), C(0, chao + rF + 1.8, -1.5), OURO, Enum.Material.Metal)
		for i = -1, 1 do peca(m, "CoroaPonta", V(0.18, 0.4, 0.18), C(i * 0.32, chao + rF + 2.05, -1.5), OURO, Enum.Material.Metal) end
		local d = peca(m, "Diamante", V(0.45, 0.45, 0.45), C(0, chao + rF + 1.05, -1.95) * CFrame.Angles(0, math.rad(45), math.rad(45)), Color3.fromRGB(180, 245, 255), Enum.Material.Glass)
		d.Transparency = 0.15
		peca(m, "Capa", V(1.3, 0.12, 1.0), C(0, chao + rF + 1.31, 0.95), Color3.fromRGB(150, 30, 50), Enum.Material.Fabric)
	end })

return "ok"
