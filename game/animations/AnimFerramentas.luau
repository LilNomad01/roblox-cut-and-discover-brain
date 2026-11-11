--[[
	ReplicatedStorage.Shared.AnimFerramentas
	Animações procedurais das ferramentas manuais (sem AnimationId: nada a publicar).
	Cada animação é uma lista de poses-chave {t, ease, juntas = {Nome = CFrame}}; o trecho que
	CHEGA numa chave usa o "ease" dela. As CFrames vão no .Transform das juntas do rig R15
	(funciona com AnimationConstraint do avatar novo e com Motor6D).
	Convenção das juntas R15: frente do personagem = -Z.
	  Ombro/Quadril: +X levanta pra frente.  Cintura: -X inclina pra frente, +Y gira pra esquerda.
	  Joelho: -X dobra.  Root: translação Y abaixa o corpo.
]]
local A = {}

local function R(x: number, y: number?, z: number?): CFrame
	return CFrame.Angles(math.rad(x), math.rad(y or 0), math.rad(z or 0))
end
local function T(x: number, y: number, z: number, rx: number?, ry: number?, rz: number?): CFrame
	return CFrame.new(x, y, z) * R(rx or 0, ry, rz)
end

-- juntas: nome da junta -> peça onde ela mora no R15
A.Juntas = {
	Root = "LowerTorso", Waist = "UpperTorso", Neck = "Head",
	RightShoulder = "RightUpperArm", RightElbow = "RightLowerArm", RightWrist = "RightHand",
	LeftShoulder = "LeftUpperArm", LeftElbow = "LeftLowerArm", LeftWrist = "LeftHand",
	RightHip = "RightUpperLeg", RightKnee = "RightLowerLeg", LeftHip = "LeftUpperLeg", LeftKnee = "LeftLowerLeg",
}

-- curvas: "influência" das curvas do pedido aproximada por potências
local function inOut(t: number, k: number) -- k ~ influência (0.35 suave, 0.7 forte)
	local p = 2 + k * 2
	if t < 0.5 then return 0.5 * (2 * t) ^ p end
	return 1 - 0.5 * (2 * (1 - t)) ^ p
end
A.Ease = {
	Linear = function(t) return t end,
	InOut35 = function(t) return inOut(t, 0.35) end,
	InOut40 = function(t) return inOut(t, 0.4) end,
	CubicIn = function(t) return t * t * t end,
	Accel = function(t) return t * t end,
	CubicOut = function(t) return 1 - (1 - t) ^ 3 end,
	Out70 = function(t) return 1 - (1 - t) ^ 3.4 end,
}

-- ===== poses-base =====
-- [Claude 2026-11-11] postura de "segurar" = ferramenta APOIADA NO OMBRO (pedido do usuário, com foto de
-- referência): mão direita na frente do peito, cabo na diagonal e cabeça/lâmina atrás e acima do ombro direito.
-- Ângulos achados por busca numérica com a cinemática real do personagem e da ferramenta: nenhum ponto do
-- cabo/lâmina dentro do tronco, cabeça, pernas ou braços, e folga ≥ 1,2 stud do centro da cabeça (capacetes).
-- O "* R(0, 0, 45)" compensa o -45° que A.pose/A.Segurar somam ao ombro da enxada e da foice.
-- Estas poses mudam o início/fim dos clipes e a postura parada. A janela de contato (janela[1]..janela[2] do
-- FerramentasConfig) só mudou nos ajustes anti-atravessamento marcados nos clipes da enxada e da foice;
-- servidor (BladeSweep) e cliente usam este mesmo módulo, então o corte continua consistente.
-- A mão esquerda fica livre na postura parada (o Animador não aplica a pegada da mão esquerda ali).
local SEGURA_CABO = { RightShoulder = R(-10, -45, -100) * R(0, 0, 45), RightElbow = R(60), RightWrist = R(120, 0, -40) }
local SEGURA_FOICE = { RightShoulder = R(-35, -50, -125) * R(0, 0, 45), RightElbow = R(45), RightWrist = R(120, 0, -40) }

