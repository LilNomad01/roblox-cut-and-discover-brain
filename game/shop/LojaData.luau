--[[
	ServerScriptService.CorteEDescubra.LojaData  [Claude 2026-11-14]
	Regras puras do bloco da loja salvo no perfil (profile.Loja):
	  { version = 1, recibos = { "<PurchaseId>", ... (últimos 100) }, boosts = { moedas = <unix>, grama = <unix>, xp = <unix> }, ovos = <n> }
	Os recibos garantem que uma compra NUNCA é entregue duas vezes (o Roblox reenvia o ProcessReceipt até receber
	PurchaseGranted).
]]
local D = {}
D.MaxRecibos = 100
local BOOSTS = { moedas = true, grama = true, xp = true }

function D.new()
	return { version = 1, recibos = {}, boosts = {}, ovos = 0 }
end

local function inteiro(v, max)
	return type(v) == "number" and v == v and v % 1 == 0 and v >= 0 and v <= max
end

function D.valid(s)
	if type(s) ~= "table" or s.version ~= 1 or type(s.recibos) ~= "table" or type(s.boosts) ~= "table" then return false end
	if not inteiro(s.ovos, 1e9) then return false end
	local n = 0
	for k, v in pairs(s.recibos) do
		n += 1
		if type(k) ~= "number" or type(v) ~= "string" or #v > 64 then return false end
	end
	if n > D.MaxRecibos or n ~= #s.recibos then return false end
	for k, v in pairs(s.boosts) do
		if not BOOSTS[k] or not inteiro(v, 4e9) then return false end
	end
	return true
end

function D.temRecibo(s, id)
	return table.find(s.recibos, id) ~= nil
end

function D.registrar(s, id)
	table.insert(s.recibos, id)
	while #s.recibos > D.MaxRecibos do table.remove(s.recibos, 1) end
end

-- soma tempo ao boost (começa de agora se já tinha acabado), com teto
function D.somarBoost(s, tipo, segundos, agora, teto)
	local atual = math.max(agora, s.boosts[tipo] or 0)
	s.boosts[tipo] = math.min(atual + segundos, agora + teto)
end

function D.ativo(s, tipo, agora)
	return (s.boosts[tipo] or 0) > agora
end

return D
