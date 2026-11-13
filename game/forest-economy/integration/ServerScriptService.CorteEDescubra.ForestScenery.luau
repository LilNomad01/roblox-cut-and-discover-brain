-- Modular scenery for Floresta Esquecida. No economy, inventory or persistence.
local S = {}
local WorldArt=require(script.Parent.WorldArt)
local mounds = {
    {-70,-235,18,3}, {88,-280,24,3.6}, {-170,-401,22,3.2},
    {176,-443,20,3.8}, {-72,-550,22,3.4}, {201,-726,24,3.5},
    {-227,-754,20,3}, {19,-674,23,3.4}, {-227,-605,22,3.2},
}

local groundQuery=RaycastParams.new()
groundQuery.FilterType=Enum.RaycastFilterType.Include
groundQuery.FilterDescendantsInstances={workspace.Terrain}
function S.height(x,z)
    local hit=workspace:Raycast(Vector3.new(x,100,z),Vector3.new(0,-150,0),groundQuery)
    return hit and hit.Position.Y or .8
end

function S.prepareTerrain(terrain)
    -- Continuous geography is authored and saved in Edit; preserve it during Play.
    -- Clearing a rectangle here recreated the clipped mountains and biome seams.
    assert(workspace:GetAttribute("WorldGeographyRevision")==21,"Continuous terrain revision missing")
end
S.Paths = {
    {Vector3.new(0,0,-165),Vector3.new(3,0,-206)},
    {Vector3.new(3,0,-206),Vector3.new(-24,0,-257)},
    {Vector3.new(-24,0,-257),Vector3.new(-62,0,-303)},
    {Vector3.new(-62,0,-303),Vector3.new(-103,0,-342)},
    {Vector3.new(-103,0,-342),Vector3.new(-37,0,-407)},
    {Vector3.new(-37,0,-407),Vector3.new(23,0,-454)},
    {Vector3.new(23,0,-454),Vector3.new(90,0,-460)},
    {Vector3.new(90,0,-460),Vector3.new(129,0,-515)},
    {Vector3.new(129,0,-515),Vector3.new(142,0,-569)},
    {Vector3.new(142,0,-569),Vector3.new(210,0,-648)},
    {Vector3.new(210,0,-648),Vector3.new(110,0,-727)},
    {Vector3.new(110,0,-727),Vector3.new(-18,0,-757)},
    {Vector3.new(-18,0,-757),Vector3.new(-172,0,-687)},
    {Vector3.new(-172,0,-687),Vector3.new(-150,0,-512)},
    {Vector3.new(-150,0,-512),Vector3.new(-103,0,-342)},
}

function S.riverX(z)
    return 64+math.sin((z+460)*.015)*15+math.sin((z+460)*.032)*4
end
function S.riverHalfWidth(z)
    return 7.4+math.sin((z+525)*.026)*1.4
end
function S.inRiver(x,z,margin)
    return z>=-756 and z<=-336 and math.abs(x-S.riverX(z))<S.riverHalfWidth(z)+(margin or 0)
end

function S.onPath(x, z, margin)
    if x>-114-margin and x<-83+margin and z>-330-margin and z<-313+margin then
        local a=Vector2.new(-111,-329) local b=Vector2.new(-86,-314) local d=b-a
        local t=math.clamp((Vector2.new(x,z)-a):Dot(d)/d:Dot(d),0,1)
        if (Vector2.new(x,z)-a-d*t).Magnitude<margin then return true end
    end
    local p = Vector2.new(x,z)
    for _, edge in ipairs(S.Paths) do
        local a,b=Vector2.new(edge[1].X,edge[1].Z),Vector2.new(edge[2].X,edge[2].Z)
        local d=b-a
        local f=math.clamp((p-a):Dot(d)/d:Dot(d),0,1)
        if (p-a-d*f).Magnitude<margin then return true end
    end
    return false
end

local function part(parent, name, size, frame, color, class, collision)
    local p=Instance.new(class or "Part")
    p.Name,p.Size,p.CFrame,p.Color=name,size,frame,color
    p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery=true,collision==true,false,collision==true
    p.Material=Enum.Material.SmoothPlastic
    p.TopSurface,p.BottomSurface=Enum.SurfaceType.Smooth,Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end

local function branch(parent, a, b, width, tone)
    local p=part(parent,"Galho",Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)*.5,b),tone)
    p.Material=Enum.Material.Wood
end

local TreeKit=require(script.Parent.ForestTreeKit)
function S.hero(parent,id,x,z,scale,yaw)
    if WorldArt.blockGrass(x,z) then return end
    if S.commerceReserved and S.commerceReserved(x,z,18) then return end
    return TreeKit.clone(id,parent,Vector3.new(x,S.height(x,z)-.25,z),scale,yaw or 0)
