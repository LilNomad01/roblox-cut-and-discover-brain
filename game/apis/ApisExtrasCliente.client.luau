--[[
	StarterPlayerScripts.ApisExtrasCliente  [Claude 2026-11-14]
	APIs do lado do cliente (pesquisa brain/22). Tudo em pcall: se uma API não existir no aparelho, nada quebra.
	  * HapticService / HapticEffect: vibração leve ao encher o saco e forte quando ele lota (celular e controle).
	    Respeita a opção "Vibração" do menu (atributo VibracaoLigada).
	  * CaptureService: ao achar um segredo da Floresta, tira uma foto e oferece "Salvar na galeria" e
	    "Compartilhar" (o convite leva o amigo ao jogo).
	  * ExperienceNotificationService: depois de 5 min jogando e de vender o saco, pergunta UMA vez por sessão se o
	    jogador quer receber avisos do jogo (o envio é configurado pelo dono no Creator Dashboard).
]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local inicio = os.clock()

---------------------------------------------------------------- vibração
local HapticService = game:GetService("HapticService")
local ultimaVib = 0
local function vibrar(forca, duracao)
	if player:GetAttribute("VibracaoLigada") == false then return end
	if os.clock() - ultimaVib < 0.12 then return end
	ultimaVib = os.clock()
	-- efeito novo (celular): HapticEffect
	pcall(function()
		local e = Instance.new("HapticEffect")
		e.Type = forca > 0.5 and Enum.HapticEffectType.GameplayExplosion or Enum.HapticEffectType.UIClick
		e.Parent = workspace
		e:Play()
		task.delay(1, function() e:Destroy() end)
	end)
	-- controle: motor pequeno
	pcall(function()
		if HapticService:IsVibrationSupported(Enum.UserInputType.Gamepad1) then
			HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, forca)
			task.delay(duracao, function() HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0) end)
		end
	end)
end
local sacoAnterior = tonumber(player:GetAttribute("Saco")) or 0
player:GetAttributeChangedSignal("Saco"):Connect(function()
	local s = tonumber(player:GetAttribute("Saco")) or 0
	local m = tonumber(player:GetAttribute("SacoMax")) or 1
	if s > sacoAnterior then
		if s >= m then vibrar(1, 0.35) else vibrar(0.25, 0.06) end
	end
	sacoAnterior = s
end)

---------------------------------------------------------------- avisos simples na tela
local function toast(texto, botoes)
	local gui = Instance.new("ScreenGui")
	gui.Name = "ApisToast"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 40
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0)
	f.Position = UDim2.new(0.5, 0, 0, 120)
	f.Size = UDim2.fromOffset(420, botoes and 108 or 56)
	f.BackgroundColor3 = Color3.fromRGB(255, 248, 230)
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 14) c.Parent = f
	local st = Instance.new("UIStroke") st.Thickness = 3 st.Color = Color3.fromRGB(40, 30, 22) st.Parent = f
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.new(1, -20, 0, 48)
	t.Position = UDim2.fromOffset(10, 4)
	t.Font = Enum.Font.GothamBold
	t.TextSize = 16
	t.TextWrapped = true
	t.TextColor3 = Color3.fromRGB(40, 30, 22)
	t.Text = texto
	t.Parent = f
	if botoes then
		for i, b in ipairs(botoes) do
			local bt = Instance.new("TextButton")
			bt.Size = UDim2.fromOffset(190, 40)
			bt.Position = UDim2.new(0, 10 + (i - 1) * 200, 0, 58)
			bt.BackgroundColor3 = b.cor
			bt.Font = Enum.Font.FredokaOne
			bt.TextSize = 17
			bt.TextColor3 = Color3.new(1, 1, 1)
			bt.Text = b.texto
			local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0, 10) bc.Parent = bt
			bt.Activated:Connect(function() gui:Destroy() b.acao() end)
			bt.Parent = f
		end
	end
	f.Parent = gui
	gui.Parent = player.PlayerGui
	task.delay(botoes and 12 or 4, function() if gui.Parent then gui:Destroy() end end)
end

---------------------------------------------------------------- foto ao achar segredo
local CaptureService = game:GetService("CaptureService")
local function contarSegredos()
	local s = tostring(player:GetAttribute("ForestClaimedSecrets") or "")
	local n = 0
	for _ in string.gmatch(s, "[^,]+") do n += 1 end
	return n
end
local segredos = contarSegredos()
player:GetAttributeChangedSignal("ForestClaimedSecrets"):Connect(function()
	local n = contarSegredos()
	if n <= segredos then segredos = n return end
	segredos = n
	task.wait(0.8) -- deixa o baú abrir na foto
	pcall(function()
		CaptureService:CaptureScreenshot(function(conteudo)
			toast("📸 Você achou um segredo! Quer guardar esta foto?", {
				{ texto = "Salvar na galeria", cor = Color3.fromRGB(70, 180, 80), acao = function()
					pcall(function() CaptureService:PromptSaveCapturesToGallery({ conteudo }, function() end) end)
				end },
				{ texto = "Compartilhar", cor = Color3.fromRGB(70, 130, 230), acao = function()
					pcall(function() CaptureService:PromptShareCapture(conteudo, "convite:" .. player.UserId, function() end, function() end) end)
				end },
			})
		end)
	end)
end)

---------------------------------------------------------------- avisos do jogo (opt-in)
local ExperienceNotificationService = game:GetService("ExperienceNotificationService")
local perguntou = false
local moedasAntes = tonumber(player:GetAttribute("Moedas")) or 0
player:GetAttributeChangedSignal("Moedas"):Connect(function()
	local m = tonumber(player:GetAttribute("Moedas")) or 0
	local vendeu = m > moedasAntes and (tonumber(player:GetAttribute("Saco")) or 0) == 0
	moedasAntes = m
	if perguntou or not vendeu or os.clock() - inicio < 300 then return end
	perguntou = true
	task.delay(3, function()
		pcall(function()
			if ExperienceNotificationService:CanPromptOptInAsync() then
				ExperienceNotificationService:PromptOptIn()
			end
		end)
	end)
end)
