--[[
	ServerScriptService.CorteEDescubra.MissoesSinal  [Claude 2026-11-12]
	Ponte pequena entre o jogo e o Quadro do Jardineiro, sem dependência circular:
	qualquer script do servidor chama  MissoesSinal.contar(player, "corte", 1)  e o MissoesServidor escuta.
	Tipos: corte, floresta, jardim, dourado, descoberta, venda, ninho.
]]
local M = {}
local evento = Instance.new("BindableEvent")
M.evento = evento.Event

function M.contar(player, tipo, qtd)
	if typeof(player) ~= "Instance" or not player:IsA("Player") or type(tipo) ~= "string" then return end
	evento:Fire(player, tipo, qtd or 1)
end

return M
