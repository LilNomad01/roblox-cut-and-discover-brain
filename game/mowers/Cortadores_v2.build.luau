--[[
	Cortadores em peças, versão 2 (mais detalhe)  [Claude 2026-11-13]
	Pedido do usuário: "em relação a modelação dos objetos, conseguimos melhorar?" -> começar pelos cortadores.
	Rodado UMA vez no Studio (Edit) e substitui os modelos da v1 (Cortadores.build.luau).
	Backup dos modelos da v1: ServerStorage.CortadoresBackup_20261113 (o backup de 2026-11-12, com as malhas
	originais, não é tocado).

	O que muda em relação à v1 (referências: brain 21 + fotos de cortadores e tratores de jardim reais):
	  * rodas: aro rebaixado, cubo cromado e 5 porcas na face de fora (não era só um disco chapado)
	  * empurrar: carcaça com a frente REDONDA (como os decks de verdade), tampa redonda, alavancas de altura
	    perto das rodas traseiras, cabo de comando descendo do guidão até o motor
	      - Turbo: motor com aletas de refrigeração, filtro de ar redondo, tampa de combustível e puxador de partida
	      - Elétrico: bateria com alça e grade de ventilação
	  * dirigíveis: capô com as quinas de cima chanfradas (cunhas), para-choque, escapamento vertical cromado,
	    respiros na lateral do capô, estribos, lanternas traseiras e calha de descarga na lateral do deck
	Convenções do jogo mantidas (GameServer.equip / MowerMount):
	  * frente = -Z do pivô; o chão fica 0,8 abaixo do pivô
	  * empurrar: peça "Guidao" (caixa invisível das mãos) e "Lamina"
	  * dirigível (Veiculo=true): "Carroceria" (colide), rodas "Roda*" (colidem), VehicleSeat
	  * as peças novas de roda se chamam "Cubo"/"Porca" (não começam com "Roda")
]]
local Mowers = game.ServerStorage.GameAssets.Mowers
local bk = game.ServerStorage:FindFirstChild("CortadoresBackup_20261113") or Instance.new("Folder")
bk.Name = "CortadoresBackup_20261113"
bk.Parent = game.ServerStorage

local PRETO = Color3.fromRGB(34, 34, 38)
local CINZA = Color3.fromRGB(150, 152, 158)
local CROMO = Color3.fromRGB(205, 208, 214)
local OURO = Color3.fromRGB(240, 196, 60)
local VERMELHO = Color3.fromRGB(230, 40, 40)

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
-- cilindro em pé (o eixo do cilindro do Roblox é o X; gira 90° em Z)
local function cilindroY(m, nome, altura, diam, off, cor, mat)
	return peca(m, nome, Vector3.new(altura, diam, diam), off * CFrame.Angles(0, 0, math.rad(90)), cor, mat, Enum.PartType.Cylinder)
end
-- cunha com o ângulo reto colado ao corpo: Y = para cima, Z = para dentro (direção "dentro" em X do modelo)
local function cunhaChanfro(m, nome, comprimento, c, pos, dentroX, cor, mat)
	local w = Instance.new("WedgePart")
	w.Name = nome w.Anchored = true w.CanCollide = false w.Color = cor w.Material = mat or Enum.Material.SmoothPlastic
	w.TopSurface = Enum.SurfaceType.Smooth w.BottomSurface = Enum.SurfaceType.Smooth
	w.Size = Vector3.new(comprimento, c, c)
	local zW = Vector3.new(dentroX, 0, 0)
	local yW = Vector3.new(0, 1, 0)
	local xW = yW:Cross(zW)
	w.CFrame = CFrame.fromMatrix((P0 * pos).Position, xW, yW, zW)
	w.Parent = m
	return w
