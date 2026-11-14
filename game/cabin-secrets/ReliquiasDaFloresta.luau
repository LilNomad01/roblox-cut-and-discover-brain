--[[
	ServerScriptService.CorteEDescubra.ReliquiasDaFloresta  [Claude 2026-11-11]
	Visual próprio para cada relíquia da floresta (antes: todas eram o mesmo pedestal cinza + placa verde).
	Só a aparência muda: id, posição, regra de revelação, prompt e recompensa continuam no GameServer.
	Sem luzes/partículas aqui: a peça começa invisível (Transparency=1) até ser revelada, e o brilho
	é feito no cliente (SegredosDaFloresta) depois da revelação.
	build(model, id, base) -> true se desenhou; base = ponto no chão.
]]
local R = {}

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local function part(parent, name, size, cf, color, material, shape)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame, p.Color = name, size, cf, color
	p.Material = material or Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local CYL, BALL = Enum.PartType.Cylinder, Enum.PartType.Ball
local VERTICAL = CFrame.Angles(0, 0, math.pi / 2)

local builders = {}

-- diário do guardião aberto sobre um toco
function builders.diario_cabana(m, b)
	part(m, "Toco", Vector3.new(1.5, 2.4, 2.4), CFrame.new(b + Vector3.new(0, .75, 0)) * VERTICAL, rgb(112, 80, 52), Enum.Material.Wood, CYL)
	part(m, "AnelToco", Vector3.new(.06, 2.0, 2.0), CFrame.new(b + Vector3.new(0, 1.52, 0)) * VERTICAL, rgb(196, 160, 110), Enum.Material.Wood, CYL)
	for _, a in ipairs({ 0, 2.1, 4.2 }) do
		part(m, "Raiz", Vector3.new(1.4, .35, .45), CFrame.new(b + Vector3.new(math.cos(a) * 1.3, .18, math.sin(a) * 1.3)) * CFrame.Angles(0, -a, math.rad(-18)), rgb(98, 70, 46), Enum.Material.Wood)
	end
	local top = b + Vector3.new(0, 1.62, 0)
	part(m, "CapaDiario", Vector3.new(1.9, .1, 1.35), CFrame.new(top) * CFrame.Angles(0, math.rad(20), 0), rgb(120, 52, 38), Enum.Material.Fabric)
	for _, s in ipairs({ -1, 1 }) do
		part(m, "PaginaDiario", Vector3.new(.85, .07, 1.2), CFrame.new(top) * CFrame.Angles(0, math.rad(20), 0) * CFrame.new(s * .44, .09, 0) * CFrame.Angles(0, 0, math.rad(-s * 7)), rgb(244, 232, 200))
	end
	part(m, "FitaDiario", Vector3.new(.08, .03, 1.3), CFrame.new(top) * CFrame.Angles(0, math.rad(20), 0) * CFrame.new(.1, .14, .2), rgb(196, 50, 40))
	part(m, "Pena", Vector3.new(.08, 1.1, .25), CFrame.new(top + Vector3.new(.7, .35, .4)) * CFrame.Angles(math.rad(50), 0, math.rad(20)), rgb(250, 248, 240))
	return true
end

-- menir com runas que brilham
function builders.pedra_runica(m, b)
	part(m, "BaseMenir", Vector3.new(2.6, .5, 2.2), CFrame.new(b + Vector3.new(0, .25, 0)), rgb(104, 106, 98), Enum.Material.Slate)
	local menir = part(m, "Menir", Vector3.new(1.7, 4.2, 1.15), CFrame.new(b + Vector3.new(0, 2.5, 0)) * CFrame.Angles(math.rad(4), 0, math.rad(-5)), rgb(128, 130, 122), Enum.Material.Slate)
	part(m, "TopoMenir", Vector3.new(1.5, 1.0, 1.0), menir.CFrame * CFrame.new(0, 2.15, 0), rgb(128, 130, 122), Enum.Material.Slate, BALL)
	part(m, "Musgo", Vector3.new(1.4, .5, 1.1), menir.CFrame * CFrame.new(.1, 2.35, 0), rgb(80, 140, 70), Enum.Material.Grass, BALL)
	local runas = { { 0, 1.1, 0 }, { -.3, .4, 0 }, { .3, .4, 0 }, { 0, -.3, 0 }, { 0, -1.0, 0 } }
	for _, face in ipairs({ -.6, .6 }) do -- runas na frente e nas costas
		for i, r in ipairs(runas) do
			local rot = i % 2 == 0 and 45 or 0
			part(m, "Runa", Vector3.new(.38, .09, .04), menir.CFrame * CFrame.new(r[1], r[2], face) * CFrame.Angles(0, 0, math.rad(rot)), rgb(103, 228, 196), Enum.Material.Neon)
			part(m, "Runa", Vector3.new(.09, .38, .04), menir.CFrame * CFrame.new(r[1], r[2], face) * CFrame.Angles(0, 0, math.rad(rot)), rgb(103, 228, 196), Enum.Material.Neon)
		end
	end
	return true
end

