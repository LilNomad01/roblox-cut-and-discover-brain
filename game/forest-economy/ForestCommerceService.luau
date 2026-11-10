-- Server-authoritative forest shops, collection, tools and discovery.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Profiles=require(script.Parent.Profiles)
local Economy=require(game.ServerScriptService.Economia)
local Catalog=require(RS.Shared.ForestCommerceCatalog)
local Data=require(script.Parent.ForestCommerceData)
local World=require(script.Parent.ForestCommerceWorld)
local S={reserved=World.reserved}
local stations,bins,resources={},{},{}
local shops,rates,kitUntil,markers={},{},{},{}
local equipmentRates={}
local gnomeGate
local remote=Instance.new("RemoteEvent") remote.Name="ForestCommerce" remote.Parent=RS
local function state(p)
    local profile=Profiles.get(p)
    return profile and profile.ForestEconomy
end
local function live(p,point,distance)
    local char=p.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not p.Parent or not p:GetAttribute("ProfileReady") or not Profiles.active(p) or not state(p)
        or not root or not hum or hum.Health<=0 then return false end
    return not point or (root.Position-point).Magnitude<=(distance or 12)
end
local function snapshot(p)
    local d=state(p)
    if not d then return end
    local known={}
    for id in pairs(d.known) do
        -- Only previously visited, ordinary merchants are navigation targets.
        if id~="Nilo" and stations[id] then known[id]=stations[id].point end
    end
    remote:FireClient(p,"state",{backpack=d.backpack,equipment=d.equipment,kits=d.kits,flowers=d.flowers,
        mushrooms=d.mushrooms,mapFragments=d.mapFragments,contract=d.contract,cabinRepaired=d.cabinRepaired,
        gnomeFound=d.gnomeFound,gnomeQuest=d.gnomeQuest,gnomeSkin=d.gnomeSkin,caveHint=d.caveHint,
        artifacts=d.artifacts,known=known,collected=d.collected,marker=markers[p],temporary=not require(RS.Shared.GameConfig).PersistenceEnabled})
end
local function pack(p)
    local d=state(p)
    local char=p.Character
    local torso=char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
    if not char or not torso or not d then return end
    local old=char:FindFirstChild("ForestBackpack")
    if old then old:Destroy() end
    -- Riding hides the mesh, never the capacity bonus.
    if (d.backpack==0 and not d.gnomeSkin) or p:GetAttribute("FerramentaAtiva")=="Cortador" then return end
    local model=Instance.new("Model") model.Name="ForestBackpack"
    local b=Catalog.Backpacks[math.max(1,d.backpack)]
    local color=d.gnomeSkin and Color3.fromRGB(149,87,194) or Color3.fromRGB(table.unpack(b.color))
    local scale=math.min(torso.Size.X/2,1.15)
    local base=torso.CFrame*CFrame.new(0,-.1,torso.Size.Z*.5+.44*scale)
    local function piece(name,size,offset,c)
        local v=Instance.new("Part") v.Name=name v.Size=size*scale v.CFrame=base*CFrame.new(offset*scale)
        v.Color=c v.Material=Enum.Material.Fabric v.Massless=true
        v.CanCollide=false v.CanTouch=false v.CanQuery=false v.CastShadow=false v.Parent=model
        local w=Instance.new("WeldConstraint") w.Part0=torso w.Part1=v w.Parent=v
    end
    local trim=Color3.fromRGB(247,210,112)
    piece("Bolsa",Vector3.new(1.45,1.65,.72),Vector3.zero,color)
    piece("Tampa",Vector3.new(1.55,.3,.82),Vector3.new(0,.7,0),color:Lerp(trim,.35))
    piece("Bolso",Vector3.new(.95,.65,.25),Vector3.new(0,-.3,.46),color:Lerp(Color3.new(0,0,0),.12))
    for _,x in ipairs({-.48,.48}) do
        piece("Alca",Vector3.new(.16,1.7,.12),Vector3.new(x,0,-.4),trim)
        piece("Fivela",Vector3.new(.2,.22,.08),Vector3.new(x,.4,.45),trim)
    end
    if d.backpack>=3 or d.gnomeSkin then
        for _,x in ipairs({-.85,.85}) do piece("Compartimento",Vector3.new(.28,.9,.6),Vector3.new(x,-.1,0),color) end
    end
    if d.gnomeSkin then piece("EmblemaGnomo",Vector3.new(.38,.38,.12),Vector3.new(0,.12,.65),trim) end
    model.Parent=char
