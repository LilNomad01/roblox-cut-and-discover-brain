--[[
	Caçambas dos 4 lotes com forma de caçamba de entulho  [Claude 2026-11-12]
	Referência (brain 21): caçamba de 8 jardas = topo 3,4 m, FUNDO 2,24 m (laterais das pontas INCLINADAS),
	largura 1,66 m, altura 1,3 m. Proporção usada: fundo = 2/3 do topo.
	Rodado UMA vez no Studio (Edit). Não apaga nada do modelo original:
	  * "Corpo" (que tem o prompt de venda, a placa e a colisão) fica INVISÍVEL e continua funcionando
	  * peças novas (pasta "Forma"): fundo, pontas inclinadas, laterais em trapézio (placa + 2 cunhas),
	    ganchos de içamento e reforços; as rodas vão para baixo do fundo e a faixa encolhe para caber
	Backup: ServerStorage.CacambasBackup_20261112.
]]
local bk = game.ServerStorage:FindFirstChild("CacambasBackup_20261112") or Instance.new("Folder")
bk.Name = "CacambasBackup_20261112"
bk.Parent = game.ServerStorage

local VERDE = Color3.fromRGB(46, 104, 58)
local ESCURO = Color3.fromRGB(34, 40, 36)

local function peca(pai, nome, tam, cf, cor, mat, forma, classe)
	local p = Instance.new(classe or "Part")
	p.Name = nome p.Size = tam p.CFrame = cf p.Color = cor p.Material = mat or Enum.Material.Metal
	p.Anchored = true p.CanCollide = false p.CanQuery = false p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth p.BottomSurface = Enum.SurfaceType.Smooth
	if forma then p.Shape = forma end
	p.Parent = pai
	return p
end

for _, plot in ipairs(workspace.GameWorld.Plots:GetChildren()) do
	local cac = plot:FindFirstChild("Cacamba")
	local corpo = cac and cac:FindFirstChild("Corpo")
	if corpo and not cac:FindFirstChild("Forma") then
		local copia = cac:Clone() copia.Name = plot.Name .. "_Cacamba" copia.Parent = bk
		local base = corpo.CFrame -- centro do corpo; X = comprimento (5,4), Y = altura (2,8), Z = largura (3,8)
		local L, H, W = corpo.Size.X, corpo.Size.Y, corpo.Size.Z
		local topo, fundo = L, L * 2 / 3
		local inc = (topo - fundo) / 2 -- quanto cada ponta avança até o topo
		local cor = corpo.Color
		corpo.Transparency = 1
		local f = Instance.new("Folder") f.Name = "Forma" f.Parent = cac
		-- fundo
		peca(f, "Fundo", Vector3.new(fundo, 0.25, W), base * CFrame.new(0, -H / 2 + 0.125, 0), cor)
		-- pontas inclinadas (topo para fora)
		local ang = math.atan2(inc, H)
		local comp = math.sqrt(inc ^ 2 + H ^ 2)
		for _, lado in ipairs({ -1, 1 }) do
			peca(f, "Ponta", Vector3.new(0.25, comp, W), base * CFrame.new(lado * (fundo / 2 + inc / 2), 0, 0) * CFrame.Angles(0, 0, -lado * ang), cor)
			-- reforços verticais e gancho de içamento em cada ponta
			for _, z in ipairs({ -W / 3, W / 3 }) do
				peca(f, "Reforco", Vector3.new(0.2, comp, 0.3), base * CFrame.new(lado * (fundo / 2 + inc / 2 + 0.1), 0, z) * CFrame.Angles(0, 0, -lado * ang), ESCURO)
			end
			peca(f, "Gancho", Vector3.new(0.25, 0.7, 0.7), base * CFrame.new(lado * (topo / 2 + 0.1), H / 2 - 0.5, 0), ESCURO, Enum.Material.Metal, Enum.PartType.Cylinder)
		end
		-- laterais em trapézio: placa central (largura do fundo) + uma cunha em cada ponta (ângulo reto no topo)
		for _, lz in ipairs({ -1, 1 }) do
			local z = lz * (W / 2 - 0.125)
			peca(f, "Lateral", Vector3.new(fundo, H, 0.25), base * CFrame.new(0, 0, z), cor)
			for _, lx in ipairs({ -1, 1 }) do
				local w = Instance.new("WedgePart")
				w.Name = "LateralCunha" w.Anchored = true w.CanCollide = false w.CanQuery = false w.CanTouch = false
				w.Color = cor w.Material = Enum.Material.Metal
				w.Size = Vector3.new(0.25, H, inc)
				-- cunha: ângulo reto em (Y-, Z+); aqui o eixo Y aponta para BAIXO e o Z para o centro,
				-- então o ângulo reto fica em cima, colado à placa central
				local zW = Vector3.new(-lx, 0, 0)
				local yW = Vector3.new(0, -1, 0)
				local xW = yW:Cross(zW) -- garante base destra (X = Y x Z)
				local pos = base * Vector3.new(lx * (fundo / 2 + inc / 2), 0, z)
				w.CFrame = CFrame.fromMatrix(pos, base:VectorToWorldSpace(xW), base:VectorToWorldSpace(yW), base:VectorToWorldSpace(zW))
				w.Parent = f
			end
			-- reforços horizontais da lateral
			peca(f, "Friso", Vector3.new(fundo + inc, 0.18, 0.12), base * CFrame.new(0, H / 2 - 0.35, lz * (W / 2 + 0.02)), ESCURO)
		end
		-- rodinhas embaixo do fundo e faixa que cabe no trapézio
		for _, r in ipairs(cac:GetChildren()) do
			if r.Name == "Roda" and r:IsA("BasePart") then
				local l = base:ToObjectSpace(r.CFrame)
				r.CFrame = base * CFrame.new(math.sign(l.X) * (fundo / 2 - 0.4), l.Y, l.Z) * (l - l.Position)
			end
		end
		local faixa = cac:FindFirstChild("Faixa")
		if faixa then
			local l = base:ToObjectSpace(faixa.CFrame)
			local largura = fundo + 2 * inc * ((l.Y + H / 2) / H)
			faixa.Size = Vector3.new(largura - 0.2, faixa.Size.Y, faixa.Size.Z)
		end
	end
end
return "ok"
