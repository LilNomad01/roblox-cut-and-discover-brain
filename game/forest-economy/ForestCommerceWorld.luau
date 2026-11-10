-- Authored merchant clearings. Positions are server-only.
local W={}
W.Stations={
    Guto={x=16,z=-200,binX=23,binZ=-190},
    Lia={x=-43,z=-280,binX=-49,binZ=-271},
    Teca={x=-77,z=-346,binX=-72,binZ=-337},
}
function W.reserved(x,z,radius)
    for _,p in pairs(W.Stations) do
        if (x-p.x)^2+(z-p.z)^2<radius^2 or (x-p.binX)^2+(z-p.binZ)^2<(radius*.6)^2 then return true end
    end
    return false
end
local function part(parent,name,size,cf,color,material)
    local p=Instance.new("Part")
    p.Name,p.Size,p.CFrame,p.Color=name,size,cf,color
    p.Material=material or Enum.Material.SmoothPlastic
    p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false
    p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end
W.part=part
local function sign(parent,name,text,pos,color)
    local p=part(parent,name,Vector3.new(6,1.8,.25),CFrame.new(pos),color,Enum.Material.Wood)
    local gui=Instance.new("SurfaceGui") gui.Face=Enum.NormalId.Back gui.PixelsPerStud=35 gui.Parent=p
    local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(1,1) t.BackgroundTransparency=1
    t.Font=Enum.Font.FredokaOne t.TextScaled=true t.TextWrapped=true t.TextColor3=Color3.fromRGB(255,248,214)
    t.Text=text t.Parent=gui
