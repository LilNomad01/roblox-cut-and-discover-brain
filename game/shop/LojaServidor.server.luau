--[[
	ServerScriptService.CorteEDescubra.LojaServidor  [Claude 2026-11-14]
	Loja com Robux: gamepasses, developer products (ProcessReceipt), ovo pago com PolicyService, boosts.
	Config em ReplicatedStorage.Shared.LojaConfig (IDs ficam nil até o dono criar os itens no Creator Dashboard).

	Efeitos viram ATRIBUTOS do jogador, lidos pelos sistemas que já existem:
	  MultMoedasLoja (Economia.Vender)   MultXPLoja (Economia.AddXP)   BoostGrama e BonusLoja (Economia.FatorGrama)
	  MultSacoLoja (Economia.RecalcularCapacidade)   VagasPetsExtra (PetsServidor)   TilesLoja e FerramentaCelestial
	  (FerramentasServer)   VenderQualquerLugar / VIP / BoostMoedasFim / BoostGramaFim / BoostXPFim (cliente)
	Compras avulsas: grava o recibo no perfil (profile.Loja) e salva ANTES de responder PurchaseGranted.
	Teste no Studio sem IDs (só no Studio): atributo do jogador "LojaTestePasses" = "DobroMoedas,VIP"
	e BindableFunction LojaServidor.TesteProduto:Invoke(player, "BoostMoedas").
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local PolicyService = game:GetService("PolicyService")

local Cfg = require(RS.Shared.LojaConfig)
local PetsCat = require(RS.Shared.PetsCatalogo)
local PetsData = require(script.Parent.PetsData)
local Profiles = require(script.Parent.Profiles)
local Data = require(script.Parent.LojaData)
local Analytics = require(script.Parent.Analytics)
local LiveConfig = require(script.Parent.LiveConfig)
local Economia = require(game.ServerScriptService.Economia)

local remote = Instance.new("RemoteFunction")
remote.Name = "LojaAcao"
remote.Parent = RS

local passes = {} -- [Player] = { [chave] = true }
local restrito = {} -- [Player] = bool (itens aleatórios pagos restritos)
local ultimo = {}
local rng = Random.new()

local function estado(p)
	local prof = Profiles.get(p)
	if not prof then return nil end
	if prof.Loja == nil or not Data.valid(prof.Loja) then prof.Loja = Data.new() end
	return prof.Loja
end

local function pronto(p)
	return p:GetAttribute("ProfileReady") == true and Profiles.active(p)
end

local function velocidade(p)
	local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local mult = tonumber(p:GetAttribute("VelocidadeLoja")) or 1
	hum.WalkSpeed = 16 * mult
end

local function tagVIP(p)
	local head = p.Character and p.Character:FindFirstChild("Head")
	local velha = head and head:FindFirstChild("TagVIP")
	if not p:GetAttribute("VIP") then
		if velha then velha:Destroy() end
		return
	end
	if not head or velha then return end
	local bb = Instance.new("BillboardGui")
	bb.Name = "TagVIP"
	bb.Size = UDim2.fromOffset(90, 26)
	bb.StudsOffset = Vector3.new(0, 3.2, 0)
	bb.AlwaysOnTop = false
	bb.MaxDistance = 80
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundColor3 = Color3.fromRGB(255, 196, 40)
	t.Text = "👑 VIP"
	t.Font = Enum.Font.FredokaOne
	t.TextScaled = true
	t.TextColor3 = Color3.new(1, 1, 1)
	t.TextStrokeTransparency = 0.2
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 8) c.Parent = t
	t.Parent = bb
	bb.Parent = head
end

local function aplicar(p)
	local s = estado(p)
	if not s then return end
	local own = passes[p] or {}
	local agora = os.time()
	p:SetAttribute("MultMoedasLoja", (own.DobroMoedas and 2 or 1) * (Data.ativo(s, "moedas", agora) and 2 or 1))
	p:SetAttribute("MultXPLoja", Data.ativo(s, "xp", agora) and 2 or 1)
	p:SetAttribute("BoostGrama", Data.ativo(s, "grama", agora) and 2 or 1)
	p:SetAttribute("BoostMoedasFim", s.boosts.moedas or 0)
	p:SetAttribute("BoostGramaFim", s.boosts.grama or 0)
	p:SetAttribute("BoostXPFim", s.boosts.xp or 0)
	p:SetAttribute("MultSacoLoja", own.SacoGigante and 2 or 1)
	p:SetAttribute("VagasPetsExtra", own.MaisAjudantes and 2 or 0)
	p:SetAttribute("VenderQualquerLugar", own.VenderEmQualquerLugar == true)
	p:SetAttribute("TilesLoja", own.FerramentasCelestiais and 2 or 0)
	p:SetAttribute("FerramentaCelestial", own.FerramentasCelestiais == true)
	p:SetAttribute("BonusLoja", (own.FerramentasCelestiais and 0.5 or 0) + (own.VIP and 0.1 or 0))
	p:SetAttribute("VelocidadeLoja", own.CorridaRapida and 1.3 or 1)
	p:SetAttribute("VIP", own.VIP == true)
	local lista = {}
	for k in pairs(own) do table.insert(lista, k) end
	table.sort(lista)
	p:SetAttribute("PassesLoja", table.concat(lista, ","))
	Economia.RecalcularCapacidade(p)
	velocidade(p)
	tagVIP(p)
end

local function carregarPasses(p)
	local own = {}
	for _, ps in ipairs(Cfg.Passes) do
		if ps.id then
			local ok, tem = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, p.UserId, ps.id)
			if ok and tem then own[ps.chave] = true end
		end
	end
	if RunService:IsStudio() then
		for chave in string.gmatch(tostring(p:GetAttribute("LojaTestePasses") or ""), "[^,]+") do
			if Cfg.passe(chave) then own[chave] = true end
		end
	end
	passes[p] = own
