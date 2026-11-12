--[[
	ServerScriptService.CorteEDescubra.AlbumServidor  [Claude 2026-11-12]
	Álbum de coleções. Regras em Shared.AlbumConfig.
	  * profile.Album = { version = 1, especies = {}, eventos = {}, paginas = {} } (salvo pelo Profiles)
	  * Segredos e ferramentas são lidos do que já existe (ForestClaimedSecrets, Raridade_<tipo>); espécies e eventos
	    são registrados aqui (uma espécie vista nunca sai do álbum, mesmo se o ajudante for solto).
	  * Página completa: paga moedas x cortador uma vez e soma BonusAlbum (+5% de grama por página).
	RemoteFunction ReplicatedStorage.AlbumAcao: "estado".
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Shared.AlbumConfig)
local PetsCat = require(RS.Shared.PetsCatalogo)
local Oficina = require(RS.Shared.OficinaConfig)
local Eventos = require(RS.Shared.EventosConfig)
local Sinal = require(script.Parent.MissoesSinal)
local Profiles = require(script.Parent.Profiles)
local Economia = require(game.ServerScriptService.Economia)

local remote = Instance.new("RemoteFunction")
remote.Name = "AlbumAcao"
remote.Parent = RS

local function dados(p)
	if not p:GetAttribute("ProfileReady") then return nil end
	local prof = Profiles.get(p)
	if not prof then return nil end
	if prof.Album == nil or not Config.valid(prof.Album) then prof.Album = { version = 1, especies = {}, eventos = {}, paginas = {} } end
	return prof.Album, prof
end

-- lista de especies em ordem de raridade
local especiesOrdem = {}
for id, e in pairs(PetsCat.Especies) do table.insert(especiesOrdem, { id = id, e = e }) end
table.sort(especiesOrdem, function(a, b)
	local ra, rb = PetsCat.Raridades[a.e.raridade].ordem, PetsCat.Raridades[b.e.raridade].ordem
	if ra ~= rb then return ra < rb end
	return a.e.nome < b.e.nome
end)

local function registroSegredos()
	return RS:FindFirstChild("SegredosDaFloresta")
end

-- itens de cada página: { id, nome, icone, tem }
local function itens(p, a)
	local out = {}
	-- segredos
	local coletados = {}
	for id in string.gmatch(p:GetAttribute("ForestClaimedSecrets") or "", "[^,]+") do coletados[id] = true end
	local seg = {}
	local reg = registroSegredos()
	if reg then
		local filhos = reg:GetChildren()
		table.sort(filhos, function(x, y) return x.Name < y.Name end)
		for _, c in ipairs(filhos) do
			local tipo = c:GetAttribute("Tipo") or c:GetAttribute("Kind")
			local nome = c:GetAttribute("Nome") or c:GetAttribute("Name")
			local rar = c:GetAttribute("Raridade")
			table.insert(seg, { id = c.Name, nome = tostring(nome or (tipo == "chest" and ("Baú " .. tostring(rar or "escondido")) or "Relíquia")),
				icone = tipo == "chest" and "📦" or "🏺", tem = coletados[c.Name] == true })
		end
	end
	out.segredos = seg
	-- ajudantes
	local aj = {}
	for _, s in ipairs(especiesOrdem) do
		table.insert(aj, { id = s.id, nome = s.e.nome, icone = s.e.icone, tem = a.especies[s.id] == true, raridade = PetsCat.Raridades[s.e.raridade].nome })
	end
	out.ajudantes = aj
	-- ferramentas
	local fe = {}
	for _, f in ipairs(Oficina.Ferramentas) do
		local n = Oficina.indice(p:GetAttribute("Raridade_" .. f.tipo) or "Comum") or 1
		for i, r in ipairs(Oficina.Raridades) do
			table.insert(fe, { id = f.tipo .. "_" .. r.id, nome = f.nome .. " " .. r.nome, icone = f.icone, tem = i <= n, raridade = r.nome })
		end
	end
	out.ferramentas = fe
	-- eventos
	local ev = {}
	for _, e in ipairs(Eventos.Eventos) do
		table.insert(ev, { id = e.id, nome = e.nome, icone = e.icone, tem = a.eventos[e.id] == true })
	end
	out.eventos = ev
	return out
end

local function contar(lista)
	local n = 0
	for _, i in ipairs(lista) do if i.tem then n += 1 end end
	return n, #lista
end

local function checar(p)
	local a, prof = dados(p)
	if not a then return end
	-- espécies que o jogador tem agora entram no álbum
	if prof.Pets and type(prof.Pets.pets) == "table" then
		for _, esp in pairs(prof.Pets.pets) do
			if type(esp) == "string" and PetsCat.Especies[esp] then a.especies[esp] = true end
		end
	end
	local it = itens(p, a)
	local completas = 0
	for _, pg in ipairs(Config.Paginas) do
		local n, total = contar(it[pg.id])
		if total > 0 and n >= total then
			completas += 1
			if not a.paginas[pg.id] then
				a.paginas[pg.id] = true
				local moedas = pg.moedas * math.max(1, tonumber(p:GetAttribute("Multiplicador")) or 1)
				Economia.AddMoedas(p, moedas)
				pcall(Economia.Notificar, p, ("📖 Página completa: %s %s! +%d moedas e +%d%% de grama para sempre."):format(
					pg.icone, pg.nome, moedas, math.floor(Config.BonusPorPagina * 100 + 0.5)), "ouro")
			end
		end
	end
	p:SetAttribute("AlbumPaginas", completas)
	p:SetAttribute("BonusAlbum", completas * Config.BonusPorPagina)
end

-- eventos: quem está online durante um evento registra o clima
local function registrarEvento(p)
	local id = workspace:GetAttribute("EventoAtual")
	if type(id) ~= "string" or id == "" then return end
	local a = dados(p)
	if a and not a.eventos[id] then
		a.eventos[id] = true
		checar(p)
	end
end
workspace:GetAttributeChangedSignal("EventoAtual"):Connect(function()
	for _, p in ipairs(Players:GetPlayers()) do task.spawn(registrarEvento, p) end
end)

Sinal.evento:Connect(function(p, tipo)
	if tipo == "ninho" or tipo == "descoberta" then task.defer(checar, p) end
end)

local function ligar(p)
	local function pronto()
		if p:GetAttribute("ProfileReady") then
			task.delay(2, function() if p.Parent then registrarEvento(p) checar(p) end end)
		end
	end
	pronto()
	p:GetAttributeChangedSignal("ProfileReady"):Connect(pronto)
	for _, nome in ipairs({ "ForestClaimedSecrets", "Raridade_CortadorUnha", "Raridade_Enxada", "Raridade_Foice", "PetsEquipados" }) do
		p:GetAttributeChangedSignal(nome):Connect(function() task.defer(checar, p) end)
	end
end
Players.PlayerAdded:Connect(ligar)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(ligar, p) end

remote.OnServerInvoke = function(p, acao)
	if acao ~= "estado" then return nil end
	local a = dados(p)
	if not a then return { erro = "Seu perfil ainda está carregando." } end
	checar(p)
	local it = itens(p, a)
	local paginas = {}
	for i, pg in ipairs(Config.Paginas) do
		local n, total = contar(it[pg.id])
		paginas[i] = { id = pg.id, nome = pg.nome, icone = pg.icone, itens = it[pg.id], n = n, total = total,
			completa = a.paginas[pg.id] == true, moedas = pg.moedas * math.max(1, tonumber(p:GetAttribute("Multiplicador")) or 1) }
	end
	return { paginas = paginas, bonus = (tonumber(p:GetAttribute("BonusAlbum")) or 0), bonusPorPagina = Config.BonusPorPagina }
end
