--[[
	ReplicatedStorage.Shared.LojaConfig  [Claude 2026-11-14]
	Pedido do usuário: "implemente todas as APIS, o jogo será para mais velhos então pode colocar venda de ovo com
	pets mais fortes por robux, venda de ferramentas mais fortes, tudo que ver em outros jogos que possa facilitar a
	jogabilidade por um valor externo".

	IDs: TODOS ficam nil. Gamepasses e Developer Products são criados PELO DONO no Creator Dashboard
	(Monetization > Passes / Developer Products) e o número é colado aqui. Sem id, o item aparece como
	"Em breve" e nada é cobrado. Preço: lido do Roblox (GetProductInfo); "precoBase" é só a sugestão para criar.

	Regras do Roblox respeitadas:
	  * Ovo pago = item aleatório pago: chances numéricas visíveis antes da compra (somam 100%) e
	    PolicyService.ArePaidRandomItemsRestricted -> o ovo some para esse jogador e aparece a compra direta
	    (resultado garantido) no lugar.
	  * Compras avulsas: ProcessReceipt grava a entrega no perfil (recibo) antes de confirmar.
	  * Sem escassez falsa, sem "acaba em X minutos" de mentira.
]]
local C = {}

-- Gamepasses (compra única, permanente)
C.Passes = {
	{ chave = "DobroMoedas", id = nil, precoBase = 399, icone = "💰", nome = "Moedas em Dobro",
		desc = "Toda venda de grama rende 2x moedas, para sempre." },
	{ chave = "SacoGigante", id = nil, precoBase = 249, icone = "🎒", nome = "Saco Gigante",
		desc = "O saco guarda 2x mais grama em todos os cortadores." },
	{ chave = "MaisAjudantes", id = nil, precoBase = 299, icone = "🐾", nome = "+2 Ajudantes",
		desc = "Equipe 5 ajudantes ao mesmo tempo (em vez de 3)." },
	{ chave = "VenderEmQualquerLugar", id = nil, precoBase = 199, icone = "📦", nome = "Caçamba de Bolso",
		desc = "Botão para vender o saco de qualquer lugar do mapa." },
	{ chave = "FerramentasCelestiais", id = nil, precoBase = 499, icone = "🌟", nome = "Ferramentas Celestiais",
		desc = "Unha, Enxada e Foice com aura celestial: +50% de grama e +2 quadrados por golpe, em qualquer raridade." },
	{ chave = "CorridaRapida", id = nil, precoBase = 149, icone = "👟", nome = "Corrida Rápida",
		desc = "+30% de velocidade andando e correndo." },
	{ chave = "VIP", id = nil, precoBase = 299, icone = "👑", nome = "Jardineiro VIP",
		desc = "Placa VIP dourada, etiqueta [VIP] no chat e +10% de grama." },
}

-- Developer Products (compra repetível)
C.Produtos = {
	{ chave = "BoostMoedas", id = nil, precoBase = 49, icone = "⚡", nome = "Moedas x2 (30 min)",
		desc = "Dobra as moedas das vendas por 30 minutos. Soma tempo se comprar de novo.", boost = "moedas" },
	{ chave = "BoostGrama", id = nil, precoBase = 49, icone = "🌿", nome = "Grama x2 (30 min)",
		desc = "Dobra a grama de cada corte por 30 minutos.", boost = "grama" },
	{ chave = "BoostXP", id = nil, precoBase = 29, icone = "⭐", nome = "XP x2 (30 min)",
		desc = "Dobra o XP por 30 minutos.", boost = "xp" },
	{ chave = "OvoCelestial", id = nil, precoBase = 99, icone = "🥚", nome = "Ovo Celestial",
		desc = "Choca um ajudante forte (Lendário ou melhor). Veja as chances antes de comprar.", ovo = "celestial" },
	{ chave = "FenixGarantida", id = nil, precoBase = 399, icone = "🔥", nome = "Fênix do Jardim (garantida)",
		desc = "Compra direta, sem sorte: um ajudante Celestial (+250% de grama).", pet = "fenix" },
	{ chave = "PacoteMateriais", id = nil, precoBase = 79, icone = "🧰", nome = "Pacote da Oficina",
		desc = "100 Fibras, 10 Cristais e 10 Pós Dourados para evoluir ferramentas.",
		materiais = { fibra = 100, cristal = 10, po = 10 } },
}

-- Assinatura mensal (Subscriptions): criada pelo dono em Monetization > Subscriptions; o id é texto ("EXP-...")
C.Assinatura = { chave = "ClubeJardineiro", id = nil, icone = "🌻", nome = "Clube do Jardineiro (mensal)",
	desc = "Enquanto assinar: +25% de grama em todo corte. Cancela quando quiser." }

C.BoostMinutos = 30 -- padrão; pode ser trocado ao vivo pelo ConfigService ("loja_boost_minutos")
C.BoostMaxMinutos = 600 -- teto de tempo acumulado por boost

function C.passe(chave)
	for _, p in ipairs(C.Passes) do if p.chave == chave then return p end end
	return nil
end
function C.produto(chave)
	for _, p in ipairs(C.Produtos) do if p.chave == chave then return p end end
	return nil
end
function C.produtoPorId(id)
	for _, p in ipairs(C.Produtos) do if p.id ~= nil and p.id == id then return p end end
	return nil
end
function C.passePorId(id)
	for _, p in ipairs(C.Passes) do if p.id ~= nil and p.id == id then return p end end
	return nil
end

return C
