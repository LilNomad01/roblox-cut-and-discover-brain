--[[
	ServerScriptService.CorteEDescubra.ApisExtrasServidor  [Claude 2026-11-14]
	APIs da pesquisa (brain/22) que não pertencem a um sistema só. Tudo em pcall: se uma API falhar, o resto segue.
	  * GlobalWind: brisa leve sempre; o evento "Vento" sopra forte e a "Chuva" um pouco (mexe a grama do Terrain,
	    as nuvens e partículas com WindAffectsDrag).
	  * Convites (SocialService/GetJoinData): quem entra por convite (LaunchData "convite:<userId>") recebe aviso, e
	    quem convidou também, se estiver no servidor. Sem prêmio novo (o bônus de amigos jogando juntos já existe),
	    então não dá para abusar.
	  * MessagingService: anúncios entre TODOS os servidores (ex.: alguém chocou um ajudante Celestial/Divino).
	    Outros scripts chamam: script.Anunciar:Fire("texto").
	  * MemoryStoreService: contador global "tufos cortados hoje no mundo" (lotes + fazenda, todos os servidores),
	    somado a cada 30 s; vira o atributo workspace.TufosMundoHoje e uma plaquinha no Quadro de Ranking.
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

---------------------------------------------------------------- vento global
local VENTOS = {
	vento = Vector3.new(22, 0, 9),
	chuva = Vector3.new(8, 0, 3),
}
local BRISA = Vector3.new(3, 0, 1.2)
local function atualizarVento()
	local ev = workspace:GetAttribute("EventoAtual")
	pcall(function() workspace.GlobalWind = VENTOS[ev] or BRISA end)
end
workspace:GetAttributeChangedSignal("EventoAtual"):Connect(atualizarVento)
atualizarVento()

---------------------------------------------------------------- avisos (reaproveita o NotificarHUD da Economia)
local function notificar(p, texto, tipo)
	local ev = RS:FindFirstChild("NotificarHUD")
	if ev then ev:FireClient(p, texto, tipo or "info") end
end
local function notificarTodos(texto, tipo)
	local ev = RS:FindFirstChild("NotificarHUD")
	if ev then ev:FireAllClients(texto, tipo or "ouro") end
end

---------------------------------------------------------------- convites
Players.PlayerAdded:Connect(function(p)
	local ok, dados = pcall(function() return p:GetJoinData() end)
	local launch = ok and type(dados) == "table" and dados.LaunchData
	if type(launch) ~= "string" then return end
	local id = tonumber(string.match(launch, "^convite:(%d+)$"))
	if not id or id == p.UserId then return end
	task.delay(8, function()
		if not p.Parent then return end
		local quem = Players:GetPlayerByUserId(id)
		local nome = quem and quem.DisplayName
		if not nome then
			local okN, n = pcall(Players.GetNameFromUserIdAsync, Players, id)
			nome = okN and n or "um amigo"
		end
		notificar(p, "🤝 Você entrou pelo convite de " .. nome .. "! Jogando juntos, amigos ganham bônus de grama.", "sucesso")
		if quem then notificar(quem, "🤝 " .. p.DisplayName .. " aceitou seu convite!", "sucesso") end
	end)
end)

---------------------------------------------------------------- anúncios entre servidores
local MessagingService = game:GetService("MessagingService")
local TOPICO = "CorteEDescubra_Anuncios"
local anunciar = Instance.new("BindableEvent")
anunciar.Name = "Anunciar"
anunciar.Parent = script
local ultimoEnvio = 0
anunciar.Event:Connect(function(texto)
	if type(texto) ~= "string" or #texto > 180 then return end
	notificarTodos(texto, "ouro") -- este servidor recebe na hora
	if os.clock() - ultimoEnvio < 2 then return end -- limite simples de envio
	ultimoEnvio = os.clock()
	pcall(MessagingService.PublishAsync, MessagingService, TOPICO, { t = texto, j = game.JobId })
end)
task.spawn(function()
	pcall(function()
		MessagingService:SubscribeAsync(TOPICO, function(msg)
			local d = msg and msg.Data
			if type(d) ~= "table" or type(d.t) ~= "string" or d.j == game.JobId then return end
			notificarTodos("🌍 " .. string.sub(d.t, 1, 180), "ouro")
		end)
	end)
end)

---------------------------------------------------------------- contador global de tufos (MemoryStore)
local MemoryStoreService = game:GetService("MemoryStoreService")
local delta = 0
local function vigiarQuadrado(q)
	if not q:IsA("BasePart") then return end
	q:GetPropertyChangedSignal("Transparency"):Connect(function()
		if q.Transparency >= 1 then delta += 1 end
	end)
end
local function vigiarPasta(f)
	for _, q in ipairs(f:GetChildren()) do vigiarQuadrado(q) end
	f.ChildAdded:Connect(vigiarQuadrado)
end
task.spawn(function()
	local mundo = workspace:WaitForChild("GameWorld", 60)
	local plots = mundo and mundo:WaitForChild("Plots", 60)
	if plots then
		for _, p in ipairs(plots:GetChildren()) do
			local gv = p:WaitForChild("GrassVisuals", 30)
			if gv then vigiarPasta(gv) end
		end
	end
	local faz = mundo and mundo:FindFirstChild("Fazenda")
	local grama = faz and faz:WaitForChild("Grama", 60)
	if grama then vigiarPasta(grama) end
end)

local function placa(total)
	local quadro = workspace:FindFirstChild("QuadroRanking", true)
	local painel = quadro and quadro:FindFirstChild("Painel")
	if not painel then return end
	local p = quadro:FindFirstChild("PlacaMundo")
	if not p then
		p = Instance.new("Part")
		p.Name = "PlacaMundo"
		p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch = true, false, false, false
		p.Size = Vector3.new(painel.Size.X * 0.7, 1.1, 0.2)
		p.Color = Color3.fromRGB(40, 70, 45)
		p.Material = Enum.Material.SmoothPlastic
		p.CFrame = painel.CFrame * CFrame.new(0, -painel.Size.Y / 2 - 0.9, -0.15)
		local g = Instance.new("SurfaceGui")
		g.Name = "Texto"
		g.Face = Enum.NormalId.Front
		g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		g.PixelsPerStud = 40
		local t = Instance.new("TextLabel")
		t.Name = "L"
		t.BackgroundTransparency = 1
		t.Size = UDim2.fromScale(1, 1)
		t.Font = Enum.Font.FredokaOne
		t.TextScaled = true
		t.TextColor3 = Color3.fromRGB(255, 240, 190)
		t.Parent = g
		g.Parent = p
		p.Parent = quadro
	end
	p.Texto.L.Text = ("🌍 Tufos cortados hoje no mundo: %s"):format(tostring(total))
end

task.spawn(function()
	local ok, mapa = pcall(MemoryStoreService.GetSortedMap, MemoryStoreService, "CorteEDescubra_Mundo")
	if not ok or not mapa then return end
	while true do
		task.wait(30)
		local chave = "tufos_" .. os.date("!%Y%m%d")
		local enviar = delta
		delta = 0
		local okU, total = pcall(function()
			return mapa:UpdateAsync(chave, function(atual) return (tonumber(atual) or 0) + enviar end, 2 * 24 * 3600)
		end)
		if okU and total then
			workspace:SetAttribute("TufosMundoHoje", total)
			pcall(placa, total)
		else
			delta += enviar -- tenta de novo no próximo ciclo
		end
	end
end)
