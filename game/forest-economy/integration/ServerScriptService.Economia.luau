--[[
	Economia (ModuleScript)
	Local: ServerScriptService > Economia

	Toda a economia do jogador fica em ATRIBUTOS do Player, e o HUD reage sozinho a eles:
	  Moedas, Nivel, XP, XPMax, Saco, SacoMax, Cortador, Multiplicador, Comprados

	Uso típico nos outros scripts do servidor:
	  local Economia = require(game.ServerScriptService.Economia)
	  Economia.CortarGrama(player)   -- quando o cortador passa numa placa de GramaAlta (retorna false se o saco estiver cheio)
	  Economia.Vender(player)        -- quando o jogador chega na caçamba de venda
	  Economia.AddMoedas(player, 100)
	  Economia.AddXP(player, 20)
	  Economia.Notificar(player, "Texto", "sucesso" | "erro" | "info" | "ouro")
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("ConfigJogo"))

local Catalog = require(ReplicatedStorage.Shared:WaitForChild("ForestCommerceCatalog"))
local Economia = {}
local sales = setmetatable({}, {__mode="k"})

function Economia.RecalcularCapacidade(p: Player)
    local item = Config.ItemPorId(p:GetAttribute("Cortador") or "Basico") or Config.Itens[1]
    local level = p:GetAttribute("MochilaNivel") or 0
    p:SetAttribute("SacoMax", Catalog.capacity(item.Saco, level))
end

function Economia.Notificar(p: Player, msg: string, tipo: string?)
	local ev = ReplicatedStorage:FindFirstChild("NotificarHUD")
	if ev then
		ev:FireClient(p, msg, tipo or "info")
	end
end

-- dados: tabela opcional vinda do DataStore { Moedas, Nivel, XP, Comprados, Cortador }
function Economia.Iniciar(p: Player, dados: { [string]: any }?)
	local d = dados or {}
	local nivel = d.Nivel or 1
	local cortador = Config.ItemPorId(d.Cortador or "Basico") or Config.Itens[1]

	p:SetAttribute("Moedas", d.Moedas or 0)
	p:SetAttribute("Nivel", nivel)
	p:SetAttribute("XP", d.XP or 0)
	p:SetAttribute("XPMax", Config.XPParaNivel(nivel))
	p:SetAttribute("Comprados", d.Comprados or "Basico")
	p:SetAttribute("Cortador", cortador.Id)
	p:SetAttribute("Multiplicador", cortador.Multiplicador)
	p:SetAttribute("MochilaNivel", 0)
	Economia.RecalcularCapacidade(p)
	p:SetAttribute("Saco", 0)

	-- leaderstats (aparece na lista de jogadores)
	local ls = Instance.new("Folder")
	ls.Name = "leaderstats"
	local vMoedas = Instance.new("IntValue")
	vMoedas.Name = "Moedas"
	vMoedas.Parent = ls
	local vNivel = Instance.new("IntValue")
	vNivel.Name = "Nível"
	vNivel.Parent = ls
	local function sync()
		vMoedas.Value = p:GetAttribute("Moedas") or 0
		vNivel.Value = p:GetAttribute("Nivel") or 1
	end
	sync()
	p:GetAttributeChangedSignal("Moedas"):Connect(sync)
	p:GetAttributeChangedSignal("Nivel"):Connect(sync)
	ls.Parent = p
end

function Economia.AddMoedas(p: Player, qtd: number)
	p:SetAttribute("Moedas", (p:GetAttribute("Moedas") or 0) + math.floor(qtd))
end

function Economia.AddXP(p: Player, qtd: number)
	local xp = (p:GetAttribute("XP") or 0) + qtd
	local nivel = p:GetAttribute("Nivel") or 1
	local subiu = false
	while xp >= Config.XPParaNivel(nivel) do
		xp -= Config.XPParaNivel(nivel)
		nivel += 1
		subiu = true
		Economia.AddMoedas(p, Config.RecompensaNivel(nivel))
	end
	p:SetAttribute("XPMax", Config.XPParaNivel(nivel))
	p:SetAttribute("XP", xp)
	if subiu then
		p:SetAttribute("Nivel", nivel) -- o HUD dispara a animação de LEVEL UP
	end
end

-- Coloca grama no saco (já aplica o Multiplicador). Retorna quanto entrou.
function Economia.EncherSaco(p: Player, qtd: number): number
	local saco = p:GetAttribute("Saco") or 0
	local max = p:GetAttribute("SacoMax") or 50
	local mult = p:GetAttribute("Multiplicador") or 1
	local add = math.min(qtd * mult, max - saco)
	if add <= 0 then
		return 0
	end
	p:SetAttribute("Saco", saco + add)
	return add
end

-- Chamar quando o cortador corta UMA placa de grama.
function Economia.CortarGrama(p: Player): boolean
	local add = Economia.EncherSaco(p, Config.GramaPorPlaca)
	if add <= 0 then
		return false
	end
	Economia.AddXP(p, Config.XPPorPlaca)
	return true
end

function Economia.Vender(p: Player): number
    local Profiles = require(game.ServerScriptService.CorteEDescubra.Profiles)
    local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
    if sales[p] or not p:GetAttribute("ProfileReady") or not Profiles.active(p)
        or not hum or hum.Health <= 0 then return 0 end
	local saco = p:GetAttribute("Saco") or 0
	if type(saco) ~= "number" or saco ~= saco or saco < 0 or saco > 1000000000 then return 0 end
	if saco <= 0 then
		Economia.Notificar(p, "Seu saco está vazio!", "info")
		return 0
	end
	local ganho = math.floor(saco * Config.PrecoGrama)
    if (p:GetAttribute("Moedas") or 0) + ganho > 1000000000 then return 0 end
    sales[p] = true
	p:SetAttribute("Saco", 0)
	Economia.AddMoedas(p, ganho) -- o HUD faz as moedas voarem até o contador
	Economia.Notificar(p, "💰 Vendeu " .. saco .. " de grama por " .. ganho .. " moedas!", "ouro")
    sales[p] = nil
	return ganho, saco
end

local function possui(p: Player, id: string): boolean
	local lista = p:GetAttribute("Comprados") or ""
	return string.find("," .. lista .. ",", "," .. id .. ",", 1, true) ~= nil
end

function Economia.Comprar(p: Player, id: string): boolean
	local item = Config.ItemPorId(id)
	if not item or p:GetAttribute("Cortador") == id then
		return false
	end

	if not possui(p, id) then
		local moedas = p:GetAttribute("Moedas") or 0
		if moedas < item.Preco then
			Economia.Notificar(p, "Faltam " .. (item.Preco - moedas) .. " moedas!", "erro")
			return false
		end
		local lista = p:GetAttribute("Comprados") or ""
		p:SetAttribute("Moedas", moedas - item.Preco)
		p:SetAttribute("Comprados", if lista == "" then id else lista .. "," .. id)
		Economia.Notificar(p, "✅ Comprou " .. item.Nome .. "!", "sucesso")
	else
		Economia.Notificar(p, "Equipou " .. item.Nome, "info")
	end

	-- equipa (o script do cortador pode ouvir p:GetAttributeChangedSignal("Cortador") pra trocar o modelo)
	p:SetAttribute("Cortador", item.Id)
	p:SetAttribute("Multiplicador", item.Multiplicador)
	Economia.RecalcularCapacidade(p)
	return true
end

return Economia