end
local function roda(m, nome, x, y, z, diam, larg, corAro)
	local lado = x >= 0 and 1 or -1
	local r = peca(m, nome, Vector3.new(larg, diam, diam), CFrame.new(x, y, z), PRETO, Enum.Material.Rubber, Enum.PartType.Cylinder)
	peca(m, nome .. "Aro", Vector3.new(larg + 0.02, diam * 0.62, diam * 0.62), CFrame.new(x, y, z), corAro or CINZA, Enum.Material.Metal, Enum.PartType.Cylinder)
	peca(m, "Cubo", Vector3.new(larg + 0.1, diam * 0.24, diam * 0.24), CFrame.new(x + lado * 0.04, y, z), CROMO, Enum.Material.Metal, Enum.PartType.Cylinder)
	for i = 0, 4 do
		local a = math.rad(i * 72)
		peca(m, "Porca", Vector3.new(0.05, diam * 0.07, diam * 0.07), CFrame.new(x + lado * (larg / 2 + 0.03), y + math.cos(a) * diam * 0.2, z + math.sin(a) * diam * 0.2), CROMO, Enum.Material.Metal, Enum.PartType.Cylinder)
	end
	return r
end
-- barra fina ligando dois pontos (cabos, hastes)
local function barra(m, nome, a, b, grossura, cor, mat)
	local d = b - a
	return peca(m, nome, Vector3.new(grossura, grossura, d.Magnitude), CFrame.lookAt((a + b) / 2, b), cor, mat or Enum.Material.SmoothPlastic)
end
local function finalizar(m)
	m.WorldPivot = P0
	m:SetAttribute("Autor", "Claude 2026-11-13 cortadores em pecas v2")
	m.Parent = Mowers
	return m
end