end
local toolNames={lantern="Lanterna portátil",compass="Bússola simples",marker="Marcador de trilha",kit="Kit de exploração"}
local function activateEquipment(p,id)
    if not live(p) or os.clock()-(equipmentRates[p] or -100)<.4 then return end
    equipmentRates[p]=os.clock()
    local d=state(p)
    local root=p.Character.HumanoidRootPart
    if id=="marker" and d.equipment.marker then
        local pos=root.Position
        if pos.X< -300 or pos.X>300 or pos.Z< -825 or pos.Z> -177 then
            Economy.Notificar(p,"Marque um local dentro da floresta.","info") return
        end
        markers[p]=pos snapshot(p) remote:FireClient(p,"map")
    elseif id=="kit" and d.kits>0 then
        if (kitUntil[p] or 0)>os.clock() then return end
        d.kits-=1 kitUntil[p]=os.clock()+12
        local clues={}
        local world=workspace:FindFirstChild("GameWorld")
        local forest=world and world:FindFirstChild("FlorestaEsquecida")
        if forest then
            for _,v in ipairs(forest:GetDescendants()) do
                if #clues>=8 then break end
                if v:IsA("BasePart") and (v.Name=="PistaAzul" or v.Name=="RunasDaGruta")
                    and v.Transparency<.95 and (v.Position-root.Position).Magnitude<=16 then
                    local ray=RaycastParams.new() ray.FilterType=Enum.RaycastFilterType.Exclude ray.FilterDescendantsInstances={p.Character}
                    local hit=workspace:Raycast(root.Position,v.Position-root.Position,ray)
                    if not hit or hit.Instance==v then table.insert(clues,v) end
                end
            end
        end
        remote:FireClient(p,"clues",clues) snapshot(p)
        Economy.Notificar(p,#clues>0 and "Pistas visíveis destacadas por 12 segundos." or "Nenhuma pista visível por perto. Kit utilizado.","info")
    end
end
local function tools(p)
    local d=state(p)
    local backpack=p:FindFirstChildOfClass("Backpack")
    if not d or not backpack then return end
    for _,container in ipairs({backpack,p.Character}) do
        if container then
            for _,t in ipairs(container:GetChildren()) do
                local id=t:GetAttribute("ForestEquipment")
                if id and ((id=="kit" and d.kits==0) or (id~="kit" and not d.equipment[id])) then t:Destroy() end
            end
        end
    end
    for _,id in ipairs({"lantern","compass","marker","kit"}) do
        local owned=(id=="kit" and d.kits>0) or d.equipment[id]
        local exists=false
        for _,container in ipairs({backpack,p.Character}) do
            if container then for _,t in ipairs(container:GetChildren()) do if t:GetAttribute("ForestEquipment")==id then exists=true end end end
        end
        if owned and not exists then
            local tool=Instance.new("Tool") tool.Name=toolNames[id] tool.ToolTip=id=="kit" and "Consome 1 kit; pistas visíveis, 16 studs / 12 s" or "Equipamento de exploração"
            tool.RequiresHandle=false tool.CanBeDropped=false tool:SetAttribute("ForestEquipment",id)
            if id=="lantern" then
                local lamp
                local function off() if lamp then lamp:Destroy() lamp=nil end end
                tool.Equipped:Connect(function()
                    off()
                    local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        lamp=Instance.new("PointLight") lamp.Name="ForestLantern" lamp.Range=18 lamp.Brightness=1.8
                        lamp.Color=Color3.fromRGB(255,226,170) lamp.Shadows=false lamp.Parent=root
                    end
                end)
                tool.Unequipped:Connect(off) tool.Destroying:Connect(off)
            end
            tool.Activated:Connect(function()
                if tool.Parent~=p.Character or not live(p) then return end
                activateEquipment(p,id)
                tools(p)
            end)
            tool.Parent=backpack
        end
    end
end
function S.attach(p)
    local profile=Profiles.get(p)
    if not profile then return end
    profile.ForestEconomy=profile.ForestEconomy or Data.new()
    local d=profile.ForestEconomy
    assert(Data.valid(d),"Invalid forest profile extension")
    p:SetAttribute("MochilaNivel",d.backpack)
    p:SetAttribute("ForestArtifacts",d.artifacts)
    p:SetAttribute("ForestGnomeTrade",d.gnomeQuest)
    Economy.RecalcularCapacidade(p)
    local function characterReady(char)
        local root=char:WaitForChild("HumanoidRootPart",10)
        local torsoName=char:FindFirstChild("UpperTorso") and "UpperTorso" or "Torso"
        local torso=char:FindFirstChild(torsoName) or char:WaitForChild("UpperTorso",5) or char:FindFirstChild("Torso")
        if not root or not torso or p.Character~=char or not p.Parent then return end
        p:WaitForChild("Backpack",5)
        tools(p) pack(p) snapshot(p)
    end
    p.CharacterAdded:Connect(function(char) task.spawn(characterReady,char) end)
    p:GetAttributeChangedSignal("FerramentaAtiva"):Connect(function() pack(p) end)
    if p.Character then task.spawn(characterReady,p.Character) end
end
function S.open(p,id)
    local station=stations[id]
    if not station or not live(p,station.point) then return end
    local d=state(p)
    if id=="Nilo" and (not d.gnomeFound or not gnomeGate or not gnomeGate()) then return end
    d.known[id]=true
    shops[p]={id=id,expires=os.clock()+90}
    snapshot(p) remote:FireClient(p,"open",id)
end
function S.sell(p,id)
    local bin=bins[id]
    if not bin or not live(p,bin.point) then return 0 end
    if id=="Teca" and not state(p).cabinRepaired then
        Economy.Notificar(p,"Depósito danificado: conclua a pesquisa de Teca.","info") return 0
    end
    local gain,amount=Economy.Vender(p)
    if gain>0 then
        local fx=RS:FindFirstChild("EfeitoVenda")
        if fx then fx:FireAllClients(bin.point,gain,p.UserId) end
        remote:FireClient(p,"sale",{amount=amount,gain=gain,bin=bin.model})
    end
    return gain
end
function S.collect(p,id)
    local resource=resources[id]
    if not resource or not live(p,resource.point,8) then return false end
    if not Data.collect(state(p),id,resource.kind) then return false end
    snapshot(p) Economy.Notificar(p,"Material guardado para as trocas da floresta!","sucesso")
    return true
end
function S.bindGnome(model,point,revealed)
    stations.Nilo={model=model,point=point} gnomeGate=revealed
end
function S.discoverGnome(p,point,revealed)
    if not revealed or not live(p,point,16) then return end
    local d=state(p)
    if not d.gnomeFound then
        d.gnomeFound=true
        p:SetAttribute("ForestSecrets",(p:GetAttribute("ForestSecrets") or 0)+1)
        Economy.AddXP(p,20)
        Economy.Notificar(p,"Nilo: você me achou! Minha barba não cabia atrás daquela folha.","ouro")
    end
    S.open(p,"Nilo")
end
function S.wasClaimed(p,id)
    local d=state(p)
    return d and d.claimed[id]==true
end
function S.recordSecret(p,id,kind)
    local d=state(p)
    if not d or d.claimed[id] then return end
    d.claimed[id]=true
    if kind~="chest" then d.artifacts+=1 end
end
function S.build(root,scenery)
    stations,bins,resources=World.build(root,scenery,Catalog,S.open,S.sell,S.collect)
end
remote.OnServerEvent:Connect(function(p,action,id,...)
    if select("#",...)~=0 or type(action)~="string" or #action>16 or not live(p) then return end
    if action=="close" then shops[p]=nil return end
    local now=os.clock()
    if now-(rates[p] or -100)<.25 then return end
    rates[p]=now
    if action=="sync" then snapshot(p) return end
    if type(id)~="string" or #id>48 then return end
    if action=="equip" then
        if not toolNames[id] then return end
        tools(p)
        local char=p.Character
        local hum=char:FindFirstChildOfClass("Humanoid")
        local held=char:FindFirstChild(toolNames[id])
        if held and held:GetAttribute("ForestEquipment")==id then
            if id=="marker" or id=="kit" then activateEquipment(p,id) tools(p)
            else hum:UnequipTools() end
        else
            local backpack=p:FindFirstChildOfClass("Backpack")
            local tool=backpack and backpack:FindFirstChild(toolNames[id])
            if not tool or tool:GetAttribute("ForestEquipment")~=id then return end
            hum:EquipTool(tool)
            if id=="marker" or id=="kit" then activateEquipment(p,id) tools(p) end
        end
        snapshot(p)
        return
    end
    if action~="buy" then return end
    local shop=shops[p]
    local product=Catalog.Products[id]
    if not shop or shop.expires<now or not product or product.vendor~=shop.id then return end
    local station=stations[shop.id]
    if not station or not live(p,station.point) then shops[p]=nil return end
    if shop.id=="Nilo" and (not gnomeGate or not gnomeGate()) then return end
    local d=state(p)
    -- No yields between validation, resource mutation and the currency write.
    local ok,coins,message=Data.transact(d,id,product,p:GetAttribute("Moedas"))
    if ok then
        p:SetAttribute("Moedas",coins)
        p:SetAttribute("MochilaNivel",d.backpack)
        p:SetAttribute("ForestGnomeTrade",d.gnomeQuest)
        Economy.RecalcularCapacidade(p)
        if product.kind=="gnomeQuest" then Economy.AddXP(p,35) end
        tools(p) pack(p)
    end
    Economy.Notificar(p,message,ok and "sucesso" or "info")
    snapshot(p)
    remote:FireClient(p,"result",{ok=ok,message=message})
end)
Players.PlayerRemoving:Connect(function(p)
    shops[p]=nil rates[p]=nil kitUntil[p]=nil markers[p]=nil equipmentRates[p]=nil
end)
return S
