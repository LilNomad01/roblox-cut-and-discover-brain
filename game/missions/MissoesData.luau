--[[
	ServerScriptService.CorteEDescubra.MissoesData  [Claude 2026-11-12]
	Formato salvo em profile.Missoes e validação (sem efeitos colaterais).
	  { version = 1, selos = n, trilhas = { { i = missão atual (1..), c = ciclo (0..), p = progresso }, x3 } }
]]
local Config = require(script.Parent.MissoesConfig)
local D = {}

function D.new()
	local t = { version = 1, selos = 0, trilhas = {} }
	for k = 1, #Config.Trilhas do t.trilhas[k] = { i = 1, c = 0, p = 0 } end
	return t
end

local function inteiro(n, max)
	return type(n) == "number" and n == n and n >= 0 and n <= max and n % 1 == 0
end

function D.valid(t)
	if type(t) ~= "table" or t.version ~= 1 or not inteiro(t.selos, 1e7) or type(t.trilhas) ~= "table" then return false end
	for k, tr in pairs(t.trilhas) do
		if not inteiro(k, #Config.Trilhas) or k < 1 or type(tr) ~= "table" then return false end
		if not inteiro(tr.i, 64) or tr.i < 1 or not inteiro(tr.c, 1e6) or not inteiro(tr.p, 1e9) then return false end
	end
	return true
end

-- completa trilhas novas (caso uma versão futura acrescente uma) e corrige índices fora da lista
function D.normalizar(t)
	for k, def in ipairs(Config.Trilhas) do
		local tr = t.trilhas[k]
		if not tr then t.trilhas[k] = { i = 1, c = 0, p = 0 }
		elseif tr.i > #def.missoes then tr.i = 1 end
	end
	return t
end

function D.rank(selos)
	return math.min(math.floor(selos / Config.SelosPorRank), Config.RankMax)
end

return D
