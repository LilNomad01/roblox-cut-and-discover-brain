-- Editor scenery is visual only. Remove it before any runtime builders start.
local editorPreview = workspace:FindFirstChild("ForestEditorPreview")
if editorPreview and editorPreview:GetAttribute("EditorOnlyForestPreview") == true then
    editorPreview:Destroy()
end
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local Config=require(game.ReplicatedStorage.Shared.GameConfig)
local Rules=require(script.Parent.Rules)
local Profiles=require(script.Parent.Profiles)
local Commerce=require(script.Parent.ForestCommerceService)
local Economia=require(game.ServerScriptService:WaitForChild("Economia"))
local Skills=require(script.Parent.SkillService)
Skills.start()
local CORTADOR_NIVEL={Basico=1,Eletrico=2,Turbo=3,Trator=3,OffRoad=3,Colheitadeira=3,Mega=3,Imperial=3}
local CORTADOR_ESCALA={Trator=1.3,OffRoad=1.36,Colheitadeira=1.42,Mega=1.48,Imperial=1.58}
local Mount=require(script.Parent.MowerMount)
local VendorAvatar=require(script.Parent.VendorAvatar)
local Reliquias=require(script.Parent.ReliquiasDaFloresta) -- [Claude 2026-11-11] visual próprio das relíquias
local MissoesSinal=require(script.Parent.MissoesSinal) -- [Claude 2026-11-12] Quadro do Jardineiro
local TufoDourado=require(script.Parent.TufoDourado) -- [Claude 2026-11-11] grama dourada (variante rara)
local Scenery=require(script.Parent.ForestScenery)
local Art=require(script.Parent.WorldArt)
local Signs=require(script.Parent.SignKit)
local GrassStyle=require(game.ReplicatedStorage.Shared.ForestVisualStyle)
local world=require(script.Parent.World).build()
require(script.Parent.WorldGeography).startGrounding()
require(script.Parent.LobbyGardenArt).start(world)
require(script.Parent.LobbyLife).build(world)
local remotes=Instance.new("Folder") remotes.Name="GameRemotes" remotes.Parent=game.ReplicatedStorage
for _,name in ipairs({"CutIntent","UpgradeRequest","NewJobRequest","StateSync","FXEvent","Ready"}) do
    local remote=Instance.new("RemoteEvent") remote.Name=name remote.Parent=remotes
end
local sessions={}
local reserved={}
local random=Random.new()
local closing=false
local serviceNpcRefresh -- referenced before its definition
local function sync(player,message)
    local s=sessions[player] if not s or not player.Parent then return end
    if message then Economia.Notificar(player,message,"ouro") message=nil end
    local ativa=player:GetAttribute("FerramentaAtiva")
    local objective=ativa=="Cortador" and "Empurre o cortador pela grama"
        or ativa=="Nenhuma" and "Escolha uma ferramenta: teclas 1 a 4" -- [Claude 2026-11-11] mão vazia
        or "Use F ou clique para cortar com a ferramenta"
    if s.job.finished then objective="Jardim restaurado! A grama volta a crescer em instantes."
    elseif s.job.secretRevealed and not s.job.secretClaimed then objective="Abra o baú revelado no gramado"
    elseif (player:GetAttribute("Saco") or 0)>=(player:GetAttribute("SacoMax") or 1) then objective="Saco cheio! Venda na ca\195\167amba dourada" end
    serviceNpcRefresh(s)
    -- [Claude 2026-11-11] progresso do jardim para as falas do jardineiro (só leitura no cliente)
    player:SetAttribute("JardimCortes",s.job.cutCount or 0)
    player:SetAttribute("JardimPronto",s.job.finished==true)
    local nextLevel=Config.Levels[s.profile.mowerLevel+1]
    remotes.StateSync:FireClient(player,{coins=player:GetAttribute("Moedas") or 0,level=s.profile.mowerLevel,count=s.job.cutCount,
        finished=s.job.finished,objective=objective,price=nextLevel and nextLevel.Price,
        temporary=not Config.PersistenceEnabled,plot=s.plot.Name,message=message})
end
local function live(player)
    local s=sessions[player]
    local char=player.Character local root=char and char:FindFirstChild("HumanoidRootPart")
    local humanoid=char and char:FindFirstChildOfClass("Humanoid")
    if not s or not root or not humanoid or humanoid.Health<=0 or not Profiles.active(player) then return nil end
    return s,root,humanoid
end
local function inPlot(s,position)
    local p=s.plot.Base.CFrame:PointToObjectSpace(position)
    return math.abs(p.X)<=25 and math.abs(p.Z)<=25 and math.abs(p.Y)<=9
end
local function allow(player,key,interval,...)
    local s=sessions[player] if not s then return false end
    local now=os.clock()
    if now-(s.rates[key] or -math.huge)<interval then return false end
    s.rates[key]=now
    return select("#",...)==0
end
local function equip(player)
    local s,root,humanoid=live(player) if not s then return end
    if not player:GetAttribute("FerramentaAtiva") then player:SetAttribute("FerramentaAtiva","Cortador") end
    -- [Ferramentas] com uma ferramenta manual ativa, o cortador não é montado (só 1 ferramenta principal)
    local ativa=player:GetAttribute("FerramentaAtiva") if ativa and ativa~="Cortador" then return end
    for _,parent in ipairs({player.Character,player:FindFirstChildOfClass("Backpack")}) do
        for _,item in ipairs(parent:GetChildren()) do if item.Name=="MowerTool" then item:Destroy() end end
    end
    local tool=Instance.new("Tool") tool.Name="MowerTool" tool.RequiresHandle=false tool.CanBeDropped=false
    tool.ToolTip="Ande para cortar a grama"
    -- Entrega 4 (Blender): cada item da loja tem seu modelo Cortador_<Id>; sem ele, cai no MowerLv antigo
    local mowers=game.ServerStorage.GameAssets.Mowers
    local visual=mowers:FindFirstChild("Cortador_"..(player:GetAttribute("Cortador") or ""))
    local model=(visual or mowers["MowerLv"..s.profile.mowerLevel]):Clone()
    local escala=not visual and CORTADOR_ESCALA[player:GetAttribute("Cortador") or ""] if escala then model:ScaleTo(escala) end
    if player:GetAttribute("Cortador") == "Trator" or model:GetAttribute("Veiculo") then -- [Claude 2026-11-12] Off-Road, Colheitadeira e Imperial também são dirigidos
        local floor = root.Position.Y - humanoid.HipHeight - root.Size.Y / 2
        Mount.vehicle(player,tool,model,CFrame.new(root.Position.X,floor+0.8,root.Position.Z)*root.CFrame.Rotation)
        return
    end
    model:PivotTo(root.CFrame*CFrame.new(0,-2.2,-4))
    for _,p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Anchored=false p.CanCollide=false p.CanTouch=false p.Massless=true
            local weld=Instance.new("WeldConstraint") weld.Part0=root weld.Part1=p weld.Parent=p
        end
    end
    local blade=model:FindFirstChild("Lamina",true)
    if blade then
        for _,side in ipairs({-1,1}) do
            local a=Instance.new("Attachment")
            a.Name=side<0 and "BladeLeft" or "BladeRight"
            a.Position=Vector3.new(blade.Size.X*.5*side,0,0)
            a.Parent=blade
        end
    end
    model.Parent=tool tool.Parent=player.Backpack humanoid:EquipTool(tool)
    Mount.push(tool,player.Character,model)
end
local function setTileClose(tile,on)
    -- Corte Rente: deixa a grama já cortada ainda mais baixa (rasteira)
    local low=tile:FindFirstChild("Cortada")
    local target=low or tile
    if on then
        if target:GetAttribute("AlturaOriginal")==nil then
            target:SetAttribute("AlturaOriginal",target.Size.Y) target:SetAttribute("CorOriginal",target.Color)
        end
        local y=target:GetAttribute("AlturaOriginal")
        TweenService:Create(target,TweenInfo.new(.14),{Size=Vector3.new(target.Size.X,math.max(.05,y*.35),target.Size.Z),
            Color=target.Color:Lerp(Color3.fromRGB(150,170,90),.35)}):Play()
    elseif target:GetAttribute("AlturaOriginal")~=nil then
        target.Size=Vector3.new(target.Size.X,target:GetAttribute("AlturaOriginal"),target.Size.Z)
        target.Color=target:GetAttribute("CorOriginal") or target.Color
        target:SetAttribute("AlturaOriginal",nil) target:SetAttribute("CorOriginal",nil)
    end
end
local function setTileCut(tile,cut)
    local low=tile:FindFirstChild("Cortada")
    if low then
        tile.Transparency=cut and 1 or 0
        low.Transparency=cut and 0 or 1
    elseif cut then
        TweenService:Create(tile,TweenInfo.new(.18),{Transparency=1,Size=Vector3.new(3.85,.1,3.85)}):Play()
    else
        tile.Transparency=0 tile.Size=Vector3.new(3.85,1.7,3.85)
    end
end
local function clearSecret(s)
    if s.secretConnection then s.secretConnection:Disconnect() s.secretConnection=nil end
    if s.secret then s.secret:Destroy() s.secret=nil end
end
local function resetJob(s)
    clearSecret(s)
    s.job=Rules.newJob(s.job and s.job.id+1 or 1,not s.profile.discovered.firstChest,random:NextNumber()<.25)
    s.lastCut=0
    for _,tile in ipairs(s.plot.GrassVisuals:GetChildren()) do setTileClose(tile,false) setTileCut(tile,false) end
    TufoDourado.sortearLote(s) -- [Claude 2026-11-11] tufos dourados deste serviço
    serviceNpcRefresh(s)
end

local function promptAnchor(model,height)
    local base=model and model.PrimaryPart
    if not base then return nil end
    local att=base:FindFirstChild("PromptAnchor")
    if att and att:IsA("Attachment") then
        att.WorldPosition=model:GetPivot().Position+Vector3.new(0,height or 2.8,0)
        return att
    end
    att=Instance.new("Attachment")
    att.Name="PromptAnchor"
    att.Parent=base
    att.WorldPosition=model:GetPivot().Position+Vector3.new(0,height or 2.8,0)
    return att
end
local function serviceNpcPivot(plot)
    local base=plot.Base.Position
    local pos=Vector3.new(base.X-17, base.Y+0.6, base.Z+16)
    return CFrame.new(pos, Vector3.new(plot.GrassZone01.Position.X, pos.Y, plot.GrassZone01.Position.Z))
