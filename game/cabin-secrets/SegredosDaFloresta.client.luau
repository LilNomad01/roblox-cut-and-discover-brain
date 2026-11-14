-- [Claude 2026-11-11] Segredos da Floresta (cliente). Só efeitos locais; nada de recompensa aqui.
-- Lê o registro público ReplicatedStorage.SegredosDaFloresta (posto pelo GameServer) e o atributo
-- ForestClaimedSecrets do jogador (lista do que ELE já coletou).
--  * pista: vaga-lumes sobre o mato onde há um segredo ainda escondido (região, não o ponto exato)
--  * revelação: som "Desbloqueio", explosão de folhas e brilhos, baú sobe do chão
--  * revelado e ainda não coletado por você: feixe de luz na cor da raridade, visível de longe
--  * coleta: tampa abre, chuva de moedas, som "Moeda" e aviso "Segredos da floresta: n/total"
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local okSons,Sons=pcall(function() return require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Sons")) end)
local function som(nome,pos) if okSons and Sons then pcall(Sons.tocar,nome,{pos=pos}) end end

local BRILHO="rbxasset://textures/particles/sparkles_main.dds" -- textura nativa do Roblox
local function rgb(r,g,b) return Color3.fromRGB(r,g,b) end
local CORES={Comum=rgb(240,236,214),Incomum=rgb(110,224,120),Raro=rgb(90,170,255),Lendario=rgb(255,202,70),Mitologico=rgb(206,124,255)}
local COR_RELIQUIA=rgb(103,228,196)
local RAIO_PISTA=85

local fxFolder=Instance.new("Folder") fxFolder.Name="SegredosFX_Local" fxFolder.Parent=workspace
local rng=Random.new()
local estado={} -- id -> {cfg,ponto,tipo,cor,pista,feixe,coletado}
local modelos={} -- id -> Model (quando carregado pelo streaming)
local tampaAberta={} -- Model -> true

local function peca(nome,size,cf,cor,material,shape)
	local p=Instance.new("Part")
	p.Name,p.Size,p.CFrame,p.Color=nome,size,cf,cor
	p.Material=material or Enum.Material.Neon
	if shape then p.Shape=shape end
	p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery,p.CastShadow=true,false,false,false,false
	p.Parent=fxFolder
	return p
end
local function emissor(parent,props)
	local e=Instance.new("ParticleEmitter")
	e.Texture=BRILHO e.LightInfluence=0
	for k,v in pairs(props) do e[k]=v end
	e.Parent=parent
	return e
end
local function seq(a,b) return NumberSequence.new({NumberSequenceKeypoint.new(0,a),NumberSequenceKeypoint.new(.5,b),NumberSequenceKeypoint.new(1,0)}) end

local function coletados()
	local set={}
	for id in string.gmatch(player:GetAttribute("ForestClaimedSecrets") or "", "[^,]+") do set[id]=true end
	return set
end

---------------------------------------------------------------- pista (vaga-lumes)
local function criarPista(st)
	if st.pista then return end
	-- deslocado do ponto exato: indica a região, não entrega o lugar
	-- acima do mato alto (os tufos chegam a ~5 studs), para serem vistos de longe
	local off=Vector3.new(rng:NextNumber(-3.5,3.5),5,rng:NextNumber(-3.5,3.5))
	local p=peca("PistaVagalumes",Vector3.new(9,3.5,9),CFrame.new(st.ponto+off),Color3.new(),Enum.Material.SmoothPlastic)
	p.Transparency=1
	emissor(p,{Color=ColorSequence.new(rgb(232,255,140)),LightEmission=1,Brightness=5,Size=seq(.15,.95),Transparency=NumberSequence.new(0),
		Lifetime=NumberRange.new(2.5,4),Rate=8,Speed=NumberRange.new(.3,.9),SpreadAngle=Vector2.new(180,180),Drag=.8,
		Acceleration=Vector3.new(0,.12,0),RotSpeed=NumberRange.new(-40,40),Shape=Enum.ParticleEmitterShape.Box,
		ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume,Enabled=false})
	st.pista=p
end
local function removerPista(st) if st.pista then st.pista:Destroy() st.pista=nil end end

---------------------------------------------------------------- feixe de luz
local function criarFeixe(st)
	if st.feixe then return end
	local alto=st.ponto.Y<-5 and 8 or 26 -- subterrâneo: feixe curto, só dentro da cripta
	local m=Instance.new("Model") m.Name="FeixeSegredo_"..st.id m.Parent=fxFolder
	local nucleo=peca("Nucleo",Vector3.new(alto,.7,.7),CFrame.new(st.ponto+Vector3.new(0,alto/2+1,0))*CFrame.Angles(0,0,math.pi/2),st.cor,Enum.Material.Neon,Enum.PartType.Cylinder)
	nucleo.Transparency=.45 nucleo.Parent=m
	local halo=peca("Halo",Vector3.new(alto,2.2,2.2),nucleo.CFrame,st.cor,Enum.Material.Neon,Enum.PartType.Cylinder)
	halo.Transparency=.85 halo.Parent=m
	local base=peca("Base",Vector3.new(3,.5,3),CFrame.new(st.ponto+Vector3.new(0,.8,0)),st.cor,Enum.Material.SmoothPlastic)
	base.Transparency=1 base.Parent=m
	emissor(base,{Color=ColorSequence.new(st.cor),LightEmission=1,Size=seq(.1,.45),Lifetime=NumberRange.new(1.2,2),Rate=8,
		Speed=NumberRange.new(2,4),SpreadAngle=Vector2.new(15,15),EmissionDirection=Enum.NormalId.Top})
	st.feixe={model=m,nucleo=nucleo,halo=halo}
end
local function removerFeixe(st) if st.feixe then st.feixe.model:Destroy() st.feixe=nil end end

---------------------------------------------------------------- explosões
local function explosao(pos,cores,qtd,vel)
	local p=peca("Explosao",Vector3.one,CFrame.new(pos),Color3.new(),Enum.Material.SmoothPlastic)
	p.Transparency=1
	for _,c in ipairs(cores) do
		local e=emissor(p,{Color=ColorSequence.new(c),LightEmission=.6,Size=seq(.25,.5),Lifetime=NumberRange.new(.9,1.6),
			Speed=NumberRange.new(vel*.6,vel),SpreadAngle=Vector2.new(70,70),Acceleration=Vector3.new(0,-28,0),Drag=1.2,
			EmissionDirection=Enum.NormalId.Top,RotSpeed=NumberRange.new(-180,180),Rate=0})
		e:Emit(qtd)
	end
	game:GetService("Debris"):AddItem(p,3)
end

---------------------------------------------------------------- modelo: subir do chão e abrir tampa
local function tampaDe(model)
	for _,d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") and d.Name:sub(1,5)=="Tampa" then return d end
	end
end
local function abrirTampa(model,instantaneo)
	if tampaAberta[model] then return end
	local tampa=tampaDe(model) if not tampa then return end
	tampaAberta[model]=true
	local centro=model:GetPivot().Position
	local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local fora=root and (centro-root.Position)*Vector3.new(1,0,1) or Vector3.new(0,0,1)
	fora=fora.Magnitude>.01 and fora.Unit or Vector3.new(0,0,1)
	local eixo=Vector3.yAxis:Cross(fora)
	local meio=math.max(tampa.Size.X,tampa.Size.Z)*.4
	local dobradica=tampa.Position+fora*meio
	local alvo=CFrame.new(dobradica)*CFrame.fromAxisAngle(eixo,math.rad(70))*CFrame.new(-dobradica)*tampa.CFrame
	if instantaneo then tampa.CFrame=alvo return end
	local inicio=tampa.CFrame
	local v=Instance.new("NumberValue")
	v.Changed:Connect(function(k) if tampa.Parent then tampa.CFrame=inicio:Lerp(alvo,k) end end)
	local tw=TweenService:Create(v,TweenInfo.new(.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Value=1})
	tw.Completed:Once(function() v:Destroy() end)
	tw:Play()
end
local function subirDoChao(model)
	local fim=model:GetPivot()
	model:PivotTo(fim-Vector3.new(0,2.4,0))
	local v=Instance.new("NumberValue")
	v.Changed:Connect(function(k) if model.Parent then model:PivotTo((fim-Vector3.new(0,2.4,0)):Lerp(fim,k)) end end)
	local tw=TweenService:Create(v,TweenInfo.new(.75,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Value=1})
	tw.Completed:Once(function() v:Destroy() if model.Parent then model:PivotTo(fim) end end)
	tw:Play()
end
local function brilhoReliquia(model,cor)
	if model:FindFirstChild("BrilhoReliquiaLocal",true) then return end
	local alvo=model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not alvo then return end
	local l=Instance.new("PointLight") l.Name="BrilhoReliquiaLocal" l.Color=cor l.Brightness=1.2 l.Range=12 l.Parent=alvo
end

---------------------------------------------------------------- aviso "Segredos n/total"
local gui=Instance.new("ScreenGui") gui.Name="SegredosAviso" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=40
gui.Parent=player:WaitForChild("PlayerGui")
local card=Instance.new("Frame") card.AnchorPoint=Vector2.new(.5,0) card.Position=UDim2.new(.5,0,0,-120) card.Size=UDim2.fromOffset(340,74)
card.BackgroundColor3=rgb(255,246,214) card.Parent=gui
Instance.new("UICorner",card).CornerRadius=UDim.new(0,16)
local st1=Instance.new("UIStroke") st1.Color=rgb(52,44,38) st1.Thickness=3 st1.Parent=card
local titulo=Instance.new("TextLabel") titulo.BackgroundTransparency=1 titulo.Size=UDim2.new(1,0,0,38) titulo.Position=UDim2.fromOffset(0,6)
titulo.Font=Enum.Font.FredokaOne titulo.TextSize=28 titulo.TextColor3=rgb(52,44,38) titulo.Text="SEGREDO ENCONTRADO!" titulo.Parent=card
local sub=Instance.new("TextLabel") sub.BackgroundTransparency=1 sub.Size=UDim2.new(1,0,0,22) sub.Position=UDim2.fromOffset(0,44)
sub.Font=Enum.Font.GothamBold sub.TextSize=16 sub.TextColor3=rgb(96,82,60) sub.Text="" sub.Parent=card
local avisoSeq=0
local function aviso(n,total)
	avisoSeq+=1 local meu=avisoSeq
	sub.Text=("Segredos da floresta: %d / %d"):format(n,total)
	card.Position=UDim2.new(.5,0,0,-120)
	TweenService:Create(card,TweenInfo.new(.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(.5,0,0,96)}):Play()
	task.delay(2.8,function()
		if meu~=avisoSeq then return end
		TweenService:Create(card,TweenInfo.new(.3,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(.5,0,0,-120)}):Play()
	end)
end

---------------------------------------------------------------- registro e eventos
local reg
repeat reg=ReplicatedStorage:FindFirstChild("SegredosDaFloresta") if not reg then task.wait(1) end until reg

local snapshot=coletados()
local function atualizar(st,animar)
	local revelado=st.cfg:GetAttribute("Revelado")==true
	st.coletado=coletados()[st.id]==true
	if not revelado then criarPista(st) else removerPista(st) end
	if revelado and not st.coletado then criarFeixe(st) else removerFeixe(st) end
	local m=modelos[st.id]
	if m and m.Parent then
		if revelado and st.tipo=="artifact" then brilhoReliquia(m,st.cor) end
		if st.coletado and st.tipo=="chest" then abrirTampa(m,not animar) end
	end
end

local function registrar(cfg)
	if estado[cfg.Name] then return end
	local tipo=cfg:GetAttribute("Tipo")
	local st={id=cfg.Name,cfg=cfg,tipo=tipo,ponto=cfg:GetAttribute("Ponto") or Vector3.zero,
		cor=tipo=="chest" and (CORES[cfg:GetAttribute("Raridade")] or CORES.Comum) or COR_RELIQUIA}
	estado[cfg.Name]=st
	atualizar(st,false)
	cfg:GetAttributeChangedSignal("Revelado"):Connect(function()
		if cfg:GetAttribute("Revelado")~=true then return end
		local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local perto=root and (root.Position-st.ponto).Magnitude<150
		if perto then
			som("Desbloqueio",st.ponto)
			explosao(st.ponto+Vector3.new(0,1,0),{rgb(96,170,80),rgb(140,200,90),st.cor},18,16)
			local m=modelos[st.id]
			if m and m.Parent and st.tipo=="chest" then subirDoChao(m) end
		end
		atualizar(st,true)
	end)
end
for _,c in ipairs(reg:GetChildren()) do registrar(c) end
reg.ChildAdded:Connect(registrar)

local function verModelo(d)
	if not d:IsA("Model") then return end
	local id=d:GetAttribute("SegredoId")
	if not id then return end
	modelos[id]=d
	local st=estado[id]
	if st then atualizar(st,false) end
end
for _,d in ipairs(workspace:GetDescendants()) do verModelo(d) end
workspace.DescendantAdded:Connect(function(d)
	if d:IsA("Model") then
		verModelo(d)
		d:GetAttributeChangedSignal("SegredoId"):Once(function() verModelo(d) end)
	end
end)

player:GetAttributeChangedSignal("ForestClaimedSecrets"):Connect(function()
	local agora=coletados()
	for id in pairs(agora) do
		if not snapshot[id] and estado[id] then
			local st=estado[id]
			som("Moeda",st.ponto)
			explosao(st.ponto+Vector3.new(0,2,0),{rgb(255,214,70),rgb(255,240,150)},34,20)
			removerFeixe(st)
			local m=modelos[id]
			if m and m.Parent then
				if st.tipo=="chest" then abrirTampa(m,false) else brilhoReliquia(m,st.cor) end
			end
			local n,total=0,0
			for _,c in ipairs(reg:GetChildren()) do total+=1 if agora[c.Name] then n+=1 end end
			aviso(n,total)
		end
	end
	snapshot=agora
end)

-- vaga-lumes só perto (economia) e feixes pulsando
local acum=0
RunService.Heartbeat:Connect(function(dt)
	local t=os.clock()
	for _,st in pairs(estado) do
		if st.feixe then
			st.feixe.nucleo.Transparency=.45+math.sin(t*2.2)*.12
			st.feixe.halo.Transparency=.85+math.sin(t*2.2+1)*.06
		end
	end
	acum+=dt
	if acum<.5 then return end
	acum=0
	local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	for _,st in pairs(estado) do
		if st.pista then
			local e=st.pista:FindFirstChildOfClass("ParticleEmitter")
			if e then e.Enabled=root~=nil and (root.Position-st.ponto).Magnitude<RAIO_PISTA end
		end
	end
end)
