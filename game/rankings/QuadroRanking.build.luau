--[[
	Construtor do quadro Workspace.GameWorld.Lobby.QuadroRanking  [Claude 2026-11-12]
	Rodado UMA vez no Studio (Edit, via MCP execute_luau); o modelo fica salvo no place. Este arquivo é a receita.
	Placar de madeira do outro lado do spawn (espelho do Quadro de Missões) com 3 colunas (Col1..Col3), cada uma
	com Titulo e L1..L10. O EstatisticasServidor escreve os textos a cada 2 min.
]]
local L = workspace.GameWorld.Lobby
local antigo = L:FindFirstChild("QuadroRanking") if antigo then antigo:Destroy() end
local m = Instance.new("Model") m.Name = "QuadroRanking"
local ESCURA = Color3.fromRGB(92, 60, 36)
local base = CFrame.lookAt(Vector3.new(15, 0.3, 17), Vector3.new(0, 0.3, 12)) -- de frente para o spawn
local function peca(nome, tam, off, cor, mat)
	local p = Instance.new("Part")
	p.Name = nome p.Size = tam p.CFrame = base * off p.Color = cor p.Material = mat or Enum.Material.Wood
	p.Anchored = true p.TopSurface = Enum.SurfaceType.Smooth p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = m
	return p
end
peca("PosteE", Vector3.new(0.8, 10, 0.8), CFrame.new(-7.4, 5, 0), ESCURA)
peca("PosteD", Vector3.new(0.8, 10, 0.8), CFrame.new(7.4, 5, 0), ESCURA)
peca("Moldura", Vector3.new(14.6, 7.6, 0.5), CFrame.new(0, 5.6, 0.05), ESCURA)
local painel = peca("Painel", Vector3.new(14, 7, 0.3), CFrame.new(0, 5.6, -0.15), Color3.fromRGB(34, 52, 40), Enum.Material.SmoothPlastic)
peca("Telhado", Vector3.new(16.4, 0.5, 2.2), CFrame.new(0, 9.8, 0) * CFrame.Angles(math.rad(-8), 0, 0), Color3.fromRGB(150, 62, 48))
local placa = peca("Placa", Vector3.new(7, 1, 0.2), CFrame.new(0, 9.75, -0.4), Color3.fromRGB(255, 200, 60), Enum.Material.SmoothPlastic)
local sgp = Instance.new("SurfaceGui") sgp.Face = Enum.NormalId.Front sgp.CanvasSize = Vector2.new(700, 100) sgp.LightInfluence = 1 sgp.Parent = placa
local tp = Instance.new("TextLabel") tp.BackgroundTransparency = 1 tp.Size = UDim2.fromScale(1, 1) tp.Font = Enum.Font.FredokaOne tp.TextScaled = true
tp.TextColor3 = Color3.fromRGB(52, 44, 38) tp.Text = "🏆 MELHORES JARDINEIROS" tp.Parent = sgp

local sg = Instance.new("SurfaceGui") sg.Face = Enum.NormalId.Front sg.CanvasSize = Vector2.new(1400, 700) sg.LightInfluence = 0.6 sg.Parent = painel
local lista = Instance.new("UIListLayout") lista.FillDirection = Enum.FillDirection.Horizontal lista.Padding = UDim.new(0, 20)
lista.HorizontalAlignment = Enum.HorizontalAlignment.Center lista.VerticalAlignment = Enum.VerticalAlignment.Center lista.Parent = sg
for i = 1, 3 do
	local col = Instance.new("Frame") col.Name = "Col" .. i col.Size = UDim2.fromOffset(440, 660) col.BackgroundColor3 = Color3.fromRGB(46, 70, 54) col.LayoutOrder = i col.Parent = sg
	Instance.new("UICorner", col).CornerRadius = UDim.new(0, 18)
	local t = Instance.new("TextLabel") t.Name = "Titulo" t.BackgroundTransparency = 1 t.Size = UDim2.new(1, -20, 0, 70) t.Position = UDim2.fromOffset(10, 6)
	t.Font = Enum.Font.FredokaOne t.TextScaled = true t.TextColor3 = Color3.fromRGB(255, 214, 90) t.Text = "..." t.Parent = col
	for k = 1, 10 do
		local l = Instance.new("TextLabel") l.Name = "L" .. k l.BackgroundTransparency = 1
		l.Size = UDim2.new(1, -30, 0, 54) l.Position = UDim2.fromOffset(18, 80 + (k - 1) * 57)
		l.Font = Enum.Font.GothamBold l.TextScaled = true l.TextXAlignment = Enum.TextXAlignment.Left
		l.TextColor3 = k <= 3 and Color3.fromRGB(255, 246, 214) or Color3.fromRGB(214, 226, 214) l.Text = k == 1 and "Carregando..." or "" l.Parent = col
	end
end
m.PrimaryPart = painel
m.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
m:SetAttribute("Autor", "Claude 2026-11-12 PAD-07")
m.Parent = L
