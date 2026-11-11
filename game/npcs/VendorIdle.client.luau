-- [Claude 2026-11-11] NPCs vivos (cliente). Substitui o idle simples anterior
-- (backup: ServerStorage.NpcBackup_20261111.VendorIdle). Tudo local e procedural: sem AnimationId/SoundId.
--  * animação parada própria de cada NPC (atributo NpcTipo, posto pelo VendorAvatar no servidor)
--  * vira o corpo e a cabeça para o jogador que chega perto e acena
--  * placa de nome e função (some de longe, não atravessa paredes)
--  * balão de fala com cumprimento, fala do momento e dicas reais (ReplicatedStorage.Shared.NpcFalas)
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local ProximityPromptService=game:GetService("ProximityPromptService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TextService=game:GetService("TextService")
local Falas=require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NpcFalas"))
local player=Players.LocalPlayer

local RAIO_OLHAR=16   -- vira para o jogador
local RAIO_FALA=12    -- começa a conversa
local RAIO_SAIR=18    -- conversa reinicia só depois de se afastar disto
local RAIO_ANIMAR=120 -- longe disto o NPC não é animado (economia)
local JUNTAS={"Root","Waist","Neck","LeftShoulder","LeftElbow","LeftWrist","RightShoulder","RightElbow","RightWrist","LeftHip","RightHip","LeftKnee","RightKnee"}
local CORES={Jardineiro=Color3.fromRGB(96,150,84),Guto=Color3.fromRGB(99,202,112),Lia=Color3.fromRGB(90,175,235),Teca=Color3.fromRGB(176,128,220)}
local MODAIS={"ForestShopOpen","LojaAberta","MenuJogadorAberto","SkillTreeOpen"}
local TINTA=Color3.fromRGB(52,44,38)
local PAPEL=Color3.fromRGB(255,251,240)

local npcs={}
local vistos={} -- tipos já cumprimentados nesta sessão (não é salvo)

local function R(x,y,z) return CFrame.Angles(x,y or 0,z or 0) end
local function suave(x) x=math.clamp(x,0,1) return x*x*(3-2*x) end
-- envelope de um gesto: entra em 0,3 s, fica, sai em 0,3 s
local function gesto(u,dur) if u<0 or u>dur then return 0 end return math.min(suave(u/.3),suave((dur-u)/.3)) end
local function lerpCF(a,b,k) return a:Lerp(b,k) end

local function novoLabel(parent,props)
	local l=Instance.new("TextLabel")
	l.BackgroundTransparency=1
	for k,v in pairs(props) do l[k]=v end
	l.Parent=parent
	return l
end

local function criarEtiqueta(st)
	local head=st.model:FindFirstChild("Head") if not head then return end
	local cor=CORES[st.tipo] or CORES.Jardineiro
	local b=Instance.new("BillboardGui")
	b.Name="NpcEtiqueta" b.Adornee=head b.Size=UDim2.fromOffset(190,50) b.StudsOffset=Vector3.new(0,2.35,3)
	b.MaxDistance=45 b.LightInfluence=0 b.AlwaysOnTop=false b.ResetOnSpawn=false
	novoLabel(b,{Name="Nome",Size=UDim2.new(1,0,0,26),Font=Enum.Font.FredokaOne,TextSize=24,TextColor3=Color3.new(1,1,1),
		TextStrokeColor3=TINTA,TextStrokeTransparency=0,Text=st.model:GetAttribute("NpcNome") or st.tipo})
	local chip=Instance.new("Frame") chip.Name="Papel" chip.AnchorPoint=Vector2.new(.5,0) chip.Position=UDim2.new(.5,0,0,27)
	chip.AutomaticSize=Enum.AutomaticSize.X chip.Size=UDim2.fromOffset(0,20) chip.BackgroundColor3=cor chip.Parent=b
	local c=Instance.new("UICorner") c.CornerRadius=UDim.new(1,0) c.Parent=chip
	local s=Instance.new("UIStroke") s.Color=TINTA s.Thickness=2 s.Parent=chip
	local p=Instance.new("UIPadding") p.PaddingLeft=UDim.new(0,9) p.PaddingRight=UDim.new(0,9) p.Parent=chip
	novoLabel(chip,{Size=UDim2.fromScale(0,1),AutomaticSize=Enum.AutomaticSize.X,Font=Enum.Font.GothamBold,TextSize=13,
		TextColor3=Color3.new(1,1,1),TextStrokeColor3=TINTA,TextStrokeTransparency=.4,Text=st.model:GetAttribute("NpcPapel") or ""})
	b.Parent=head
	st.etiqueta=b
end

local function criarBalao(st)
	local head=st.model:FindFirstChild("Head") if not head then return end
	local b=Instance.new("BillboardGui")
	b.Name="NpcBalao" b.Adornee=head b.Size=UDim2.fromOffset(300,140) b.StudsOffset=Vector3.new(0,3.2,3)
	b.SizeOffset=Vector2.new(0,.5) b.MaxDistance=60 b.LightInfluence=0 b.AlwaysOnTop=false b.Enabled=false b.ResetOnSpawn=false
	local box=Instance.new("Frame") box.Name="Caixa" box.AnchorPoint=Vector2.new(.5,1) box.Position=UDim2.new(.5,0,1,-12)
	box.AutomaticSize=Enum.AutomaticSize.XY box.Size=UDim2.fromOffset(0,0) box.BackgroundColor3=PAPEL box.ZIndex=2 box.Parent=b
	local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,14) c.Parent=box
	local s=Instance.new("UIStroke") s.Color=TINTA s.Thickness=3 s.Parent=box
	local p=Instance.new("UIPadding") p.PaddingLeft=UDim.new(0,14) p.PaddingRight=UDim.new(0,14) p.PaddingTop=UDim.new(0,9) p.PaddingBottom=UDim.new(0,10) p.Parent=box
	local label=novoLabel(box,{Name="Texto",AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.fromOffset(240,0),Font=Enum.Font.GothamBold,
		TextSize=17,TextColor3=TINTA,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3,Text=""})
	-- bico do balão
	local tail=Instance.new("Frame") tail.Name="Bico" tail.AnchorPoint=Vector2.new(.5,.5) tail.Position=UDim2.new(.5,0,1,-12)
	tail.Size=UDim2.fromOffset(16,16) tail.Rotation=45 tail.BackgroundColor3=PAPEL tail.ZIndex=1 tail.Parent=b
	local ts=Instance.new("UIStroke") ts.Color=TINTA ts.Thickness=3 ts.Parent=tail
	local scale=Instance.new("UIScale") scale.Scale=1 scale.Parent=box
	b.Parent=head
	st.balao,st.texto,st.escala,st.bico=b,label,scale,tail
