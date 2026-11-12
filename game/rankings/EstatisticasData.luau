--[[
	ServerScriptService.CorteEDescubra.EstatisticasData  [Claude 2026-11-12]
	Formato e validação de profile.Estatisticas e profile.Conquistas (PAD-07).
	  Estatisticas = { version = 1, cortes, dourados, descobertas, jardins, vendas }  (inteiros >= 0)
	  Conquistas   = { [id da conquista] = true }
]]
local D = {}
local CAMPOS = { "cortes", "dourados", "descobertas", "jardins", "vendas" }

function D.new()
	local t = { version = 1 }
	for _, k in ipairs(CAMPOS) do t[k] = 0 end
	return t
end

function D.valid(t)
	if type(t) ~= "table" or t.version ~= 1 then return false end
	for _, k in ipairs(CAMPOS) do
		local v = t[k]
		if v ~= nil and (type(v) ~= "number" or v ~= v or v < 0 or v > 1e12 or v % 1 ~= 0) then return false end
	end
	return true
end

function D.validConquistas(t)
	if type(t) ~= "table" then return false end
	local n = 0
	for k, v in pairs(t) do
		n += 1
		if type(k) ~= "string" or #k > 32 or v ~= true or n > 200 then return false end
	end
	return true
end

return D
