--[[
	ServerScriptService.CorteEDescubra.LiveConfig  [Claude 2026-11-14]
	Valores ao vivo pelo ConfigService (Creator Dashboard > Configs), sem publicar o jogo de novo.
	Se o serviço não existir, falhar ou a chave não estiver criada, vale o PADRÃO do código (o jogo segue igual).
	Chaves usadas hoje (criar no Dashboard com o mesmo nome e tipo):
	  preco_grama_mult    número  (padrão 1)    multiplica o preço de venda da grama (limite 0,1–5)
	  loja_boost_minutos  número  (padrão 30)   duração de cada boost comprado com Robux (limite 5–120)
	  evento_intervalo_mult número (padrão 1)   reservado para o ciclo de eventos
]]
local L = {}
local snap = nil

task.spawn(function()
	local ok, svc = pcall(game.GetService, game, "ConfigService")
	if not ok or not svc then return end
	local ok2, s = pcall(function() return svc:GetConfigAsync() end)
	if not ok2 or not s then return end
	snap = s
	pcall(function()
		s.UpdateAvailable:Connect(function() pcall(function() s:Refresh() end) end)
	end)
end)

function L.get(chave, padrao, min, max)
	local v = padrao
	if snap then
		local ok, valor = pcall(function() return snap:GetValue(chave) end)
		if ok and valor ~= nil and type(valor) == type(padrao) then v = valor end
	end
	if type(v) == "number" and min and max then v = math.clamp(v, min, max) end
	return v
end

return L
