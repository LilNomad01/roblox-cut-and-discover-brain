--[[
	ServerScriptService.CorteEDescubra.Analytics  [Claude 2026-11-14]
	Telemetria nativa (AnalyticsService) para o Creator Dashboard. Tudo em pcall: se a API falhar ou não
	existir, o jogo segue igual. Só no servidor.
	  * economia: moedas que entram (venda do saco) e saem (cortadores, ninhos)
	  * funil de onboarding: 1 entrou, 2 primeiro corte, 3 primeira venda, 4 primeira compra (uma vez por jogador por sessão)
	  * progressão: nível alcançado
	  * eventos: compras com Robux, ovos, boosts
]]
local Players = game:GetService("Players")
local ok, AS = pcall(game.GetService, game, "AnalyticsService")
if not ok then AS = nil end

local A = {}
local passos = {} -- [Player] = maior passo do funil já enviado nesta sessão
Players.PlayerRemoving:Connect(function(p) passos[p] = nil end)

local function tipoTransacao(nome)
	local okE, v = pcall(function() return Enum.AnalyticsEconomyTransactionType[nome].Name end)
	return okE and v or nome
end

function A.fonte(p, qtd, saldo, tipo, sku)
	if not AS or qtd <= 0 then return end
	pcall(function()
		AS:LogEconomyEvent(p, Enum.AnalyticsEconomyFlowType.Source, "Moedas", qtd, saldo, tipoTransacao(tipo or "Gameplay"), sku)
	end)
end

function A.gasto(p, qtd, saldo, tipo, sku)
	if not AS or qtd <= 0 then return end
	pcall(function()
		AS:LogEconomyEvent(p, Enum.AnalyticsEconomyFlowType.Sink, "Moedas", qtd, saldo, tipoTransacao(tipo or "Shop"), sku)
	end)
end

local NOMES_FUNIL = { "Entrou", "PrimeiroCorte", "PrimeiraVenda", "PrimeiraCompra" }
function A.funil(p, passo)
	if not AS then return end
	local ultimo = passos[p] or 0
	if passo ~= ultimo + 1 then return end -- os passos precisam vir em ordem
	passos[p] = passo
	pcall(function() AS:LogOnboardingFunnelStepEvent(p, passo, NOMES_FUNIL[passo]) end)
end

function A.nivel(p, nivel)
	if not AS then return end
	pcall(function() AS:LogProgressionEvent(p, "Nivel", Enum.AnalyticsProgressionType.Complete, nivel) end)
end

-- campo: texto opcional que vai no CustomField01 (ex.: qual item foi comprado)
function A.evento(p, nome, valor, campo)
	if not AS then return end
	pcall(function()
		local campos = campo and { [Enum.AnalyticsCustomFieldKeys.CustomField01.Name] = tostring(campo) } or nil
		AS:LogCustomEvent(p, nome, valor or 1, campos)
	end)
end

Players.PlayerAdded:Connect(function(p) A.funil(p, 1) end)
for _, p in ipairs(Players:GetPlayers()) do A.funil(p, 1) end

return A
