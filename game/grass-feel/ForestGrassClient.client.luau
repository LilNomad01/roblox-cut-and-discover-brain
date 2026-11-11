-- Nearby visual grass only. Cutting, stages, rewards and secret gates belong to the server.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local stream=game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ForestGrassStream")
local library=game.ReplicatedStorage:WaitForChild("GramaAssets"):WaitForChild("GrassPack")
local visuals=Instance.new("Folder")
visuals.Name="Floresta_MatagalLocal"
visuals.Parent=workspace
local records={}
local distant={}
local distantVisuals=Instance.new("Folder")
distantVisuals.Name="Floresta_CoberturaDistante"
distantVisuals.Parent=workspace
local states={"TALL","SHORT","STUBBLE"}
local radius=UserInputService.TouchEnabled and 58 or 82
local effects=0
local Sons=require(game.ReplicatedStorage.Shared:WaitForChild("Sons"))
local lastCutSound=-100
local wind={}
local pendingCut={} -- [Claude 2026-11-10] tufos com corte previsto localmente, aguardando o servidor
local function remove(g)
    if g.part then g.part:Destroy() g.part=nil end
end
local function clear()
    for _,g in pairs(records) do remove(g) end
    for _,g in pairs(distant) do remove(g) end
    table.clear(records) table.clear(distant) table.clear(wind)