end
function W.build(root,scenery,catalog,onShop,onSell,onCollect)
    local folder=Instance.new("Folder") folder.Name="ComercioDaFloresta" folder.Parent=root
    local avatar=require(script.Parent.VendorAvatar)
    local avatarBuilding=false
    local function merchantAvatar()
        while avatarBuilding do task.wait(.1) end
        avatarBuilding=true
        local ok,rig=pcall(avatar.create)
        avatarBuilding=false
        if not ok then error(rig) end
        return rig
    end
    local stations,bins,resources={},{},{}
    local wood=Color3.fromRGB(120,79,48)
    for _,id in ipairs({"Guto","Lia","Teca"}) do
        local config=W.Stations[id]
        local vendor=catalog.Vendors[id]
        local color=Color3.fromRGB(table.unpack(vendor.color))
        local accent=Color3.fromRGB(table.unpack(vendor.accent))
        local pos=Vector3.new(config.x,scenery.height(config.x,config.z),config.z)
        local model=Instance.new("Model") model.Name=id.."_Acampamento" model:SetAttribute("ForestMerchantId",id)
        local anchor=part(model,"Interacao",Vector3.one,CFrame.new(pos+Vector3.new(0,3,3)),color)
        anchor.Transparency=1
        local prompt=Instance.new("ProximityPrompt") prompt.ObjectText=vendor.name prompt.ActionText="Conversar / loja"
        prompt.MaxActivationDistance=9 prompt.RequiresLineOfSight=false prompt.HoldDuration=.15
        prompt.GamepadKeyCode=Enum.KeyCode.ButtonX prompt.Parent=anchor
        prompt.Triggered:Connect(function(p) onShop(p,id) end)
        part(model,"Balcao",Vector3.new(7,.35,2.3),CFrame.new(pos+Vector3.new(0,2.5,2)),wood,Enum.Material.Wood)
        for _,x in ipairs({-2.8,2.8}) do
            part(model,"PeBancada",Vector3.new(.35,2.4,.35),CFrame.new(pos+Vector3.new(x,1.2,2)),wood,Enum.Material.Wood)
            if id~="Teca" then
                part(model,"Pilar",Vector3.new(.35,6.8,.35),CFrame.new(pos+Vector3.new(x,3.4,-.8)),wood,Enum.Material.Wood)
            end
        end
        if id=="Guto" then
            part(model,"ToldoMadeira",Vector3.new(8,.45,5),CFrame.new(pos+Vector3.new(0,7,0))*CFrame.Angles(.12,0,0),color,Enum.Material.Wood)
            for i=1,3 do
                part(model,"MochilaExposta",Vector3.new(.9,1.25,.6),CFrame.new(pos+Vector3.new((i-2)*1.8,3.3,2)),i==2 and accent or color,Enum.Material.Fabric)
            end
        elseif id=="Lia" then
            for _,side in ipairs({-1,1}) do
                part(model,"LonaBarraca",Vector3.new(4.8,.2,6),CFrame.new(pos+Vector3.new(side*1.65,4.5,-2))*CFrame.Angles(0,0,side*.8),side==1 and color or accent,Enum.Material.Fabric)
            end
            part(model,"Mapa",Vector3.new(2.2,.06,1.4),CFrame.new(pos+Vector3.new(-1,2.72,2)),Color3.fromRGB(244,226,173))
            local compass=part(model,"Bussola",Vector3.new(.5,.12,.5),CFrame.new(pos+Vector3.new(1.1,2.8,2)),accent)
            compass.Shape=Enum.PartType.Ball
        else
            part(model,"Prateleira",Vector3.new(6,.25,1),CFrame.new(pos+Vector3.new(0,5,-1)),wood,Enum.Material.Wood)
            for i=1,5 do
                local off=Vector3.new((i-3)*1.05,i%2==0 and 3 or 5.4,i%2==0 and 2 or -1)
                part(model,"Vaso",Vector3.new(.65,.65,.65),CFrame.new(pos+off),Color3.fromRGB(183,108,74))
                local bloom=part(model,"Ervas",Vector3.new(.8,.8,.8),CFrame.new(pos+off+Vector3.yAxis*.55),i%2==0 and accent or color)
                bloom.Shape=Enum.PartType.Ball
            end
        end
        sign(model,"Letreiro",vendor.name,pos+Vector3.new(0,6.1,3),color)
        model.PrimaryPart=anchor model.Parent=folder
        stations[id]={point=anchor.Position,model=model}
        -- Avatar construction may fetch Roblox assets. Decor and prompts do not wait on that fetch.
        task.spawn(function()
            local ok,rig=pcall(merchantAvatar)
            if not ok then warn("[Floresta comércio] Avatar de "..id..": "..tostring(rig)) return end
            if not model.Parent then rig:Destroy() return end
            rig.Name=id.."_Comerciante"
            local _,size=rig:GetBoundingBox()
            rig:PivotTo(CFrame.new(pos+Vector3.new(0,size.Y*.5,0)))
            for _,v in ipairs(rig:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:find("Torso") or v.Name:find("UpperArm")) then v.Color=color end
            end
            if id=="Teca" then
                part(rig,"Avental",Vector3.new(1.25,1.5,.12),rig.PrimaryPart.CFrame*CFrame.new(0,.1,-.62),accent,Enum.Material.Fabric)
            else
                part(rig,"MochilaNPC",Vector3.new(1.4,1.8,.8),rig.PrimaryPart.CFrame*CFrame.new(0,.2,.95),accent,Enum.Material.Fabric)
            end
            rig.Parent=model
        end)
        local bin=Instance.new("Model") bin.Name="CacambaFloresta_"..id bin:SetAttribute("ForestBinId",id)
        local bp=Vector3.new(config.binX,scenery.height(config.binX,config.binZ),config.binZ)
        local floor=part(bin,"Fundo",Vector3.new(5,.35,4),CFrame.new(bp+Vector3.yAxis*.4),wood,Enum.Material.Wood)
        for _,sx in ipairs({-1,1}) do
            part(bin,"Lateral",Vector3.new(.3,2.5,4),CFrame.new(bp+Vector3.new(sx*2.35,1.5,0)),color,Enum.Material.Metal)
            part(bin,"FaixaMetal",Vector3.new(5,.24,.22),CFrame.new(bp+Vector3.new(0,1.2,sx*1.9)),accent,Enum.Material.Metal)
        end
        part(bin,"FundoMadeira",Vector3.new(5,2.5,.3),CFrame.new(bp+Vector3.new(0,1.5,-1.9)),wood,Enum.Material.Wood)
        sign(bin,"PlacaVenda",id=="Teca" and "DEPÓSITO DANIFICADO" or "VENDA DE GRAMA",bp+Vector3.new(0,4,-1.8),color)
        local pp=Instance.new("ProximityPrompt") pp.Name="VenderGrama" pp.ActionText="Vender grama" pp.ObjectText=id=="Teca" and "Restaure com Teca" or "Depósito da floresta"
        pp.MaxActivationDistance=9 pp.RequiresLineOfSight=false pp.HoldDuration=.2 pp.GamepadKeyCode=Enum.KeyCode.ButtonX pp.Parent=floor
        pp.Triggered:Connect(function(p) onSell(p,id) end)
        if id=="Teca" then
            local broken=part(bin,"TabuaDanificada",Vector3.new(4,.2,.6),CFrame.new(bp+Vector3.new(0,1.4,.6))*CFrame.Angles(.2,.3,.4),wood,Enum.Material.Wood)
            broken:SetAttribute("ForestRepairDecoration",true)
        end
        bin.PrimaryPart=floor bin.Parent=folder bins[id]={model=bin,point=floor.Position}
        task.wait()
    end
    -- Finite authored discoveries, collected once per player, never shared reward state.
    local points={
        {"flower",-97,-608},{"flower",-88,-622},{"flower",-104,-629},{"flower",146,-570},
        {"flower",152,-600},{"flower",134,-595},{"flower",-137,-361},{"flower",-92,-393},
        {"mushroom",-155,-550},{"mushroom",-176,-577},{"mushroom",-138,-593},{"mushroom",-120,-649},
        {"mushroom",-106,-658},{"mushroom",-181,-590},{"mushroom",-145,-620},{"mushroom",-99,-682},
        {"map",-127,-355},{"map",-178,-558},
    }
    for i,p in ipairs(points) do
        local id="forest_resource_"..i
        local pos=Vector3.new(p[2],scenery.height(p[2],p[3]),p[3])
        local model=Instance.new("Model") model.Name="Coletavel_"..id model:SetAttribute("ForestResourceId",id)
        local stem=part(model,"Caule",Vector3.new(.22,.8,.22),CFrame.new(pos+Vector3.yAxis*.4),Color3.fromRGB(77,140,80))
        local color=p[1]=="flower" and Color3.fromRGB(182,154,241) or p[1]=="mushroom" and Color3.fromRGB(226,111,97) or Color3.fromRGB(242,212,143)
        local cap=part(model,p[1]=="map" and "Pergaminho" or "Petalas",Vector3.new(.85,.3,.85),CFrame.new(pos+Vector3.yAxis*.9),color)
        if p[1]~="map" then cap.Shape=Enum.PartType.Ball end
        local prompt=Instance.new("ProximityPrompt") prompt.ObjectText=p[1]=="flower" and "Flor do orvalho" or p[1]=="mushroom" and "Cogumelo raro" or "Fragmento de mapa"
        prompt.ActionText="Coletar" prompt.MaxActivationDistance=6 prompt.RequiresLineOfSight=true prompt.HoldDuration=.25 prompt.GamepadKeyCode=Enum.KeyCode.ButtonX prompt.Parent=stem
        prompt.Triggered:Connect(function(player) onCollect(player,id) end)
        model.PrimaryPart=stem model.Parent=folder
        resources[id]={point=stem.Position,model=model,kind=p[1]}
    end
    return stations,bins,resources
end
return W
