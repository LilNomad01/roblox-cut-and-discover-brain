--[[
	ServerScriptService.CorteEDescubra.ServicosJardim  [Claude 2026-11-12]
	Serviços de jardim em níveis (MON-04): o jogador escolhe o CLIENTE do próximo jardim no jardineiro do lote.
	  Casinha (padrão) → Sítio → Mansão → Praça, liberados por nível.
	  * pagamento: bônus em moedas ao concluir (x multiplicador do cortador x precisão)
	  * grama: bônus de grama enquanto o jardim do cliente está ativo (BonusServico, somado na Economia.FatorGrama)
	  * canteiros: quadrados com flores que NÃO são grama (já começam "cortados"). Passar o carrinho por cima
	    pisa as flores: cada canteiro pisado tira 20% do pagamento (mínimo 20%). Ferramentas manuais não pisam.
	Chamado pelo GameServer: preparar(s, setTileCut) no resetJob, aoPassar(player, s, prev, here, alcance) no corte
	do carrinho, aoConcluir(player, s) no bônus de jardim completo, e ligar(api) para trocar de cliente na hora.
	Escolha salva em profile.Servicos = { version = 1, escolhido = id }.
	RemoteFunction ReplicatedStorage.ServicoAcao: "estado" | "escolher" (id).
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Economia = require(game.ServerScriptService.Economia)

local M = {}

M.Clientes = {
	{ id = "casinha", nome = "Casinha", icone = "🏠", nivel = 1, pagamento = 0, canteiros = 0, grama = 0,
		texto = "O jardim de sempre. Sem canteiros." },
	{ id = "sitio", nome = "Sítio", icone = "🐓", nivel = 4, pagamento = 150, canteiros = 3, grama = 0.15,
		texto = "3 canteiros de flores. Grama +15%." },
	{ id = "mansao", nome = "Mansão", icone = "🏰", nivel = 8, pagamento = 400, canteiros = 5, grama = 0.35,
		texto = "5 canteiros de flores. Grama +35%." },
	{ id = "praca", nome = "Praça", icone = "⛲", nivel = 14, pagamento = 1000, canteiros = 8, grama = 0.6,
		texto = "8 canteiros de flores. Grama +60%." },
}
M.PenaPorCanteiro = 0.2
M.PrecisaoMinima = 0.2

local porId = {}
for _, c in ipairs(M.Clientes) do porId[c.id] = c end

local rng = Random.new()
local api = nil -- { sessao = fn(player) -> s, reiniciar = fn(player) }

function M.valid(t)
	return type(t) == "table" and t.version == 1 and type(t.escolhido) == "string" and porId[t.escolhido] ~= nil
end

local function dono(s)
	local uid = s.plot and s.plot:GetAttribute("OwnerUserId")
	local p = uid and Players:GetPlayerByUserId(uid)
	if p and api and api.sessao(p) == s then return p end
	return nil
end

local function nivelDe(p, s)
	if p then return tonumber(p:GetAttribute("Nivel")) or 1 end
	return (s.profile and s.profile.Economy and tonumber(s.profile.Economy.Nivel)) or 1
end

local function escolhido(s, nivel)
	local d = s.profile and s.profile.Servicos
	local c = d and M.valid(d) and porId[d.escolhido] or M.Clientes[1]
	if nivel < c.nivel then c = M.Clientes[1] end
	return c
end

---------------------------------------------------------------- visual dos canteiros
local CORES = { Color3.fromRGB(240, 90, 120), Color3.fromRGB(255, 210, 70), Color3.fromRGB(170, 110, 230), Color3.fromRGB(255, 150, 60), Color3.fromRGB(250, 250, 250) }

local function pastaCanteiros(plot)
	local f = plot:FindFirstChild("Canteiros")
	if not f then
		f = Instance.new("Folder")
		f.Name = "Canteiros"
		f.Parent = plot
	end
	return f
end

local function criarCanteiro(pasta, tile, id)
	local m = Instance.new("Model")
	m.Name = "Canteiro_" .. id
	local terra = Instance.new("Part")
	terra.Name = "Terra"
	terra.Anchored = true terra.CanCollide = false terra.CanQuery = false terra.CanTouch = false
	terra.Size = Vector3.new(3.4, 0.35, 3.4)
	terra.Color = Color3.fromRGB(110, 72, 44)
	terra.Material = Enum.Material.Ground
	local base = tile.Position - Vector3.new(0, tile.Size.Y / 2, 0)
	terra.CFrame = CFrame.new(base + Vector3.new(0, 0.3, 0))
	terra.Parent = m
	for i = 1, 6 do
		local f = Instance.new("Part")
		f.Name = "Flor"
		f.Shape = Enum.PartType.Ball
		f.Anchored = true f.CanCollide = false f.CanQuery = false f.CanTouch = false
		f.Size = Vector3.new(0.75, 0.75, 0.75)
		f.Color = CORES[rng:NextInteger(1, #CORES)]
		f.Material = Enum.Material.SmoothPlastic
		f.CFrame = CFrame.new(base + Vector3.new(rng:NextNumber(-1.2, 1.2), 0.85, rng:NextNumber(-1.2, 1.2)))
		f.Parent = m
	end
	m:SetAttribute("Pisado", false)
	m.Parent = pasta
	return m
end

local function murchar(pasta, id)
	local m = pasta:FindFirstChild("Canteiro_" .. id)
	if not m then return end
	m:SetAttribute("Pisado", true)
	for _, f in ipairs(m:GetChildren()) do
		if f.Name == "Flor" then
			f.Color = Color3.fromRGB(120, 96, 60)
			f.Size = Vector3.new(0.6, 0.25, 0.6)
			f.CFrame = f.CFrame - Vector3.new(0, 0.45, 0)
		end
	end
end

---------------------------------------------------------------- ganchos do GameServer
function M.preparar(s, setTileCut)
	if not s or not s.job or not s.plot then return end
	local p = dono(s)
	local c = escolhido(s, nivelDe(p, s))
	local pasta = pastaCanteiros(s.plot)
	pasta:ClearAllChildren()
	s.job.servico = c.id
	s.job.canteiros = {}
	s.job.pisados = 0
	local livres = {}
	for id = 1, 64 do
		local row, col = math.floor((id - 1) / 8) + 1, (id - 1) % 8 + 1
		local tile = s.plot.GrassVisuals:FindFirstChild(string.format("Grass_%02d_%02d", row, col))
		if tile and not tile:GetAttribute("Dourado") then table.insert(livres, { id = id, tile = tile }) end
	end
	local Rules = require(script.Parent.Rules)
	for _ = 1, math.min(c.canteiros, #livres) do
		local e = table.remove(livres, rng:NextInteger(1, #livres))
		-- canteiro não é grama: conta como já feito para o jardim fechar em 64
		if Rules.cut(s.profile, s.job, e.id) then
			s.job.canteiros[e.id] = false -- false = flores intactas
			if setTileCut then setTileCut(e.tile, true) end
			criarCanteiro(pasta, e.tile, e.id)
		end
	end
	if p then
		p:SetAttribute("ServicoAtual", c.id)
		p:SetAttribute("BonusServico", c.grama)
	end
end

function M.aoPassar(player, s, prev, here, alcance)
	local cs = s and s.job and s.job.canteiros
	if not cs or s.job.finished then return end
	local limite = alcance * 0.6
	for id, pisado in pairs(cs) do
		if not pisado then
			local row, col = math.floor((id - 1) / 8) + 1, (id - 1) % 8 + 1
			local c = Vector2.new(-18 + col * 4, -18 + row * 4)
			local ab = here - prev
			local t = ab.Magnitude > 0 and math.clamp((c - prev):Dot(ab) / ab:Dot(ab), 0, 1) or 0
			if (c - (prev + ab * t)).Magnitude <= limite then
				cs[id] = true
				s.job.pisados += 1
				murchar(pastaCanteiros(s.plot), id)
				local cli = porId[s.job.servico]
				local prec = math.max(M.PrecisaoMinima, 1 - M.PenaPorCanteiro * s.job.pisados)
				pcall(Economia.Notificar, player, ("🌼 Opa! Você passou por cima de um canteiro. Pagamento do cliente: %d%%"):format(math.floor(prec * 100 + 0.5)), "erro")
				if cli then player:SetAttribute("ServicoPrecisao", prec) end
			end
		end
	end
end

function M.aoConcluir(player, s)
	local c = s and s.job and porId[s.job.servico]
	if not c or c.pagamento <= 0 then return end
	local prec = math.max(M.PrecisaoMinima, 1 - M.PenaPorCanteiro * (s.job.pisados or 0))
	local moedas = math.floor(c.pagamento * math.max(1, tonumber(player:GetAttribute("Multiplicador")) or 1) * prec)
	Economia.AddMoedas(player, moedas)
	local perfeito = (s.job.pisados or 0) == 0
	pcall(Economia.Notificar, player, ("%s Cliente %s satisfeito: +%d moedas%s"):format(c.icone, c.nome, moedas,
		perfeito and " · trabalho perfeito, nenhum canteiro pisado!" or (" · precisão %d%%"):format(math.floor(prec * 100 + 0.5))), "ouro")
end

function M.ligar(gameApi)
	api = gameApi
end

---------------------------------------------------------------- remote
local remote = Instance.new("RemoteFunction")
remote.Name = "ServicoAcao"
remote.Parent = RS
local ultimo = {}
Players.PlayerRemoving:Connect(function(p) ultimo[p] = nil end)

local function estado(p, s)
	local nivel = tonumber(p:GetAttribute("Nivel")) or 1
	local mult = math.max(1, tonumber(p:GetAttribute("Multiplicador")) or 1)
	local lista = {}
	for i, c in ipairs(M.Clientes) do
		lista[i] = { id = c.id, nome = c.nome, icone = c.icone, nivel = c.nivel, liberado = nivel >= c.nivel,
			pagamento = c.pagamento * mult, canteiros = c.canteiros, grama = c.grama, texto = c.texto }
	end
	return { clientes = lista, escolhido = escolhido(s, nivel).id, atual = s.job and s.job.servico or "casinha",
		pisados = s.job and s.job.pisados or 0 }
end

remote.OnServerInvoke = function(p, acao, arg)
	if type(acao) ~= "string" or not api then return nil end
	local s = api.sessao(p)
	if not s then return { erro = "Seu jardim ainda está carregando." } end
	if acao == "estado" then return { estado = estado(p, s) } end
	if acao ~= "escolher" then return nil end
	local agora = os.clock()
	if ultimo[p] and agora - ultimo[p] < 0.8 then return { erro = "Calma, um de cada vez!", estado = estado(p, s) } end
	ultimo[p] = agora
	local c = type(arg) == "string" and porId[arg]
	if not c then return { erro = "Cliente inválido." } end
	if (tonumber(p:GetAttribute("Nivel")) or 1) < c.nivel then
		return { erro = ("Libera no nível %d."):format(c.nivel), estado = estado(p, s) }
	end
	s.profile.Servicos = { version = 1, escolhido = c.id }
	-- jardim ainda intocado (só canteiros "cortados"): troca o cliente na hora
	local reais = (s.job.cutCount or 0)
	for _ in pairs(s.job.canteiros or {}) do reais -= 1 end
	if reais <= 0 and not s.job.finished then
		api.reiniciar(p)
		return { ok = "agora", estado = estado(p, s) }
	end
	return { ok = "proximo", estado = estado(p, s) }
end

return M