end
local function serviceNpcCreate(player,s)
    local npc=VendorAvatar.create()
    local root=npc:FindFirstChild("HumanoidRootPart")
    local hum=npc:FindFirstChildOfClass("Humanoid")
    local rootHeight=hum.HipHeight+root.Size.Y/2

    local ring=Instance.new("Part")
    ring.Name="Ring" ring.Shape=Enum.PartType.Cylinder ring.Size=Vector3.new(.26,4.8,4.8)
    ring.Anchored=true ring.CanCollide=false ring.CanTouch=false ring.CanQuery=false
    ring.Material=Enum.Material.Neon ring.Color=Color3.fromRGB(247,207,84)
    ring.Transparency=.18 ring.CFrame=root.CFrame*CFrame.new(0,-rootHeight+.04,0)*CFrame.Angles(0,0,math.rad(90))
    ring.Parent=npc
    local rw=Instance.new("WeldConstraint") rw.Part0=root rw.Part1=ring rw.Parent=ring

    local att=Instance.new("Attachment") att.Name="PromptAnchor" att.Position=Vector3.new(0,1.7,0) att.Parent=root
    local prompt=Instance.new("ProximityPrompt")
    prompt.Name="Prompt"
    prompt.ActionText="Conferir"
    prompt.ObjectText="Jardineiro do lobby"
    prompt.MaxActivationDistance=10
    prompt.HoldDuration=.18
    prompt.RequiresLineOfSight=false
    prompt.Style=Enum.ProximityPromptStyle.Default
    prompt.KeyboardKeyCode=Enum.KeyCode.E
    prompt.GamepadKeyCode=Enum.KeyCode.ButtonX
    prompt.Parent=att

    local bubble=Instance.new("BillboardGui")
    bubble.Name="Bubble" bubble.Size=UDim2.fromOffset(148,44) bubble.MaxDistance=30 bubble.StudsOffset=Vector3.new(0,1.8,0) bubble.Adornee=npc:FindFirstChild("Head")
    bubble.AlwaysOnTop=false bubble.Parent=npc
    local bubbleFrame=Instance.new("Frame")
    bubbleFrame.Name="Frame" bubbleFrame.Size=UDim2.fromScale(1,1) bubbleFrame.BackgroundColor3=Color3.fromRGB(86,138,84)
    bubbleFrame.BackgroundTransparency=.07 bubbleFrame.Parent=bubble
    local uic=Instance.new("UICorner") uic.CornerRadius=UDim.new(0,18) uic.Parent=bubbleFrame
    local stroke=Instance.new("UIStroke") stroke.Color=Color3.fromRGB(250,244,226) stroke.Thickness=2.4 stroke.Parent=bubbleFrame
    local txt=Instance.new("TextLabel")
    txt.Name="Label" txt.BackgroundTransparency=1 txt.Size=UDim2.new(1,-16,1,-14) txt.Position=UDim2.fromOffset(8,7)
    txt.Font=Enum.Font.FredokaOne txt.TextScaled=true txt.TextWrapped=true txt.TextColor3=Color3.fromRGB(248,244,228)
    txt.TextStrokeTransparency=.7 txt.Text="NOVO\nSERVIÇO" txt.Parent=bubbleFrame

    npc.Parent=s.plot
    npc:PivotTo(serviceNpcPivot(s.plot)*CFrame.new(0,rootHeight,0))

    prompt.Triggered:Connect(function(visitor)
        if visitor~=player then return end
        local current,root=live(visitor)
        if not current or current~=s or not root or not npc.PrimaryPart then return end
        if (root.Position-npc.PrimaryPart.Position).Magnitude>14 then return end
        if s.job.finished then
            resetJob(s)
            sync(player,"Novo serviço iniciado! O jardim precisa de você de novo.")
        else
            local restante=math.max(0,64-(s.job.cutCount or 0))
            sync(player,restante>0 and ("Termine o jardim atual primeiro. Faltam "..restante.." tufos.") or "Continue explorando seu jardim atual.")
        end
    end)
    return npc
end
serviceNpcRefresh=function(s)
    local npc=s.serviceNpc
    if not npc or not npc.Parent then return end
    local prompt=npc:FindFirstChild("Prompt",true)
    local label=npc:FindFirstChild("Label",true)
    local frame=npc:FindFirstChild("Frame",true)
    local ring=npc:FindFirstChild("Ring",true)
    local pronto=s.job and s.job.finished
    if prompt then
        prompt.ActionText=pronto and "Novo serviço" or "Conferir"
        prompt.ObjectText=pronto and "Jardineiro pronto" or "Jardineiro do lobby"
    end
    if label and label:IsA("TextLabel") then
        label.Text=pronto and "NOVO SERVIÇO" or "JARDIM EM ANDAMENTO"
        label.TextColor3=pronto and Color3.fromRGB(255,246,216)or Color3.fromRGB(64,49,35)
    end
    if frame and frame:IsA("Frame") then
        frame.BackgroundColor3=pronto and Color3.fromRGB(96,133,76) or Color3.fromRGB(255,241,202)
    end
    if ring and ring:IsA("BasePart") then
        ring.Color=pronto and Color3.fromRGB(247,207,84) or Color3.fromRGB(90,187,131)
        ring.Transparency=pronto and .16 or .35
    end
end
local function reveal(player,s,tile)
    s.job.secretRevealed=true
    local model=(function() -- [Baús] modelos do Blender (recompensa não muda)
        local baus=game.ServerStorage.GameAssets:FindFirstChild("Baus")
        local nome=s.job.tutorial and "Comum" or (random:NextNumber()<.1 and "Lendario" or "Incomum")
        local b=baus and baus:FindFirstChild("Bau_"..nome)
        if not b then return game.ServerStorage.GameAssets.Secrets[s.job.tutorial and "RustyChest" or "PartsCrate"]:Clone() end
        local c=b:Clone() local base=c:FindFirstChild("Base_"..nome)
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Anchored=true p.CanCollide=false end end
        if not c.PrimaryPart and base and base:IsA("BasePart") then c.PrimaryPart=base end
        -- Tampa e base são MeshParts independentes do Blender.
        -- A orientação é calculada ao posicionar, nunca inferida do avatar.

        c:SetAttribute("Raridade",nome)
        return c
    end)()
    -- Corrige o FBX importado deitado: escolhe a rotação que coloca a Tampa acima da Base.
    local groundY = s.plot.GrassZone01.Position.Y + 0.2
    local originalPivot = model:GetPivot()
    local rarity = model:GetAttribute("Raridade")
    local lid = rarity and model:FindFirstChild("Tampa_" .. rarity, true)
    local base = model.PrimaryPart
    local upLocal = (lid and base and lid:IsA("BasePart") and (lid.Position-base.Position).Magnitude > 0.04)
        and originalPivot:VectorToObjectSpace(lid.Position-base.Position).Unit or Vector3.yAxis
    local variants = {
        CFrame.identity, CFrame.Angles(math.rad(90),0,0), CFrame.Angles(math.rad(-90),0,0),
        CFrame.Angles(0,0,math.rad(90)), CFrame.Angles(0,0,math.rad(-90)),
        CFrame.Angles(math.rad(180),0,0),
    }
    local best,score=variants[1],-math.huge
    for _,rot in ipairs(variants) do
        local alignment=rot:VectorToWorldSpace(upLocal).Y
        if alignment>score then best,score=rot,alignment end
    end
    local spawnPos=Vector3.new(tile.Position.X,groundY,tile.Position.Z)
    model:PivotTo(CFrame.new(spawnPos)*best)
    -- Apoia o fundo no solo. Pivot e dimensões importadas podem variar entre raridades.
    local bound,size=model:GetBoundingBox()
    local correction=groundY - (bound.Position.Y-size.Y*0.5) + 0.06
    model:PivotTo(model:GetPivot()+Vector3.new(0,correction,0))
    model.Parent=s.plot s.secret=model
    local _,size=model:GetBoundingBox()
    local anchor=promptAnchor(model,math.max(2.4,size.Y*.68))
    local prompt=Instance.new("ProximityPrompt") prompt.ActionText="Abrir" prompt.ObjectText=s.job.tutorial and "Baú encontrado!" or "Peças escondidas!"
    prompt.HoldDuration=.2 prompt.MaxActivationDistance=10 prompt.RequiresLineOfSight=false prompt.KeyboardKeyCode=Enum.KeyCode.E prompt.GamepadKeyCode=Enum.KeyCode.ButtonX
    prompt.Style=Enum.ProximityPromptStyle.Default prompt.Parent=anchor or model.PrimaryPart
    s.secretConnection=prompt.Triggered:Connect(function(visitor)
        local current,root=live(visitor)
        if visitor~=player or current~=s or s.secret~=model or (root.Position-model.PrimaryPart.Position).Magnitude>14 then return end
        if not Rules.claim(s.profile,s.job) then return end
        Economia.AddMoedas(player,s.job.tutorial and Config.TutorialReward or Config.CrateReward) Economia.AddXP(player,15) MissoesSinal.contar(player,"descoberta",1)
        prompt.Enabled=false
        remotes.FXEvent:FireClient(player,"Secret",model.PrimaryPart.Position)
        sync(player,s.job.tutorial and "Baú aberto! +15 moedas" or "Peças encontradas! +10 moedas")
        clearSecret(s)
    end)
    sync(player,"Baú encontrado! Aproxime-se para abrir.")
end
local function upgrade(player)
    local abrir=game.ReplicatedStorage:FindFirstChild("AbrirLoja") if abrir then abrir:FireClient(player) end
    do return end
    local s,root=live(player) if not s then return end
    if not inPlot(s,root.Position) then sync(player,"Volte ao seu lote para melhorar.") return end
    local ok,message=Rules.upgrade(s.profile)
    if ok then equip(player) end
    sync(player,message)
end
remotes.UpgradeRequest.OnServerEvent:Connect(function(player,...)
    if allow(player,"upgrade",.8,...) then upgrade(player) end
end)
remotes.NewJobRequest.OnServerEvent:Connect(function(player,...)
    if not allow(player,"new",1,...) then return end
    local s,root=live(player)
    if not s or not s.job.finished or not inPlot(s,root.Position) then return end
    resetJob(s) sync(player,"Novo serviço! Encontre o que a grama esconde.")
end)
remotes.Ready.OnServerEvent:Connect(function(player,...)
    if allow(player,"ready",1,...) then sync(player) end
end)
local function tileOf(s,id)
    local row=math.floor((id-1)/8)+1 local col=(id-1)%8+1
    return s.plot.GrassVisuals[string.format("Grass_%02d_%02d",row,col)],row,col
end
-- Recurso passivo real: um bônus em aparas apenas a cada quatro cortes VÁLIDOS.
-- Não cria XP extra, não duplica o mesmo tufo e não inventa uma moeda separada.
local function coletarAparas(player,s,quantidade)
    if quantidade<=0 or not Skills.has(player,"TECH_CLIPPINGS") then return end
    s.aparasContador=(s.aparasContador or 0)+quantidade
    local lotes=math.floor(s.aparasContador/4)
    if lotes>0 then
        s.aparasContador=s.aparasContador%4
        Economia.EncherSaco(player,lotes*2)
    end
end
-- corta os ids informados (já validados pelo chamador); devolve quantos cortou
-- [Claude 2026-11-11] a grama do lote volta a crescer sozinha depois do jardim completo (antes era preciso pedir
-- um novo serviço ao jardineiro; o NPC continua reiniciando na hora com E). Se o baú do jardim foi revelado e
-- ainda não foi aberto, espera até 3 min (resetJob apagaria o baú).
local REBROTA_SEGUNDOS=20
local function agendarRebrota(player,s)
    local job=s.job
    task.spawn(function()
        task.wait(tonumber(workspace:GetAttribute("EventoRebrota")) or REBROTA_SEGUNDOS) -- [Claude 2026-11-12] Chuva de Primavera: 5 s
        local limite=os.clock()+180
        while sessions[player]==s and s.job==job and job.secretRevealed and not job.secretClaimed and os.clock()<limite do task.wait(5) end
        if sessions[player]~=s or s.job~=job or not player.Parent then return end
        resetJob(s)
        sync(player,"🌱 A grama do seu jardim cresceu de novo!")
    end)
