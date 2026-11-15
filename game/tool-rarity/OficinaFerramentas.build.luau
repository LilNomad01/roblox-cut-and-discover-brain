--[[
	Construtor da bancada Workspace.GameWorld.Lobby.OficinaFerramentas  [Claude 2026-11-12]
	Rodado UMA vez no Studio (Edit, via MCP execute_luau); o modelo fica salvo no place. Este arquivo é a receita.
	Bancada de madeira atrás do spawn, de frente para ele, com bigorna, as 3 ferramentas (modelos Comum clonados
	de ServerStorage.GameAssets.Ferramentas, só visual), placa "OFICINA" e ProximityPrompt "Evoluir ferramentas" (E).
]]
local L = workspace.GameWorld.Lobby
local antigo = L:FindFirstChild("OficinaFerramentas") if antigo then antigo:Destroy() end
local m = Instance.new("Model") m.Name = "OficinaFerramentas"
local MADEIRA = Color3.fromRGB(124, 84, 52)
local ESCURA = Color3.fromRGB(92, 60, 36)
-- 2026-11-12 (revisão): fora da estrada norte (PathZ, x -6..6), na grama entre a estrada e a cerca dos lotes, de frente para a estrada
local base = CFrame.lookAt(Vector3.new(-13, 0.3, 32), Vector3.new(0, 0.3, 32))
local function peca(nome, tam, off, cor, mat)
	local p = Instance.new("Part")
	p.Name = nome p.Size = tam p.CFrame = base * off p.Color = cor p.Material = mat or Enum.Material.Wood
	p.Anchored = true p.TopSurface = Enum.SurfaceType.Smooth p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = m
	return p
end
local tampo = peca("Tampo", Vector3.new(9, 0.6, 3.4), CFrame.new(0, 3.2, 0), MADEIRA, Enum.Material.WoodPlanks)
for _, x in ipairs({ -4, 4 }) do for _, z in ipairs({ -1.3, 1.3 }) do peca("Perna", Vector3.new(0.6, 2.9, 0.6), CFrame.new(x, 1.45, z), ESCURA) end end
peca("Painel", Vector3.new(9, 5, 0.4), CFrame.new(0, 6, 1.6), MADEIRA, Enum.Material.WoodPlanks)
peca("Telhado", Vector3.new(10.4, 0.5, 4.6), CFrame.new(0, 8.7, 0.2) * CFrame.Angles(math.rad(8), 0, 0), Color3.fromRGB(150, 62, 48))
local bigorna = peca("Bigorna", Vector3.new(1.6, 1, 0.9), CFrame.new(-2.6, 4, 0), Color3.fromRGB(70, 74, 80), Enum.Material.Metal)
peca("BigornaPe", Vector3.new(0.8, 0.5, 0.6), CFrame.new(-2.6, 3.3, 0), Color3.fromRGB(60, 62, 68), Enum.Material.Metal)
-- as 3 ferramentas penduradas no painel (cópia visual do modelo Comum)
local pasta = game.ServerStorage.GameAssets.Ferramentas
for i, tipo in ipairs({ "CortadorUnha", "Enxada", "Foice" }) do
	local molde = pasta:FindFirstChild(tipo) and pasta[tipo]:FindFirstChild(tipo .. "_Comum")
	local p = molde and molde:FindFirstChildWhichIsA("BasePart")
	if p then
		local c = p:Clone()
		c.Name = "Vitrine_" .. tipo
		c.Anchored = true c.CanCollide = false c.CanQuery = false c.CanTouch = false
		-- na frente do painel (face em z 1,4) com folga de 0,1, para o modelo não atravessar para o lado de trás
		local meia = math.min(c.Size.X, c.Size.Z) / 2
		c.CFrame = base * CFrame.new(-3 + i * 2, 6, math.min(0.85, 1.4 - meia - 0.1)) * CFrame.Angles(0, math.rad(180), 0)
		c.Parent = m
	end
end
local placa = peca("Placa", Vector3.new(5, 1, 0.2), CFrame.new(0, 8.1, 1.35), Color3.fromRGB(255, 200, 60), Enum.Material.SmoothPlastic)
local sg = Instance.new("SurfaceGui") sg.Face = Enum.NormalId.Front sg.CanvasSize = Vector2.new(500, 100) sg.LightInfluence = 1 sg.Parent = placa
local t = Instance.new("TextLabel") t.BackgroundTransparency = 1 t.Size = UDim2.fromScale(1, 1) t.Font = Enum.Font.FredokaOne t.TextScaled = true
t.TextColor3 = Color3.fromRGB(52, 44, 38) t.Text = "🔨 OFICINA" t.Parent = sg
local at = Instance.new("Attachment") at.Name = "Interacao" at.Position = Vector3.new(0, 0.8, -1.4) at.Parent = tampo
local pr = Instance.new("ProximityPrompt") pr.ActionText = "Evoluir ferramentas" pr.ObjectText = "Oficina"
pr.KeyboardKeyCode = Enum.KeyCode.E pr.GamepadKeyCode = Enum.KeyCode.ButtonX pr.HoldDuration = 0 pr.MaxActivationDistance = 10 pr.RequiresLineOfSight = false pr.Parent = at
m.PrimaryPart = tampo
m.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
m:SetAttribute("Autor", "Claude 2026-11-12 MON-04 raridade")
m.Parent = L
