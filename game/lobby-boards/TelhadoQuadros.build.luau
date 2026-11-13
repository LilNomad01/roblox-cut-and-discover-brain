--[[
	Quadros de Missões e Ranking: telhado de duas águas  [Claude 2026-11-13, MOD-02]
	Rodado UMA vez no Studio (Edit). O "Telhado" (uma tábua reta) fica invisível e continua como referência.
	Por cima entram: duas águas de tábuas vermelhas (25°), beirais claros, cumeeira redonda e sapatas
	nos pés dos postes. No Ranking, a "Placa" ("MELHORES JARDINEIROS") foi trazida 1,1 para a frente, porque a
	água da frente a escondia.
	Backup dos telhados antigos: ServerStorage.CortadoresBackup_20261113.<Quadro>_Telhado.
	Os quadros estão em workspace.GameWorld.Lobby (posições do Codex: (-15,-40) e (15,-40)).
]]
local bk = game.ServerStorage.CortadoresBackup_20261113
for _, n in ipairs({ "QuadroMissoes", "QuadroRanking" }) do
	local m = workspace.GameWorld.Lobby:FindFirstChild(n)
	local t = m and m:FindFirstChild("Telhado")
	if t and not m:FindFirstChild("TelhadoAgua") then
		local c = t:Clone() c.Name = n .. "_Telhado" c.Parent = bk
		t.Transparency = 1
		local W, D = t.Size.X, t.Size.Z
		local ang = math.rad(25)
		local meia = D / 2 + 0.25
		local cor = Color3.fromRGB(150, 62, 46)
		local function peca(nome, tam, cf, cr, mat, forma)
			local p = Instance.new("Part")
			p.Name = nome p.Size = tam p.CFrame = cf p.Color = cr p.Material = mat
			p.Anchored = true p.CanCollide = false p.CanQuery = false p.CanTouch = false
			p.TopSurface = Enum.SurfaceType.Smooth p.BottomSurface = Enum.SurfaceType.Smooth
			if forma then p.Shape = forma end
			p.Parent = m
			return p
		end
		local sobe = meia / 2 * math.sin(ang)
		for _, lado in ipairs({ -1, 1 }) do
			peca("TelhadoAgua", Vector3.new(W + 0.6, 0.22, meia), t.CFrame * CFrame.new(0, sobe, lado * meia / 2 * math.cos(ang)) * CFrame.Angles(lado * ang, 0, 0), cor, Enum.Material.WoodPlanks)
			peca("Beiral", Vector3.new(W + 0.7, 0.14, 0.18), t.CFrame * CFrame.new(0, sobe - meia / 2 * math.sin(ang) - 0.02, lado * meia * math.cos(ang)), Color3.fromRGB(235, 225, 200), Enum.Material.Wood)
		end
		peca("Cumeeira", Vector3.new(W + 0.7, 0.32, 0.32), t.CFrame * CFrame.new(0, sobe * 2 + 0.08, 0), Color3.fromRGB(110, 45, 34), Enum.Material.Wood, Enum.PartType.Cylinder)
		-- sapatas nos pés dos postes
		for _, pn in ipairs({ "PosteE", "PosteD" }) do
			local po = m:FindFirstChild(pn)
			if po then peca("PosteTampa", Vector3.new(1.05, 0.25, 1.05), po.CFrame * CFrame.new(0, -po.Size.Y / 2 + 0.6, 0), Color3.fromRGB(90, 60, 38), Enum.Material.Wood) end
		end
		if n == "QuadroRanking" and m:FindFirstChild("Placa") then
			m.Placa.CFrame = m.Placa.CFrame + m:GetPivot().LookVector * 1.1
		end
	end
end
return "ok"