A.Clips = {}

-- CORTADOR DE UNHA (0,80 s): agacha bem baixo, chega com o cortador no chão, "TEC", volta.
A.Clips.CortadorUnha = {
	duracao = 0.80,
	{ t = 0, juntas = { RightShoulder = R(25), RightElbow = R(35) } },
	{ t = 0.20, ease = "InOut35", juntas = {
		Root = T(0, -0.65, 0, 8), Waist = R(-32), Neck = R(-18),
		RightHip = R(80, 0, -6), LeftHip = R(80, 0, 6), RightKnee = R(-105), LeftKnee = R(-105),
		RightShoulder = R(55), RightElbow = R(20), LeftShoulder = R(28, 0, 18), LeftElbow = R(45),
	} },
	{ t = 0.34, ease = "CubicIn", juntas = {
		Root = T(0, -0.55, 0, 10), Waist = R(-48), Neck = R(-28, 0, 6),
		RightHip = R(86, 0, -6), LeftHip = R(86, 0, 6), RightKnee = R(-112), LeftKnee = R(-112),
		RightShoulder = R(30), RightElbow = R(6), RightWrist = R(0), LeftShoulder = R(30, 0, 22), LeftElbow = R(50),
	} },
	-- "TEC": o pulso fecha e o corpo inteiro dá um tremidinho de esforço
	{ t = 0.40, ease = "Linear", juntas = {
		Root = T(0.05, -0.53, 0, 10), Waist = R(-50, 4), Neck = R(-30, 0, -8),
		RightHip = R(86, 0, -6), LeftHip = R(86, 0, 6), RightKnee = R(-112), LeftKnee = R(-112),
		RightShoulder = R(26), RightElbow = R(4), RightWrist = R(-4, 0, 18), LeftShoulder = R(34, 0, 22), LeftElbow = R(50),
	} },
	{ t = 0.45, ease = "Linear", juntas = {
		Root = T(-0.05, -0.55, 0, 10), Waist = R(-47, -4), Neck = R(-24, 0, 10),
		RightHip = R(86, 0, -6), LeftHip = R(86, 0, 6), RightKnee = R(-112), LeftKnee = R(-112),
		RightShoulder = R(30), RightElbow = R(6), RightWrist = R(8, 0, -10), LeftShoulder = R(30, 0, 22), LeftElbow = R(50),
	} },
	{ t = 0.80, ease = "Out70", juntas = { RightShoulder = R(25), RightElbow = R(35) } },
}

-- ENXADA (0,82 s): ergue com o tronco pra trás, desce rápido, contato 0,32–0,43, volta.
-- [Claude 2026-11-11] ombro/pulso corrigidos em 0,36 e 0,43: o cabo passava pelas coxas no golpe.
-- Isto muda o trajeto da lâmina (~0,85 stud em média); servidor e cliente usam este mesmo módulo.
A.Clips.Enxada = {
	duracao = 0.82,
	{ t = 0, juntas = SEGURA_CABO },
	{ t = 0.20, ease = "InOut40", juntas = {
		Waist = R(14, 6), Neck = R(6), RightShoulder = R(168, 0, -4), RightElbow = R(28),
		Root = T(0, 0.05, 0), RightHip = R(-4), LeftHip = R(6),
	} },
	{ t = 0.36, ease = "CubicIn", juntas = {
		Waist = R(-30, 4), Neck = R(-14), RightShoulder = R(47) * R(0, 30, 40), RightElbow = R(6), RightWrist = R(15, 0, -30),
		Root = T(0, -0.4, 0, -4), RightHip = R(26), LeftHip = R(18), RightKnee = R(-34), LeftKnee = R(-28),
	} },
	{ t = 0.43, ease = "Linear", juntas = {
		Waist = R(-32, 4), Neck = R(-16), RightShoulder = R(43) * R(0, 30, 40), RightElbow = R(4), RightWrist = R(15, 0, -30),
		Root = T(0, -0.45, 0, -4), RightHip = R(28), LeftHip = R(20), RightKnee = R(-36), LeftKnee = R(-30),
	} },
	{ t = 0.82, ease = "Out70", juntas = SEGURA_CABO },
}