---------------------------------------------------------------- cortador de empurrar
local function empurrar(nome, c1, c2, extra)
	local m = novoModelo(nome)
	-- carcaça: parte de trás reta + frente redonda (deck real); mesma área da v1 (z de -1,53 a 1,45)
	peca(m, "Carcaca", Vector3.new(2.46, 0.46, 1.75), CFrame.new(0, -0.14, 0.575), c2)
	cilindroY(m, "CarcacaFrente", 0.46, 2.46, CFrame.new(0, -0.14, -0.3), c2)
	peca(m, "Saia", Vector3.new(2.56, 0.1, 1.8), CFrame.new(0, -0.34, 0.575), PRETO)
	cilindroY(m, "SaiaFrente", 0.1, 2.56, CFrame.new(0, -0.34, -0.3), PRETO)
	peca(m, "Tampa", Vector3.new(2.2, 0.2, 1.6), CFrame.new(0, 0.18, 0.5), c1)
	cilindroY(m, "TampaFrente", 0.2, 2.2, CFrame.new(0, 0.18, -0.3), c1)
	peca(m, "Lamina", Vector3.new(1.94, 0.1, 0.36), CFrame.new(0, -0.31, -0.18), CINZA, Enum.Material.Metal)
	roda(m, "RodaFrenteEsq", -1.33, -0.38, -1.15, 0.84, 0.32)
	roda(m, "RodaFrenteDir", 1.33, -0.38, -1.15, 0.84, 0.32)
	roda(m, "RodaTrasEsq", -1.35, -0.25, 1.15, 1.1, 0.36)
	roda(m, "RodaTrasDir", 1.35, -0.25, 1.15, 1.1, 0.36)
	-- alavancas de altura do corte, junto das rodas traseiras
	for _, x in ipairs({ -1.12, 1.12 }) do
		peca(m, "AlavancaAltura", Vector3.new(0.08, 0.55, 0.08), CFrame.new(x, 0.3, 0.75) * CFrame.Angles(math.rad(25), 0, 0), PRETO, Enum.Material.Metal)
		peca(m, "AlavancaPonta", Vector3.new(0.14, 0.14, 0.14), CFrame.new(x, 0.55, 0.86), Color3.fromRGB(230, 60, 40), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	end
	-- guidão: duas hastes subindo para trás e a manopla (mãos em y 2,47, z 2,51)
	local base = Vector3.new(0, 0.15, 1.25)
	local topo = Vector3.new(0, 2.45, 2.5)
	local dir = (topo - base)
	local comp = dir.Magnitude
	local ang = math.atan2(dir.Z, dir.Y)
	for _, x in ipairs({ -0.85, 0.85 }) do
		peca(m, "Haste", Vector3.new(0.14, comp, 0.14), CFrame.new(x, (base.Y + topo.Y) / 2, (base.Z + topo.Z) / 2) * CFrame.Angles(ang, 0, 0), PRETO, Enum.Material.Metal)
		peca(m, "HasteJunta", Vector3.new(0.2, 0.2, 0.2), CFrame.new(x, (base.Y + topo.Y) / 2, (base.Z + topo.Z) / 2), CINZA, Enum.Material.Metal, Enum.PartType.Ball)
	end
	-- manopla: cilindro deitado em X, de ponta a ponta entre as hastes
	peca(m, "Manopla", Vector3.new(1.9, 0.2, 0.2), CFrame.new(0, topo.Y, topo.Z), PRETO, Enum.Material.Rubber, Enum.PartType.Cylinder)
	peca(m, "Gatilho", Vector3.new(1.2, 0.08, 0.3), CFrame.new(0, topo.Y - 0.2, topo.Z - 0.15), c2, Enum.Material.Metal)
	-- cabo de comando: da manopla, descendo pela haste direita até o motor
	barra(m, "CaboComando", Vector3.new(0.72, topo.Y - 0.1, topo.Z - 0.1), Vector3.new(0.45, 0.9, 0.1), 0.05, PRETO)
	-- caixa invisível que o MowerMount usa para achar a manopla (mesma medida do modelo original)
	local g = peca(m, "Guidao", Vector3.new(2.04, 2.57, 2.55), CFrame.new(0, 1.29, 1.44), c1)
	g.Transparency = 1
	-- saco coletor atrás, entre as hastes
	peca(m, "SacoColetor", Vector3.new(1.5, 1.0, 1.15), CFrame.new(0, 0.55, 1.75) * CFrame.Angles(math.rad(-12), 0, 0), Color3.fromRGB(60, 90, 60), Enum.Material.Fabric)
	peca(m, "SacoAro", Vector3.new(1.6, 0.14, 0.14), CFrame.new(0, 1.05, 1.3), PRETO, Enum.Material.Metal)
	peca(m, "SacoAlca", Vector3.new(0.7, 0.1, 0.1), CFrame.new(0, 1.12, 1.9), PRETO, Enum.Material.Metal)
	if extra then extra(m, c1, c2) end
	return finalizar(m)
end

-- Elétrico: bateria com alça e respiro, raio, LED
empurrar("Cortador_Eletrico", Color3.fromRGB(110, 225, 255), Color3.fromRGB(40, 120, 235), function(m, c1, c2)
	cilindroY(m, "Motor", 0.75, 1.3, CFrame.new(0, 0.66, -0.35), Color3.fromRGB(235, 240, 248))
	peca(m, "Bateria", Vector3.new(0.9, 0.3, 0.7), CFrame.new(0, 1.18, -0.35), PRETO)
	peca(m, "BateriaAlca", Vector3.new(0.6, 0.08, 0.1), CFrame.new(0, 1.42, -0.35), c2)
	for _, x in ipairs({ -0.27, 0.27 }) do peca(m, "BateriaAlcaPe", Vector3.new(0.08, 0.2, 0.1), CFrame.new(x, 1.36, -0.35), c2) end
	for i = -2, 2 do -- grade de ventilação na tampa, atrás do motor
		peca(m, "Respiro", Vector3.new(0.06, 0.04, 0.4), CFrame.new(i * 0.16, 0.29, 0.6), PRETO)
	end
	peca(m, "Raio", Vector3.new(0.18, 0.5, 0.06), CFrame.new(0.05, 0.7, -1.03) * CFrame.Angles(0, 0, math.rad(-20)), Color3.fromRGB(255, 226, 60), Enum.Material.Neon)
	peca(m, "Raio2", Vector3.new(0.18, 0.35, 0.06), CFrame.new(-0.08, 0.5, -1.03) * CFrame.Angles(0, 0, math.rad(25)), Color3.fromRGB(255, 226, 60), Enum.Material.Neon)
	peca(m, "Led", Vector3.new(0.3, 0.12, 0.12), CFrame.new(0, 1.18, -0.75), Color3.fromRGB(90, 255, 140), Enum.Material.Neon)
end)

-- Turbo: motor com aletas, filtro de ar, tampa de combustível, puxador de partida, escapes, faixa e aerofólio
empurrar("Cortador_Turbo", Color3.fromRGB(255, 190, 70), Color3.fromRGB(240, 100, 20), function(m, c1, c2)
	local motor = Color3.fromRGB(50, 50, 56)
	peca(m, "Motor", Vector3.new(1.45, 0.9, 1.3), CFrame.new(0, 0.75, -0.3), motor, Enum.Material.Metal)
	for i = 0, 3 do -- aletas de refrigeração nas duas laterais
		for _, x in ipairs({ -0.76, 0.76 }) do
			peca(m, "Aleta", Vector3.new(0.08, 0.08, 1.1), CFrame.new(x, 0.42 + i * 0.2, -0.3), CINZA, Enum.Material.Metal)
		end
	end
	peca(m, "Tampa2", Vector3.new(1.2, 0.25, 1.0), CFrame.new(0, 1.3, -0.3), c2)
	peca(m, "FiltroAr", Vector3.new(0.3, 0.6, 0.6), CFrame.new(-0.35, 0.85, -1.1) * CFrame.Angles(0, math.rad(90), 0), PRETO, Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
	cilindroY(m, "TampaCombustivel", 0.14, 0.3, CFrame.new(0.35, 1.49, -0.55), Color3.fromRGB(255, 220, 40))
	-- puxador de partida preso na haste direita, com a corda descendo até o motor
	peca(m, "PuxadorPartida", Vector3.new(0.3, 0.1, 0.1), CFrame.new(0.68, 1.5, 1.98), PRETO, Enum.Material.Rubber)
	barra(m, "CordaPartida", Vector3.new(0.6, 1.48, 1.95), Vector3.new(0.5, 1.0, 0.3), 0.04, Color3.fromRGB(230, 230, 230))
	for _, x in ipairs({ -0.55, 0.55 }) do
		peca(m, "Escape", Vector3.new(0.9, 0.22, 0.22), CFrame.new(x, 1.1, 0.45) * CFrame.Angles(0, math.rad(90), math.rad(35)), CROMO, Enum.Material.Metal, Enum.PartType.Cylinder)
	end
	peca(m, "Faixa", Vector3.new(0.4, 0.22, 1.62), CFrame.new(0, 0.2, 0.5), Color3.new(1, 1, 1))
	peca(m, "Aerofolio", Vector3.new(2.3, 0.1, 0.45), CFrame.new(0, 0.95, 1.05) * CFrame.Angles(math.rad(-10), 0, 0), PRETO)
	for _, x in ipairs({ -0.9, 0.9 }) do peca(m, "AerofolioPe", Vector3.new(0.1, 0.55, 0.1), CFrame.new(x, 0.62, 1.05), PRETO) end
end)

---------------------------------------------------------------- dirigíveis
local function dirigivel(nome, o)
	local m = novoModelo(nome)
	local s = o.escala or 1
	local function V(x, y, z) return Vector3.new(x * s, y * s, z * s) end
	local function C(x, y, z) return CFrame.new(x * s, y * s, z * s) end
	local rT, rF = 1.0 * (o.rodaT or 1), 0.62 * (o.rodaF or 1)
	local chao = -0.8
	local ch = chao / s
	local car = peca(m, "Carroceria", V(2.4, 1.0, 4.0), C(0, ch + rF + 0.45, 0.1), o.c2)
	car.CanCollide = true
	-- capô: corpo + faixa de cima mais estreita + cunhas nas quinas (chanfro)
	local yc = ch + rF + 1.1
	peca(m, "Capo", V(2.0, 0.7, 1.7), C(0, yc - 0.15, -1.05), o.c1)
	peca(m, "CapoTopo", V(1.4, 0.3, 1.7), C(0, yc + 0.35, -1.05), o.c1)
	for _, lx in ipairs({ -1, 1 }) do
		cunhaChanfro(m, "CapoChanfro", 1.7 * s, 0.3 * s, C(lx * 0.85, yc + 0.35, -1.05), -lx, o.c1)
		for i = 0, 2 do -- respiros na lateral do capô
			peca(m, "Respiro", V(0.04, 0.07, 0.9), C(lx * 1.01, yc - 0.32 + i * 0.15, -1.0), PRETO)
		end
	end
	peca(m, "Grade", V(1.6, 0.6, 0.08), C(0, yc - 0.1, -1.93), PRETO, Enum.Material.DiamondPlate)
	for _, x in ipairs({ -0.75, 0.75 }) do
		peca(m, "Farol", V(0.12, 0.32, 0.32), C(x, yc + 0.2, -1.92) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(255, 248, 210), Enum.Material.Neon, Enum.PartType.Cylinder)
	end
	if not o.semParaChoque then peca(m, "ParaChoque", V(2.3, 0.25, 0.25), C(0, yc - 0.5, -2.05), PRETO, Enum.Material.Metal) end
	-- escapamento vertical cromado com chapéu, do lado direito do capô
	cilindroY(m, "Escapamento", 0.9 * s, 0.18 * s, C(0.7, yc + 0.85, -0.55), CROMO, Enum.Material.Metal)
	cilindroY(m, "EscapamentoChapeu", 0.06 * s, 0.26 * s, C(0.7, yc + 1.32, -0.55), PRETO, Enum.Material.Metal)
	-- banco, encosto e volante
	local yBanco = ch + rF + 1.15
	peca(m, "Banco", V(1.3, 0.3, 1.0), C(0, yBanco, 0.95), PRETO, Enum.Material.Fabric)
	peca(m, "Encosto", V(1.3, 1.0, 0.25), C(0, yBanco + 0.55, 1.45) * CFrame.Angles(math.rad(-10), 0, 0), PRETO, Enum.Material.Fabric)
	peca(m, "Coluna", V(0.15, 0.9, 0.15), C(0, yBanco + 0.3, -0.05) * CFrame.Angles(math.rad(-35), 0, 0), PRETO, Enum.Material.Metal)
	peca(m, "Volante", V(0.12, 0.85, 0.85), C(0, yBanco + 0.72, -0.3) * CFrame.Angles(math.rad(-35), 0, 0) * CFrame.Angles(0, 0, math.rad(90)), PRETO, Enum.Material.Rubber, Enum.PartType.Cylinder)
	local seat = Instance.new("VehicleSeat")
	seat.Name = "AssentoMotorista" seat.Size = V(1.3, 0.3, 1.0) seat.Transparency = 1 seat.Anchored = true seat.CanCollide = false
	seat.CFrame = P0 * C(0, yBanco + 0.05, 0.95) seat.Parent = m
	-- estribos (onde o motorista apoia os pés) e lanternas traseiras
	for _, lx in ipairs({ -1, 1 }) do
		if not o.semEstribo then peca(m, "Estribo", V(0.4, 0.1, 0.8), C(lx * 1.35, ch + rF + 0.1, -0.25), PRETO, Enum.Material.DiamondPlate) end
		peca(m, "Lanterna", V(0.3, 0.2, 0.08), C(lx * 0.85, ch + rF + 0.7, 2.13), VERMELHO, Enum.Material.Neon)
	end
	-- rodas: traseiras grandes, dianteiras pequenas
	local largT, largF = 0.7 * (o.largRoda or 1), 0.45 * (o.largRoda or 1)
	for _, lado in ipairs({ -1, 1 }) do
		roda(m, lado < 0 and "RodaTrasEsq" or "RodaTrasDir", lado * 1.45 * s, (ch + rT) * s, 1.2 * s, 2 * rT * s, largT * s, o.aro)
		roda(m, lado < 0 and "RodaFrenteEsq" or "RodaFrenteDir", lado * 1.25 * s, (ch + rF) * s, -1.3 * s, 2 * rF * s, largF * s, o.aro)
		peca(m, "ParaLama", V(largT + 0.15, 0.15, 2 * rT * 0.9), C(lado * 1.45, ch + 2 * rT + 0.1, 1.2), o.c1)
	end
	-- plataforma de corte (deck) embaixo, com a lâmina e a calha de descarga do lado direito
	peca(m, "Deck", V(2.6, 0.3, 1.3), C(0, ch + 0.3, -0.2), o.deck or CINZA, Enum.Material.Metal)
	peca(m, "Lamina", V(2.3, 0.08, 0.4), C(0, ch + 0.15, -0.2), CROMO, Enum.Material.Metal)
	peca(m, "Descarga", V(0.6, 0.22, 0.7), C(1.55, ch + 0.28, -0.2) * CFrame.Angles(0, 0, math.rad(-15)), o.deck or CINZA, Enum.Material.Metal)
	if o.extra then o.extra(m, V, C, ch, rT, rF, yc) end
	m:SetAttribute("Veiculo", true)
	m.PrimaryPart = car
	finalizar(m)
	m.WorldPivot = P0
	return m
end

-- Mini Trator (verde, clássico de jardim) com faixa amarela no capô
dirigivel("Cortador_Trator", { c1 = Color3.fromRGB(120, 210, 70), c2 = Color3.fromRGB(36, 140, 60), aro = Color3.fromRGB(250, 214, 60),
	extra = function(m, V, C, ch, rT, rF, yc)
		for _, lx in ipairs({ -1, 1 }) do
			peca(m, "FaixaCapo", V(0.03, 0.12, 1.5), C(lx * 1.015, yc + 0.08, -1.05), Color3.fromRGB(250, 214, 60))
		end
	end })

-- Trator Off-Road: cáqui, pneus grandes com cravos, santo-antônio e faróis no teto
dirigivel("Cortador_OffRoad", { c1 = Color3.fromRGB(208, 178, 104), c2 = Color3.fromRGB(120, 92, 50), escala = 1.15, rodaT = 1.15, rodaF = 1.15, largRoda = 1.3,
	aro = Color3.fromRGB(60, 60, 64), deck = Color3.fromRGB(80, 80, 84),
	extra = function(m, V, C, ch, rT, rF)
		for _, x in ipairs({ -0.75, 0.75 }) do
			peca(m, "SantoAntonio", V(0.15, 2.2, 0.15), C(x, ch + rF + 2.1, 1.65), PRETO, Enum.Material.Metal)
		end
		peca(m, "SantoAntonioTopo", V(1.65, 0.15, 0.15), C(0, ch + rF + 3.2, 1.65), PRETO, Enum.Material.Metal)
		for _, x in ipairs({ -0.5, 0.5 }) do
			peca(m, "FarolTeto", V(0.3, 0.25, 0.2), C(x, ch + rF + 3.35, 1.6), Color3.fromRGB(255, 240, 190), Enum.Material.Neon)
		end
		for _, lado in ipairs({ -1, 1 }) do
			for i = 0, 7 do
				local a = math.rad(i * 45)
				peca(m, "Cravo", V(0.95, 0.18, 0.3), C(lado * 1.45, ch + rT + math.cos(a) * rT, 1.2 + math.sin(a) * rT) * CFrame.Angles(-a, 0, 0), PRETO, Enum.Material.Rubber)
			end
		end
		-- protetor de grade (bull bar)
		for _, x in ipairs({ -0.6, 0.6 }) do peca(m, "BullBar", V(0.12, 0.9, 0.12), C(x, ch + rF + 0.95, -2.15), PRETO, Enum.Material.Metal) end
		peca(m, "BullBarTopo", V(1.35, 0.12, 0.12), C(0, ch + rF + 1.4, -2.15), PRETO, Enum.Material.Metal)
	end })

-- Colheitadeira: amarela, plataforma com molinete na frente, cabine alta envidraçada, tanque e tubo de descarga
dirigivel("Cortador_Colheitadeira", { c1 = Color3.fromRGB(255, 220, 110), c2 = Color3.fromRGB(220, 160, 40), escala = 1.25, rodaT = 0.75, rodaF = 1.35,
	aro = Color3.fromRGB(60, 60, 64), deck = Color3.fromRGB(220, 160, 40), semParaChoque = true, semEstribo = true,
	extra = function(m, V, C, ch, rT, rF)
		local amarelo = Color3.fromRGB(240, 190, 50)
		peca(m, "Plataforma", V(3.6, 0.5, 1.1), C(0, ch + 0.4, -2.55), amarelo, Enum.Material.Metal)
		peca(m, "PlataformaFundo", V(3.6, 0.9, 0.15), C(0, ch + 0.85, -2.05), amarelo, Enum.Material.Metal)
		peca(m, "Molinete", V(3.4, 0.9, 0.9), C(0, ch + 1.25, -2.65), Color3.fromRGB(200, 60, 40), Enum.Material.Metal, Enum.PartType.Cylinder).Transparency = 0.35
		for i = 0, 3 do
			local a = math.rad(i * 90)
			peca(m, "Pente", V(3.4, 0.08, 0.08), C(0, ch + 1.25 + math.cos(a) * 0.5, -2.65 + math.sin(a) * 0.5), Color3.fromRGB(240, 240, 240), Enum.Material.Metal)
		end
		for _, x in ipairs({ -1.8, 1.8 }) do peca(m, "PontaDivisora", V(0.15, 0.6, 1.2), C(x, ch + 0.5, -2.55), amarelo, Enum.Material.Metal) end
		peca(m, "Cabine", V(1.6, 1.5, 1.5), C(0, ch + rF + 2.4, 0.6), Color3.fromRGB(150, 210, 240), Enum.Material.Glass).Transparency = 0.45
		peca(m, "CabineTeto", V(1.8, 0.2, 1.7), C(0, ch + rF + 3.2, 0.6), Color3.fromRGB(240, 240, 240))
		for _, x in ipairs({ -0.78, 0.78 }) do -- colunas da cabine
			for _, z in ipairs({ -0.12, 1.32 }) do peca(m, "CabineColuna", V(0.1, 1.5, 0.1), C(x, ch + rF + 2.4, z), PRETO, Enum.Material.Metal) end
		end
		peca(m, "GiroFlex", V(0.25, 0.2, 0.25), C(0.5, ch + rF + 3.4, 0.6), Color3.fromRGB(255, 150, 30), Enum.Material.Neon)
		peca(m, "Tanque", V(2.2, 1.1, 1.5), C(0, ch + rF + 2.0, 2.0), amarelo, Enum.Material.Metal)
		peca(m, "TanqueBorda", V(2.3, 0.12, 1.6), C(0, ch + rF + 2.58, 2.0), PRETO, Enum.Material.Metal)
		cilindroY(m, "TuboBase", 1.6 * 1.25, 0.35 * 1.25, C(1.25, ch + rF + 2.2, 2.3), CINZA, Enum.Material.Metal)
		peca(m, "Tubo", V(2.4, 0.3, 0.3), C(1.25, ch + rF + 3.0, 1.2) * CFrame.Angles(0, math.rad(90), math.rad(-8)), CINZA, Enum.Material.Metal, Enum.PartType.Cylinder)
	end })

-- Imperial GX: azul real com frisos dourados, coroa no capô, diamante e aros dourados
dirigivel("Cortador_Imperial", { c1 = Color3.fromRGB(110, 210, 255), c2 = Color3.fromRGB(50, 80, 210), escala = 1.2, aro = OURO, deck = Color3.fromRGB(40, 50, 90),
	extra = function(m, V, C, ch, rT, rF, yc)
		peca(m, "FrisoCapo", V(0.3, 0.04, 1.72), C(0, yc + 0.51, -1.05), OURO, Enum.Material.Metal)
		peca(m, "FrisoLado", V(2.45, 0.15, 4.05), C(0, ch + rF + 0.95, 0.1), OURO, Enum.Material.Metal)
		peca(m, "CoroaBase", V(0.9, 0.25, 0.5), C(0, yc + 0.62, -1.5), OURO, Enum.Material.Metal)
		for i = -1, 1 do peca(m, "CoroaPonta", V(0.18, 0.4, 0.18), C(i * 0.32, yc + 0.87, -1.5), OURO, Enum.Material.Metal) end
		local d = peca(m, "Diamante", V(0.45, 0.45, 0.45), C(0, yc - 0.1, -1.98) * CFrame.Angles(0, math.rad(45), math.rad(45)), Color3.fromRGB(180, 245, 255), Enum.Material.Glass)
		d.Transparency = 0.15
		peca(m, "Capa", V(1.3, 0.12, 1.0), C(0, ch + rF + 1.31, 0.95), Color3.fromRGB(150, 30, 50), Enum.Material.Fabric)
		peca(m, "ParaChoqueOuro", V(2.35, 0.08, 0.27), C(0, yc - 0.37, -2.05), OURO, Enum.Material.Metal)
	end })

return "ok"
