--[[
	ReplicatedStorage.Shared.HudKit  [Claude 2026-11-12]
	Peças do HUD no MESMO estilo e na MESMA grade da HUD original (StarterPlayerScripts.InterfaceHUD):
	  * botão quadrado 80x80 (tela base 1600x900): cantos 24, degradê vertical, contorno escuro 4 + aro branco 1,5,
	    faixa de brilho no topo, ícone emoji e rótulo FredokaOne com contorno; cresce no hover e afunda no clique
	  * escala = clamp(min(largura/1600, altura/900), 0.5, 1.15), a mesma fórmula da InterfaceHUD
	  * coluna ESQUERDA = o próprio HUDCortaGrama.Menu (botões entram na mesma lista, mesmo espaçamento 8)
	  * coluna DIREITA = grade 2 x N com o mesmo botão, margem 18 da borda (igual às moedas), que se posiciona
	    sozinha logo abaixo do cartão de missão (ExplorationQuestHUD) e do botão Explorar (ForestCommerceUI)
	  * selo vermelho (contador) no canto superior direito e "chip" de informação no canto superior esquerdo
	Uso: local b, api = HudKit.botao({ nome, rotulo, icone, c1, c2, ordem, lado = "esquerda" | "direita" })
	     api.badge(n | nil)   api.chip(texto | nil, cor?)   b.Activated:Connect(...)
]]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer

local K = {}

K.C = {
	Contorno = Color3.fromRGB(12, 22, 14),
	Branco = Color3.new(1, 1, 1),
	Ouro1 = Color3.fromRGB(255, 221, 74), Ouro2 = Color3.fromRGB(255, 152, 24),
	Azul1 = Color3.fromRGB(110, 225, 255), Azul2 = Color3.fromRGB(40, 130, 235),
	Verde1 = Color3.fromRGB(120, 230, 90), Verde2 = Color3.fromRGB(36, 160, 70),
	Roxo1 = Color3.fromRGB(230, 140, 255), Roxo2 = Color3.fromRGB(130, 50, 220),
	Vermelho1 = Color3.fromRGB(255, 110, 110), Vermelho2 = Color3.fromRGB(200, 40, 60),
	Laranja1 = Color3.fromRGB(255, 190, 110), Laranja2 = Color3.fromRGB(226, 104, 40),
}
K.Margem = 18 -- mesma margem da InterfaceHUD (pixels de tela, sem escala)
K.Tam = 80 -- botão base (tela 1600x900)
K.Espaco = 8

local FONTE = Enum.Font.FredokaOne

function K.escala()
	local vp = workspace.CurrentCamera.ViewportSize
	return math.clamp(math.min(vp.X / 1600, vp.Y / 900), 0.5, 1.15)
end

local escalas = {}
function K.registrarEscala(s)
	s.Scale = K.escala()
	table.insert(escalas, s)
	return s
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	local e = K.escala()
	for _, s in ipairs(escalas) do s.Scale = e end
end)

local function make(classe, props, filhos)
	local o = Instance.new(classe)
	for k, v in pairs(props) do if k ~= "Parent" then o[k] = v end end
	for _, f in ipairs(filhos or {}) do f.Parent = o end
	if props.Parent then o.Parent = props.Parent end
	return o