end
local function leaves(position)
    if effects>=30 then return end
    for i=1,(UserInputService.TouchEnabled and 2 or 3) do
        effects+=1
        local p=Instance.new("Part")
        p.Name="FolhaCortada" p.Size=Vector3.new(.12,.58,.18)
        p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=false
        p.Color=Color3.fromRGB(157,218,88)
        p.CFrame=CFrame.new(position+Vector3.new(0,1,0))*CFrame.Angles(i,0,i*.7)
        p.Parent=visuals
        TweenService:Create(p,TweenInfo.new(.42,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
            {Position=p.Position+Vector3.new(math.cos(i*2.4)*2,1.2,math.sin(i*2.4)*2),Transparency=1}):Play()
        Debris:AddItem(p,.45)
        task.delay(.45,function() effects=math.max(0,effects-1) end)
    end
end
-- Small clusters retain the test grass silhouette instead of stretching one clump across a cell.
local function grassTone(g)
    local blend=math.clamp(.5+math.noise(g.x*.021,g.z*.021)*1.4,0,1)
    return Color3.fromRGB(105,172,66):Lerp(Color3.fromRGB(155,202,89),blend)
end
local function renderDistant(g)
    remove(g)
    local model=Instance.new("Model") model.Name="Cobertura_"..g.id
    local template=library:FindFirstChild("Grass_"..g.variant.."_"..states[g.stage+1])
    if not template then return end
    g.blades={}
    for i,offset in ipairs({Vector3.new(-4,0,-4),Vector3.new(4,0,-4),Vector3.new(-4,0,4),Vector3.new(4,0,4)}) do
        if bit32.band(g.distantMask or 15,2^(i-1))==0 then continue end
        local p=template:Clone()
        p.Name="MatoDistante"
        p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=false
        p.Size=Vector3.new(template.Size.X*1.95,template.Size.Y*(g.heightFactor or 1),template.Size.Z*1.95)
        p.Color=grassTone(g)
        p.CFrame=CFrame.new(g.x+offset.X,g.y-.08+p.Size.Y/2,g.z+offset.Z)*CFrame.Angles(0,g.rotation+i*1.7,0)
        p.Parent=model table.insert(g.blades,p)
    end
    model.Parent=distantVisuals g.part=model g.fade=nil
end
local function render(g,cut)
    if g.distant then renderDistant(g) return end
    local template=library:FindFirstChild("Grass_"..g.variant.."_"..states[g.stage+1])
    if not template then return end
    local old=g.part
    local p=template:Clone()
    p.Name="MatoCortavel_"..g.id
    p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=false
    p.Size=template.Size*g.scale
    -- Overlap neighboring native clumps without adding instances or rewards.
    -- Preserve authored low vegetation along paths and clearings.
    local heightFactor=g.heightFactor or 1
    if heightFactor>=.65 then heightFactor=math.max(.95,heightFactor) end
    p.Size=Vector3.new(p.Size.X*1.28,p.Size.Y*heightFactor,p.Size.Z*1.28)
    p.Color=grassTone(g)
    g.base=CFrame.new(g.x,g.y-.08+p.Size.Y/2,g.z)*CFrame.Angles(0,g.rotation,0)
    p.CFrame=g.base
    p.Parent=g.distant and distantVisuals or visuals g.part=p
    if cut and old then
        local h=old.Size.Y
        TweenService:Create(old,TweenInfo.new(.23,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),
            {Size=Vector3.new(old.Size.X,.12,old.Size.Z),
            CFrame=old.CFrame*CFrame.new(0,-h*.45,0)*CFrame.Angles(.28,0,.12),Transparency=1}):Play()
        Debris:AddItem(old,.26)
        leaves(Vector3.new(g.x,g.y,g.z))
        if os.clock()-lastCutSound>=.12 then
            lastCutSound=os.clock()
            Sons.tocar("Corte",{pos=Vector3.new(g.x,g.y+1,g.z),pitch=1.02+math.random()*.14,volume=.8})
        end
        p.Transparency=1
        TweenService:Create(p,TweenInfo.new(.16),{Transparency=template.Transparency}):Play()
    elseif old then old:Destroy() end
end
stream.OnClientEvent:Connect(function(kind,packet)
    if kind=="clear" then clear() return end
    if kind=="nearClear" then
        for _,g in pairs(records) do remove(g) end
        table.clear(records) table.clear(wind)
        return
    end
    local destination=kind=="distant" and distant or records
    for _,row in ipairs(packet) do
        if kind=="update" then pendingCut[row[1]]=nil end -- servidor respondeu: previsao confirmada ou corrigida
        local g=destination[row[1]]
        if g then
            if g.stage~=row[8] then
                g.stage=row[8]
                if g.part then render(g,not g.distant) end
            end
        else
            destination[row[1]]={id=row[1],x=row[2],z=row[3],y=row[4],scale=row[5],rotation=row[6],variant=row[7],stage=row[8],heightFactor=row[9] or 1,distantMask=row[10] or 15,distant=kind=="distant"}
        end
    end
end)
local requestElapsed,refreshElapsed,windElapsed=0,0,0
RunService.Heartbeat:Connect(function(dt)
    requestElapsed+=dt refreshElapsed+=dt windElapsed+=dt
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if requestElapsed>=1 then requestElapsed=0 stream:FireServer() end
    if not root then return end
    local pos=root.Position
    if refreshElapsed>=.18 then
        refreshElapsed=0 table.clear(wind)
        local created=0
        for id,g in pairs(records) do
            local distance=(Vector2.new(g.x,g.z)-Vector2.new(pos.X,pos.Z)).Magnitude
            if distance>115 then remove(g) records[id]=nil
            elseif distance>radius+7 then remove(g)
            elseif distance<radius and not g.part and created<80 then render(g,false) created+=1 end
            if g.part then
                local far=math.clamp((distance-radius+10)/17,0,.94)
                local camera=workspace.CurrentCamera
                local fade=0
                if camera then
                    local a,b=camera.CFrame.Position,pos
                    local segment=b-a
                    local length=segment:Dot(segment)
                    local t=length>0 and math.clamp((g.part.Position-a):Dot(segment)/length,0,1) or 0
                    local distanceToView=(g.part.Position-(a+segment*t)).Magnitude
                    if distanceToView<3.8 then fade=.86*(1-math.clamp((distanceToView-2)/1.8,0,1)) end
                end
                g.part.LocalTransparencyModifier=math.max(far,fade)
                if distance<33 and #wind<96 then table.insert(wind,g) end
            end
        end
        local distantCreated=0
        local inside=pos.X>=-300 and pos.X<=300 and pos.Z>=-825 and pos.Z<=-177
        for _,g in pairs(distant) do
            local distance=(Vector2.new(g.x,g.z)-Vector2.new(pos.X,pos.Z)).Magnitude
            local blend=inside and math.clamp((distance-radius+12)/18,0,1) or 1
            local camera=workspace.CurrentCamera
            local visible=true
            if camera then
                local screen=camera:WorldToViewportPoint(Vector3.new(g.x,g.y+3,g.z))
                visible=screen.Z>0 and screen.X>-100 and screen.X<camera.ViewportSize.X+100
                    and screen.Y>-100 and screen.Y<camera.ViewportSize.Y+100
            end
            if blend<=0 or not visible then
                if g.part then g.part.Parent=nil end
            else
                if not g.part and distantCreated<75 then render(g,false) distantCreated+=1 end
                if g.part and not g.part.Parent then g.part.Parent=distantVisuals end
                if g.part and g.fade~=blend then
                    g.fade=blend
                    for _,blade in ipairs(g.blades) do blade.LocalTransparencyModifier=1-blend end
                end
            end
        end
        visuals:SetAttribute("VisibleClumps",#visuals:GetChildren())
        distantVisuals:SetAttribute("VisibleCells",#distantVisuals:GetChildren())
    end
    if windElapsed>=.05 then
        windElapsed=0
        local now=os.clock()
        for _,g in ipairs(wind) do
            if g.part and g.part.Parent and g.stage==0 then
                local lean=math.sin(now*1.45+g.x*.11+g.z*.07)*.021
                local h=g.part.Size.Y
                g.part.CFrame=g.base*CFrame.new(0,-h/2,0)*CFrame.Angles(lean,0,lean*.45)*CFrame.new(0,h/2,0)
            end
        end
    end
end)
player.CharacterAdded:Connect(function() clear() requestElapsed=1 end)

-- [Claude 2026-11-10] Previsão local do corte na floresta (carrinho e ferramentas manuais).
-- Mesmas regras do servidor (GameServer forestMowerCut / FOREST.cutTrace). O tufo previsto já fica
-- no estágio que o servidor vai mandar, então a atualização dele não reanima nem repete som/folhas.
-- Sem confirmação em PREDICT_TIMEOUT, o tufo volta (recusa). O servidor continua decidindo tudo.
local Shared=game.ReplicatedStorage.Shared
local Config=require(Shared:WaitForChild("GameConfig"))
local okPreview,Preview=pcall(function() return require(Shared:WaitForChild("LotCutPreview",10)) end)
if not okPreview then Preview=nil end
local PREDICT_TIMEOUT=.9
local FOREST_MOWER_INTERVAL=.19 -- igual ao servidor
local MOWER_MARGIN=.6 -- perto da borda do alcance o cliente não prevê; o servidor decide
local TOOL_MARGIN=.3
local function dist2D(g,a,b)
    local abx,abz=b.X-a.X,b.Z-a.Z
    local l2=abx*abx+abz*abz
    local t=l2>0 and math.clamp(((g.x-a.X)*abx+(g.z-a.Z)*abz)/l2,0,1) or 0
    local px,pz=a.X+abx*t,a.Z+abz*t
    return math.sqrt((g.x-px)^2+(g.z-pz)^2)
end
local function sackFull()
    return (player:GetAttribute("Saco") or 0)>=(player:GetAttribute("SacoMax") or 1)
end
local function predictClump(g)
    if g.stage~=0 or not g.part or pendingCut[g.id] then return false end
    pendingCut[g.id]={t=os.clock()}
    g.stage=1
    render(g,true)
    -- contadores locais para QA (atributos na pasta visual; não replicam)
    visuals:SetAttribute("PrevisoesCorte",(visuals:GetAttribute("PrevisoesCorte") or 0)+1)
    return true
end
local mTokens,mClock,mPrev=nil,nil,nil
RunService.Heartbeat:Connect(function()
    local now=os.clock()
    for id,p in pairs(pendingCut) do
        if now-p.t>PREDICT_TIMEOUT then
            pendingCut[id]=nil
            local g=records[id]
            if g and g.stage==1 then
                g.stage=0 g.predDamage=nil
                if g.part then render(g,false) end
                visuals:SetAttribute("PrevisoesRecusadas",(visuals:GetAttribute("PrevisoesRecusadas") or 0)+1)
            end
        end
    end
    local char=player.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    local tool=char and char:FindFirstChild("MowerTool")
    if not tool or not hum or hum.Health<=0 or hum.MoveDirection.Magnitude<=.05
        or player:GetAttribute("RegiaoAtual")~="Floresta Esquecida" or sackFull() then
        mTokens,mClock,mPrev=nil,nil,nil
        return
    end
    local blade=tool:FindFirstChild("Lamina",true)
    if not blade or not blade:IsA("BasePart") then return end
    local level=Preview and Preview.level or 1
    local base=math.clamp(4+level,3,9)
    mTokens=math.min((mTokens or base)+(now-(mClock or now))/FOREST_MOWER_INTERVAL*base,base*2)
    mClock=now
    local cur=blade.Position
    local prev=mPrev
    if not prev or (cur-prev).Magnitude>12 then prev=cur end
    mPrev=cur
    if mTokens<1 then return end
    local lv=Config.Levels[level] or Config.Levels[1]
    local reach=math.clamp((lv.Width or 1)+1.4,1.5,4.5)-MOWER_MARGIN
    local cands={}
    for id,g in pairs(records) do
        if g.stage==0 and g.part and not pendingCut[id] and (g.x-cur.X)^2+(g.z-cur.Z)^2<400 then
            local d=dist2D(g,prev,cur)
            if d<=reach and math.abs((prev.Y+cur.Y)*.5-g.y)<=6.5 then table.insert(cands,{g=g,d=d}) end
        end
    end
    table.sort(cands,function(a,b) return a.d<b.d end)
    for _,c in ipairs(cands) do
        if mTokens<1 then break end
        mTokens-=1
        predictClump(c.g)
    end
end)
-- Golpes manuais na floresta: chamado por LotCutPreview.swing a cada amostra da lâmina.
-- Espelha FOREST.cutTrace (raio = largura/2 limitado a 0,6..4,5; máximo de tufos por golpe na ordem
-- do toque; dano = força x raridade; estágio 1 também conta como contato).
if Preview then
    Preview.forestTool=function(base,tip,cfg,mult,state)
        if player:GetAttribute("RegiaoAtual")~="Floresta Esquecida" then return false end
        -- servidor: raio + min(1, largura do tufo x 0,1); a largura vai de 2 a 3, então soma pelo menos 0,2
        local radius=math.clamp(cfg.largura/2,.6,4.5)+.2-TOOL_MARGIN
        -- ferramenta de vários golpes (unha): o cliente não sabe qual tufo o servidor escolheu nos golpes
        -- anteriores, então só dá o feedback; a queda da grama fica com o servidor
        local oneHit=cfg.forca*mult>=.999
        local mid=(base+tip)/2
        local cands={}
        for id,g in pairs(records) do
            if not state.touched[id] and g.stage<2 and g.part and (g.x-mid.X)^2+(g.z-mid.Z)^2<225 then
                local d=dist2D(g,base,tip)
                if d<=radius and math.abs(mid.Y-g.y)<=6.5 then table.insert(cands,{g=g,d=d}) end
            end
        end
        table.sort(cands,function(a,b) return a.d<b.d end)
        local any=false
        for _,c in ipairs(cands) do
            if state.n>=cfg.maxTiles then break end
            local g=c.g
            state.n+=1 state.touched[g.id]=true any=true
            if g.stage==0 and not pendingCut[g.id] then
                g.predDamage=(g.predDamage or 0)+cfg.forca*mult
                -- a última vaga do golpe (maxTiles) é disputada no mato denso: ali o servidor decide
                local contestedSlot=cfg.maxTiles>1 and state.n>=cfg.maxTiles
                if oneHit and not contestedSlot and g.predDamage>=.999 and not sackFull() then
                    g.predDamage=nil
                    predictClump(g)
                else
                    leaves(Vector3.new(g.x,g.y,g.z))
                end
            end
        end
        return any
    end
end
