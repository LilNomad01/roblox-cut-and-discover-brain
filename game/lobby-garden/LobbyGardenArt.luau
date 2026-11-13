-- Native, modular lobby art. Existing plots, prompts and economy remain owned by their services.
local L={}
local T=workspace.Terrain
local q=RaycastParams.new();q.FilterType=Enum.RaycastFilterType.Include;q.FilterDescendantsInstances={T}
local C={wood=Color3.fromRGB(136,93,57),trim=Color3.fromRGB(193,145,87),cream=Color3.fromRGB(238,218,169),
    roof=Color3.fromRGB(159,79,57),green=Color3.fromRGB(91,137,88),dark=Color3.fromRGB(55,75,66),stone=Color3.fromRGB(184,181,159),soil=Color3.fromRGB(105,77,48)}
local function ground(x,z)
    local h=workspace:Raycast(Vector3.new(x,220,z),Vector3.new(0,-300,0),q)
    return h and h.Position.Y or 0
end
local function part(parent,name,size,cf,color,mat,collision,class)
    local p=Instance.new(class or 'Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
    p.Material=mat or Enum.Material.Wood;p.Anchored=true;p.CanCollide=collision==true;p.CanTouch=false;p.CanQuery=collision==true
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.CastShadow=math.max(size.X,size.Y,size.Z)>1
    p.Parent=parent;return p
end
local function model(parent,name)
    local m=Instance.new('Model');m.Name=name;m.Parent=parent;return m
end
local function cylinder(parent,name,pos,radius,height,color,mat,collision)
    local p=part(parent,name,Vector3.new(height,radius*2,radius*2),CFrame.new(pos)*CFrame.Angles(0,0,math.pi/2),color,mat,collision)
    p.Shape=Enum.PartType.Cylinder;return p
end
local function bloom(parent,pos,color,scale)
    part(parent,'Haste',Vector3.new(.08,.55,.08)*scale,CFrame.new(pos+Vector3.yAxis*.28*scale),C.green,Enum.Material.Grass)
    for i=1,4 do
        local a=i*math.pi/2
        local petal=part(parent,'Petala',Vector3.new(.55,.35,.55)*scale,CFrame.new(pos+Vector3.new(math.cos(a)*.24,.6,math.sin(a)*.24)*scale),color,Enum.Material.SmoothPlastic)
        petal.Shape=Enum.PartType.Ball
    end
    local core=part(parent,'Miolo',Vector3.new(.28,.23,.28)*scale,CFrame.new(pos+Vector3.yAxis*.66*scale),C.cream,Enum.Material.SmoothPlastic);core.Shape=Enum.PartType.Ball
end
local function crate(parent,cf,produce)
    local m=model(parent,'Caixote')
    part(m,'Fundo',Vector3.new(2.2,.17,1.65),cf,C.trim)
    for _,side in ipairs({-1,1})do
        for i=1,2 do
            part(m,'Ripa',Vector3.new(2.3,.28,.15),cf*CFrame.new(0,.28*i,side*.77),C.wood)
            part(m,'RipaCurta',Vector3.new(.15,.28,1.6),cf*CFrame.new(side*1.04,.28*i,0),C.trim)
        end
    end
    if produce then for i=1,6 do
        local fruit=part(m,'Colheita',Vector3.new(.45,.45,.45),cf*CFrame.new((i%3-1)*.57,.45,math.floor((i-1)/3)*.6-.3),i%2==0 and Color3.fromRGB(214,132,67) or Color3.fromRGB(151,179,76),Enum.Material.SmoothPlastic)
        fruit.Shape=Enum.PartType.Ball
    end end
end
local function wateringCan(parent,cf)
    local m=model(parent,'Regador')
    cylinder(m,'Reservatorio',cf.Position,.45,.65,Color3.fromRGB(95,151,156),Enum.Material.Metal)
    part(m,'Bico',Vector3.new(.18,.2,.85),cf*CFrame.new(0,.15,-.63)*CFrame.Angles(-.25,0,0),Color3.fromRGB(95,151,156),Enum.Material.Metal)
    for _,side in ipairs({-1,1})do part(m,'Alca',Vector3.new(.12,.45,.12),cf*CFrame.new(side*.3,.5,.1),C.dark,Enum.Material.Metal)end
    part(m,'Alca',Vector3.new(.7,.12,.12),cf*CFrame.new(0,.72,.1),C.dark,Enum.Material.Metal)
end
local function tool(parent,cf)
    part(parent,'CaboFerramenta',Vector3.new(.13,2.5,.13),cf*CFrame.Angles(0,0,.18),C.trim)
    part(parent,'Pa',Vector3.new(.65,.8,.13),cf*CFrame.new(-.16,-1.25,0)*CFrame.Angles(0,0,.18),Color3.fromRGB(103,126,126),Enum.Material.Metal,false,'WedgePart')
end
local function bed(parent,name,cf,width,length,vegetables)
    local m=model(parent,name)
    part(m,'Terra',Vector3.new(width,.35,length),cf*CFrame.new(0,.18,0),C.soil,Enum.Material.Ground)
    for _,side in ipairs({-1,1})do
        part(m,'Borda',Vector3.new(.22,.6,length+.2),cf*CFrame.new(side*width/2,.3,0),C.trim)
        part(m,'Borda',Vector3.new(width+.2,.6,.22),cf*CFrame.new(0,.3,side*length/2),C.wood)
    end
    for i=1,5 do for j=1,2 do
        local pos=(cf*CFrame.new((j-1.5)*width*.42,.4,(i-3)*length*.16)).Position
        if vegetables then
            local leaf=part(m,'Hortalica',Vector3.new(.95,.8,.95),CFrame.new(pos+Vector3.yAxis*.35),i%2==0 and Color3.fromRGB(129,172,81) or Color3.fromRGB(81,143,91),Enum.Material.LeafyGrass)
            leaf.Shape=Enum.PartType.Ball
            part(m,'Folha',Vector3.new(.15,.85,.75),CFrame.new(pos+Vector3.yAxis*.65)*CFrame.Angles(.3,i,.2),C.green,Enum.Material.LeafyGrass,false,'WedgePart')
        else bloom(m,pos,i%2==0 and Color3.fromRGB(219,166,187) or Color3.fromRGB(243,206,121),.65)end
    end end
    return m
end
local function lamp(parent,pos)
    local m=model(parent,'LanternaDoJardim')
    part(m,'Pe',Vector3.new(.7,.3,.7),CFrame.new(pos+Vector3.yAxis*.15),C.stone,Enum.Material.Cobblestone)
    part(m,'Poste',Vector3.new(.25,5.7,.25),CFrame.new(pos+Vector3.yAxis*3),C.dark,Enum.Material.Metal)
    local glass=part(m,'Luz',Vector3.new(.8,.9,.8),CFrame.new(pos+Vector3.yAxis*5.9),Color3.fromRGB(255,226,150),Enum.Material.Neon)
    part(m,'Chapeu',Vector3.new(1.2,.2,1.2),CFrame.new(pos+Vector3.yAxis*6.45),C.wood)
    local light=Instance.new('PointLight');light.Color=glass.Color;light.Brightness=.45;light.Range=11;light.Shadows=false;light.Parent=glass
end
local function bench(parent,cf)
    local m=model(parent,'BancoDoJardim')
    for i=1,3 do part(m,'Assento',Vector3.new(4,.18,.35),cf*CFrame.new(0,1.25,(i-2)*.4),C.trim,nil,true)end
    for _,side in ipairs({-1,1})do
        part(m,'Pe',Vector3.new(.3,1.2,1.3),cf*CFrame.new(side*1.5,.6,0),C.dark,Enum.Material.Metal)
        part(m,'Suporte',Vector3.new(.2,1.5,.2),cf*CFrame.new(side*1.5,1.8,.7),C.dark,Enum.Material.Metal)
    end
    for i=1,2 do part(m,'Encosto',Vector3.new(4,.35,.18),cf*CFrame.new(0,1.65+i*.4,.68),C.wood)end
end
local function foundation(parent,cx,cz,w,d)
    local y=ground(cx,cz)
    for _,x in ipairs({-w/2,w/2})do for _,z in ipairs({-d/2,d/2})do y=math.max(y,ground(cx+x,cz+z))end end
    y+=.15
    local low=math.min(ground(cx-w/2,cz-d/2),ground(cx+w/2,cz-d/2),ground(cx-w/2,cz+d/2),ground(cx+w/2,cz+d/2))
    local thickness=math.max(.45,y-low+.45)
    part(parent,'Embasamento',Vector3.new(w,thickness,d),CFrame.new(cx,y+.145-thickness/2,cz),C.stone,Enum.Material.Cobblestone,true)
    for _,x in ipairs({-w/2+.4,w/2-.4})do for _,z in ipairs({-d/2+.4,d/2-.4})do
        local g=ground(cx+x,cz+z);local h=math.max(.3,y-g)
        part(parent,'ApoioEnterrado',Vector3.new(.8,h,.8),CFrame.new(cx+x,g+h/2,cz+z),C.stone,Enum.Material.Cobblestone)
    end end
    return y+.15
end
local function hut(parent,cx,cz)
    local m=model(parent,'MoinhoDaHorta');local y=foundation(m,cx,cz,11,10)
    part(m,'Corpo',Vector3.new(8.5,12,7.8),CFrame.new(cx,y+6,cz),C.cream,Enum.Material.Plaster,true)
    for _,side in ipairs({-1,1})do
        part(m,'Telhado',Vector3.new(6.1,.45,10.2),CFrame.new(cx+side*2.3,y+13.4,cz)*CFrame.Angles(0,0,-side*.53),C.roof)
        part(m,'Coluna',Vector3.new(.35,12,.35),CFrame.new(cx+side*4.3,y+6,cz+4),C.wood)
    end
    part(m,'PortaDecorativa',Vector3.new(2.6,4.5,.18),CFrame.new(cx,y+2.25,cz+4),C.wood)
    local rotor=model(m,'Rotor')
    local hub=part(rotor,'Eixo',Vector3.new(1,1,1),CFrame.new(cx,y+10.3,cz+4.5),C.dark,Enum.Material.Metal)
    hub.Shape=Enum.PartType.Ball;rotor.PrimaryPart=hub
    for i=0,3 do
        local cf=hub.CFrame*CFrame.Angles(0,0,i*math.pi/2+.3)
        part(rotor,'Braco',Vector3.new(.22,6,.25),cf*CFrame.new(0,3,0),C.wood)
        part(rotor,'Vela',Vector3.new(1.45,3.5,.12),cf*CFrame.new(.6,4.2,-.06),Color3.fromRGB(242,226,188),Enum.Material.Fabric)
    end
    for _,p in ipairs(rotor:GetDescendants())do if p:IsA('BasePart')then p.CastShadow=false end end
    require(script.Parent.SignKit).create(m,'Nome','MOINHO DA HORTA',Vector3.new(cx-7.7,ground(cx-7.7,cz+3)+3.1,cz+3),7,C.green)
    return m
end
local function greenhouse(parent,cx,cz)
    local m=model(parent,'EstufaDaVila');local y=foundation(m,cx,cz,19,14)
    for _,x in ipairs({-8.5,0,8.5})do for _,z in ipairs({-6,6})do part(m,'Pilar',Vector3.new(.25,6.5,.25),CFrame.new(cx+x,y+3.25,cz+z),C.green)end end
    for _,side in ipairs({-1,1})do
        for _,offset in ipairs(side<0 and {-4.5,4.5}or {0})do
            local glass=part(m,'VidroLateral',Vector3.new(.12,6.2,side<0 and 3 or 12),CFrame.new(cx+side*8.4,y+3.25,cz+offset),Color3.fromRGB(181,216,199),Enum.Material.Glass)
            glass.Transparency=.72;glass.CastShadow=false
        end
        local roof=part(m,'VidroDoTeto',Vector3.new(10,.12,12.5),CFrame.new(cx+side*4.2,y+7.4,cz)*CFrame.Angles(0,0,-side*.26),Color3.fromRGB(181,216,199),Enum.Material.Glass)
        roof.Transparency=.6;roof.CastShadow=false
        part(m,'Cumeeira',Vector3.new(.22,.22,13),CFrame.new(cx,y+8.5,cz),C.green)
        part(m,'Viga',Vector3.new(17,.25,.25),CFrame.new(cx,y+6.5,cz+side*6),C.green)
    end
    for i=-2,2 do
        part(m,'CaixilhoDoFundo',Vector3.new(.12,6,.16),CFrame.new(cx+i*3.4,y+3.2,cz+6),C.green)
        for _,side in ipairs({-1,1})do part(m,'CaibroDoTeto',Vector3.new(9,.14,.14),CFrame.new(cx+side*4.2,y+7.4,cz+i*2.8)*CFrame.Angles(0,0,-side*.26),C.green)end
    end
    local entry=ground(cx-11,cz)
    for i=1,3 do
        local h=math.max(.15,(y-entry)*i/3)
        part(m,'DegrauDaEntrada',Vector3.new(1,h,5),CFrame.new(cx-12+i,entry+h/2,cz),C.stone,Enum.Material.Cobblestone,true)
    end
    for _,x in ipairs({-5.4,5.4})do bed(m,'CanteiroDaEstufa',CFrame.new(cx+x,y+.1,cz),3.5,9,false)end
    require(script.Parent.SignKit).create(m,'Nome','ESTUFA DA VILA',Vector3.new(cx-12,ground(cx-12,cz+5)+3.1,cz+5),7,C.green)
    wateringCan(m,CFrame.new(cx+1,y+.4,cz-2));crate(m,CFrame.new(cx-1,y+.3,cz-3),false)
end
local function layoutExisting(world)
    local lobby=world.Lobby
    for _,name in ipairs({'Title','Welcome'})do
        local m=lobby:FindFirstChild(name)
        if m then for _,v in ipairs(m:GetDescendants())do
            if v:IsA('BasePart')then v.Transparency=1;v.CanCollide=false;v.CanTouch=false
            elseif v:IsA('SurfaceGui')then v.Enabled=false end
        end end
    end
    local targets={QuadroMissoes=Vector2.new(-16,-21),QuadroRanking=Vector2.new(16,-21)}
    for name,target in pairs(targets)do
        local m=lobby:FindFirstChild(name)
        if m and not m:GetAttribute('GardenLobbyPositioned')then
            local gui=m:FindFirstChildWhichIsA('SurfaceGui',true)
            if gui and gui.Parent:IsA('BasePart')then
                local normal=gui.Parent.CFrame:VectorToWorldSpace(Vector3.FromNormalId(gui.Face));normal=Vector3.new(normal.X,0,normal.Z).Unit
                local desired=Vector3.new(-target.X,0,-8-target.Y).Unit
                local angle=math.atan2(normal:Cross(desired).Y,normal:Dot(desired))
                local pivot=m:GetPivot();m:PivotTo(CFrame.new(pivot.Position)*CFrame.Angles(0,angle,0)*pivot.Rotation)
            end
            local cf,size=m:GetBoundingBox()
            m:PivotTo(m:GetPivot()+Vector3.new(target.X-cf.X,ground(target.X,target.Y)+.12-(cf.Y-size.Y/2),target.Y-cf.Z))
            m:SetAttribute('GardenLobbyPositioned',true)
        end
    end
    for _,plot in ipairs(world.Plots:GetChildren())do
        local sign=plot:FindFirstChild('PlotSign')
        if sign and not sign:GetAttribute('GardenLobbyFramed')then
            local panel=sign:FindFirstChild('Panel')or sign.PrimaryPart
            if panel then
                panel.Size=Vector3.new(math.min(panel.Size.X,12),math.min(panel.Size.Y,2.7),panel.Size.Z)
                panel.Color=C.wood;panel.Material=Enum.Material.Wood;panel.CanCollide=false
                for _,side in ipairs({-1,1})do
                    part(sign,'MolduraJardim',Vector3.new(panel.Size.X+.2,.16,panel.Size.Z+.1),panel.CFrame*CFrame.new(0,side*panel.Size.Y/2,0),C.trim)
                    part(sign,'MolduraJardim',Vector3.new(.16,panel.Size.Y,panel.Size.Z+.1),panel.CFrame*CFrame.new(side*panel.Size.X/2,0,0),C.trim)
                end
            end
            sign:SetAttribute('GardenLobbyFramed',true)
        end
    end
    local curbs=world.Decoracao and world.Decoracao:FindFirstChild("Meios-fios")
    if curbs then for _,p in ipairs(curbs:GetChildren())do if p:IsA("BasePart")then
        p.Color=Color3.fromRGB(192,183,156);p.Material=Enum.Material.Cobblestone
        p.Size=Vector3.new(p.Size.X,.28,p.Size.Z);p.Position=Vector3.new(p.Position.X,.14,p.Position.Z)
    end end end
    for _,plot in ipairs(world.Plots:GetChildren())do
        plot.Base.Material=Enum.Material.Cobblestone;plot.Base.Color=Color3.fromRGB(209,196,162)
    end
    for _,name in ipairs({'Plaza','PathX','PathZ'})do
        local p=lobby:FindFirstChild(name)
        if p and p:IsA('BasePart')then p.Material=Enum.Material.Cobblestone;p.Color=name=='Plaza'and Color3.fromRGB(216,208,178)or Color3.fromRGB(229,218,189)end
    end
end
local function paintPath(parent,points,width)
    local f=Instance.new('Folder');f.Name='CaminhoIntegrado';f.Parent=parent
    for i=1,#points-1 do
        local a,b=Vector3.new(points[i][1],0,points[i][2]),Vector3.new(points[i+1][1],0,points[i+1][2])
        local n=math.max(1,math.ceil((b-a).Magnitude/3))
        for j=0,n do
            local p=a:Lerp(b,j/n);local y=ground(p.X,p.Z)
            local region=Region3.new(Vector3.new(p.X-width/2,y-4,p.Z-width/2),Vector3.new(p.X+width/2,y+2,p.Z+width/2)):ExpandToGrid(4)
            T:ReplaceMaterial(region,4,Enum.Material.Grass,Enum.Material.Ground)
            T:ReplaceMaterial(region,4,Enum.Material.LeafyGrass,Enum.Material.Ground)
        end
    end
end
function L.build(world)
    world=world or workspace:WaitForChild('GameWorld')
    assert(#world.Plots:GetChildren()==4,'Preserve the four existing plots')
    layoutExisting(world)
    local existing=world:FindFirstChild('LobbyGardenReform')
    if existing then return existing end
    local root=model(world,'LobbyGardenReform');root:SetAttribute('VisualOnly',true);root:SetAttribute('ArtRevision',1)
    -- Keep ornamental soil warm and readable from the aerial camera.
    if not world:GetAttribute("GardenGroundOriginal")then world:SetAttribute("GardenGroundOriginal",T:GetMaterialColor(Enum.Material.Ground))end
    T:SetMaterialColor(Enum.Material.Ground,Color3.fromRGB(154,130,92))
    local trees=world.Decoracao:FindFirstChild("Arvores")
    if trees then for _,tree in ipairs(trees:GetChildren())do if tree:IsA("Model")and not tree:GetAttribute("GardenClearanceAdjusted")then
        local cf=tree:GetBoundingBox();local target
        if (Vector2.new(cf.X-126,cf.Z-39)).Magnitude<15 then target=Vector2.new(151,57)
        elseif (Vector2.new(cf.X+100,cf.Z+4)).Magnitude<6 then target=Vector2.new(-100,-36)end
        if target then
            tree:SetAttribute("BeforeGardenPivot",tree:GetPivot())
            tree:PivotTo(tree:GetPivot()+Vector3.new(target.X-cf.X,ground(target.X,target.Y)-ground(cf.X,cf.Z),target.Y-cf.Z))
            tree:SetAttribute("GardenClearanceAdjusted",true)
        end
    end end end
    local center=model(root,'PracaDoJardineiro');local centerPos=Vector3.new(0,.3,-8)
    cylinder(center,'PracaCircular',centerPos+Vector3.yAxis*.1,10.8,.16,C.stone,Enum.Material.Cobblestone,true)
    cylinder(center,'TerraDaArvore',centerPos+Vector3.yAxis*.37,5.6,.55,C.soil,Enum.Material.Ground)
    for i=1,20 do
        local a=i*math.pi/10;local p=centerPos+Vector3.new(math.cos(a)*6,.45,math.sin(a)*6)
        part(center,'BordaDoCanteiro',Vector3.new(.45,.65,1.95),CFrame.new(p)*CFrame.Angles(0,-a,0),C.trim,Enum.Material.Wood,true)
        if i%2==0 then bloom(center,centerPos+Vector3.new(math.cos(a)*4.9,.7,math.sin(a)*4.9),i%4==0 and Color3.fromRGB(244,198,110)or Color3.fromRGB(210,162,195),.8)end
    end
    require(script.Parent.ForestTreeKit).clone(1,center,centerPos+Vector3.yAxis*.65,.72,.4)
    require(script.Parent.SignKit).create(center,'Identidade','CORTE & DESCUBRA',Vector3.new(0,2.7,1),10,Color3.fromRGB(228,182,88))
    for i=1,24 do
        local a=i*math.pi/12;local x,z=math.cos(a)*7.4,-8+math.sin(a)*7.4
        bloom(center,Vector3.new(x,.5,z),i%3==0 and Color3.fromRGB(239,175,128)or(i%2==0 and Color3.fromRGB(240,209,124)or Color3.fromRGB(194,148,201)),1)
    end
    for _,x in ipairs({-9,9})do
        cylinder(center,'VasoDeBarro',Vector3.new(x,1,0),.9,1.25,C.roof,Enum.Material.SmoothPlastic)
        for j=1,3 do bloom(center,Vector3.new(x+(j-2)*.4,1.62,0),Color3.fromRGB(237,204,130),1.2)end
    end
    wateringCan(center,CFrame.new(5.3,1.1,-4.4));tool(center,CFrame.new(-5,1.6,-4.6)*CFrame.Angles(0,.3,0))
    for _,x in ipairs({-19,19})do
        bench(center,CFrame.new(x,.3,9)*CFrame.Angles(0,x<0 and math.pi/2 or -math.pi/2,0))
        lamp(center,Vector3.new(x,.3,-12));lamp(center,Vector3.new(x,.3,18))
    end
    for _,x in ipairs({-14,14})do for _,z in ipairs({-47,47})do bed(root,'JardimEntreCaminhos',CFrame.new(x,ground(x,z),z),4,8,false)end end
    for _,v in ipairs({Vector2.new(-85,0),Vector2.new(85,0),Vector2.new(0,85),Vector2.new(0,-85)})do cylinder(root,'EncontroArredondado',Vector3.new(v.X,.12,v.Y),6,.2,Color3.fromRGB(229,218,189),Enum.Material.Cobblestone,true)end
    local rural=model(root,'RecantoDaHorta');hut(rural,-137,-31)
    for i=1,3 do bed(rural,'HortaComunitaria',CFrame.new(-119,ground(-119,17+i*8)+.1,17+i*8),8,5.5,true)end
    require(script.Parent.SignKit).create(rural,'NomeHorta','HORTA DA VILA',Vector3.new(-108,ground(-108,35)+3,35),7,C.green)
    local cy=ground(-114,-18)
    crate(rural,CFrame.new(-114,cy+.15,-18),true);crate(rural,CFrame.new(-116,cy+.95,-18)*CFrame.Angles(0,.2,0),false)
    wateringCan(rural,CFrame.new(-110,ground(-110,-16)+.5,-16));tool(rural,CFrame.new(-132,ground(-132,-25)+1.6,-25)*CFrame.Angles(0,.5,0))
    local compost=model(rural,'Compostagem')
    for _,x in ipairs({-116,-111})do
        local y=ground(x,-42);part(compost,'Composto',Vector3.new(3,.8,3),CFrame.new(x,y+.4,-42),C.soil,Enum.Material.Ground)
        for _,z in ipairs({-43.5,-40.5})do for j=1,3 do part(compost,'Tabua',Vector3.new(3.4,.22,.18),CFrame.new(x,y+j*.35,z),C.wood)end end
    end
    greenhouse(root,126,39)
    local rest=model(root,'RecantoDeDescanso');local y=foundation(rest,120,-85,13,13)
    for _,x in ipairs({-5.5,5.5})do for _,z in ipairs({-5.5,5.5})do part(rest,'Pilar',Vector3.new(.35,7,.35),CFrame.new(120+x,y+3.5,-85+z),C.wood)end end
    for _,side in ipairs({-1,1})do part(rest,'Telhado',Vector3.new(7.4,.35,15),CFrame.new(120+side*3,y+8,-85)*CFrame.Angles(0,0,-side*.34),C.green)end
    bench(rest,CFrame.new(120,y,-88));bench(rest,CFrame.new(116,y,-85)*CFrame.Angles(0,math.pi/2,0))
    paintPath(root,{{85,0},{102,6},{108,24},{118,39}},6)
    paintPath(root,{{85,-1},{101,-19},{112,-48},{120,-78}},5)
    paintPath(root,{{-85,0},{-104,-7},{-119,-19},{-131,-28}},6)
    paintPath(root,{{-104,-7},{-109,13},{-110,32}},5)
    paintPath(root,{{0,85},{19,100},{28,120},{25,147},{9,172},{0,204}},6)
    -- Repeat small garden motifs around the plots; keep every gate and road clear.
    local border=model(root,"BairroDosJardins")
    for _,sx in ipairs({-1,1})do for _,sz in ipairs({-1,1})do
        local x,z=sx*81,sz*48
        bed(border,"CanteiroExterno",CFrame.new(x,ground(x,z),z),3,11,false)
        bench(border,CFrame.new(sx*95,ground(sx*95,sz*60),sz*60)*CFrame.Angles(0,sx*math.pi/2,0))
        local y=ground(sx*88,sz*76)
        for i=1,6 do bloom(border,Vector3.new(sx*(86+i*.6),y,sz*(76+i%2)),i%2==0 and Color3.fromRGB(236,193,110)or Color3.fromRGB(203,158,199),.8)end
    end end
    local fence=model(rural,"CercaDaHorta")
    for i=0,5 do
        local x,z=-132+i*5,49;local y=ground(x,z)
        part(fence,"Mourao",Vector3.new(.35,2.3,.35),CFrame.new(x,y+1.15,z),C.wood)
        if i<5 then for _,h in ipairs({.8,1.7})do part(fence,"Travessa",Vector3.new(5,.2,.18),CFrame.new(x+2.5,y+h,z),C.trim)end end
    end
    local cart=model(rural,"CarrinhoDeJardinagem");local y=ground(-105,42)
    part(cart,"Cacamba",Vector3.new(2.8,.7,1.8),CFrame.new(-105,y+1.1,42),C.green,Enum.Material.Metal)
    for _,z in ipairs({41.3,42.7})do part(cart,"Cabo",Vector3.new(3.6,.13,.13),CFrame.new(-103.7,y+.9,z),C.wood)end
    local wheel=cylinder(cart,"Roda",Vector3.new(-106.5,y+.5,42),.5,.28,C.dark,Enum.Material.SmoothPlastic)
    wheel.CFrame=CFrame.new(wheel.Position)*CFrame.Angles(math.pi/2,0,0)
    for i=1,3 do
        local x,z=-146+(i%2)*2,-17+math.floor(i/2)*2;local y=ground(x,z)
        part(rural,"FardoDeFeno",Vector3.new(2.2,1.5,1.8),CFrame.new(x,y+.75,z),Color3.fromRGB(207,177,94),Enum.Material.Fabric)
        part(rural,"CordaDoFardo",Vector3.new(.13,1.54,1.84),CFrame.new(x,y+.75,z),C.wood)
    end
    local neighborhood=model(root,'AteliesDeJardinagem')
    for _,sx in ipairs({-1,1})do for _,sz in ipairs({-1,1})do
        local x,z=sx*91,sz*86;local y=ground(x,z)
        -- A compact potting station anchors each garden corner outside the playable plot.
        part(neighborhood,'Bancada',Vector3.new(5,.3,2.3),CFrame.new(x,y+2.1,z),C.trim)
        for _,dx in ipairs({-2,2})do for _,dz in ipairs({-.85,.85})do part(neighborhood,'PeDaBancada',Vector3.new(.22,2,.22),CFrame.new(x+dx,y+1,z+dz),C.wood)end end
        for i=1,3 do
            cylinder(neighborhood,'Vaso',Vector3.new(x+(i-2)*1.25,y+2.6,z),.4,.7,C.roof,Enum.Material.SmoothPlastic)
            bloom(neighborhood,Vector3.new(x+(i-2)*1.25,y+3,z),i%2==0 and Color3.fromRGB(211,158,199)or Color3.fromRGB(240,201,121),.9)
        end
        wateringCan(neighborhood,CFrame.new(x-3,ground(x-3,z)+.5,z));crate(neighborhood,CFrame.new(x+3,ground(x+3,z)+.1,z),false)
        local gardenX=x+sx*7
        bed(neighborhood,'HortaDoBairro',CFrame.new(gardenX,ground(gardenX,z),z),5,11,true)
        for j=1,3 do
            local hx,hz=x+sx*6+(j-2)*3,z+sz*8;local hy=ground(hx,hz)
            local leaf=part(neighborhood,'ArbustoDoJardim',Vector3.new(3.4,2.2,2.7),CFrame.new(hx,hy+1,hz),Color3.fromRGB(91,145,85),Enum.Material.LeafyGrass);leaf.Shape=Enum.PartType.Ball
            for k=1,2 do bloom(neighborhood,Vector3.new(hx+(k-1.5)*.8,hy+1.8,hz-.8),Color3.fromRGB(237,184,143),.7)end
        end
    end end
    -- Potting shed and sheltered delivery corner join the eastern neighborhood.
    local shed=model(root,'AbrigoDeSementes');local sy=foundation(shed,94,111,13,10)
    part(shed,'ParedeDeFundo',Vector3.new(12,7,.3),CFrame.new(94,sy+3.5,115),C.cream,Enum.Material.WoodPlanks)
    for _,side in ipairs({-1,1})do
        part(shed,'Lateral',Vector3.new(.3,7,8),CFrame.new(94+side*5.8,sy+3.5,111),C.wood)
        part(shed,'Telhado',Vector3.new(7.5,.35,12),CFrame.new(94+side*3,sy+7.8,111)*CFrame.Angles(0,0,-side*.35),C.roof)
    end
    for i=1,3 do crate(shed,CFrame.new(90+i*2,sy+.2,112),i%2==0)end
    crate(shed,CFrame.new(94,sy+1.1,112),false);wateringCan(shed,CFrame.new(90,sy+.5,108))
    paintPath(root,{{0,85},{24,95},{52,100},{76,104},{94,105}},5)
    local Signs=require(script.Parent.SignKit)
    Signs.create(root,'RumoFloresta','FLORESTA ESQUECIDA',Vector3.new(-14,ground(-14,-83)+3.4,-83),8,C.green)
    Signs.create(root,'RumoFazenda','FAZENDA',Vector3.new(-13,ground(-13,89)+3.4,89),6,Color3.fromRGB(222,176,87))
    Signs.create(root,'Oficina','OFICINA',Vector3.new(-19,ground(-19,30)+3.2,30),5,Color3.fromRGB(202,156,88))
    root:SetAttribute('Ready',true)
    return root
end
function L.start(world)
    L.build(world)
    if game:GetService('RunService'):IsRunning()then
        world.Lobby.ChildAdded:Connect(function(m)
            if m.Name=='QuadroRanking'or m.Name=='QuadroMissoes'then task.delay(1,function()if m.Parent then layoutExisting(world)end end)end
        end)
    end
end
return L