end

local function carregarPolitica(p)
	local ok, info = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, p)
	-- sem resposta = trata como restrito (o lado seguro): o ovo some e fica a compra direta
	restrito[p] = not ok or not info or info.ArePaidRandomItemsRestricted ~= false
	p:SetAttribute("OvosPagosRestritos", restrito[p])
end

local function ligar(p)
	task.spawn(carregarPolitica, p)
	local function tentar()
		if not p:GetAttribute("ProfileReady") then return end
		carregarPasses(p)
		aplicar(p)
	end
	p:GetAttributeChangedSignal("ProfileReady"):Connect(tentar)
	p:GetAttributeChangedSignal("LojaTestePasses"):Connect(tentar)
	p.CharacterAdded:Connect(function()
		task.delay(0.6, function() velocidade(p) tagVIP(p) end)
	end)
	tentar()
end
Players.PlayerAdded:Connect(ligar)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(ligar, p) end
Players.PlayerRemoving:Connect(function(p) passes[p] = nil restrito[p] = nil ultimo[p] = nil end)

-- gamepass comprado durante a partida
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, id, comprou)
	if not comprou then return end
	local ps = Cfg.passePorId(id)
	if not ps then return end
	passes[p] = passes[p] or {}
	passes[p][ps.chave] = true
	aplicar(p)
	Economia.Notificar(p, ps.icone .. " " .. ps.nome .. " ativado! Obrigado pelo apoio.", "ouro")
	Analytics.evento(p, "PasseComprado", 1, ps.chave)
end)

-- entrega pets pelo PetsServidor (BindableFunction criada por ele)
local function darPet(p, especie)
	local f = script.Parent:FindFirstChild("PetsServidor") and script.Parent.PetsServidor:WaitForChild("DarPet", 10)
	if not f then return false, "sistema de ajudantes indisponível" end
	local ok, res = pcall(f.Invoke, f, p, especie)
	if not ok then return false, tostring(res) end
	return res == true, res ~= true and tostring(res) or nil
end

