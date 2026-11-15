--[[
	Construtor do quadro físico Workspace.GameWorld.Lobby.QuadroMissoes  [Claude 2026-11-12]
	Rodado UMA vez no Studio (Edit, via MCP execute_luau). O modelo fica salvo no place; este arquivo é só a receita.
	Quadro de madeira com telhado, 3 papéis (Jardim, Floresta, Negócios), placa "QUADRO DE MISSÕES" e
	ProximityPrompt "Ver missões" (E). O MissoesCliente abre o painel pelo ProximityPromptService.PromptTriggered.
]]
local L = workspace.GameWorld.Lobby
local antigo = L:FindFirstChild("QuadroMissoes") if antigo then antigo:Destroy() end
local m = Instance.new("Model") m.Name = "QuadroMissoes"
local MADEIRA = Color3.fromRGB(124, 84, 52)
local ESCURA = Color3.fromRGB(92, 60, 36)
local base = CFrame.lookAt(Vector3.new(-15, 0.3, 17), Vector3.new(0, 0.3, 12)) -- de frente para o spawn
local function peca(nome, tam, off, cor, mat)
	local p = Instance.new("Part")
	p.Name = nome p.Size = tam p.CFrame = base * off p.Color = cor p.Material = mat or Enum.Material.Wood
	p.Anchored = true p.TopSurface = Enum.SurfaceType.Smooth p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = m
	return p
end
peca("PosteE", Vector3.new(0.8, 9, 0.8), CFrame.new(-4.6, 4.5, 0), ESCURA)
peca("PosteD", Vector3.new(0.8, 9, 0.8), CFrame.new(4.6, 4.5, 0), ESCURA)
local quadro = peca("Quadro", Vector3.new(8.6, 5.2, 0.4), CFrame.new(0, 5.2, 0), MADEIRA, Enum.Material.WoodPlanks)
peca("Telhado", Vector3.new(10.4, 0.5, 2.2), CFrame.new(0, 8.4, 0) * CFrame.Angles(math.rad(-8), 0, 0), Color3.fromRGB(150, 62, 48))
peca("Moldura", Vector3.new(9, 0.4, 0.6), CFrame.new(0, 2.5, 0), ESCURA)
local cores = { Color3.fromRGB(255, 246, 214), Color3.fromRGB(214, 240, 200), Color3.fromRGB(255, 226, 180) }
for i = -1, 1 do
	local papel = peca("Papel" .. (i + 2), Vector3.new(2.2, 2.6, 0.05), CFrame.new(i * 2.7, 4.6, -0.23) * CFrame.Angles(0, 0, math.rad(i * 4)), cores[i + 2], Enum.Material.SmoothPlastic)
	local alfinete = peca("Alfinete" .. (i + 2), Vector3.new(0.25, 0.25, 0.12), CFrame.new(i * 2.7, 5.75, -0.28), Color3.fromRGB(220, 60, 50), Enum.Material.SmoothPlastic)
	alfinete.Shape = Enum.PartType.Ball alfinete.Size = Vector3.new(0.3, 0.3, 0.3)
	local sg = Instance.new("SurfaceGui") sg.Face = Enum.NormalId.Front sg.CanvasSize = Vector2.new(220, 260) sg.LightInfluence = 1 sg.Parent = papel
	local t = Instance.new("TextLabel") t.BackgroundTransparency = 1 t.Size = UDim2.fromScale(1, 1) t.Font = Enum.Font.FredokaOne t.TextScaled = true
	t.TextColor3 = Color3.fromRGB(52, 44, 38) t.Text = ({ "🌱\nJardim", "🌲\nFloresta", "💰\nNegócios" })[i + 2] t.Parent = sg
	local pad = Instance.new("UIPadding") pad.PaddingTop = UDim.new(0, 30) pad.PaddingBottom = UDim.new(0, 30) pad.PaddingLeft = UDim.new(0, 16) pad.PaddingRight = UDim.new(0, 16) pad.Parent = t
end
local placa = peca("Placa", Vector3.new(7.6, 1.1, 0.2), CFrame.new(0, 7.3, -0.25), Color3.fromRGB(255, 200, 60), Enum.Material.SmoothPlastic)
local sg = Instance.new("SurfaceGui") sg.Face = Enum.NormalId.Front sg.CanvasSize = Vector2.new(760, 110) sg.LightInfluence = 1 sg.Parent = placa
local t = Instance.new("TextLabel") t.BackgroundTransparency = 1 t.Size = UDim2.fromScale(1, 1) t.Font = Enum.Font.FredokaOne t.TextScaled = true
t.TextColor3 = Color3.fromRGB(52, 44, 38) t.Text = "QUADRO DE MISSÕES" t.Parent = sg
local at = Instance.new("Attachment") at.Name = "Interacao" at.Position = Vector3.new(0, -1.5, -0.5) at.Parent = quadro
local pr = Instance.new("ProximityPrompt") pr.ActionText = "Ver missões" pr.ObjectText = "Quadro do Jardineiro"
pr.KeyboardKeyCode = Enum.KeyCode.E pr.GamepadKeyCode = Enum.KeyCode.ButtonX pr.HoldDuration = 0 pr.MaxActivationDistance = 10 pr.RequiresLineOfSight = false pr.Parent = at
m.PrimaryPart = quadro
m.ModelStreamingMode = Enum.ModelStreamingMode.Atomic -- chega inteiro no cliente (StreamingEnabled)
m:SetAttribute("Autor", "Claude 2026-11-12 PAD-05")
m.Parent = L