-- FOICE (0,72 s): tronco gira pra direita (lâmina à direita), varre na frente e continua pra esquerda.
-- [Claude 2026-11-11] ombro/pulso corrigidos em 0,14/0,30/0,46: o cabo atravessava o tronco na varrida.
-- Isto muda o trajeto da lâmina (~0,87 stud em média); servidor e cliente usam este mesmo módulo.
A.Clips.Foice = {
	duracao = 0.72,
	{ t = 0, juntas = SEGURA_FOICE },
	{ t = 0.14, ease = "InOut35", juntas = {
		Root = T(0, -0.25, 0, 0, -18), Waist = R(-10, -52), Neck = R(-6, 30),
		RightShoulder = R(34, 0, 12) * R(50, 0, 30), RightElbow = R(16), RightWrist = R(-45, 0, -15), RightHip = R(10), LeftHip = R(-6), RightKnee = R(-14),
	} },
	{ t = 0.30, ease = "Accel", juntas = {
		Root = T(0, -0.4, 0, 0, -2), Waist = R(-18, -4), Neck = R(-10, 4),
		RightShoulder = R(28, 0, 2) * R(50, 0, 30), RightElbow = R(8), RightWrist = R(-45, 0, -15), RightHip = R(16), LeftHip = R(16), RightKnee = R(-20), LeftKnee = R(-20),
	} },
	{ t = 0.46, ease = "Linear", juntas = {
		Root = T(0, -0.3, 0, 0, 20), Waist = R(-12, 58), Neck = R(-6, -30),
		RightShoulder = R(34, 0, -14) * R(50, 0, 30), RightElbow = R(14), RightWrist = R(-45, 0, -15), LeftHip = R(10), RightHip = R(-6), LeftKnee = R(-14),
	} },
	{ t = 0.72, ease = "Out70", juntas = SEGURA_FOICE },
}

-- postura parada segurando cada ferramenta (fica por baixo do andar quando parado)
A.Segurar = {
	CortadorUnha = { RightShoulder = R(25), RightElbow = R(35) },
	Enxada = SEGURA_CABO,
	Foice = SEGURA_FOICE,
}

-- devolve { Junta = CFrame } no instante t (com chaves faltando = identidade)
function A.pose(nome: string, t: number): { [string]: CFrame }
	local clip = A.Clips[nome]
	if not clip then return {} end
	t = math.clamp(t, 0, clip.duracao)
	local i = 1
	while clip[i + 1] and clip[i + 1].t < t do i += 1 end
	local a, b = clip[i], clip[i + 1] or clip[i]
	local f = 0
	if b ~= a and b.t > a.t then
		f = (A.Ease[b.ease or "Linear"] or A.Ease.Linear)((t - a.t) / (b.t - a.t))
	end
	local out = {}
	for junta in pairs(A.Juntas) do
		local ca, cb = a.juntas[junta], b.juntas[junta]
		if ca or cb then
			out[junta] = (ca or CFrame.identity):Lerp(cb or CFrame.identity, f)
		end
	end
    if nome == "Enxada" or nome == "Foice" then
        out.RightShoulder = (out.RightShoulder or CFrame.identity) * R(0,0,-45)
    end
	return out
end

for _, kind in ipairs({"Enxada", "Foice"}) do
    local hold = table.clone(A.Segurar[kind])
    hold.RightShoulder = hold.RightShoulder * R(0,0,-45)
    A.Segurar[kind] = hold
end

return A