end
local treeIndex=0
function S.tree(parent,x,z,variety,rng,multiplier)
    if WorldArt.blockGrass(x,z) then return end
    if S.commerceReserved and S.commerceReserved(x,z,18) then return end
    if S.onPath(x,z,6) or S.inRiver(x,z,5) then return end
    treeIndex+=1
    local palette={1,2,3,4,5,6,11,12,3,1,7,9,8,10}
    local id=palette[(treeIndex-1)%#palette+1]
    local scale=rng:NextNumber(.84,1.14)*(multiplier or 1)
    -- Pivot is authored at root level; bury roots slightly into the sampled soil.
    return TreeKit.clone(id,parent,Vector3.new(x,S.height(x,z)-.25,z),scale,rng:NextNumber(0,math.pi*2))
end

local function mushroom(parent, position, scale, glow)
    local m=Instance.new("Model") m.Name="Cogumelos"
    part(m,"Haste",Vector3.new(.25,.9,.25)*scale,CFrame.new(position+Vector3.new(0,.45*scale,0)),Color3.fromRGB(220,204,153))
    local cap=part(m,"Chapeu",Vector3.new(1.2,.45,1.2)*scale,CFrame.new(position+Vector3.new(0,1*scale,0)),
        glow and Color3.fromRGB(97,207,190) or Color3.fromRGB(188,117,88))
    cap.Shape=Enum.PartType.Ball
    if glow then cap.Material=Enum.Material.Neon end
    m.Parent=parent
end

function S.bridge(parent)
    local m=Instance.new("Model") m.Name="PonteDasRaizes"
    local brown=Color3.fromRGB(107,81,57)
    for i=0,13 do
        local x=38+i*3.8
        local lift=math.sin(i/13*math.pi)*1.2
        part(m,"Tabua_"..i,Vector3.new(3.55,.45,8.5),CFrame.new(x,1.45+lift,-460)*CFrame.Angles(0,0,math.rad(math.cos(i/13*math.pi)*3)),brown,nil,true)
    end
    for _,z in ipairs({-465,-455}) do
        for _,x in ipairs({38,51,64,77,90}) do
            part(m,"Poste",Vector3.new(.6,4.6,.6),CFrame.new(x,3.3,z),brown)
        end
        part(m,"Corrimao",Vector3.new(54,.4,.4),CFrame.new(64,5.1,z),brown)
    end
    m.Parent=parent
    return m
end

function S.enrich(root,spawnGrass,addSecret,path,sign,rng)
    local props=Instance.new("Folder") props.Name="PropsExploracao" props.Parent=root
    local sectors=root.Setores
    local cabin=root:FindFirstChild("CabanaDoGuardiao",true)
    if cabin then
        local brown=Color3.fromRGB(94,75,54)
        for _,x in ipairs({-118,-98}) do
            part(cabin,"PilarVaranda",Vector3.new(.6,8.4,.6),CFrame.new(x,6,-330),brown)
        end
        for i=1,3 do
            part(cabin,"DegrauVaranda",Vector3.new(7,.35,1.2),CFrame.new(-111,1+i*.24,-330+i*1.1),brown,nil,true)
        end
        for _,x in ipairs({-109,-104}) do
            part(cabin,"MolduraJanela",Vector3.new(3.8,.35,.35),CFrame.new(x,8,-336.6),brown)
            part(cabin,"MolduraJanela",Vector3.new(.25,3.5,.35),CFrame.new(x,6.5,-336.6),brown)
        end
        local lamp=part(cabin,"LanternaAntiga",Vector3.new(.6,.9,.6),CFrame.new(-115,6.8,-330.5),Color3.fromRGB(239,192,101))
        lamp.Material=Enum.Material.Neon
        local light=Instance.new("PointLight")
        light.Color,light.Brightness,light.Range=lamp.Color,.65,12
        light.Parent=lamp
    end
    -- Broad old trees form a canopy behind and beside the cabin, with a clear porch vista.
    S.hero(root.ArvoresModulares,1,-131,-363,1.25,.4)
    S.hero(root.ArvoresModulares,2,-88,-365,1.15,2.2)
    S.hero(root.ArvoresModulares,12,-111,-384,1.15,.9)
    S.hero(root.ArvoresModulares,3,-145,-326,.95,1.1)
    S.hero(root.ArvoresModulares,4,-70,-335,.95,2.1)
    -- A curved approach, stones, weathered fence and leaf litter frame the porch.
    local approach={Vector3.new(-86,.8,-314),Vector3.new(-96,.8,-320),Vector3.new(-108,.8,-324),Vector3.new(-111,1.2,-329)}
    for i=1,#approach-1 do path(props,approach[i],approach[i+1],4.5) end
    local plants=game.ReplicatedStorage.GramaAssets.GrassPack
    local litter=plants:FindFirstChild("Debris_D01_Espalhadas")
    local leaf=plants:FindFirstChild("Herb_H02_FolhaLarga")
    for _,center in ipairs({Vector3.new(-127,.8,-338),Vector3.new(-91,.8,-341),Vector3.new(-124,.8,-359),Vector3.new(-88,.8,-360)}) do
        for j=1,9 do
            local angle=j*2.4 local r=1+math.sqrt(j)*1.2
            local q=center+Vector3.new(math.cos(angle)*r,0,math.sin(angle)*r)
            if j%3==0 then
                local rock=part(props,"PedraDaCabana",Vector3.new(2.5,1.4,2)*rng:NextNumber(.7,1.3),CFrame.new(q+Vector3.yAxis*.35)*CFrame.Angles(.2,angle,.15),Color3.fromRGB(91,112,94))
                rock.Shape=Enum.PartType.Ball rock.Material=Enum.Material.Slate
            elseif leaf then
                local v=leaf:Clone() v.Name="ArbustoDaCabana" v.Size=leaf.Size*rng:NextNumber(1.6,2.8)
                v.Anchored=true v.CanCollide=false v.CanTouch=false v.CanQuery=false
                v.CFrame=CFrame.new(q+Vector3.yAxis*(v.Size.Y/2))*CFrame.Angles(0,angle,0) v.Parent=props
            end
            if litter and j%2==0 then
                local v=litter:Clone() v.Name="FolhasCaidas" v.Size=litter.Size*2.5
                v.Anchored=true v.CanCollide=false v.CanTouch=false v.CanQuery=false
                v.CFrame=CFrame.new(q+Vector3.new(1,.1,1))*CFrame.Angles(0,angle,0) v.Parent=props
            end
        end
    end
    for i=1,5 do
        local x=-132+i*2.5
        local post=part(props,"CercaVaranda",Vector3.new(.45,3,.5),CFrame.new(x,2.1,-329)*CFrame.Angles(0,0,i==3 and .28 or -.05),Color3.fromRGB(110,91,64))
        post.Material=Enum.Material.Wood
    end
    branch(props,Vector3.new(-130,2.5,-329),Vector3.new(-123,2.9,-329),.3,Color3.fromRGB(109,91,65))
    branch(props,Vector3.new(-121,1,-328),Vector3.new(-118,2.9,-329),.3,Color3.fromRGB(109,91,65))
    TreeKit.hollowLog(props,CFrame.new(-139,3,-353)*CFrame.Angles(0,.6,.08))
    -- Scatter the borders of the planted patches rather than creating rectangular walls.
    for _,center in ipairs({Vector3.new(-131,0,-322),Vector3.new(-87,0,-349),Vector3.new(-135,0,-371)}) do
        for i=1,85 do
            local angle=i*2.39996 local radius=math.sqrt(i)*1.0
            spawnGrass(center.X+math.cos(angle)*radius,center.Z+math.sin(angle)*radius*.65)
        end
    end
    for i,name in ipairs({"06_BosqueDasLuciernagas","07_RuinasDaNascente","08_TrilhaDosGuardioes"}) do
        local folder=Instance.new("Folder") folder.Name=name folder.Parent=sectors
    end
    for i=10,#S.Paths do path(sectors,S.Paths[i][1],S.Paths[i][2],5.5) end
    sign(sectors,"BOSQUE DOS VAGALUMES",Vector3.new(182,0,-634),18)
    sign(sectors,"NASCENTE ANTIGA",Vector3.new(-36,0,-744),16)
    -- Deliberate vegetation corridors follow the route, leaving a clear walking lane.
    local count=0
    for _,edge in ipairs(S.Paths) do
        local d=edge[2]-edge[1]
        local steps=math.floor(d.Magnitude/1.5)
        local side=Vector3.new(-d.Z,0,d.X).Unit
        for i=0,steps do
            if (i+math.floor(edge[1].X))%43<12 then
            local center=edge[1]:Lerp(edge[2],i/math.max(steps,1))
            for _,offset in ipairs({-10,-8.5,8.5,10}) do
                local p=center+side*(offset+math.sin(i*.33)*2.2+rng:NextNumber(-1.3,1.3))
                spawnGrass(p.X+rng:NextNumber(-1,1),p.Z+rng:NextNumber(-1,1))
                count+=1
                if count%80==0 then task.wait() end
            end
        end
    end
    end
    -- Low ruins make a destination, with a clear entrance and a grass-covered secret.
    for i=1,9 do
        local angle=i*math.pi*2/10
        local p=Vector3.new(-18+math.cos(angle)*19,.8,-757+math.sin(angle)*16)
        local column=part(props,"PilarAntigo",Vector3.new(2,rng:NextNumber(5,9),2),CFrame.new(p+Vector3.new(0,3,0))*CFrame.Angles(0,angle,.06),Color3.fromRGB(99,121,111),nil,true)
        column.Material=Enum.Material.Slate
        part(props,"CoroaMusgosa",Vector3.new(3,.7,3),CFrame.new(column.Position+Vector3.new(0,column.Size.Y*.5,0)),Color3.fromRGB(79,130,87),"WedgePart")
    end
    local hero=S.tree(root.ArvoresModulares,154,-605,4,rng,1.25)
    if hero then hero.Name="GuardiaoDasRaizes" end
    -- Small ferns and flowers add readable detail below the main cuttable grass.
    for i=1,68 do
        local edge=S.Paths[rng:NextInteger(1,#S.Paths)]
        local d=(edge[2]-edge[1]).Unit
        local side=Vector3.new(-d.Z,0,d.X)
        local p=edge[1]:Lerp(edge[2],rng:NextNumber())+side*(rng:NextNumber(4.5,6.5)*(i%2==0 and 1 or -1))+Vector3.yAxis*.8
        local library=game.ReplicatedStorage.GramaAssets.GrassPack
        local template=library:FindFirstChild("Herb_H02_FolhaLarga")
        if template and template:IsA("BasePart") then
            for leaf=1,3 do
                local fern=template:Clone() fern.Name="VegetacaoIntermediaria"
                fern.Size=template.Size*rng:NextNumber(1.7,2.3)
                fern.Color=Color3.fromRGB(161,190,156)
                fern.Anchored=true fern.CanCollide=false fern.CanTouch=false fern.CanQuery=false
                fern.CFrame=CFrame.new(p.X,S.height(p.X,p.Z)+fern.Size.Y/2,p.Z)*CFrame.Angles(0,leaf*2.09,0)
                fern.Parent=props
            end
        end
        if i%3==0 then
            for j=1,3 do
                part(props,"FlorDaTrilha",Vector3.new(.5,.5,.5),CFrame.new(p+Vector3.new(j*.45,.75,1)),Color3.fromRGB(193,171,218),"CornerWedgePart")
            end
        end
    end
    -- A natural entrance and warm stone markers establish the route from the village.
    for _,x in ipairs({-11,11}) do
        part(props,"PilarEntrada",Vector3.new(1.4,12,1.4),CFrame.new(x,6.8,-181)*CFrame.Angles(0,0,x<0 and -.12 or .12),Color3.fromRGB(92,71,52),nil,true)
    end
    branch(props,Vector3.new(-12,12,-181),Vector3.new(12,13,-181),1.3,Color3.fromRGB(92,71,52))
    -- [Claude 2026-11-10] o arco vira um portal: placa pendurada no centro da viga (lado da vila diz
    -- FLORESTA ESQUECIDA, lado da mata diz VILA) e duas lanternas quentes.
    do
        local rope=Color3.fromRGB(70,54,40)
        for _,x in ipairs({-3.6,3.6}) do part(props,"CordaPlaca",Vector3.new(.18,1.6,.18),CFrame.new(x,11.6,-181),rope) end
        local frame=part(props,"MolduraPlaca",Vector3.new(11.1,2.9,.3),CFrame.new(0,9.7,-181),Color3.fromRGB(92,71,52))
        frame.Material=Enum.Material.Wood
        local board=part(props,"PlacaPortal",Vector3.new(10.5,2.4,.45),CFrame.new(0,9.7,-181),Color3.fromRGB(58,86,58))
        board.Material=Enum.Material.Wood
        for _,face in ipairs({Enum.NormalId.Back,Enum.NormalId.Front}) do
            -- mesmo padrão das placas do SignKit (canvas por stud, texto em escala, TextStroke)
            local ui=Instance.new("SurfaceGui") ui.Name="Letreiro" ui.Face=face ui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
            ui.PixelsPerStud=45 ui.ZOffset=.05 ui.LightInfluence=.4 ui.MaxDistance=140 ui.Parent=board
            local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(.92,.78) t.Position=UDim2.fromScale(.04,.11) t.BackgroundTransparency=1
            t.Text=face==Enum.NormalId.Back and "FLORESTA ESQUECIDA" or "VILA"
            t.Font=Enum.Font.FredokaOne t.TextScaled=true t.TextWrapped=true t.TextColor3=Color3.fromRGB(255,222,120)
            t.TextStrokeColor3=Color3.fromRGB(36,28,18) t.TextStrokeTransparency=.2 t.Parent=ui
        end
        for _,x in ipairs({-8.6,8.6}) do
            part(props,"CordaLanterna",Vector3.new(.12,1.2,.12),CFrame.new(x,11.9,-181),rope)
            local lamp=part(props,"LanternaPortal",Vector3.new(.8,1.1,.8),CFrame.new(x,10.9,-181),Color3.fromRGB(246,196,96))
            lamp.Material=Enum.Material.Neon
            local light=Instance.new("PointLight") light.Color=lamp.Color light.Brightness=.9 light.Range=14 light.Shadows=false light.Parent=lamp
        end
    end
    for i,edge in ipairs(S.Paths) do
        local p=edge[1]+Vector3.new(4.2,1.1,0)
        part(props,"MarcoDaTrilha",Vector3.new(.65,1.8,.65),CFrame.new(p),Color3.fromRGB(97,114,97))
        local glow=part(props,"PistaDiscreta",Vector3.new(.45,.25,.45),CFrame.new(p+Vector3.new(0,1,0)),Color3.fromRGB(233,194,107))
        glow.Material=Enum.Material.Neon
        if i%3==0 then
            local lamp=Instance.new("PointLight")
            lamp.Color,lamp.Brightness,lamp.Range=glow.Color,.55,11
            lamp.Parent=glow
        end
    end
    for i=1,95 do
        local edge=S.Paths[rng:NextInteger(1,#S.Paths)]
        local p=edge[1]:Lerp(edge[2],rng:NextNumber())+Vector3.new(rng:NextNumber(-18,18),.8,rng:NextNumber(-18,18))
        if not S.onPath(p.X,p.Z,3) then mushroom(props,p,rng:NextNumber(.7,1.5),i%4==0) end
    end
    -- Transition trees frame the road without changing the village itself.
    for i=0,6 do
        for _,side in ipairs({-1,1}) do S.tree(root.ArvoresModulares,side*(17+i*1.1),-126-i*13,(i%5)+1,rng) end
    end
    for i=1,65 do
        local x,z=rng:NextNumber(-280,280),rng:NextNumber(-803,-650)
        if (x+18)^2+(z+757)^2>27^2 then S.tree(root.ArvoresModulares,x,z,rng:NextInteger(1,5),rng) end
        if i%20==0 then task.wait() end
    end
    -- Stone banks and broken fence sections give the scenery a human history.
    for i=0,29 do
        local z=-340-i*14
        local center=S.riverX(z)
        local half=S.riverHalfWidth(z)
        for _,x in ipairs({center-half-1.5,center+half+1.5}) do
            part(props,"MargemMusgosa",Vector3.new(rng:NextNumber(2.5,4.5),1.3,rng:NextNumber(4,7)),CFrame.new(x,.9,z)*CFrame.Angles(0,rng:NextNumber(-.3,.3),0),Color3.fromRGB(90,113,104),"WedgePart")
        end
    end
    for i=1,5 do
        local x,z=-128-i*2,-329+i*3
        part(props,"CercaAntiga",Vector3.new(.6,3,.6),CFrame.new(x,2.3,z)*CFrame.Angles(.12,.2,.18),Color3.fromRGB(107,92,67))
    end
    addSecret({id="bau_vagalumes",kind="chest",rarity="Raro",x=212,z=-666})
    addSecret({id="reliquia_nascente",kind="artifact",x=-18,z=-757})
    addSecret({id="bau_guardiao",kind="chest",rarity="Incomum",x=-184,z=-711})
    for _,center in ipairs({Vector3.new(212,.8,-666),Vector3.new(-18,.8,-757),Vector3.new(-184,.8,-711)}) do
        for i=1,36 do
            local angle=i*2.39996
            local radius=2+math.sqrt(i/36)*10
            spawnGrass(center.X+math.cos(angle)*radius,center.Z+math.sin(angle)*radius)
        end
    end
    -- Border groves shelter the routes and hide the artificial edge of the region.
    for index,grove in ipairs({{-245,-246},{240,-260},{-245,-370},{245,-395},
        {-240,-492},{245,-530},{-236,-633},{235,-667},{-227,-773},{233,-775},
        {-190,-265},{146,-300},{-10,-338},{150,-375},{-208,-471},{0,-540},
        {-80,-594},{195,-695},{-100,-760}}) do
        for j=1,6 do
            local angle=j*2.39996+index*.45
            local distance=4+math.sqrt(j)*5.2
            S.tree(root.ArvoresModulares,grove[1]+math.cos(angle)*distance,
                grove[2]+math.sin(angle)*distance,index%5+1,rng,1.05)
        end
        task.wait()
    end
    -- A low spring and a broken, luminous waystone give the ruin a distinct focal point.
    local spring=part(props,"EspelhoDaNascente",Vector3.new(.2,12,12),
        CFrame.new(-18,1.02,-757)*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(65,137,119))
    spring.Shape=Enum.PartType.Cylinder spring.Material=Enum.Material.Glass spring.Transparency=.26
    for i=1,11 do
        local angle=i*math.pi*2/12
        local stone=part(props,"BordaDaNascente",Vector3.new(2.8,1.1,2.3),
            CFrame.new(-18+math.cos(angle)*6.6,1.1,-757+math.sin(angle)*6.6)*CFrame.Angles(.15,angle,.1),
            Color3.fromRGB(94,112,95))
        stone.Shape=Enum.PartType.Ball stone.Material=Enum.Material.Slate
    end
    local monument=part(props,"MarcoDaNascente",Vector3.new(3.5,10,2.8),
        CFrame.new(-26,5.8,-763)*CFrame.Angles(.08,.3,-.14),Color3.fromRGB(83,104,91),"WedgePart",true)
    monument.Material=Enum.Material.Slate
    for j=1,3 do
        local rune=part(props,"RunasDoOrvalho",Vector3.new(.24,1.1,.17),
            CFrame.new(-25.5+j*.45,4.8+j*.7,-761.5)*CFrame.Angles(0,0,.4),
            Color3.fromRGB(214,192,113))
        rune.Material=Enum.Material.Neon
    end
    S.hero(root.ArvoresModulares,1,-42,-780,1.3,1.2)
    S.hero(root.ArvoresModulares,12,7,-775,1.25,2.3)
    root:SetAttribute("SceneryVersion",11)
    root:SetAttribute("TreeModels",12)
    root:SetAttribute("PlayableArea","600 x 648 studs")
end


-- A small, original low-poly NPC, assembled from reusable native parts.
function S.gnome(parent,position)
    local m=Instance.new("Model") m.Name="Nilo_GnomoColecionador"
    local function piece(name,size,offset,color,shape)
        local p=part(m,name,size,CFrame.new(position+offset),color)
        if shape then p.Shape=shape end
        return p
    end
    local green=Color3.fromRGB(70,111,88)
    local leather=Color3.fromRGB(86,57,39)
    piece("Casaco",Vector3.new(1.3,1.25,.95),Vector3.new(0,1.35,0),green,Enum.PartType.Ball)
    piece("Rosto",Vector3.new(1.05,1.05,.95),Vector3.new(0,2.22,-.08),Color3.fromRGB(225,182,136),Enum.PartType.Ball)
    piece("Barba",Vector3.new(.9,.95,.35),Vector3.new(0,1.85,-.52),Color3.fromRGB(219,219,191),Enum.PartType.Ball)
    piece("Nariz",Vector3.new(.38,.35,.4),Vector3.new(0,2.25,-.6),Color3.fromRGB(229,180,127),Enum.PartType.Ball)
    for _,side in ipairs({-1,1}) do
        piece("Bota",Vector3.new(.56,.48,.82),Vector3.new(side*.4,.3,-.16),leather)
        piece("Mao",Vector3.new(.34,.4,.35),Vector3.new(side*.8,1.3,-.15),Color3.fromRGB(225,182,136),Enum.PartType.Ball)
        piece("Olho",Vector3.new(.1,.13,.08),Vector3.new(side*.22,2.41,-.52),Color3.fromRGB(31,45,39),Enum.PartType.Ball)
    end
    for i=0,9 do
        local width=1.4-i*.14
        local hat=piece("ChapeuDeMusgo",Vector3.new(.17,width,width),Vector3.new(.014*i,2.7+i*.145,0),
            Color3.fromRGB(177+i*3,63+i*2,54+i),Enum.PartType.Cylinder)
        hat.CFrame*=CFrame.Angles(0,0,math.pi/2)
    end
    piece("BolsaDeReliquias",Vector3.new(.65,.85,.6),Vector3.new(.64,1.1,.42),leather)
    m:PivotTo(CFrame.new(position)*CFrame.Angles(0,math.pi,0)*CFrame.new(-position)*m:GetPivot())
    local board=piece("PlacaDoColecionador",Vector3.new(4.8,1.6,.22),Vector3.new(4,3.3,0),Color3.fromRGB(49,72,47))
    local post=piece("PosteDaPlaca",Vector3.new(.25,2.6,.25),Vector3.new(4,1.3,0),leather)
    local gui=Instance.new("SurfaceGui")
    gui.Name="ForestNPCContext" gui.Face=Enum.NormalId.Back gui.PixelsPerStud=100
    gui.CanvasSize=Vector2.new(480,160)
    gui.Enabled=false gui.Parent=board
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1) label.BackgroundTransparency=1
    label.TextColor3=Color3.fromRGB(245,229,180)
    label.Font=Enum.Font.GothamSemibold label.TextScaled=true label.TextWrapped=true
    label.Text="NILO\nColeciono histórias e caminhos!"
    label.Parent=gui
    m:SetAttribute("ForestNPC",true)
    m.Parent=parent
    return m
end

-- Branches off the main loop use deliberately planted pockets rather than uniform scatter.
function S.exploration(root,spawnGrass,addSecret,path,rng)
    local discoveries=Instance.new("Folder")
    discoveries.Name="DescobertasDaMata"
    discoveries.Parent=root
    local cave=Instance.new("Model")
    cave.Name="GrutaDasPedrasAzuis"
    cave.Parent=discoveries
    local x,z=-67,-712
    local y=S.height(x,z)
    local stone=Color3.fromRGB(66,79,83)
    local moss=Color3.fromRGB(57,94,73)
    local function rock(name,dx,dy,dz,w,h,d,color,collision)
        local p=part(cave,name,Vector3.new(w,h,d),CFrame.new(x+dx,y+dy,z+dz),color,nil,collision)
        p.Material=Enum.Material.Slate
        return p
    end
    -- Walls and roof leave a continuous opening, wide enough for mobile steering.
    for _,side in ipairs({-1,1}) do
        for j=0,4 do
            local b=rock("RochaDaEncosta",side*(10+j*.95),4.6+j*.45,-j*4,8,9+j,10,stone,false)
            b.Shape=Enum.PartType.Ball
            b.CFrame*=CFrame.Angles(.2,j*.24,side*.28)
        end
    end
    -- Native terrain forms a rounded hillside and a carved chamber, rather than a box tunnel.
    local terrain=workspace.Terrain
    terrain:FillBall(Vector3.new(x,y+1,z-12),18,Enum.Material.Rock)
    terrain:FillBall(Vector3.new(x-2,y+13,z-13),8.5,Enum.Material.Grass)
    for dz=9,-14,-4 do
        terrain:FillBall(Vector3.new(x,y+3.8,z+dz),6.5,Enum.Material.Air)
    end
    terrain:FillBall(Vector3.new(x-1,y+4,z-15),9,Enum.Material.Air)
    terrain:FillBall(Vector3.new(x+2,y+3.5,z-21),6.7,Enum.Material.Air)
    task.wait(.2)
    local floor=rock("ChaoDaGruta",0,-.1,-13,17,.2,30,Color3.fromRGB(84,92,83),true)
    floor.Material=Enum.Material.Slate
    -- Irregular boulders conceal the structural wall edges and form a natural rock arch.
    for _,side in ipairs({-1,1}) do
        for j=0,2 do
            local b=rock("RochedoDoPortal",side*(9+j*.55),3.3+j*2.5,4.5-j*.8,
                8.4-j*.4,7.2-j*.4,8.5,stone:Lerp(moss,j*.1),false)
            b.Shape=Enum.PartType.Ball
            b.CFrame*=CFrame.Angles(.12*j,side*.3,side*.16)
        end
    end
    for i=-1,1 do
        local b=rock("ArcoIrregular",i*6.4,10.4+math.abs(i)*.25,3.5,10.8,5.5,9.5,
            stone:Lerp(moss,.12),false)
        b.Shape=Enum.PartType.Ball b.CFrame*=CFrame.Angles(.16,i*.35,i*.12)
        local cap=rock("MusgoDoPortal",i*6.4,12.5,3.5,9.5,1.2,7.8,moss,false)
        cap.Shape=Enum.PartType.Ball cap.Material=Enum.Material.Grass
    end
    S.hero(root.ArvoresModulares,1,x-25,z-24,1.15,.6)
    S.hero(root.ArvoresModulares,12,x+26,z-22,1.1,2.4)
    local gate=rock("RaizesQueBloqueiamAEntrada",0,3.9,1,12,7.8,1.2,moss,true)
    gate.Material=Enum.Material.LeafyGrass
    for j=-2,2 do
        local rootPart=part(gate,"Raiz",Vector3.new(1.2,7.8,.9),CFrame.new(x+j*2.1,y+4,z+1.6)*CFrame.Angles(0,0,j*.12),Color3.fromRGB(76,56,43))
        rootPart.Material=Enum.Material.Wood
    end
    -- Small fallen stones reinforce the chamber floor without narrowing its center lane.
    for j=0,5 do
        local side=j%2==0 and -1 or 1
        local pebble=rock("PedraDaGruta",side*(5.5+(j%3)*.3),.3,-3-j*4.2,
            1.1+(j%3)*.25,.65,1.4,stone:Lerp(moss,.12),false)
        pebble.Shape=Enum.PartType.Ball
    end
    for j=0,5 do
        local dx=(j%2==0 and -1 or 1)*(4.1+j%3*.22)
        local p=Vector3.new(x+dx,y+1.12,z-4-j*3.8)
        for shard=1,3 do
            local crystal=part(cave,"CristalIntegrado",Vector3.new(.48,1.35+shard*.45,.7),
                CFrame.new(p+Vector3.new((shard-2)*.35,shard*.13,0))*CFrame.Angles(.10*shard,j*.6,(shard-2)*.25),
                Color3.fromRGB(73+shard*9,150+shard*8,148+shard*7),"WedgePart")
            crystal.Material=Enum.Material.Glass crystal.Transparency=.08
        end
        if j%2==0 then
            local glow=Instance.new("PointLight")
            glow.Color=Color3.fromRGB(136,202,182) glow.Range=10 glow.Brightness=.45
            glow.Parent=cave:GetChildren()[#cave:GetChildren()]
        end
    end
    local niche=rock("NichoDoTesouro",0,.12,-20,6,.28,5,Color3.fromRGB(79,96,75),false)
    local lantern=rock("LuzDoTesouro",0,4.6,-22,.4,.6,.4,Color3.fromRGB(225,184,104),false)
    lantern.Material=Enum.Material.Neon
    local treasureLight=Instance.new("PointLight")
    treasureLight.Color=Color3.fromRGB(240,206,143) treasureLight.Range=15 treasureLight.Brightness=1.15
    treasureLight.Parent=lantern
    for i=-1,1 do
        local rune=part(cave,"RunasDaGruta",Vector3.new(.3,1.3,.18),
            CFrame.new(x+i*.8,y+3.2+math.abs(i)*.3,z-25.8)*CFrame.Angles(0,0,i*.35),
            Color3.fromRGB(203,177,105),"WedgePart")
        rune.Material=Enum.Material.Neon
    end
    addSecret({id="gruta_pedras_azuis",kind="chest",rarity="Raro",x=x,z=z-20,groundY=y,
        cutPoint=Vector3.new(x,y,z+7),cutRadius=12,revealAt=18,gate=gate})
    addSecret({id="gnomo_colecionador",kind="gnome",x=-169,z=-568,cutRadius=11,revealAt=9,
        hint="Gnomo: siga as pedras azuis depois do tronco oco. Corte o mato diante da encosta."})
    addSecret({id="flor_do_orvalho",kind="artifact",x=-94,z=-618,cutRadius=10,revealAt=7})
    addSecret({id="bau_cogumelos",kind="chest",rarity="Incomum",x=-118,z=-655,cutRadius=12,revealAt=10})
    local trail={{-151,-547},{-169,-568},{-133,-590},{-110,-617},{-103,-651},{-83,-678},{-69,-694}}
    for i,point in ipairs(trail) do
        local tx,tz=table.unpack(point)
        if i>1 then
            local prev=trail[i-1]
            path(discoveries,Vector3.new(prev[1],0,prev[2]),Vector3.new(tx,0,tz),4.1)
        end
        local pebble=part(discoveries,"PistaAzul",Vector3.new(1.65,.8,1.4),
            CFrame.new(tx+3,S.height(tx+3,tz)+.25,tz)*CFrame.Angles(.2,i,.15),Color3.fromRGB(82,142,153))
        pebble.Material=Enum.Material.Slate
        pebble.Shape=Enum.PartType.Ball
        for k=1,4 do mushroom(discoveries,Vector3.new(tx+3+k*.7,S.height(tx+3+k*.7,tz+k*.4),tz+k*.4),rng:NextNumber(.7,1.2),k==4) end
    end
    TreeKit.hollowLog(discoveries,CFrame.new(-178,S.height(-178,-559)+1.3,-559)*CFrame.Angles(0,1.2,.04))
    S.hero(root.ArvoresModulares,4,-182,-574,1.0,.5)
    S.hero(root.ArvoresModulares,3,-157,-580,.92,2.1)
    for i=1,6 do
        local a=i*1.7
        mushroom(discoveries,Vector3.new(-169+math.cos(a)*5.5,S.height(-169,-568),-568+math.sin(a)*5.5),1.2,i%3==0)
    end
    for _,pocket in ipairs({{x,z+7,9,6},{-169,-568,8,7},{-94,-618,8,6},{-118,-655,9,7},{-83,-678,9,5},{-133,-590,7,5}}) do
        local cx,cz,rx,rz=table.unpack(pocket)
        for dx=-rx,rx,1.7 do
            for dz=-rz,rz,1.7 do
                if (dx/rx)^2+(dz/rz)^2<1 then
                    spawnGrass(cx+dx+rng:NextNumber(-.27,.27),cz+dz+rng:NextNumber(-.27,.27))
                end
            end
        end
        task.wait()
    end
    -- Re-seat low branches and trunks that would intrude into the cave chamber.
    local sources={root.ArvoresModulares,workspace.GameWorld.Decoracao.Arvores} local moved=0 for _,source in ipairs(sources) do for _,tree in ipairs(source:GetChildren()) do if tree:IsA("Model") then local obstructs=false for _,p in ipairs(tree:GetDescendants()) do if p:IsA("BasePart") and p.Position.Y<9.3 and p.Position.X>-76 and p.Position.X<-58 and p.Position.Z>-742 and p.Position.Z<-710 then obstructs=true break end end if obstructs then local cf=tree:GetPivot() local targetX=cf.Position.X<-67 and -94 or -40 tree:PivotTo(cf+Vector3.new(targetX-cf.Position.X,0,0)) moved+=1 end end end end
end

return S
