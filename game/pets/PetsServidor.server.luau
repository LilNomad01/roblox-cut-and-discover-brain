--[[
	ServerScriptService.CorteEDescubra.PetsServidor  [Claude 2026-11-11]
	Ajudantes do Jardim no servidor: chocar ninho (moedas), equipar/tirar, soltar, equipar os melhores.
	Tudo validado aqui; o cliente só pede (RemoteFunction ReplicatedStorage.PetsAcao).
	Efeito: atributo BonusPets (soma dos bônus equipados) que a Economia aplica na grama de cada tufo,
	e PetsEquipados (espécies, para os clientes desenharem os ajudantes seguindo o jogador).
	Os pets vivem em profile.Pets e são salvos junto com o perfil (Profiles).
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Cat = require(RS.Shared.PetsCatalogo)
local Data = require(script.Parent.PetsData)
local Profiles = require(script.Parent.Profiles)

local remote = Instance.new("RemoteFunction")
remote.Name = "PetsAcao"
remote.Parent = RS

local rng = Random.new()
local ultimo = {}

local function estado(p)
	local prof = Profiles.get(p)
	if not prof then return nil end
	if prof.Pets == nil or not Data.valid(prof.Pets) then prof.Pets = Data.new() end
	return prof.Pets
end

local function aplicar(p, s)
	p:SetAttribute("BonusPets", Data.bonus(s))
	local especies = {}
	for _, id in ipairs(s.equipados) do table.insert(especies, s.pets[id]) end
	p:SetAttribute("PetsEquipados", table.concat(especies, ","))
end

local function snapshot(s)
	local lista = {}
	for id, esp in pairs(s.pets) do
		table.insert(lista, { id = id, especie = esp, equipado = table.find(s.equipados, id) ~= nil })
	end
	return { pets = lista, equipados = #s.equipados, bonus = Data.bonus(s) }
end

local function pronto(p)
	return p:GetAttribute("ProfileReady") == true and Profiles.active(p)
end

local function ligar(p)
	local function tentar()
		if p:GetAttribute("ProfileReady") then
			local s = estado(p)
			if s then aplicar(p, s) end
		end
	end
	p:GetAttributeChangedSignal("ProfileReady"):Connect(tentar)
	tentar()
end
Players.PlayerAdded:Connect(ligar)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(ligar, p) end
Players.PlayerRemoving:Connect(function(p) ultimo[p] = nil end)

local function melhores(s)
	local ids = {}
	for id in pairs(s.pets) do table.insert(ids, id) end
	table.sort(ids, function(a, b)
		local ba, bb = Cat.bonus(s.pets[a]), Cat.bonus(s.pets[b])
		if ba ~= bb then return ba > bb end
		return tonumber(a) < tonumber(b)
	end)
	s.equipados = {}
	for i = 1, math.min(Cat.MaxEquipados, #ids) do s.equipados[i] = ids[i] end
end

remote.OnServerInvoke = function(p, acao, arg)
	if type(acao) ~= "string" or #acao > 12 then return nil end
	if not pronto(p) then return { erro = "Seu perfil ainda está carregando." } end
	local s = estado(p)
	if not s then return nil end
	if acao == "sync" then return { estado = snapshot(s) } end
	local agora = os.clock()
	if ultimo[p] and agora - ultimo[p] < 0.35 then return { erro = "Calma, um de cada vez!", estado = snapshot(s) } end
	ultimo[p] = agora

	if acao == "chocar" then
		local ninho = type(arg) == "string" and Cat.ninho(arg)
		if not ninho then return { erro = "Ninho inválido." } end
		if Data.contar(s) >= Cat.MaxInventario then
			return { erro = "Inventário cheio! Solte um ajudante primeiro.", estado = snapshot(s) }
		end
		local moedas = p:GetAttribute("Moedas") or 0
		if type(moedas) ~= "number" or moedas < ninho.preco then
			return { erro = ("Faltam %d moedas."):format(ninho.preco - (tonumber(moedas) or 0)), estado = snapshot(s) }
		end
		p:SetAttribute("Moedas", moedas - ninho.preco)
		local esp = Data.sortear(ninho, rng)
		local id = tostring(s.proximo)
		s.proximo += 1
		s.pets[id] = esp
		if #s.equipados < Cat.MaxEquipados then table.insert(s.equipados, id) end
		aplicar(p, s)
		return { novo = { id = id, especie = esp }, estado = snapshot(s) }
	elseif acao == "equipar" then
		if type(arg) ~= "string" or not s.pets[arg] then return { erro = "Ajudante inválido." } end
		local i = table.find(s.equipados, arg)
		if i then
			table.remove(s.equipados, i)
		else
			if #s.equipados >= Cat.MaxEquipados then
				return { erro = ("Máximo de %d ajudantes equipados."):format(Cat.MaxEquipados), estado = snapshot(s) }
			end
			table.insert(s.equipados, arg)
		end
		aplicar(p, s)
		return { estado = snapshot(s) }
	elseif acao == "soltar" then
		if type(arg) ~= "string" or not s.pets[arg] then return { erro = "Ajudante inválido." } end
		local i = table.find(s.equipados, arg)
		if i then table.remove(s.equipados, i) end
		s.pets[arg] = nil
		aplicar(p, s)
		return { estado = snapshot(s) }
	elseif acao == "melhores" then
		melhores(s)
		aplicar(p, s)
		return { estado = snapshot(s) }
	end
	return nil
end