local function entregar(p, prod, s)
	local agora = os.time()
	if prod.boost then
		local minutos = LiveConfig.get("loja_boost_minutos", Cfg.BoostMinutos, 5, 120)
		Data.somarBoost(s, prod.boost, minutos * 60, agora, Cfg.BoostMaxMinutos * 60)
		aplicar(p)
		Economia.Notificar(p, prod.icone .. " " .. prod.nome .. " ativado!", "ouro")
		return true
	elseif prod.ovo then
		local ovo = PetsCat.OvosRobux and PetsCat.OvosRobux[prod.ovo]
		if not ovo then return false, "ovo inválido" end
		-- jogador restrito nunca recebe sorte paga: recebe um resultado fixo (Lendário)
		local especie = restrito[p] == false and PetsData.sortear(ovo, rng) or ovo.garantidoRestrito
		local ok, erro = darPet(p, especie)
		if not ok then return false, erro end
		s.ovos += 1
		local e = PetsCat.Especies[especie]
		Economia.Notificar(p, ("🥚 Ovo Celestial: %s %s (%s)!"):format(e.icone, e.nome, PetsCat.raridade(especie).nome), "ouro")
		Analytics.evento(p, "OvoCelestial", 1, especie)
		return true
	elseif prod.pet then
		local ok, erro = darPet(p, prod.pet)
		if not ok then return false, erro end
		local e = PetsCat.Especies[prod.pet]
		Economia.Notificar(p, ("%s %s chegou para ajudar!"):format(e.icone, e.nome), "ouro")
		return true
	elseif prod.materiais then
		local prof = Profiles.get(p)
		if not prof then return false, "perfil" end
		local d = prof.Ferramentas
		if type(d) ~= "table" or type(d.materiais) ~= "table" then
			d = { version = 1, nivel = {}, materiais = { fibra = 0, cristal = 0, po = 0 } }
			prof.Ferramentas = d
		end
		for mat, qtd in pairs(prod.materiais) do
			d.materiais[mat] = (d.materiais[mat] or 0) + qtd
			p:SetAttribute("Mat_" .. mat, d.materiais[mat])
		end
		Economia.Notificar(p, "🧰 Pacote da Oficina entregue!", "ouro")
		return true
	end
	return false, "produto sem efeito"
end

local function processar(p, prod, purchaseId)
	if not pronto(p) then return false end
	local s = estado(p)
	if not s then return false end
	if Data.temRecibo(s, purchaseId) then return true end
	local ok, erro = entregar(p, prod, s)
	if not ok then
		Economia.Notificar(p, "Não deu para entregar agora (" .. tostring(erro) .. "). Vamos tentar de novo.", "erro")
		return false
	end
	Data.registrar(s, purchaseId)
	Analytics.evento(p, "CompraRobux", 1, prod.chave)
	return Profiles.save(p) == true
end

MarketplaceService.ProcessReceipt = function(info)
	local p = Players:GetPlayerByUserId(info.PlayerId)
	local prod = Cfg.produtoPorId(info.ProductId)
	if not p or not prod then return Enum.ProductPurchaseDecision.NotProcessedYet end
	local ok, granted = pcall(processar, p, prod, tostring(info.PurchaseId))
	if ok and granted then return Enum.ProductPurchaseDecision.PurchaseGranted end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- boosts que acabam: recalcula os atributos quando o conjunto de boosts ativos muda
local chaveBoosts = {}
Players.PlayerRemoving:Connect(function(p) chaveBoosts[p] = nil end)
task.spawn(function()
	while true do
		task.wait(5)
		local agora = os.time()
		for _, p in ipairs(Players:GetPlayers()) do
			local s = pronto(p) and estado(p)
			if s then
				local k = tostring(Data.ativo(s, "moedas", agora)) .. tostring(Data.ativo(s, "grama", agora)) .. tostring(Data.ativo(s, "xp", agora))
				if chaveBoosts[p] ~= nil and chaveBoosts[p] ~= k then aplicar(p) end
				chaveBoosts[p] = k
			end
		end
	end
end)

remote.OnServerInvoke = function(p, acao)
	if type(acao) ~= "string" or #acao > 16 then return nil end
	if not pronto(p) then return { erro = "Seu perfil ainda está carregando." } end
	local agora = os.clock()
	if ultimo[p] and agora - ultimo[p] < 0.3 then return { erro = "Calma!" } end
	ultimo[p] = agora
	local s = estado(p)
	if acao == "sync" then
		return { passes = passes[p] or {}, restrito = restrito[p] ~= false, boosts = s and s.boosts or {}, agora = os.time() }
	elseif acao == "vender" then
		if not (passes[p] or {}).VenderEmQualquerLugar then return { erro = "Precisa da Caçamba de Bolso." } end
		local ganho = Economia.Vender(p)
		return { ganho = ganho }
	end
	return nil
end

-- teste no Studio sem IDs: simula a compra de um produto (recibo falso, mesmo caminho do ProcessReceipt)
if RunService:IsStudio() then
	local teste = Instance.new("BindableFunction")
	teste.Name = "TesteProduto"
	teste.OnInvoke = function(p, chave)
		local prod = Cfg.produto(chave)
		if not prod then return "produto inválido" end
		local ok, res = pcall(processar, p, prod, "teste-" .. game:GetService("HttpService"):GenerateGUID(false))
		return ok and res or tostring(res)
	end
	teste.Parent = script
end