end
local function cutIds(player,s,ids)
    local count=0
    for _,id in ipairs(ids) do
        if not s.job.cutFlags[id] and Economia.CortarGrama(player) and Rules.cut(s.profile,s.job,id) then
            count+=1
            local tile=tileOf(s,id)
            setTileCut(tile,true)
            TufoDourado.aoCortarLote(player,s,id,tile) -- [Claude 2026-11-11]
            if s.job.hasBonusSecret and not s.job.secretRevealed and s.job.cutCount>=s.job.revealAt then reveal(player,s,tile) end
            remotes.FXEvent:FireClient(player,"Cut",tile.Position)
        end
    end
    coletarAparas(player,s,count)
    if count>0 and s.job.finished and not s.job.ecoBonus then s.job.ecoBonus=true Economia.AddMoedas(player,Config.JobReward) Economia.AddXP(player,40) agendarRebrota(player,s) MissoesSinal.contar(player,"jardim",1) end
    if count>0 then sync(player,s.job.finished and "Jardim restaurado! Bônus +40 moedas" or nil) end
    return count
end
-- Corte Rente (passiva): depois do jardim concluído, a 2ª passada deixa a grama rasteira
local function closeCut(player,s,localOrigin,width)
    s.job.closeFlags=s.job.closeFlags or {} s.job.closeCount=s.job.closeCount or 0
    local candidates={}
    for row=1,8 do for col=1,8 do
        local id=(row-1)*8+col
        if s.job.cutFlags[id] and not s.job.closeFlags[id] then
            local distance=(Vector2.new(-18+col*4,-18+row*4)-Vector2.new(localOrigin.X,localOrigin.Z)).Magnitude
            if distance<=4 then table.insert(candidates,{id=id,distance=distance}) end
        end
    end end
    table.sort(candidates,function(a,b) return a.distance<b.distance end)
    local count=0
    for _,cell in ipairs(candidates) do
        if count>=width then break end
        if Economia.CortarGrama(player) then
            s.job.closeFlags[cell.id]=true s.job.closeCount+=1 count+=1
            local tile=tileOf(s,cell.id)
            setTileClose(tile,true)
            remotes.FXEvent:FireClient(player,"Cut",tile.Position)
        end
    end
    if count>0 and s.job.closeCount>=64 and not s.job.closeBonus then
        s.job.closeBonus=true Economia.AddMoedas(player,20) Economia.AddXP(player,20)
        sync(player,"Acabamento perfeito! Grama rasteira em todo o jardim: +20 moedas")
    end
end
-- Floresta Esquecida | patch v7 para o GameServer original da copia 2 / v6.
-- A floresta e construida em PECAS MODULARES durante Play, sem substituir Lobby/Plots.
-- Reutiliza o GrassPack do prototipo e Economia.CortarGrama, com recompensa apenas no 1o corte.
-- Nao cria DataStore. Os segredos sao por sessao enquanto PersistenceEnabled=false.
local FOREST = {
    xMin = -300, xMax = 300, zMin = -825, zMax = -177,
    grass = {}, buckets = {}, secrets = {}, trees = 0, cutCount = 0,
    mowerPos = {}, ready = false, cellSize = 9,
}
local forestRng = Random.new(20261108)
local function forestPart(parent, name, size, cf, color, material, collide, shape)
    local p = Instance.new("Part")
    p.Name, p.Size, p.CFrame = name, size, cf
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CanCollide = collide == true
    p.CanTouch = false
    p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end
local function forestFolder(parent, name)
    local f = Instance.new("Folder") f.Name = name f.Parent = parent return f
end
local forestGroundY = 0.8
local fColors = {
    ground = Color3.fromRGB(51, 89, 69), moss = Color3.fromRGB(75, 112, 73),
    path = Color3.fromRGB(149, 132, 94), bark = Color3.fromRGB(92, 61, 42),
    water = Color3.fromRGB(46, 115, 128), stone = Color3.fromRGB(85, 107, 96),
}
local function forestSign(parent,text,pos,width)
    return Signs.create(parent,"Placa_"..text:sub(1,16),text,Vector3.new(pos.X,Scenery.height(pos.X,pos.Z)+3.8,pos.Z),math.min(width or 9,12))
end
local function forestPath(parent,a,b,width)
    -- Paint onto the actual ground instead of suspending a rectangular collision slab.
    local folder=Instance.new("Folder");folder.Name="TrilhaIntegrada";folder.Parent=parent
    local steps=math.max(1,math.ceil((b-a).Magnitude/3))
    for i=0,steps do
        local p=a:Lerp(b,i/steps);local y=Scenery.height(p.X,p.Z)
        local region=Region3.new(Vector3.new(p.X-width/2,y-4,p.Z-width/2),Vector3.new(p.X+width/2,y+2,p.Z+width/2)):ExpandToGrid(4)
        workspace.Terrain:ReplaceMaterial(region,4,Enum.Material.Grass,Enum.Material.Ground)
        workspace.Terrain:ReplaceMaterial(region,4,Enum.Material.LeafyGrass,Enum.Material.Ground)
    end
    return folder
end
local function forestRoot(parent, x, z, angle, scale)
    forestPart(parent,"RaizAntiga",Vector3.new(.8*scale,1.15*scale,4.3*scale),
        CFrame.new(x,forestGroundY+.42*scale,z)*CFrame.Angles(0,angle,math.rad(13)),
        fColors.bark, Enum.Material.Wood, false)
end
local function forestTree(parent, x, z, variety)
    if Commerce.reserved(x,z,18) then return end
    return Scenery.tree(parent,x,z,variety,forestRng)
end
local function forestStone(parent,x,z,scale)
    if Commerce.reserved(x,z,12) then return end
    local stone=forestPart(parent,"PedraMusgosa",Vector3.new(2.6*scale,1.5*scale,2.1*scale),
        CFrame.new(x,forestGroundY+.52*scale,z)*CFrame.Angles(0,forestRng:NextNumber(0,6.28),forestRng:NextNumber(-.1,.1)),
        fColors.stone,Enum.Material.Slate,true,Enum.PartType.Ball)
    stone.CanTouch=false
end
local function forestLog(parent,x,z,ang,len)
    if Commerce.reserved(x,z,12) then return end
    forestPart(parent,"TroncoCaido",Vector3.new(1.8,1.8,len),
        CFrame.new(x,forestGroundY+.8,z)*CFrame.Angles(0,ang,math.rad(3)),
        fColors.bark,Enum.Material.Wood,false)
end
local function forestCabin(parent)
    local pos=Vector3.new(-108,forestGroundY,-346)
    local library=game.ServerStorage:FindFirstChild("GameAssets")
    local modular=library and library:FindFirstChild("ForestModular")
    local authentic=modular and modular:FindFirstChild("Cabana_Abandonada")
    if authentic and authentic:IsA("Model") then
        local cabin=authentic:Clone() cabin.Name="Cabana_Abandonada_OriginalBlender" cabin:PivotTo(CFrame.new(pos+Vector3.new(0,1,0))) cabin.Parent=parent
        for _,d in ipairs(cabin:GetDescendants()) do
            if d:IsA("BasePart") then d.Anchored=true end
        end
        return cabin
    end
    local model=Instance.new("Model")model.Name="CabanaDoGuardiao" model.Parent=parent
    local x,z=pos.X,pos.Z
    local wood=Color3.fromRGB(91,76,51)
    forestPart(model,"Fundacao",Vector3.new(22,1.6,18),CFrame.new(x,forestGroundY+1,z),Color3.fromRGB(65,64,51),Enum.Material.Wood,true)
    -- Fachada modular com VAO de porta verdadeiro (nao bloquear a entrada com uma parede inteira).
    forestPart(model,"FachadaEsquerda",Vector3.new(5.8,8,1),CFrame.new(x-8.1,forestGroundY+5,z+8.5),wood,Enum.Material.Wood,true)
    forestPart(model,"FachadaDireita",Vector3.new(11.8,8,1),CFrame.new(x+5.1,forestGroundY+5,z+8.5),wood,Enum.Material.Wood,true)
    forestPart(model,"LintelPorta",Vector3.new(4.4,2,1),CFrame.new(x-3,forestGroundY+8,z+8.5),wood,Enum.Material.Wood,true)
    forestPart(model,"ParedeTras",Vector3.new(22,8,1),CFrame.new(x,forestGroundY+5,z-8.5),wood,Enum.Material.Wood,true)
    for _,sx in ipairs({-10.5,10.5}) do forestPart(model,"Lateral",Vector3.new(1,8,17),CFrame.new(x+sx,forestGroundY+5,z),wood,Enum.Material.Wood,true) end
    forestPart(model,"Porta",Vector3.new(4.4,6,0.4),CFrame.new(x-3,forestGroundY+4,z+9.15),Color3.fromRGB(55,48,39),Enum.Material.Wood,false)
    for i=1,2 do
        forestPart(model,"Janela",Vector3.new(3.3,3.1,.22),CFrame.new(x+2+(i-1)*5,forestGroundY+5.8,z+9.2),Color3.fromRGB(124,133,104),Enum.Material.Glass,false)
    end
    for i=1,2 do
        forestPart(model,"TelhadoEnvelhecido",Vector3.new(13,1,21),
            CFrame.new(x+(i==1 and -5.7 or 5.7),forestGroundY+11,z)*CFrame.Angles(0,0,math.rad(i==1 and 25 or -25)),
            Color3.fromRGB(133,66+10*i,48),Enum.Material.Wood,false)
    end
    forestPart(model,"Varanda",Vector3.new(23,0.65,7),CFrame.new(x,forestGroundY+1.4,z+12.2),Color3.fromRGB(109,83,55),Enum.Material.Wood,true)
    forestPart(model,"Chamine",Vector3.new(3,6,3),CFrame.new(x+5,forestGroundY+14,z-3),Color3.fromRGB(83,88,88),Enum.Material.Brick,false)
    -- Layered shingles, structural trim and small furnishings give the cabin a readable silhouette.
    local trim=Color3.fromRGB(61,49,37)
    for _,sx in ipairs({-10.4,10.4}) do
        forestPart(model,"VigaCanto",Vector3.new(.65,8.2,.65),CFrame.new(x+sx,forestGroundY+5,z+9),trim,Enum.Material.Wood,false)
    end
    for side=-1,1,2 do
        local roof=CFrame.new(x+side*5.7,forestGroundY+11,z)*CFrame.Angles(0,0,math.rad(-side*25))
        for row=0,5 do for col=0,7 do
            local tile=forestPart(model,"TelhaMusgosa",Vector3.new(2.15,.17,2.8),roof*CFrame.new(-5.4+row*2.15,.59,-9.3+col*2.65),
                Color3.fromRGB(71+row*3,83+col*2,67+row),Enum.Material.Slate,false)
            tile.CastShadow=false
        end end
    end
    for _,wx in ipairs({x+2,x+7}) do
        for _,side in ipairs({-1,1}) do forestPart(model,"BatenteJanela",Vector3.new(.25,3.5,.4),CFrame.new(wx+side*1.75,forestGroundY+5.8,z+9.4),trim,Enum.Material.Wood,false) end
        for _,dy in ipairs({-1.7,1.7}) do forestPart(model,"BatenteJanela",Vector3.new(3.8,.25,.4),CFrame.new(wx,forestGroundY+5.8+dy,z+9.4),trim,Enum.Material.Wood,false) end
        forestPart(model,"DivisaoJanela",Vector3.new(.15,3.2,.35),CFrame.new(wx,forestGroundY+5.8,z+9.5),trim,Enum.Material.Wood,false)
        forestPart(model,"Floreira",Vector3.new(4,.8,1),CFrame.new(wx,forestGroundY+3.8,z+9.8),wood,Enum.Material.Wood,false)
    end
    for i=0,10 do
        local wx=x-10+i*2
        if wx<x-5.3 or wx>x-.7 then
            forestPart(model,"TabuaFachada",Vector3.new(.14,7.8,.16),CFrame.new(wx,forestGroundY+5,z+9.05),trim,Enum.Material.Wood,false)
        end
    end
    for _,sx in ipairs({-1,1}) do
        forestPart(model,"PersianaAntiga",Vector3.new(.8,3.3,.25),CFrame.new(x+2+sx*2.35,forestGroundY+5.8,z+9.5)*CFrame.Angles(0,sx*.25,sx*.04),Color3.fromRGB(76,91,65),Enum.Material.Wood,false)
    end
    local plants=game.ReplicatedStorage.GramaAssets.GrassPack
    local leaf=plants:FindFirstChild("Herb_H02_FolhaLarga")
    if leaf then
        for i=1,16 do
            local v=leaf:Clone() v.Name="VegetacaoDaCabana" v.Size=leaf.Size*(i<9 and 2.2 or 1.2)
            v.Anchored=true v.CanCollide=false v.CanTouch=false v.CanQuery=false
            local px=x-10+(i%8)*2.5
            local py=i<9 and (forestGroundY+14-math.abs(px-x)*.46) or forestGroundY+4.5
            v.CFrame=CFrame.new(px,py,z+(i<9 and 4 or 10))*CFrame.Angles(0,i*2.4,0) v.Parent=model
        end
    end
    forestPart(model,"BancoVaranda",Vector3.new(5,.45,1.5),CFrame.new(x+7,forestGroundY+2.8,z+12),trim,Enum.Material.Wood,true)
    for _,dx in ipairs({5.1,8.9}) do forestPart(model,"PeBanco",Vector3.new(.4,1.2,1.2),CFrame.new(x+dx,forestGroundY+2.1,z+12),trim,Enum.Material.Wood,false) end
    forestSign(model,"CABANA ESQUECIDA",Vector3.new(x-15,0,z+18),12)
    model:SetAttribute("Modular",true)
    return model