end
local function tween(obj, t, props, estilo)
	local tw = TweenService:Create(obj, TweenInfo.new(t, estilo or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

---------------------------------------------------------------- colunas
local colunaEsquerda = nil
function K.colunaEsquerda()
	if colunaEsquerda then return colunaEsquerda end
	local hud = player:WaitForChild("PlayerGui"):WaitForChild("HUDCortaGrama", 30)
	local menu = hud and hud:WaitForChild("Menu", 30)
	if not menu then return nil end
	colunaEsquerda = menu
	-- a lista é centralizada; só garante que a área comporta os botões novos (não muda a posição dos antigos)
	local function ajustar()
		local n = 0
		for _, c in ipairs(menu:GetChildren()) do if c:IsA("GuiButton") and c.Visible then n += 1 end end
		menu.Size = UDim2.fromOffset(86, math.max(440, n * K.Tam + (n - 1) * K.Espaco))
	end
	menu.ChildAdded:Connect(function() task.defer(ajustar) end)
	ajustar()
	return menu
end

local colunaDireita = nil
function K.colunaDireita()
	if colunaDireita then return colunaDireita end
	local gui = make("ScreenGui", { Name = "HUDExtras", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 14, Parent = player:WaitForChild("PlayerGui") })
	local f = make("Frame", { Name = "ColunaDireita", AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1,
		Size = UDim2.fromOffset(2 * K.Tam + K.Espaco, 4 * K.Tam + 3 * K.Espaco), Position = UDim2.new(1, -K.Margem, 0, 240), Parent = gui }, {
		make("UIGridLayout", { CellSize = UDim2.fromOffset(K.Tam, K.Tam), CellPadding = UDim2.fromOffset(K.Espaco, K.Espaco),
			FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder, FillDirectionMaxCells = 2 }),
	})
	K.registrarEscala(make("UIScale", { Parent = f }))
	colunaDireita = f
	-- topo da grade = logo abaixo do que já existe no canto superior direito (cartão de missão, Explorar)
	task.spawn(function()
		while f.Parent do
			local pg = player.PlayerGui
			local topo = 0
			local inset = GuiService:GetGuiInset().Y
			local function considerar(obj)
				if obj and obj:IsA("GuiObject") and obj.Visible then
					local g = obj:FindFirstAncestorOfClass("ScreenGui")
					if g and g.Enabled then
						-- AbsolutePosition nunca conta a barra do topo; a grade (IgnoreGuiInset) usa a tela inteira
						local y = obj.AbsolutePosition.Y + obj.AbsoluteSize.Y + inset
						local x = obj.AbsolutePosition.X + obj.AbsoluteSize.X
						if x > workspace.CurrentCamera.ViewportSize.X * 0.6 then topo = math.max(topo, y) end
					end
				end
			end
			local q = pg:FindFirstChild("ExplorationQuestHUD")
			local card = q and q:FindFirstChild("Quest")
			considerar(card)
			local fc = pg:FindFirstChild("ForestCommerceUI")
			-- pilha da direita: cartão de missão -> Explorar -> grade, todos com a mesma margem e o mesmo espaço
			if fc and card and card.Visible then
				for _, c in ipairs(fc:GetChildren()) do
					if c:IsA("TextButton") and c.Visible and c.AbsoluteSize.X < 300 and c.AbsolutePosition.X > workspace.CurrentCamera.ViewportSize.X * 0.6 then
						local yCard = card.AbsolutePosition.Y + card.AbsoluteSize.Y + math.floor(K.Espaco * K.escala())
						c.AnchorPoint = Vector2.new(1, 0)
						c.Position = UDim2.new(1, -K.Margem, 0, yCard + (fc.IgnoreGuiInset and inset or 0))
					end
				end
			end
			if fc then for _, c in ipairs(fc:GetChildren()) do if c:IsA("TextButton") or c:IsA("ImageButton") then considerar(c) end end end
			local m = pg:FindFirstChild("HUDCortaGrama") and pg.HUDCortaGrama:FindFirstChild("Moedas")
			considerar(m)
			f.Position = UDim2.new(1, -K.Margem, 0, math.floor(topo + K.Espaco * K.escala()))
			task.wait(0.4)
		end
	end)
	return f
end

---------------------------------------------------------------- botão
function K.botao(o)
	local c1, c2 = o.c1 or K.C.Verde1, o.c2 or K.C.Verde2
	local b = make("TextButton", {
		Name = o.nome, LayoutOrder = o.ordem or 0, Text = "", AutoButtonColor = false,
		Size = UDim2.fromOffset(K.Tam, K.Tam), BackgroundColor3 = K.C.Branco,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 24) }),
		make("UIGradient", { Color = ColorSequence.new(c1:Lerp(K.C.Branco, 0.08), c2), Rotation = 90 }),
		make("UIStroke", { Color = K.C.Contorno, Thickness = 4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, LineJoinMode = Enum.LineJoinMode.Round }),
	})
	make("Frame", { Name = "Brilho", Size = UDim2.new(1, -14, 0.3, 0), Position = UDim2.fromOffset(7, 6), BackgroundColor3 = K.C.Branco,
		BackgroundTransparency = 0.72, Parent = b }, { make("UICorner", { CornerRadius = UDim.new(0, 14) }) })
	make("TextLabel", { Name = "Icone", Text = o.icone or "", Font = FONTE, TextScaled = true, BackgroundTransparency = 1, TextColor3 = K.C.Branco,
		Size = UDim2.fromScale(0.56, 0.5), Position = UDim2.fromScale(0.5, 0.4), AnchorPoint = Vector2.new(0.5, 0.5), Parent = b })
	make("TextLabel", { Name = "Rotulo", Text = string.upper(o.rotulo or o.nome), Font = FONTE, TextScaled = true, BackgroundTransparency = 1,
		TextColor3 = K.C.Branco, Size = UDim2.new(0.92, 0, 0, 19), Position = UDim2.new(0.5, 0, 1, -15), AnchorPoint = Vector2.new(0.5, 0.5), Parent = b },
		{ make("UIStroke", { Color = K.C.Contorno, Thickness = 2.2, LineJoinMode = Enum.LineJoinMode.Round }) })
	local aro = make("UIStroke", { Color = K.C.Branco, Thickness = 1.5, Transparency = 0.52, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = b })
	local esc = make("UIScale", { Parent = b })
	b.MouseEnter:Connect(function() tween(aro, 0.14, { Transparency = 0.16 }) tween(esc, 0.15, { Scale = 1.07 }, Enum.EasingStyle.Back) end)
	b.MouseLeave:Connect(function() tween(aro, 0.16, { Transparency = 0.52 }) tween(esc, 0.15, { Scale = 1 }) end)
	b.MouseButton1Down:Connect(function() tween(esc, 0.08, { Scale = 0.92 }) end)
	b.MouseButton1Up:Connect(function() tween(esc, 0.25, { Scale = 1 }, Enum.EasingStyle.Back) end)

	-- selo (contador) no canto superior direito, no estilo do selo da HUD
	local selo = make("Frame", { Name = "Selo", Visible = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -6, 0, 6),
		Size = UDim2.fromOffset(30, 30), BackgroundColor3 = K.C.Branco, ZIndex = 5, Parent = b }, {
		make("UICorner", { CornerRadius = UDim.new(1, 0) }),
		make("UIGradient", { Color = ColorSequence.new(K.C.Vermelho1, K.C.Vermelho2), Rotation = 90 }),
		make("UIStroke", { Color = K.C.Branco, Thickness = 2.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
	})
	local seloTexto = make("TextLabel", { Text = "", Font = FONTE, TextScaled = true, BackgroundTransparency = 1, TextColor3 = K.C.Branco, ZIndex = 6,
		Size = UDim2.fromScale(0.75, 0.75), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Parent = selo },
		{ make("UIStroke", { Color = K.C.Contorno, Thickness = 1.5 }) })
	local seloEsc = make("UIScale", { Parent = selo })
	-- chip (informação curta) no canto superior esquerdo
	local chip = make("Frame", { Name = "Chip", Visible = false, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, -8, 0, 4),
		Size = UDim2.fromOffset(52, 24), BackgroundColor3 = K.C.Branco, ZIndex = 5, Parent = b }, {
		make("UICorner", { CornerRadius = UDim.new(1, 0) }),
		make("UIStroke", { Color = K.C.Contorno, Thickness = 2.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
	})
	local chipGrad = make("UIGradient", { Color = ColorSequence.new(K.C.Ouro1, K.C.Ouro2), Rotation = 90, Parent = chip })
	local chipTexto = make("TextLabel", { Text = "", Font = FONTE, TextScaled = true, BackgroundTransparency = 1, TextColor3 = K.C.Branco, ZIndex = 6,
		Size = UDim2.new(1, -8, 1, -4), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Parent = chip },
		{ make("UIStroke", { Color = K.C.Contorno, Thickness = 1.5 }) })

	local api = {}
	function api.badge(n)
		local mostrar = n ~= nil and n ~= false and n ~= 0
		if mostrar and not selo.Visible then seloEsc.Scale = 0.3 tween(seloEsc, 0.3, { Scale = 1 }, Enum.EasingStyle.Back) end
		selo.Visible = mostrar
		seloTexto.Text = type(n) == "number" and tostring(math.min(n, 99)) or "!"
	end
	function api.chip(texto, c1c, c2c)
		chip.Visible = texto ~= nil and texto ~= ""
		chipTexto.Text = texto or ""
		chip.Size = UDim2.fromOffset(math.max(40, 14 + #(texto or "") * 9), 24)
		chipGrad.Color = ColorSequence.new(c1c or K.C.Ouro1, c2c or K.C.Ouro2)
	end
	function api.pulsar()
		tween(esc, 0.07, { Scale = 1.15 }).Completed:Connect(function() tween(esc, 0.3, { Scale = 1 }, Enum.EasingStyle.Back) end)
	end

	local pai = (o.lado == "esquerda") and K.colunaEsquerda() or K.colunaDireita()
	b.Parent = pai
	return b, api
end

return K
