--[[
	ServerScriptService.CorteEDescubra.RecompensasData  [Claude 2026-11-11]
	Regras puras da extensão profile.Recompensas (salva com o perfil):
	  { version = 1, ultimoDia = <dia UTC do último prêmio diário>, sequencia = <dias seguidos>, codigos = { CODIGO = true } }
]]
local D = {}

local function int(v, max)
	return type(v) == "number" and v == v and v >= 0 and v <= max and v % 1 == 0
end

function D.new()
	return { version = 1, ultimoDia = 0, sequencia = 0, codigos = {} }
end

function D.valid(s)
	if type(s) ~= "table" or s.version ~= 1 or not int(s.ultimoDia, 10000000) or not int(s.sequencia, 100000) then return false end
	if type(s.codigos) ~= "table" then return false end
	local n = 0
	for k, v in pairs(s.codigos) do
		n += 1
		if n > 200 or type(k) ~= "string" or #k > 24 or v ~= true then return false end
	end
	return true
end

function D.hoje(agora)
	return math.floor((agora or os.time()) / 86400)
end

-- devolve: pode coletar?, sequência que ficará depois de coletar
function D.diaria(s, hoje)
	if s.ultimoDia >= hoje then return false, s.sequencia end
	if s.ultimoDia == hoje - 1 then return true, s.sequencia + 1 end
	return true, 1
end

function D.indiceDia(sequencia, dias)
	return ((math.max(sequencia, 1) - 1) % dias) + 1
end

return D