end
local function forestBridge(parent)
    return Scenery.bridge(parent)
end
local function forestBuck(x,z)
    return math.floor(x/FOREST.cellSize)..":"..math.floor(z/FOREST.cellSize)
end
local forestStream=Instance.new("RemoteEvent")
forestStream.Name="ForestGrassStream"
forestStream.Parent=game.ReplicatedStorage.Remotes
local forestViewers={}
local forestDistant={}
local function forestPacket(g)
    return {g.id,g.x,g.z,g.groundY,g.scale,g.rotation,g.variant,g.stage,g.heightFactor or 1,g.distantMask or 15}
end
local function forestGrassSet(rec, stage)
    -- Preserve exactly the proportions and state meshes used by the test area.
    -- Logical records stay on the server; each client renders only nearby vegetation.
    local previous=rec.stage
    rec.stage=stage
    local group=rec.distantGroup
    if group and stage~=previous then
        if previous==0 then group.cut+=1 end
        if stage==2 then group.stubble+=1 end
        local level=group.stubble/group.total>=.65 and 2 or group.cut/group.total>=.65 and 1 or 0
        if level~=group.stage then
            group.stage=level
            for player,viewer in pairs(forestViewers) do
                if viewer.distant then forestStream:FireClient(player,"distant",{forestPacket(group)}) end
            end
        end
    end
    for player,viewer in pairs(forestViewers) do
        if viewer.loaded[rec.id] then forestStream:FireClient(player,"update",{forestPacket(rec)}) end
    end