end

local function esconderBalao(st)
	st.fila=nil st.falaAte=nil
	if st.balao then st.balao.Enabled=false end
end

local function falar(st,texto)
	if not st.balao then criarBalao(st) end
	if not st.balao then return end
	-- largura do balão = largura real do texto (até 250 px), para não quebrar linha cedo
	local medida=TextService:GetTextSize(texto,17,Enum.Font.GothamBold,Vector2.new(250,1000))
	st.texto.Size=UDim2.fromOffset(math.ceil(medida.X)+2,0)
	st.texto.Text=texto
	st.texto.MaxVisibleGraphemes=0
	st.digInicio=os.clock()
	st.digTotal=utf8.len(texto) or #texto
	st.falaAte=os.clock()+math.max(3.6,(st.digTotal/45)+2.6)
	st.balao.Enabled=true
	st.escala.Scale=.6
	TweenService:Create(st.escala,TweenInfo.new(.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
end

local function podeConversar(st)
	for _,a in ipairs(MODAIS) do if player:GetAttribute(a) then return false end end
	if st.tipo=="Jardineiro" then
		-- o jardineiro fala do jardim do dono do lote; com os outros jogadores ele fica quieto
		local plot=st.model.Parent
		if not plot or plot:GetAttribute("OwnerUserId")~=player.UserId then return false end
	end
	return Falas[st.tipo]~=nil
end

local function montarFila(st)
	local f=Falas[st.tipo]
	local fila={}
	if not vistos[st.tipo] then
		vistos[st.tipo]=true
		table.insert(fila,f.primeira)
	else
		table.insert(fila,f.saudacao[math.random(1,#f.saudacao)])
	end
	local ok,ctx=pcall(f.contexto,player)
	if ok and ctx then table.insert(fila,ctx) end
	st.dica=(st.dica or math.random(0,#f.dicas-1))%#f.dicas+1
	table.insert(fila,f.dicas[st.dica])
	st.fila=fila
	st.proxima=os.clock()+.35
end

local function watch(v)
	if npcs[v] or not v:IsA("Model") or not v:GetAttribute("AvatarVendedor") then return end
	if v.Name:find("^VendorAvatarTemplate") then return end
	npcs[v]={model=v,tipo=v:GetAttribute("NpcTipo") or "Jardineiro",fase=math.random()*20,j={},nJ=-1,jEm=0,
		corpoYaw=0,cabecaYaw=0,perto=false,conversa=false}
end
workspace.DescendantAdded:Connect(watch)
for _,v in ipairs(workspace:GetDescendants()) do watch(v) end
-- o NpcTipo pode chegar depois do modelo
workspace.DescendantAdded:Connect(function(d)
	if d:IsA("Model") and d:GetAttribute("AvatarVendedor")==nil then
		d:GetAttributeChangedSignal("AvatarVendedor"):Once(function() watch(d) end)
	end
end)

-- quem abre a loja/serviço com E encerra a conversa daquele NPC
ProximityPromptService.PromptTriggered:Connect(function(prompt)
	local holder=prompt.Parent
	local pos=holder and (holder:IsA("Attachment") and holder.WorldPosition or holder:IsA("BasePart") and holder.Position)
	if not pos then return end
	for _,st in pairs(npcs) do
		local base=st.model.PrimaryPart
		if base and (base.Position-pos).Magnitude<8 then esconderBalao(st) st.conversa=true end
	end
end)

local function juntasDe(st)
	if st.nJ>=#JUNTAS and os.clock()-st.jEm<5 then return st.j end
	if os.clock()-st.jEm<1 then return st.j end
	st.j,st.nJ,st.jEm={},0,os.clock()
	for _,d in ipairs(st.model:GetDescendants()) do
		if (d:IsA("Motor6D") or d:IsA("AnimationConstraint")) and table.find(JUNTAS,d.Name) then st.j[d.Name]=d st.nJ+=1 end
	end
	return st.j
end

-- poses de cada tipo no instante t (sem o jogador)
local POSES={}
function POSES.Jardineiro(t,T)
	T.Root=R(0,0,math.sin(t*.55)*.025)
	T.RightShoulder=R(.08,0,-.04) T.RightElbow=R(.15)
	-- a cada 11 s enxuga a testa com a mão esquerda
	local k=gesto(t%11,1.9)
	T.LeftShoulder=R(2.3*k,math.sin(t*7)*.12*k,.35*k) T.LeftElbow=R(1.9*k) T.Neck=R(-.08*k)
end
function POSES.Guto(t,T)
	-- polegares nas alças da mochila
	T.LeftShoulder=R(.42,0,.18) T.RightShoulder=R(.42,0,-.18) T.LeftElbow=R(1.45) T.RightElbow=R(1.45)
	-- a cada 7 s dá um pulinho ajeitando a mochila
	local u=t%7
	local hop=u<.5 and math.sin(u/.5*math.pi)*.18 or 0
	T.Root=CFrame.new(0,hop,0)
	T.Neck=R(0,math.sin(t*.4)*.25,0)
end
function POSES.Lia(t,T)
	-- debruçada no balcão lendo o mapa; a cada 9 s olha o horizonte com a mão na testa
	local k=gesto(t%9,2.6)
	T.Waist=R(-.18*(1-k)) T.Neck=R(-.32*(1-k)+.05*k,math.sin(t*1.3)*.35*k,0)
	T.LeftShoulder=R(.75,0,.12) T.LeftElbow=R(.55)
	T.RightShoulder=lerpCF(R(.75,0,-.12),R(2.4,0,-.4),k) T.RightElbow=R(.55+1.55*k)
end
function POSES.Teca(t,T)
	-- rega as plantas a cada 6 s
	local k=gesto(t%6,2.4)
	T.RightShoulder=R(.12+.83*k,0,-.04+.14*k) T.RightElbow=R(.2+.15*k) T.RightWrist=R(-1.3*k)
	T.Neck=R(-.35*k) T.Waist=R(-.12*k)
	T.LeftShoulder=R(.06,0,.06) T.LeftElbow=R(.2)
end

local ultimo=os.clock()
RunService.PreSimulation:Connect(function()
	local agora=os.clock()
	local dt=math.min(agora-ultimo,.1) ultimo=agora
	local t0=workspace:GetServerTimeNow()
	local char=player.Character
	local root=char and char:FindFirstChild("HumanoidRootPart")
	-- NPC mais próximo que pode conversar
	local falante,menor=nil,math.huge
	for model,st in pairs(npcs) do
		if not model.Parent then npcs[model]=nil continue end
		local base=model.PrimaryPart if not base then continue end
		local dist=root and (root.Position-base.Position).Magnitude or math.huge
		st.dist=dist
		if dist<RAIO_FALA and dist<menor and podeConversar(st) then falante,menor=st,dist end
	end
	for model,st in pairs(npcs) do
		local base=model.PrimaryPart
		if not base or st.dist>RAIO_ANIMAR then continue end
		if not st.etiqueta then criarEtiqueta(st) end
		local js=juntasDe(st)
		local t=t0+st.fase
		local T={}
		local pose=POSES[st.tipo] or POSES.Jardineiro
		pose(t,T)
		T.Waist=(T.Waist or CFrame.identity)*R(math.sin(t*1.7)*.012) -- respiração
		-- olhar e virar para o jogador
		local perto=st.dist<RAIO_OLHAR
		local alvoCorpo,alvoCabeca=0,0
		if perto and root then
			local l=base.CFrame:PointToObjectSpace(root.Position)
			local yaw=math.atan2(-l.X,-l.Z)
			alvoCorpo=math.clamp(yaw*.6,-1,1)
			alvoCabeca=math.clamp(yaw-alvoCorpo,-.6,.6)
		end
		local a=math.min(1,dt*4)
		st.corpoYaw+=(alvoCorpo-st.corpoYaw)*a
		st.cabecaYaw+=(alvoCabeca-st.cabecaYaw)*a
		T.Root=R(0,st.corpoYaw,0)*(T.Root or CFrame.identity)
		if perto then
			-- olhando o jogador, a cabeça para de "procurar" e a Lia larga o mapa
			T.Neck=R(0,st.cabecaYaw,0)*R(st.tipo=="Lia" and -.05 or 0)
			if st.tipo=="Lia" then T.Waist=R(math.sin(t*1.7)*.012) end
		end
		-- acena quando o jogador chega
		local chegou=st.dist<RAIO_FALA
		if chegou and not st.perto then st.aceno=agora end
		st.perto=chegou
		if st.aceno then
			local u=agora-st.aceno
			local k=gesto(u,1.7)
			if k>0 then
				T.LeftShoulder=lerpCF(T.LeftShoulder or CFrame.identity,R(1.9,0,.35),k)
				T.LeftElbow=lerpCF(T.LeftElbow or CFrame.identity,R(.7+math.sin(u*9)*.25),k)
			elseif u>1.7 then st.aceno=nil end
		end
		for _,nome in ipairs(JUNTAS) do
			local j=js[nome]
			if j and j.Parent then j.Transform=T[nome] or CFrame.identity end
		end
		-- jardineiro: o selo de status do servidor aparece de longe; de perto, placa e balão assumem
		local selo=model:FindFirstChild("Bubble")
		if st.tipo=="Jardineiro" and selo and selo:IsA("BillboardGui") then
			selo.Enabled=st.dist>RAIO_SAIR
			if st.etiqueta then st.etiqueta.Enabled=st.dist<=RAIO_SAIR end
		end
		-- conversa
		if st==falante then
			if not st.conversa then st.conversa=true montarFila(st) end
		elseif st.dist>RAIO_SAIR then
			st.conversa=false
			if st.balao and st.balao.Enabled then esconderBalao(st) end
		elseif st.balao and st.balao.Enabled and not podeConversar(st) then
			esconderBalao(st)
		end
		if st.balao and st.balao.Enabled then
			st.texto.MaxVisibleGraphemes=math.min(st.digTotal,math.floor((agora-st.digInicio)*45))
			if st.falaAte and agora>st.falaAte then
				st.balao.Enabled=false st.falaAte=nil
				st.proxima=agora+.9
			end
		elseif st.fila and #st.fila>0 and st==falante and agora>=(st.proxima or 0) then
			falar(st,table.remove(st.fila,1))
		end
	end
end)