-- ânfora antiga da nascente, com água brilhando
function builders.reliquia_nascente(m, b)
	part(m, "PedraBase", Vector3.new(.6, 2.8, 2.8), CFrame.new(b + Vector3.new(0, .3, 0)) * VERTICAL, rgb(118, 122, 116), Enum.Material.Slate, CYL)
	local terra = rgb(186, 104, 70)
	part(m, "CorpoAnfora", Vector3.new(1.8, 2.0, 1.8), CFrame.new(b + Vector3.new(0, 1.65, 0)), terra, Enum.Material.Sand, BALL)
	part(m, "PescocoAnfora", Vector3.new(1.0, .8, .8), CFrame.new(b + Vector3.new(0, 2.85, 0)) * VERTICAL, terra, Enum.Material.Sand, CYL)
	part(m, "BocaAnfora", Vector3.new(.2, 1.1, 1.1), CFrame.new(b + Vector3.new(0, 3.3, 0)) * VERTICAL, rgb(170, 92, 60), Enum.Material.Sand, CYL)
	part(m, "AguaAnfora", Vector3.new(.06, .85, .85), CFrame.new(b + Vector3.new(0, 3.38, 0)) * VERTICAL, rgb(110, 210, 255), Enum.Material.Neon, CYL)
	for _, s in ipairs({ -1, 1 }) do
		part(m, "AlcaAnfora", Vector3.new(.22, .9, .22), CFrame.new(b + Vector3.new(s * .75, 2.7, 0)) * CFrame.Angles(0, 0, math.rad(s * 25)), terra, Enum.Material.Sand)
	end
	part(m, "FaixaAnfora", Vector3.new(.2, 1.86, 1.86), CFrame.new(b + Vector3.new(0, 1.9, 0)) * VERTICAL, rgb(236, 206, 130), Enum.Material.SmoothPlastic, CYL)
	return true
end

-- flor do orvalho de cristal
function builders.flor_do_orvalho(m, b)
	part(m, "Folhagem", Vector3.new(2.4, .8, 2.4), CFrame.new(b + Vector3.new(0, .3, 0)), rgb(70, 140, 80), Enum.Material.Grass, BALL)
	part(m, "Caule", Vector3.new(2.4, .16, .16), CFrame.new(b + Vector3.new(0, 1.5, 0)) * VERTICAL, rgb(90, 170, 100), Enum.Material.SmoothPlastic, CYL)
	for i = 0, 1 do
		part(m, "FolhaCaule", Vector3.new(.9, .08, .45), CFrame.new(b + Vector3.new(i == 0 and .4 or -.4, 1.1 + i * .5, 0)) * CFrame.Angles(0, 0, math.rad(i == 0 and 25 or -25)), rgb(96, 180, 104))
	end
	local centro = b + Vector3.new(0, 2.9, 0)
	for i = 0, 5 do
		local a = i * math.pi / 3
		local p = part(m, "PetalaCristal", Vector3.new(.75, 1.3, .32), CFrame.new(centro) * CFrame.Angles(0, a, 0) * CFrame.new(0, .15, -.6) * CFrame.Angles(math.rad(-35), 0, 0), rgb(196, 170, 255), Enum.Material.Glass)
		p.Transparency = .2
	end
	part(m, "Miolo", Vector3.new(.6, .6, .6), CFrame.new(centro + Vector3.new(0, .1, 0)), rgb(255, 236, 140), Enum.Material.Neon, BALL)
	for i = 0, 3 do
		local a = i * 1.7
		part(m, "Orvalho", Vector3.new(.2, .2, .2), CFrame.new(centro + Vector3.new(math.cos(a) * .7, -.2 + i * .1, math.sin(a) * .7)), rgb(180, 240, 255), Enum.Material.Neon, BALL)
	end
	return true
end

-- relíquia da cripta: orbe âmbar preso entre raízes
function builders.cripta_raizes_reliquia(m, b)
	part(m, "Pedestal", Vector3.new(2.6, 1.6, 2.6), CFrame.new(b + Vector3.new(0, .8, 0)), rgb(92, 90, 84), Enum.Material.Cobblestone)
	part(m, "Orbe", Vector3.new(1.2, 1.2, 1.2), CFrame.new(b + Vector3.new(0, 2.4, 0)), rgb(255, 176, 64), Enum.Material.Neon, BALL)
	for i = 0, 4 do
		local a = i * 2 * math.pi / 5
		part(m, "RaizOrbe", Vector3.new(.28, 2.2, .28), CFrame.new(b + Vector3.new(math.cos(a) * .55, 2.2, math.sin(a) * .55)) * CFrame.Angles(math.sin(a) * .5, 0, -math.cos(a) * .5), rgb(96, 68, 44), Enum.Material.Wood)
	end
	return true
end

function R.build(model, id, base)
	local f = builders[id]
	if not f then return false end
	local ok, res = pcall(f, model, base)
	if not ok then
		warn("[Relíquias] "..tostring(id)..": "..tostring(res))
		for _, c in ipairs(model:GetChildren()) do c:Destroy() end
		return false
	end
	model.PrimaryPart = model:FindFirstChildWhichIsA("BasePart")
	return res
end

return R