end
local function forestGrassSpawn(parent, x, z, important)
    if not important and Art.blockGrass(x,z) then return false end
    local density,biomeHeight=Art.grassBlend(x,z)
    local scatter=(math.sin(x*12.9898+z*78.233)*43758.5453)%1
    if not important and scatter>density then return false end
    -- Manchas de matagal podem ocultar trilhas, mas nunca nascer dentro da cabana,
    -- rio, em cima da ponte ou no centro da clareira secreta.
    if Commerce.reserved(x,z,10) then return false end
    if Scenery.onPath(x,z,2.5) then return false end
    if x>-123 and x<-80 and z>-340 and z<-309 then return false end
    if (x+108)^2+(z+346)^2<20^2 then return false end
    if Scenery.inRiver(x,z,1.5) then return false end
    if (x-142)^2+(z+581)^2<9^2 then return false end
    if x<-298 or x>298 or z<-823 or z>-179 then return false end
    -- Keep the cave chamber clear; the outer approach remains concealed by cuttable grass.
    if x>-80 and x<-54 and z>-741 and z<-711 then return false end
    for bx=math.floor((x-2.65)/FOREST.cellSize),math.floor((x+2.65)/FOREST.cellSize) do
        for bz=math.floor((z-2.65)/FOREST.cellSize),math.floor((z+2.65)/FOREST.cellSize) do
            for _,g in ipairs(FOREST.buckets[bx..":"..bz] or {}) do
                if (g.x-x)^2+(g.z-z)^2<2.65^2 then return false end
            end
        end
    end
    local lib=game.ReplicatedStorage:FindFirstChild("GramaAssets")
    local grass=lib and lib:FindFirstChild("GrassPack")
    if not grass then return false end
    -- Alguns dos 70 GLBs podem ainda nao estar importados: escolhe APENAS familias completas.
    local complete={}
    for _,candidate in ipairs({"A01","A02","A03","A04","A05","A06"}) do
        if grass:FindFirstChild("Grass_"..candidate.."_TALL")
            and grass:FindFirstChild("Grass_"..candidate.."_SHORT")
            and grass:FindFirstChild("Grass_"..candidate.."_STUBBLE") then
            table.insert(complete,candidate)
        end
    end
    if #complete==0 then return false end
    local variant=complete[forestRng:NextInteger(1,#complete)]
    local templates={}
    for _,state in ipairs({"TALL","SHORT","STUBBLE"}) do
        templates[#templates+1]=grass:FindFirstChild("Grass_"..variant.."_"..state)
    end
    local id=#FOREST.grass+1
    local heightFactor=.88+math.noise(x*.019,z*.019)*.28
    if Scenery.onPath(x,z,5.7) then heightFactor*=.67 end
    for _,clearing in ipairs({{-18,-757,10},{142,-581,10},{-169,-568,3}}) do
        local distance=Vector2.new(x-clearing[1],z-clearing[2]).Magnitude
        if distance<clearing[3] then heightFactor*=.32
        elseif distance<clearing[3]+9 then heightFactor*=.55+.45*(distance-clearing[3])/9 end
    end
    heightFactor=important and 1.05 or heightFactor*biomeHeight
    local rec={ id=id,x=x,z=z,groundY=important and .8 or Scenery.height(x,z),variant=variant,heightFactor=heightFactor,stage=0,scale=forestRng:NextNumber(.95,1.16),
        width=forestRng:NextNumber(2.0,3.0),rotation=forestRng:NextNumber(0,6.283),
        parent=parent,templates=templates,lastHit=-100 }
    rec.important=important==true
    FOREST.grass[id]=rec
    local buck=forestBuck(x,z)
    local list=FOREST.buckets[buck] if not list then list={} FOREST.buckets[buck]=list end
    table.insert(list,rec)
    forestGrassSet(rec,0)
    return true,rec
end
local function forestChest(parent, x,z,rarity)
    local model
    local lib=game.ServerStorage:FindFirstChild("GameAssets")
    local chests=lib and lib:FindFirstChild("Baus")
    local tmpl=chests and chests:FindFirstChild("Bau_"..rarity)
    if tmpl then
        model=tmpl:Clone()
        for _,p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false end
        end
        local base=model:FindFirstChild("Base_"..rarity,true)
        local lid=model:FindFirstChild("Tampa_"..rarity,true)
        local up=(base and lid and base:IsA("BasePart") and lid:IsA("BasePart"))
            and model:GetPivot():VectorToObjectSpace(lid.Position-base.Position) or Vector3.yAxis
        local best=CFrame.identity local score=-math.huge
        for _,rot in ipairs({CFrame.identity,CFrame.Angles(math.pi/2,0,0),CFrame.Angles(-math.pi/2,0,0),
            CFrame.Angles(0,0,math.pi/2),CFrame.Angles(0,0,-math.pi/2),CFrame.Angles(math.pi,0,0)}) do
            local s=rot:VectorToWorldSpace(up).Y
            if s>score then score=s best=rot end
        end
        model:PivotTo(CFrame.new(x,forestGroundY+1,z)*best)
        local box,size=model:GetBoundingBox()
        model:PivotTo(model:GetPivot()+Vector3.new(0,forestGroundY-(box.Position.Y-size.Y/2)+.08,0))
    else
        model=Instance.new("Model") model.Name="Bau_Reserva"
        local base=forestPart(model,"Base",Vector3.new(3,2,2.5),CFrame.new(x,forestGroundY+1,z),Color3.fromRGB(122,75,42),Enum.Material.Wood,false)
        forestPart(model,"Tampa",Vector3.new(3.1,.65,2.6),CFrame.new(x,forestGroundY+2.3,z),Color3.fromRGB(209,155,53),Enum.Material.Wood,false)
        model.PrimaryPart=base
    end
    model.Name="BauEscondido_"..rarity
    model.Parent=parent
    return model
end
-- [Claude 2026-11-10] Lista, por jogador, dos segredos ja coletados. So serve para o cliente
-- esconder o prompt dele; a recompensa continua validada abaixo (secret.claimed/Commerce.wasClaimed).
local function forestMarkClaimed(player,id)
    local list=player:GetAttribute("ForestClaimedSecrets") or ""
    if string.find(","..list..",",","..id..",",1,true) then return end
    player:SetAttribute("ForestClaimedSecrets",list=="" and id or list..","..id)
end
local function forestAddSecret(parent, info)
    local placementY=info.groundY or forestGroundY
    local point=Vector3.new(info.x,info.groundY or Scenery.height(info.x,info.z),info.z)
    local visibleModel
    if info.kind=="gnome" then
        visibleModel=Scenery.gnome(parent,Vector3.new(info.x,Scenery.height(info.x,info.z),info.z))
    elseif info.kind=="chest" then
        visibleModel=forestChest(parent,info.x,info.z,info.rarity)
        if info.groundY then visibleModel:PivotTo(visibleModel:GetPivot()+Vector3.new(0,placementY-forestGroundY,0)) end
    else
        visibleModel=Instance.new("Model") visibleModel.Name="Artefato_"..info.id visibleModel.Parent=parent
        -- [Claude 2026-11-11] cada relíquia com visual próprio (ReliquiasDaFloresta); id desconhecido = pedestal antigo
        if not Reliquias.build(visibleModel,info.id,point) then -- no chão de verdade (terreno ou cripta)
            forestPart(visibleModel,"Pedestal",Vector3.new(3.3,2.3,3.3),CFrame.new(info.x,placementY+1.2,info.z),fColors.stone,Enum.Material.Slate,false)
            forestPart(visibleModel,"Simbolo",Vector3.new(1.2,2.2,.5),CFrame.new(info.x,placementY+3,info.z),Color3.fromRGB(103,198,172),Enum.Material.Neon,false)
        end
    end
    local savedTrans={}
    for _,d in ipairs(visibleModel:GetDescendants()) do
        if d:IsA("BasePart") then savedTrans[d]=d.Transparency if not info.visible then d.Transparency=1 end end
    end
    local marker=forestPart(parent,"InteracaoSegredo_"..info.id,Vector3.new(1,1,1),
        CFrame.new(info.x,placementY+2,info.z),Color3.new(1,1,1),Enum.Material.SmoothPlastic,false)
    marker.Transparency=1 marker.CanQuery=false
    if not visibleModel.PrimaryPart then
        visibleModel.PrimaryPart=visibleModel:FindFirstChildWhichIsA("BasePart",true)
    end
    local _,size=visibleModel:GetBoundingBox()
    local anchor=promptAnchor(visibleModel,math.max(2.6,size.Y*.72))
    local prompt=Instance.new("ProximityPrompt") prompt.ActionText=info.kind=="chest" and "Abrir baú" or "Investigar"
    prompt.ObjectText=info.kind=="chest" and "Tesouro escondido" or "Relíquia esquecida"
    prompt.MaxActivationDistance=10 prompt.HoldDuration=.22 prompt.Enabled=false prompt.RequiresLineOfSight=false
    prompt.KeyboardKeyCode=Enum.KeyCode.E prompt.GamepadKeyCode=Enum.KeyCode.ButtonX prompt.Style=Enum.ProximityPromptStyle.Default
    prompt.Parent=anchor or marker
    prompt:SetAttribute("ForestSecretId",info.id)
    local secret={model=visibleModel, marker=marker, prompt=prompt,point=point,id=info.id,kind=info.kind,
        cuts=0, revealed=info.visible==true, claimed={}, originalTrans=savedTrans,
        cutPoint=info.cutPoint or point,cutRadius=info.cutRadius or 13,revealAt=info.revealAt or 9,gate=info.gate,requiredGrass=info.requiredGrass}
    table.insert(FOREST.secrets,secret)
    -- [Claude 2026-11-11] registro público do segredo, para pistas e efeitos no cliente (SegredosDaFloresta).
    -- Só posição/tipo/estado; a recompensa continua validada aqui no servidor.
    if info.kind~="gnome" then
        local reg=game.ReplicatedStorage:FindFirstChild("SegredosDaFloresta")
        if not reg then reg=Instance.new("Folder") reg.Name="SegredosDaFloresta" reg.Parent=game.ReplicatedStorage end
        local c=Instance.new("Configuration") c.Name=info.id
        c:SetAttribute("Tipo",info.kind) c:SetAttribute("Raridade",info.rarity or "")
        c:SetAttribute("Ponto",point) c:SetAttribute("Revelado",secret.revealed)
        c.Parent=reg
        secret.registro=c
        visibleModel:SetAttribute("SegredoId",info.id)
    end
    prompt.Enabled=secret.revealed
    if info.kind=="gnome" then
        prompt.ActionText="Conversar / trocar"
        prompt.ObjectText="Nilo, o Gnomo Colecionador"
        visibleModel.Name="Nilo_GnomoColecionador"
        visibleModel:SetAttribute("ForestMerchantId","Nilo")
        Commerce.bindGnome(visibleModel,point,function() return secret.revealed end)
    end
    local notification=game.ReplicatedStorage:FindFirstChild("NotificarHUD")
    prompt.Triggered:Connect(function(player)
        local s,root=live(player)
        if not s or not root or (root.Position-point).Magnitude>16 or not secret.revealed then return end
        if info.kind=="gnome" then
            Commerce.discoverGnome(player,point,secret.revealed)
            return
        end
        if secret.claimed[player.UserId] or Commerce.wasClaimed(player,info.id) then forestMarkClaimed(player,info.id) return end
        secret.claimed[player.UserId]=true
        forestMarkClaimed(player,info.id)
        Commerce.recordSecret(player,info.id,info.kind)
        local amount=info.kind=="chest" and (info.rarity=="Comum" and 14 or info.rarity=="Incomum" and 28 or info.rarity=="Raro" and 55 or info.rarity=="Lendario" and 110 or 200) or 35
        Economia.AddMoedas(player,amount)
        Economia.AddXP(player,info.kind=="chest" and 10 or 25) MissoesSinal.contar(player,"descoberta",1)
        player:SetAttribute("ForestSecrets",(player:GetAttribute("ForestSecrets") or 0)+1)
        if info.kind~="chest" then player:SetAttribute("ForestArtifacts",(player:GetAttribute("ForestArtifacts") or 0)+1) end
        if notification then notification:FireClient(player,"Segredo encontrado! +"..amount.." moedas", "ouro") end
    end)
    return secret
end
local function forestRevealSecret(secret)
    if secret.revealed then return end
    secret.revealed=true secret.prompt.Enabled=true if secret.marker then secret.marker.Transparency=1 end
    if secret.registro then secret.registro:SetAttribute("Revelado",true) end -- [Claude 2026-11-11] efeitos no cliente
    local context=secret.model:FindFirstChild("ForestNPCContext",true)
    if context then context.Enabled=true end
    if secret.gate and secret.gate:GetAttribute("UndergroundEntrance") then
        Art.revealGate(secret.gate)
    elseif secret.gate then
        secret.gate.CanCollide=false
        for _,v in ipairs(secret.gate:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=false end
        end
        game:GetService("TweenService"):Create(secret.gate,TweenInfo.new(.65),{Transparency=1}):Play()
        for _,v in ipairs(secret.gate:GetDescendants()) do
            if v:IsA("BasePart") then game:GetService("TweenService"):Create(v,TweenInfo.new(.65),{Transparency=1}):Play() end
        end
    end
    for p,trans in pairs(secret.originalTrans) do
        if p.Parent then p.Transparency=trans end
    end
    local fx=forestPart(secret.model,"BrilhoDescoberta",Vector3.new(0.65,.65,.65),
        CFrame.new(secret.point+Vector3.new(0,3.8,0)),Color3.fromRGB(247,204,84),Enum.Material.Neon,false,Enum.PartType.Ball)
    fx.CanQuery=false
    game:GetService("Debris"):AddItem(fx,3)
end
function FOREST.inside(position)
    return position.X>=FOREST.xMin and position.X<=FOREST.xMax and position.Z>=FOREST.zMin and position.Z<=FOREST.zMax
        and position.Y>-40 and position.Y<85
end
local function forestDist2D(p, a,b)
    local v=Vector2.new(b.X-a.X,b.Z-a.Z)
    local w=Vector2.new(p.x-a.X,p.z-a.Z)
    local d=v:Dot(v)
    local t=d>0 and math.clamp(w:Dot(v)/d,0,1) or 0
    return (w-v*t).Magnitude
end
function FOREST.cutTrace(player, points, radius, maxClumps, segments, strength, allowedTypes)
    if allowedTypes and not table.find(allowedTypes,"Alta") then return 0,0 end
    strength=math.clamp(tonumber(strength) or 1,.01,3)
    if not FOREST.ready or type(points)~="table" or #points==0 or #points>160 then return 0 end
    local s,root=live(player)
    if not s or not root or not FOREST.inside(root.Position) then return 0 end
    radius=math.clamp(tonumber(radius) or 2,0.6,4.5)
    maxClumps=math.clamp(tonumber(maxClumps) or 5,1,16)
    local valid={}
    for _,p in ipairs(points) do
        if segments then
            if typeof(p[1])=="Vector3" and typeof(p[2])=="Vector3"
                and (p[1]-root.Position).Magnitude<15 and (p[2]-root.Position).Magnitude<15 then
                table.insert(valid,p)
            end
        elseif typeof(p)=="Vector3" and (p-root.Position).Magnitude<15 and math.abs(p.Y-root.Position.Y)<7 then
            table.insert(valid,p)
        end
    end
    if #valid==0 then return 0 end
    local candidates={} local seen={}
    local cs=FOREST.cellSize
    for i,entry in ipairs(valid) do
        local a=segments and entry[1] or entry
        local b=segments and entry[2] or valid[math.min(i+1,#valid)]
        if (a-b).Magnitude<=14 then
            local minX,maxX=math.min(a.X,b.X)-radius,math.max(a.X,b.X)+radius
            local minZ,maxZ=math.min(a.Z,b.Z)-radius,math.max(a.Z,b.Z)+radius
            for ix=math.floor(minX/cs),math.floor(maxX/cs) do
                for iz=math.floor(minZ/cs),math.floor(maxZ/cs) do
                    for _,g in ipairs(FOREST.buckets[ix..":"..iz] or {}) do
                        if not seen[g.id] and g.stage<2 then
                            local distance=forestDist2D(g,a,b)
                            if distance<=radius + math.min(1,g.width*.1) and math.abs((a.Y+b.Y)*.5-g.groundY)<=6.5 then
                                seen[g.id]=true
                                table.insert(candidates,{grass=g,distance=distance,order=i})
                            end
                        end
                    end
                end
            end
        end
    end
    -- [Claude 2026-11-10] limite aplicado NA ORDEM DO TOQUE (amostras em ordem de tempo), desempate
    -- pela distancia; o cliente (ForestGrassClient) preve no contato com a mesma ordem.
    table.sort(candidates,function(a,b) if a.order~=b.order then return a.order<b.order end return a.distance<b.distance end)
    local count,contacts=0,0 local now=os.clock()
    for _,candidate in ipairs(candidates) do
        if contacts>=maxClumps then break end
        local g=candidate.grass
        if now-g.lastHit>=.45 then
            contacts+=1
            if g.stage==0 then
                g.damage=(g.damage or 0)+strength
                if g.damage<.999 then g.lastHit=now continue end
                -- Cada primeiro corte usa A MESMA economia do lobby. Nunca repete XP no mesmo tufo.
                if Economia.CortarGrama(player) then
                    g.lastHit=now
                    forestGrassSet(g,1)
                    count+=1 FOREST.cutCount+=1
                    player:SetAttribute("ForestGrassCut",(player:GetAttribute("ForestGrassCut") or 0)+1)
                    TufoDourado.aoCortarFloresta(player,Vector3.new(g.x,g.groundY,g.z)) -- [Claude 2026-11-11] grama dourada na floresta
                    MissoesSinal.contar(player,"floresta",1)
                    for _,secret in ipairs(FOREST.secrets) do
                        if not secret.revealed and (not secret.requiredGrass or secret.requiredGrass[g.id]) and (g.x-secret.cutPoint.X)^2+(g.z-secret.cutPoint.Z)^2<secret.cutRadius^2
                            and math.abs(g.groundY-secret.cutPoint.Y)<5.5 then
                            secret.cuts+=1
                            if secret.cuts>=secret.revealAt then forestRevealSecret(secret) end
                        end
                    end
                else break end
            elseif g.stage==1 then
                g.lastHit=now
                forestGrassSet(g,2)
                count+=1 -- acabamento visual; sem dinheiro ou XP extra, evita farm duplicado
            end
        end
    end
    return count,contacts
end
local function forestBuild()
    local previous=world:FindFirstChild("FlorestaEsquecida")
    if previous then FOREST.root=previous FOREST.ready=false
        warn("[Floresta] Regiao ja existia; evitando duplicar. Confira se outro builder esta ativo.") return end
    Scenery.prepareTerrain(workspace.Terrain)
    Art.foundation()
    local root=Instance.new("Model") root.Name="FlorestaEsquecida" root.Parent=world
    Commerce.build(root,Scenery)
    root:SetAttribute("Regiao","Floresta Esquecida")
    root:SetAttribute("Modular",true)
    local areas=forestFolder(root,"Setores")
    local entrance=forestFolder(areas,"01_Entrada_Transicao")
    local trail=forestFolder(areas,"02_TrilhaOculta")
    local cabinArea=forestFolder(areas,"03_Cabana")
    local riverArea=forestFolder(areas,"04_RiachoPonte")
    local clearing=forestFolder(areas,"05_ClareiraSecreta")
    local woods=forestFolder(root,"ArvoresModulares")
    local foliage=forestFolder(root,"MatagalCortavel")
    local stoneGroup=forestFolder(root,"PedrasTroncos")
    local secrets=forestFolder(root,"SegredosRecompensas")
    -- The former rectangular floor parts are now a continuous, sculptable Terrain surface.
    -- Alongamento natural da estrada: andando, sem teleporte seco.
    local entrancePts={Vector3.new(0,0,-83),Vector3.new(-6,0,-111),Vector3.new(-12,0,-135),Vector3.new(0,0,-165),Vector3.new(3,0,-206)}
    for i=1,#entrancePts-1 do forestPath(entrance,entrancePts[i],entrancePts[i+1],i==1 and 13 or 10) end
    forestSign(entrance,"FLORESTA ESQUECIDA",Vector3.new(-13,0,-161),20)
    -- [Claude 2026-11-10] bordas da trilha de entrada: pedrinhas e flores quebram as bordas retas das placas
    do
        local edgeRng=Random.new(1110)
        local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Exclude rp.FilterDescendantsInstances={root}
        local flowers={Color3.fromRGB(246,214,104),Color3.fromRGB(236,150,190),Color3.fromRGB(190,170,236)}
        for i=1,#entrancePts-1 do
            local a,b=entrancePts[i],entrancePts[i+1]
            local d=b-a local len=d.Magnitude local dir=d.Unit local side=Vector3.new(-dir.Z,0,dir.X)
            local half=(i==1 and 13 or 10)/2
            for s=0,len,2.6 do
                for _,sgn in ipairs({-1,1}) do
                    local p=a+dir*s+side*sgn*(half+edgeRng:NextNumber(.2,1.1))
                    local hit=workspace:Raycast(Vector3.new(p.X,70,p.Z),Vector3.new(0,-140,0),rp)
                    local y=hit and hit.Position.Y or forestGroundY
                    if edgeRng:NextNumber()<.55 then
                        local sz=edgeRng:NextNumber(.7,1.5)
                        local stone=forestPart(entrance,"PedraDaBorda",Vector3.new(sz,sz,sz),CFrame.new(p.X,y+sz*.2,p.Z),
                            Color3.fromRGB(128,132,120):Lerp(Color3.fromRGB(96,116,96),edgeRng:NextNumber()),Enum.Material.Slate,false,Enum.PartType.Ball)
                        stone.CanQuery=false
                    else
                        local col=flowers[edgeRng:NextInteger(1,#flowers)]
                        for _=1,3 do
                            local flower=forestPart(entrance,"FlorDaBorda",Vector3.new(.45,.45,.45),
                                CFrame.new(p.X+edgeRng:NextNumber(-.6,.6),y+.3,p.Z+edgeRng:NextNumber(-.6,.6)),col,Enum.Material.SmoothPlastic,false,Enum.PartType.Ball)
                            flower.CanQuery=false
                        end
                    end
                end
            end
        end
    end
    local mainTrail={Vector3.new(3,0,-206),Vector3.new(-24,0,-257),Vector3.new(-62,0,-303),Vector3.new(-103,0,-342)}
    for i=1,#mainTrail-1 do forestPath(trail,mainTrail[i],mainTrail[i+1],forestRng:NextNumber(6,8)) end
    for _,path in ipairs({{Vector3.new(-103,0,-342),Vector3.new(-37,0,-407)},
        {Vector3.new(-37,0,-407),Vector3.new(23,0,-454)},
        {Vector3.new(23,0,-454),Vector3.new(41,0,-460)},
        {Vector3.new(90,0,-460),Vector3.new(129,0,-515)},
        {Vector3.new(129,0,-515),Vector3.new(142,0,-569)}}) do forestPath(trail,path[1],path[2],6) end
    forestCabin(cabinArea)
    Art.water(root,Scenery)
    forestBridge(riverArea)
    forestSign(clearing,"CLAREIRA DAS RAIZES",Vector3.new(146,0,-576),16)
    for i=1,12 do
        local a=i*math.pi/6
        forestStone(clearing,142+math.cos(a)*18,-581+math.sin(a)*16,forestRng:NextNumber(.8,1.7))
    end
    -- Dense, irregular patches: native test-area meshes at 1.5 stud spacing.
    local patches={{-28,-231,15,12},{-64,-278,16,12},{-136,-317,16,13},
        {-139,-373,16,14},{-73,-393,16,13},{-8,-427,17,14},
        {35,-480,14,13},{106,-503,16,14},{151,-548,17,13},
        {174,-603,16,13},{-116,-505,17,14},{-180,-577,16,13},
        {175,-662,16,13},{93,-713,17,14},{-41,-740,17,13},{-171,-682,17,14}}
    local attempts=0
    for _,patch in ipairs(patches) do
        patch[3]*=.76 patch[4]*=.76
        for dx=-patch[3],patch[3],1.5 do for dz=-patch[4],patch[4],1.5 do
            local norm=(dx/patch[3])^2+(dz/patch[4])^2
            if norm<.78+math.noise(dx*.14,dz*.14,patch[1])*.22 then
                forestGrassSpawn(foliage,patch[1]+dx+forestRng:NextNumber(-.25,.25),patch[2]+dz+forestRng:NextNumber(-.25,.25))
                attempts+=1 if attempts%100==0 then task.wait() end
            end
        end end
    end
    -- Authored grove centers frame the route, with irregular satellite trees.
    local groves={{-39,-218},{36,-227},{-82,-267},{24,-280},{-140,-302},
        {-153,-359},{-79,-366},{-65,-405},{17,-395},{103,-419},{130,-478},
        {104,-550},{180,-575},{-135,-482},{-185,-546},{-72,-564},{-32,-653},
        {183,-700},{82,-757},{-124,-737},{-229,-686},{-226,-404},{215,-329}}
    for index,center in ipairs(groves) do
        for j=1,10 do
            local a=j*2.39996+index*.7
            local r=6+math.sqrt(j)*8
            local x,z=center[1]+math.cos(a)*r,center[2]+math.sin(a)*r
            local clearCabin=(x+108)^2+(z+346)^2>29^2
            local clearVista=not (x>-126 and x<-81 and z>-345 and z<-306)
            local clearRiver=not Scenery.inRiver(x,z,6)
            if clearCabin and clearVista and clearRiver then forestTree(woods,x,z,index%5+1) end
        end
        task.wait()
    end
    -- Two older trees behind the cabin establish a sheltered destination.
    Scenery.tree(woods,-130,-369,1,forestRng,1.05)
    Scenery.tree(woods,-83,-373,2,forestRng,.95)
    for i=1,103 do
        local x=forestRng:NextNumber(-211,212)
        local z=forestRng:NextNumber(-629,-217)
        if forestRng:NextNumber()<.69 then forestStone(stoneGroup,x,z,forestRng:NextNumber(.7,2.2))
        else forestLog(stoneGroup,x,z,forestRng:NextNumber(0,math.pi*2),forestRng:NextNumber(4,10)) end
    end
    -- Segredos predeterminados e INVESTIGAVEIS; revelados ao cortar perto, nao apenas RNG de um tufo.
    for _,s in ipairs({
        {id="entrada_bau",kind="chest",rarity="Comum",x=-19,z=-243,visible=true},
        {id="diario_cabana",kind="artifact",x=-125,z=-351},
        {id="bau_raizes",kind="chest",rarity="Incomum",x=-150,z=-512},
        {id="bau_rio",kind="chest",rarity="Raro",x=31,z=-478},
        {id="pedra_runica",kind="artifact",x=143,z=-587},
        {id="bau_clareira",kind="chest",rarity="Lendario",x=157,z=-589},
        {id="bau_norte",kind="chest",rarity="Comum",x=-180,z=-301},
        {id="bau_sul",kind="chest",rarity="Incomum",x=-7,z=-606},
        {id="bau_antigo",kind="chest",rarity="Mitologico",x=-195,z=-620},
    }) do forestAddSecret(secrets,s) end
    Scenery.enrich(root,
        function(x,z) return forestGrassSpawn(foliage,x,z) end,
        function(info) return forestAddSecret(secrets,info) end,
        forestPath,forestSign,forestRng)
    Scenery.exploration(root,
        function(x,z) return forestGrassSpawn(foliage,x,z) end,
        function(info) return forestAddSecret(secrets,info) end,
        forestPath,forestRng)
    Art.transition(root,Scenery)
    Art.oldCave(root,Scenery)
    Art.underground(root,Scenery,function(x,z,important) return forestGrassSpawn(foliage,x,z,important) end,
        function(info) return forestAddSecret(secrets,info) end)
    Art.polish(root,Scenery)
    -- [Claude 2026-11-11] cabana por fora e por dentro (só decoração)
    do local ok,err=pcall(function() require(script.Parent.CabanaDetalhes).decorate(root) end) if not ok then warn("[Cabana] "..tostring(err)) end end
    -- Continuous cover across the grass footprint, with natural jitter and protected paths.
    -- Native clumps are 4–6 studs wide; 3.8-stud centers overlap without enlarging the meshes.
    for x=-296,296,3.8 do
        for z=-821,-181,3.8 do
            forestGrassSpawn(foliage,x+forestRng:NextNumber(-.85,.85),z+forestRng:NextNumber(-.85,.85))
        end
        task.wait()
    end
    -- One wider native clump per distant cell preserves coverage when the camera zooms out.
    -- Its stage approximates the majority of the authoritative clumps in that cell.
    for _,g in ipairs(FOREST.grass) do
        local key=math.floor(g.x/16)..":"..math.floor(g.z/16)
        local group=forestDistant[key]
        if not group then
            group={id="distant:"..key,x=0,z=0,groundY=0,scale=1,rotation=g.rotation,variant=g.variant,
                stage=0,total=0,cut=0,stubble=0,heightFactor=0}
            forestDistant[key]=group
        end
        group.x+=g.x group.z+=g.z group.groundY+=g.groundY group.total+=1 group.heightFactor+=g.heightFactor
        g.distantGroup=group
    end
    local distantCount=0
    for _,group in pairs(forestDistant) do
        group.x/=group.total group.z/=group.total group.groundY/=group.total group.heightFactor/=group.total
        group.distantMask=0
        for i,off in ipairs({Vector2.new(-4,-4),Vector2.new(4,-4),Vector2.new(-4,4),Vector2.new(4,4)}) do
            local offset=GrassStyle.offset(group.x,group.z,i)
            local px,pz=group.x+offset.X,group.z+offset.Z
            if not Scenery.inRiver(px,pz,2) and not Scenery.onPath(px,pz,3.5) and not Commerce.reserved(px,pz,22) and not Art.blockGrass(px,pz) and GrassStyle.scatter(px,pz)<=Art.grassBlend(px,pz) then
                group.distantMask+=2^(i-1)
            end
        end
        distantCount+=1
    end
    root:SetAttribute("DistantGrassCells",distantCount)
    root:SetAttribute("CoverageSpacing",3.8)
    root:SetAttribute("GrassRendering","Client proximity streaming; authoritative server cuts")
    FOREST.root=root FOREST.ready=true
    root:SetAttribute("GrassCount",#FOREST.grass)
    root:SetAttribute("SecretsCount",#FOREST.secrets)
    print("[Floresta] PRONTA: "..#FOREST.grass.." tufos cortaveis GrassPack, "..#FOREST.secrets.." segredos, area 600x648 studs")
end
-- Clients request proximity snapshots; they cannot choose grass stages or award progress.
forestStream.OnServerEvent:Connect(function(player)
    local now=os.clock()
    local viewer=forestViewers[player]
    if viewer and now-viewer.last<.7 then return end
    viewer=viewer or {loaded={},last=-100}
    viewer.last=now forestViewers[player]=viewer
    local _,root=live(player)
    if not root or not FOREST.ready then return end
    if viewer.character~=player.Character then
        viewer.loaded={} viewer.distant=false viewer.character=player.Character
    end
    if not viewer.distant then
        viewer.distant=true
        local coarse={}
        for _,g in pairs(forestDistant) do
            table.insert(coarse,forestPacket(g))
            if #coarse>=180 then forestStream:FireClient(player,"distant",coarse) coarse={} end
        end
        if #coarse>0 then forestStream:FireClient(player,"distant",coarse) end
    end
    if not FOREST.inside(root.Position) then
        if next(viewer.loaded) then viewer.loaded={} forestStream:FireClient(player,"nearClear",{}) end
        return
    end
    local p=root.Position
    for id in pairs(viewer.loaded) do
        local g=FOREST.grass[id]
        if not g or (g.x-p.X)^2+(g.z-p.Z)^2>115^2 then viewer.loaded[id]=nil end
    end
    local packet={}
    local cs=FOREST.cellSize
    for bx=math.floor((p.X-100)/cs),math.floor((p.X+100)/cs) do
        for bz=math.floor((p.Z-100)/cs),math.floor((p.Z+100)/cs) do
            for _,g in ipairs(FOREST.buckets[bx..":"..bz] or {}) do
                if not viewer.loaded[g.id] and (g.x-p.X)^2+(g.z-p.Z)^2<=100^2 then
                    viewer.loaded[g.id]=true
                    table.insert(packet,forestPacket(g))
                    if #packet>=180 then forestStream:FireClient(player,"add",packet) packet={} end
                end
            end
        end
    end
    if #packet>0 then forestStream:FireClient(player,"add",packet) end
end)
Players.PlayerRemoving:Connect(function(player)
    forestViewers[player]=nil
    for _,secret in ipairs(FOREST.secrets) do secret.claimed[player.UserId]=nil end
end)
task.spawn(function()
    local ok,err=pcall(forestBuild)
    if not ok then warn("[Floresta] ERRO AO CONSTRUIR: "..tostring(err)) end
end)

-- [Claude 2026-11-10] Distancia do trajeto a-b da lamina (XZ local do lote) ate a AREA do
-- quadrado 4x4 de centro c. Usada pelo corte continuo do carrinho (mesma regra no cliente).
-- Nivel de largura 1 corta so o quadrado por onde o centro da lamina passa; cada +1 de
-- largura alarga a faixa em 2 studs para cada lado (media de 'largura' quadrados por fileira).
local LOT_CUT_REACH=0
local function lotSegDist(c,a,b)
    local best=math.huge
    for i=0,5 do
        local q=a:Lerp(b,i/5)
        local dx=math.max(math.abs(q.X-c.X)-2,0)
        local dy=math.max(math.abs(q.Y-c.Y)-2,0)
        best=math.min(best,math.sqrt(dx*dx+dy*dy))
    end
    return best
end
-- [Claude 2026-11-10] Corte do carrinho no lote (trajeto da lamina + orcamento). Chamado pelo
-- CutIntent e tambem quando o servidor detecta que o jogador PAROU, para processar o ultimo
-- trecho percorrido (o cliente so envia CutIntent enquanto ha input de movimento).
local function lotMowerCut(player,s,root,equipped)
    local settings=Config.Levels[s.profile.mowerLevel]
    local now=os.clock()
    if now-s.motion.at>.35 then return end
    if (root.Position-s.motion.position).Magnitude>7 then return end
    -- A direção medida do deslocamento prevalece sobre a câmera e a rotação do avatar.
    local origin=root.Position+s.motion.direction*2.6
    -- [Ferramentas] quem corta é a lâmina: usa a posição real da Lamina do cortador equipado
    local lamina=equipped:FindFirstChild("Lamina",true)
    if lamina and lamina:IsA("BasePart") and (lamina.Position-root.Position).Magnitude<9 then origin=lamina.Position end
    local zone=s.plot.GrassZone01
    local localOrigin=zone.CFrame:PointToObjectSpace(origin)
    if math.abs(localOrigin.Y)>7 then s.lastBladeLocal=nil return end
    local width=settings.Width+Skills.widthBonus(player)
    if s.job.finished then
        if now-s.lastCut<settings.Interval then return end
        s.lastCut=now
        closeCut(player,s,localOrigin,width) return
    end
    -- [Claude 2026-11-10] Corte continuo do carrinho: corta os quadrados que a LAMINA PERCORREU
    -- desde o ultimo pedido, na ordem da passagem. Orcamento de "largura por intervalo" (acumula
    -- ate 3x) mantem o mesmo ritmo medio do nivel; antes, a cadencia do cliente (0,16 s) contra o
    -- intervalo (0,22 s) cortava so a cada 0,32 s e pulava quadrados atravessados entre pedidos.
    -- O cliente (StarterPlayerScripts.LotCutFeel) preve com esta mesma regra.
    s.cutTokens=math.min((s.cutTokens or width)+(now-(s.cutClock or now))/settings.Interval*width,width*3)
    s.cutClock=now
    local here=Vector2.new(localOrigin.X,localOrigin.Z)
    local prev=s.lastBladeLocal
    if not prev or (prev-here).Magnitude>8 then prev=here end
    s.lastBladeLocal=here
    if s.cutTokens<1 then return end
    local reach=LOT_CUT_REACH+(width-1)*2
    local candidates={}
    for row=1,8 do for col=1,8 do
        local id=(row-1)*8+col
        if not s.job.cutFlags[id] then
            local c=Vector2.new(-18+col*4,-18+row*4)
            if lotSegDist(c,prev,here)<=reach then table.insert(candidates,{id=id,d=(c-prev).Magnitude}) end
        end
    end end
    if #candidates==0 then return end
    table.sort(candidates,function(a,b) return a.d<b.d end)
    local chosen={}
    for _,cell in ipairs(candidates) do
        if #chosen>=math.floor(s.cutTokens) then break end
        table.insert(chosen,cell.id)
    end
    s.cutTokens-=#chosen
    s.lastCut=now
    cutIds(player,s,chosen)
end
-- [Claude 2026-11-10] Carrinho na floresta com orcamento: mesmo ritmo de projeto (ate 4+nivel tufos
-- por 0,19 s, acumula ate 2x), sem o descompasso entre a cadencia do cliente (0,16 s) e o bloqueio
-- de 0,19 s que fazia o corte sair em lotes a cada ~0,38 s. Tambem chamado quando o jogador para.
-- O cliente (ForestGrassClient) preve com esta mesma regra.
local FOREST_MOWER_INTERVAL=0.19
local function forestMowerCut(player,s,root)
    local equipped=player.Character and player.Character:FindFirstChild("MowerTool")
    if not equipped then return end
    local blade=equipped:FindFirstChild("Lamina",true) or equipped:FindFirstChild("CutOrigin",true)
    if not blade or not blade:IsA("BasePart") or (blade.Position-root.Position).Magnitude>11 then return end
    local now=os.clock()
    local base=math.clamp(4+s.profile.mowerLevel,3,9)
    s.forestTokens=math.min((s.forestTokens or base)+(now-(s.forestClock or now))/FOREST_MOWER_INTERVAL*base,base*2)
    s.forestClock=now
    local previous=FOREST.mowerPos[player]
    local current=blade.Position
    FOREST.mowerPos[player]=current
    if not previous or (current-previous).Magnitude>12 then previous=current end
    if s.forestTokens<1 then return end
    local width=math.clamp((Config.Levels[s.profile.mowerLevel].Width or 1)*1.0+1.4,1.5,4.5)
    local _,contacts=FOREST.cutTrace(player,{previous,current},width,math.floor(s.forestTokens))
    s.forestTokens-=(tonumber(contacts) or 0)
end
remotes.CutIntent.OnServerEvent:Connect(function(player,...)
    if not allow(player,"cut",.14,...) then return end
    local s,root=live(player)
    if not s or not s.motion or not s.motion.valid then return end
    if not inPlot(s,root.Position) then
        if FOREST.inside(root.Position) and FOREST.ready then forestMowerCut(player,s,root) end
        return
    end
    if s.job.finished and not Skills.has(player,"CUT_CLOSE") then return end
    local equipped=player.Character:FindFirstChild("MowerTool")
    if not equipped or not equipped:IsA("Tool") then return end
    lotMowerCut(player,s,root,equipped)
end)
Skills.bindGame({
    session=function(player) return live(player) end,
    inPlot=inPlot,
    hasMower=function(player)
        local tool=player.Character and player.Character:FindFirstChild("MowerTool")
        return tool~=nil and tool:IsA("Tool")
    end,
    -- quadrados ainda não cortados num raio (studs) da posição, mais próximos primeiro
    cellsNear=function(s,position,radius,max)
        local localPos=s.plot.GrassZone01.CFrame:PointToObjectSpace(position)
        local list={}
        for row=1,8 do for col=1,8 do
            local id=(row-1)*8+col
            if not s.job.cutFlags[id] then
                local d=(Vector2.new(-18+col*4,-18+row*4)-Vector2.new(localPos.X,localPos.Z)).Magnitude
                if d<=radius then table.insert(list,{id=id,d=d}) end
            end
        end end
        table.sort(list,function(a,b) return a.d<b.d end)
        local ids={}
        for i=1,math.min(max,#list) do ids[i]=list[i].id end
        return ids
    end,
    cutIds=function(player,s,ids) return cutIds(player,s,ids) end,
    equipMower=function(player,id)
        local lista=","..(player:GetAttribute("Comprados") or "")..","
        if type(id)~="string" or not string.find(lista,","..id..",",1,true) then return false end
        return Economia.Comprar(player,id) -- item já comprado: o servidor só equipa
    end,
    findChest=function(player)
        local s,root=live(player)
        if not s or not s.secret or not s.secret.PrimaryPart then return nil end
        return s.secret.PrimaryPart.Position, (root.Position-s.secret.PrimaryPart.Position).Magnitude
    end,
    fx=function(player,kind,position,data) Skills.feedback(player,kind,position,data) end,
})
-- [Ferramentas] ganchos pro FerramentasServer: corte pela lâmina das ferramentas manuais e re-equipar o cortador
local ganchos=Instance.new("Folder") ganchos.Name="GameServerGanchos"
local evEquipar=Instance.new("BindableEvent") evEquipar.Name="EquiparCortador" evEquipar.Parent=ganchos
evEquipar.Event:Connect(function(player) if sessions[player] then equip(player) sync(player) end end)
local fnCortar=Instance.new("BindableFunction") fnCortar.Name="CortarPorLamina" fnCortar.Parent=ganchos
local function distSeg(c,a,b)
    local ab=b-a local l2=ab:Dot(ab)
    local t=l2>0 and math.clamp((c-a):Dot(ab)/l2,0,1) or 0
    return (a+ab*t-c).Magnitude
end
-- [Claude 2026-11-10] Distancia do traco da lamina ate a AREA do quadrado do lote (4x4 studs),
-- e nao ate o centro: o acerto deixa de depender do alinhamento do jogador com a grade.
-- Os tracos sao curtos (amostrados a ~90 Hz), entao 6 pontos por segmento bastam.
local MEIO_QUADRADO=2
local function distQuadrado(c,a,b)
    local best=math.huge
    for i=0,5 do
        local q=a:Lerp(b,i/5)
        local dx=math.max(math.abs(q.X-c.X)-MEIO_QUADRADO,0)
        local dy=math.max(math.abs(q.Y-c.Y)-MEIO_QUADRADO,0)
        best=math.min(best,math.sqrt(dx*dx+dy*dy))
    end
    return best
end
fnCortar.OnInvoke=function(player,amostras,raio,forca,maxTiles,segments,allowedTypes)
    local s,root=live(player)
    if not s then return 0 end
    if not inPlot(s,root.Position) then
        -- Os golpes manuais continuam validados no FerramentasServer.
        -- Reutilizamos a mesma varredura da lamina para a floresta, sem novo RemoteEvent.
        return FOREST.cutTrace(player,amostras,raio,maxTiles,segments,forca,allowedTypes)
    end
    if s.job.finished then return 0 end
    if allowedTypes and not table.find(allowedTypes,"Curta") then return 0,0 end
    local zone=s.plot.GrassZone01
    local pts={}
    for _,sample in ipairs(amostras) do
        local a=segments and sample[1] or sample
        local b=segments and sample[2] or sample
        local la,lb=zone.CFrame:PointToObjectSpace(a),zone.CFrame:PointToObjectSpace(b)
        if math.abs(la.Y)<=7 and math.abs(lb.Y)<=7 then
            table.insert(pts,{Vector2.new(la.X,la.Z),Vector2.new(lb.X,lb.Z)})
        end
    end
    if #pts==0 then return 0 end
    -- quadrados do lote cujo centro está perto do TRAÇO da lâmina (segmentos entre amostras)
    local hits={}
    for row=1,8 do for col=1,8 do
        local id=(row-1)*8+col
        if not s.job.cutFlags[id] then
            local c=Vector2.new(-18+col*4,-18+row*4) local d=math.huge local primeiro=nil
            for index,segment in ipairs(pts) do
                d=math.min(d,distSeg(c,segment[1],segment[2]))
                if not primeiro and distQuadrado(c,segment[1],segment[2])<=raio then primeiro=index end
            end
            if primeiro then table.insert(hits,{id=id,row=row,col=col,d=d,primeiro=primeiro}) end
        end
    end end
    -- [Claude 2026-11-10] limite de maxTiles aplicado NA ORDEM DO TOQUE (amostras em ordem de tempo),
    -- desempate pela distancia; o cliente (LotCutPreview.swing) preve no contato com a mesma ordem.
    table.sort(hits,function(a,b) if a.primeiro~=b.primeiro then return a.primeiro<b.primeiro end return a.d<b.d end)
    s.job.dano=s.job.dano or {}
    local count,tocados=0,0
    for _,cell in ipairs(hits) do
        if tocados>=maxTiles then break end
        tocados+=1
        local tile=s.plot.GrassVisuals[string.format("Grass_%02d_%02d",cell.row,cell.col)]
        s.job.dano[cell.id]=(s.job.dano[cell.id] or 0)+forca
        if s.job.dano[cell.id]>=0.999 then
            if Economia.CortarGrama(player) and Rules.cut(s.profile,s.job,cell.id) then
                count+=1 setTileCut(tile,true)
                TufoDourado.aoCortarLote(player,s,cell.id,tile) -- [Claude 2026-11-11]
                if s.job.hasBonusSecret and not s.job.secretRevealed and s.job.cutCount>=s.job.revealAt then reveal(player,s,tile) end
                remotes.FXEvent:FireClient(player,"Cut",tile.Position)
            else s.job.dano[cell.id]=0.999 end
        end
    end
    coletarAparas(player,s,count)
    if count>0 and s.job.finished and not s.job.ecoBonus then s.job.ecoBonus=true Economia.AddMoedas(player,Config.JobReward) Economia.AddXP(player,40) agendarRebrota(player,s) MissoesSinal.contar(player,"jardim",1) end
    if count>0 then sync(player,s.job.finished and "Jardim restaurado! Bônus +40 moedas" or nil) end
    return count,tocados
end
ganchos.Parent=game.ServerStorage

for _,plot in ipairs(world.Plots:GetChildren()) do
    plot.UpgradePad.UpgradePrompt.Triggered:Connect(function(player)
        local s,root=live(player)
        if not s or s.plot~=plot or (root.Position-plot.UpgradePad.Position).Magnitude>11 then return end
        if allow(player,"upgrade",.8) then upgrade(player) end
    end)
end
local function spawnCharacter(player,character)
    local root=character:WaitForChild("HumanoidRootPart",10)
    local humanoid=character:WaitForChild("Humanoid",10)
    local s=sessions[player]
    if not root or not humanoid or not s or player.Character~=character then return end
    character:PivotTo(s.plot.PlayerSpawn.CFrame)
    s.motion=nil s.previousPosition=nil
    humanoid.WalkSpeed=16
    equip(player) sync(player)
end
local function added(player)
    if closing then return end
    local plot
    for _,candidate in ipairs(world.Plots:GetChildren()) do if not reserved[candidate] then plot=candidate break end end
    if not plot then player:Kick("Os quatro lotes estão ocupados. Entre em outro servidor.") return end
    reserved[plot]=player
    local profile=Profiles.load(player)
    if not profile then reserved[plot]=nil player:Kick("Seu perfil está indisponível. Tente novamente em instantes.") return end
    if not player.Parent or closing then Profiles.save(player,true) reserved[plot]=nil return end
    Economia.Iniciar(player,profile.Economy)
    player:SetAttribute("ForestGrassCut",0)
    player:SetAttribute("ForestSecrets",0)
    player:SetAttribute("ForestArtifacts",0)
    player:SetAttribute("RegiaoAtual","Vila")
    Commerce.attach(player)
    -- [Claude 2026-11-11] persistência: saco limitado à capacidade (mochilas já aplicadas) e segredos já coletados
    -- de volta para o cliente (feixes/contador) a partir do perfil salvo
    player:SetAttribute("Saco",math.min(player:GetAttribute("Saco") or 0,player:GetAttribute("SacoMax") or 0))
    do
        local fe=profile.ForestEconomy
        if fe and type(fe.claimed)=="table" then
            local ids={} for id in pairs(fe.claimed) do table.insert(ids,id) end
            table.sort(ids)
            player:SetAttribute("ForestClaimedSecrets",table.concat(ids,","))
            player:SetAttribute("ForestSecrets",#ids)
        end
    end
    player:SetAttribute("ProfileReady",true)
    Skills.attach(player)
    local s={profile=profile,plot=plot,rates={}}
    sessions[player]=s resetJob(s)
    plot:SetAttribute("OwnerUserId",player.UserId)
    -- Avatar appearance may load from Roblox; keep economy and respawn initialization independent.
    task.spawn(function()
        local ok,npc=pcall(serviceNpcCreate,player,s)
        if not ok then warn("[Vendedor] "..tostring(npc)) return end
        if sessions[player]~=s then npc:Destroy() return end
        s.serviceNpc=npc
        serviceNpcRefresh(s)
    end)
    plot.PlotSign.Panel.Label.Text.Text=player.DisplayName.."\nSEU JARDIM"
    s.characterConnection=player.CharacterAdded:Connect(function(character) spawnCharacter(player,character) end)
    local function aplicarCortador() s.profile.mowerLevel=CORTADOR_NIVEL[player:GetAttribute("Cortador") or ""] or 1 if player.Character then equip(player) end end
    s.profile.mowerLevel=CORTADOR_NIVEL[player:GetAttribute("Cortador") or ""] or 1
    s.cortadorConnection=player:GetAttributeChangedSignal("Cortador"):Connect(aplicarCortador)
    s.sacoConnection=player:GetAttributeChangedSignal("Saco"):Connect(function() local v,m=player:GetAttribute("Saco") or 0,player:GetAttribute("SacoMax") or 1 if v==0 or v>=m then sync(player) end end)
    if player.Character then task.spawn(spawnCharacter,player,player.Character) end
end
local function removing(player)
    local s=sessions[player]
    if s then
        sessions[player]=nil
        s.characterConnection:Disconnect() clearSecret(s)
        if s.serviceNpc then s.serviceNpc:Destroy() s.serviceNpc=nil end
        if s.cortadorConnection then s.cortadorConnection:Disconnect() end
        if s.sacoConnection then s.sacoConnection:Disconnect() end
        s.plot:SetAttribute("OwnerUserId",nil)
        s.plot.PlotSign.Panel.Label.Text.Text="LOTE LIVRE"
        for _,tile in ipairs(s.plot.GrassVisuals:GetChildren()) do setTileClose(tile,false) setTileCut(tile,false) end
        reserved[s.plot]=nil
    end
    FOREST.mowerPos[player]=nil
    Profiles.save(player,true)
end
Players.PlayerAdded:Connect(added) Players.PlayerRemoving:Connect(removing)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(added,player) end
local elapsed=0
RunService.Heartbeat:Connect(function(dt)
    elapsed+=dt if elapsed<.1 then return end elapsed=0
    local now=os.clock()
    for player,s in pairs(sessions) do
        local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local area=FOREST.inside(root.Position) and "Floresta Esquecida" or "Vila"
            if player:GetAttribute("RegiaoAtual")~=area then
                player:SetAttribute("RegiaoAtual",area)
                -- [Claude 2026-11-10] o aviso de entrada agora é o cartão de região do cliente (RegionTitleCard)
            end
            if s.previousPosition then
                local wasMoving=s.motion and s.motion.valid
                local difference=root.Position-s.previousPosition
                local flat=Vector3.new(difference.X,0,difference.Z)
                local speed=flat.Magnitude/math.max(now-s.previousTime,.001)
                s.motion={valid=speed>1 and speed<=26 and math.abs(difference.Y)<5,
                    direction=flat.Magnitude>0 and flat.Unit or Vector3.zero,position=root.Position,at=now}
                -- [Claude 2026-11-10] parou: fecha o ultimo trecho da lamina com a posicao do servidor
                if wasMoving and not s.motion.valid and s.lastBladeLocal and not s.job.finished then
                    local mower=player.Character and player.Character:FindFirstChild("MowerTool")
                    if mower and mower:IsA("Tool") and inPlot(s,root.Position) then lotMowerCut(player,s,root,mower) end
                    s.lastBladeLocal=nil
                end
                if wasMoving and not s.motion.valid and FOREST.ready and FOREST.mowerPos[player] and FOREST.inside(root.Position) then
                    forestMowerCut(player,s,root)
                    FOREST.mowerPos[player]=nil
                end
            end
            s.previousPosition=root.Position s.previousTime=now
        else s.previousPosition=nil s.motion=nil end
    end
end)
task.spawn(function()
    while not closing do
        task.wait(45)
        for player in pairs(sessions) do task.spawn(Profiles.save,player,false) end
    end
end)
game:BindToClose(function()
    closing=true
    local pending=0
    for _,player in pairs(reserved) do
        pending+=1 task.spawn(function() removing(player) pending-=1 end)
    end
    local deadline=os.clock()+25
    while pending>0 and os.clock()<deadline do task.wait(.1) end
    -- [Claude 2026-11-11] espera também os salvamentos finais disparados pelo PlayerRemoving
    while Profiles.pendentes()>0 and os.clock()<deadline do task.wait(.1) end
end)
