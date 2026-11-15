--[[
	ServerScriptService.CorteEDescubra.FamaServidor  [Claude 2026-11-12]
	"Fama de Jardineiro" — renascimento (MON-05). Regras em Shared.FamaConfig.
	RemoteFunction ReplicatedStorage.FamaAcao: "estado" | "renascer".
	Guarda profile.Fama = { version = 1, estrelas = n } (salvo pelo Profiles; Economy é capturada dos atributos).
	Atributos: FamaEstrelas, BonusFama (Economia.FatorGrama). Visual: estrela sobre a cabeça e coluna "Fama" no placar.
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Shared.FamaConfig)
local ConfigJogo = require(RS.ConfigJogo)
local Profiles = require(script.Parent.Profiles)
local Economia = require(game.ServerScriptService.Economia)

local remote = Instance.new("RemoteFunction")
remote.Name = "FamaAcao"
remote.Parent = RS

local ocupado = {}

local function dados(p)
	if not p:GetAttribute("ProfileReady") then return nil end
	local prof = Profiles.get(p)
	if not prof then return nil end
	if prof.Fama == nil or not Config.valid(prof.Fama) then prof.Fama = { version = 1, estrelas = 0 } end
	return prof.Fama
end

local function possui(p, id)
	local lista = p:GetAttribute("Comprados") or ""
	return string.find("," .. lista .. ",", "," .. id .. ",", 1, true) ~= nil
end

local function estrelaNaCabeca(p, n)
	local char = p.Character
	local cabeca = char and char:FindFirstChild("Head")
	if not cabeca then return end
	local b = cabeca:FindFirstChild("FamaEstrela")
	if n <= 0 then if b then b:Destroy() end return end
	if not b then
		b = Instance.new("BillboardGui")
		b.Name = "FamaEstrela"
		b.Size = UDim2.fromOffset(90, 30)
		b.StudsOffset = Vector3.new(0, 2.6, 0)
		b.MaxDistance = 80
		b.LightInfluence = 0
		local t = Instance.new("TextLabel")
		t.Name = "Texto"
		t.BackgroundTransparency = 1
		t.Size = UDim2.fromScale(1, 1)
		t.Font = Enum.Font.FredokaOne
		t.TextScaled = true
		t.TextColor3 = Color3.fromRGB(255, 214, 60)
		t.TextStrokeColor3 = Color3.fromRGB(52, 44, 38)
		t.TextStrokeTransparency = 0
		t.Parent = b
		b.Parent = cabeca
	end
	b.Texto.Text = "⭐ " .. n
end

local function aplicar(p, f)
	p:SetAttribute("FamaEstrelas", f.estrelas)
	p:SetAttribute("BonusFama", f.estrelas * Config.BonusPorEstrela)
	local ls = p:FindFirstChild("leaderstats")
	if ls then
		local v = ls:FindFirstChild("Fama") or Instance.new("IntValue")
		v.Name = "Fama"
		v.Value = f.estrelas
		v.Parent = ls
	end
	estrelaNaCabeca(p, f.estrelas)
end

local function snapshot(p, f)
	local custo = Config.custo(f.estrelas)
	local moedas = tonumber(p:GetAttribute("Moedas")) or 0
	local temCortador = possui(p, Config.CortadorExigido)
	local item = ConfigJogo.ItemPorId(Config.CortadorExigido)
	return {
		estrelas = f.estrelas, titulo = Config.titulo(f.estrelas), proximoTitulo = Config.titulo(f.estrelas + 1),
		bonus = f.estrelas * Config.BonusPorEstrela, bonusProximo = (f.estrelas + 1) * Config.BonusPorEstrela,
		custo = custo, moedas = moedas, temCortador = temCortador, nomeCortador = item and item.Nome or Config.CortadorExigido,
		pode = temCortador and moedas >= custo and f.estrelas < Config.MaxEstrelas, maximo = f.estrelas >= Config.MaxEstrelas,
	}
end

local function ligar(p)
	local function pronto()
		local f = dados(p)
		if f then
			-- espera o leaderstats da Economia
			task.delay(1, function() if p.Parent then aplicar(p, f) end end)
		end
	end
	if p:GetAttribute("ProfileReady") then pronto() end
	p:GetAttributeChangedSignal("ProfileReady"):Connect(pronto)
	p.CharacterAdded:Connect(function(char)
		char:WaitForChild("Head", 10)
		estrelaNaCabeca(p, tonumber(p:GetAttribute("FamaEstrelas")) or 0)
	end)
end
Players.PlayerAdded:Connect(ligar)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(ligar, p) end
Players.PlayerRemoving:Connect(function(p) ocupado[p] = nil end)

remote.OnServerInvoke = function(p, acao)
	if type(acao) ~= "string" then return nil end
	if not Profiles.active(p) then return { erro = "Seu perfil ainda está carregando." } end
	local f = dados(p)
	if not f then return { erro = "Seu perfil ainda está carregando." } end
	if acao == "estado" then
		return { estado = snapshot(p, f) }
	elseif acao == "renascer" then
		if ocupado[p] then return { erro = "Calma, um de cada vez!" } end
		local s = snapshot(p, f)
		if s.maximo then return { erro = "Você já tem a fama máxima!", estado = s } end
		if not s.temCortador then return { erro = ("Compre o %s primeiro."):format(s.nomeCortador), estado = s } end
		if s.moedas < s.custo then return { erro = ("Faltam %d moedas."):format(s.custo - s.moedas), estado = s } end
		ocupado[p] = true
		-- zera a economia de cortadores (a Economy do perfil é capturada destes atributos no salvamento)
		p:SetAttribute("Moedas", 0)
		p:SetAttribute("Comprados", "Basico")
		p:SetAttribute("Cortador", "Basico")
		p:SetAttribute("Multiplicador", 1)
		p:SetAttribute("Saco", 0)
		Economia.RecalcularCapacidade(p)
		f.estrelas += 1
		aplicar(p, f)
		pcall(Economia.Notificar, p, ("⭐ FAMA %d! Agora você é %s: +%d%% de grama para sempre."):format(
			f.estrelas, Config.titulo(f.estrelas), math.floor(f.estrelas * Config.BonusPorEstrela * 100 + 0.5)), "ouro")
		for _, o in ipairs(Players:GetPlayers()) do
			if o ~= p then pcall(Economia.Notificar, o, ("⭐ %s ganhou a Fama %d!"):format(p.DisplayName, f.estrelas), "info") end
		end
		pcall(Profiles.save, p) -- salva já, para a estrela não se perder
		ocupado[p] = nil
		return { ok = true, estado = snapshot(p, f) }
	end
	return nil
end
