-- Composed public garden spaces. Decorative additions never advertise new services.
local L={}
local wood=Color3.fromRGB(133,91,55)
local trim=Color3.fromRGB(201,158,97)
local green=Color3.fromRGB(92,143,99)
local stone=Color3.fromRGB(180,170,140)
local query=RaycastParams.new()
query.FilterType=Enum.RaycastFilterType.Include
query.FilterDescendantsInstances={workspace.Terrain}
local function ground(x,z)
    local h=workspace:Raycast(Vector3.new(x,500,z),Vector3.new(0,-700,0),query)
    return h and h.Position.Y or 0
end
local function part(parent,name,size,cf,color,material,collide)
    local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
    p.Material=material or Enum.Material.Wood;p.Anchored=true;p.CanCollide=collide==true
    p.CanTouch=false;p.CanQuery=p.CanCollide;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent;return p
end
local function model(parent,name)
    local m=Instance.new('Model');m.Name=name;m.Parent=parent;return m
end
local function disk(parent,name,pos,r,h,color,material)
    local p=part(parent,name,Vector3.new(h,r*2,r*2),CFrame.new(pos)*CFrame.Angles(0,0,math.pi/2),color,material)
    p.Shape=Enum.PartType.Cylinder;return p
end
local function planter(parent,x,z,color,floor)
    local y=floor or ground(x,z)
    disk(parent,'VasoDeTerracota',Vector3.new(x,y+.65,z),.9,1.3,Color3.fromRGB(176,105,75),Enum.Material.SmoothPlastic)
    disk(parent,'AroDoVaso',Vector3.new(x,y+1.25,z),1,.22,trim)
    for j=1,5 do
        local a=j*2.4
        local leaf=part(parent,'Folha',Vector3.new(.4,1.7,.8),CFrame.new(x+math.cos(a)*.45,y+1.9,z+math.sin(a)*.45)*CFrame.Angles(.2,a,.15),green,Enum.Material.LeafyGrass)
        local flower=part(parent,'Flor',Vector3.new(.7,.45,.7),CFrame.new(x+math.cos(a)*.4,y+2.75,z+math.sin(a)*.4),color,Enum.Material.SmoothPlastic)
        flower.Shape=Enum.PartType.Ball
    end
end
local function crate(parent,cf)
    for _,side in ipairs({-1,1})do
        for j=1,3 do part(parent,'RipaDoCaixote',Vector3.new(2.6,.25,.16),cf*CFrame.new(0,j*.32,side*.95),wood)end
        part(parent,'LateralDoCaixote',Vector3.new(.18,1.15,2),cf*CFrame.new(side*1.25,.5,0),trim)
    end
    part(parent,'FundoDoCaixote',Vector3.new(2.6,.15,2),cf,wood)
end
local function path(points)
    for i=1,#points-1 do
        local a,b=Vector3.new(points[i][1],0,points[i][2]),Vector3.new(points[i+1][1],0,points[i+1][2])
        local n=math.max(1,math.ceil((b-a).Magnitude/3))
        for j=0,n do
            local p=a:Lerp(b,j/n);local y=ground(p.X,p.Z)
            local region=Region3.new(Vector3.new(p.X-3,y-4,p.Z-3),Vector3.new(p.X+3,y+2,p.Z+3)):ExpandToGrid(4)
            workspace.Terrain:ReplaceMaterial(region,4,Enum.Material.Grass,Enum.Material.Ground)
            workspace.Terrain:ReplaceMaterial(region,4,Enum.Material.LeafyGrass,Enum.Material.Ground)
        end
    end
end
function L.build(world)
    if world:FindFirstChild('LobbyVillageLife')then return world.LobbyVillageLife end
    local root=model(world,'LobbyVillageLife');root:SetAttribute('VisualOnly',true)
    local nursery=model(root,'RecantoDosVasos');local x,z=-126,-78;local y=ground(x,z)
    for _,side in ipairs({-1,1})do
        for _,front in ipairs({-1,1})do
            local py=ground(x+side*7,z+front*4.5)-.2
            part(nursery,'Pilar',Vector3.new(.4,y+8-py,.4),CFrame.new(x+side*7,(py+y+8)/2,z+front*4.5),wood,nil,true)
        end
        part(nursery,'Cobertura',Vector3.new(8,.25,12),CFrame.new(x+side*3.5,y+8.9,z)*CFrame.Angles(0,0,-side*.27),side<0 and Color3.fromRGB(240,217,158)or green,Enum.Material.Fabric)
        part(nursery,'Prateleira',Vector3.new(12,.3,2),CFrame.new(x,y+3.1,z+side*3.6),trim)
    end
    for i=1,4 do planter(nursery,x-5+i*2.5,z+3,Color3.fromRGB(222,161,188),y+3.3)end
    for i=1,3 do crate(nursery,CFrame.new(x-4+i*3,y+.1,z-2))end
    require(script.Parent.SignKit).create(nursery,'Nome','RECANTO DOS VASOS',Vector3.new(x,y+6.3,z+4.8),10,green)
    path({{-103,-76},{-113,-78},{-118,-78}})

    local cart=model(root,'CarrocaDaColheita');x,z=-122,12;y=ground(x,z)
    part(cart,'Estrado',Vector3.new(5,.35,8),CFrame.new(x,y+1.5,z),trim,nil,true)
    for _,side in ipairs({-1,1})do
        for _,endSide in ipairs({-1,1})do
            local wheel=disk(cart,'Roda',Vector3.new(x+side*2.8,y+1,z+endSide*2.5),1.1,.35,Color3.fromRGB(64,61,48),Enum.Material.Wood)
            wheel.CFrame=CFrame.new(wheel.Position)
        end
        for j=1,3 do part(cart,'Lateral',Vector3.new(.22,.25,8),CFrame.new(x+side*2.4,y+1.6+j*.35,z),wood)end
        part(cart,'Braco',Vector3.new(.18,.18,5),CFrame.new(x+side*1.3,y+1.1,z+6),wood)
    end
    for i=1,3 do part(cart,'Feno',Vector3.new(2.1,1.4,2),CFrame.new(x+(i%2-.5)*2.2,y+2.4,z+(i-2)*2),Color3.fromRGB(215,184,102),Enum.Material.Fabric)end

    local workshop=model(root,'AtelieDoJardim');x,z=128,-30;y=ground(x,z)
    for _,side in ipairs({-1,1})do
        part(workshop,'Coluna',Vector3.new(.4,7,.4),CFrame.new(x+side*6,y+3.5,z),wood,nil,true)
        part(workshop,'Telhado',Vector3.new(7,.3,8),CFrame.new(x+side*2.9,y+7.8,z)*CFrame.Angles(0,0,-side*.3),Color3.fromRGB(170,101,73))
    end
    part(workshop,'PainelDeFerramentas',Vector3.new(12,5,.35),CFrame.new(x,y+4,z+3),trim)
    part(workshop,'Bancada',Vector3.new(12,.4,3),CFrame.new(x,y+2.5,z),wood,nil,true)
    for i=1,5 do
        part(workshop,'Cabo',Vector3.new(.15,2.3,.15),CFrame.new(x-4+(i-1)*2,y+4.4,z+2.7)*CFrame.Angles(0,0,i%2==0 and .15 or -.15),wood)
        part(workshop,'Pa',Vector3.new(.65,.75,.16),CFrame.new(x-4+(i-1)*2,y+3.3,z+2.6),Color3.fromRGB(112,143,142),Enum.Material.Metal)
    end
    planter(workshop,x-8,z-1,Color3.fromRGB(240,200,112));planter(workshop,x+8,z-1,Color3.fromRGB(185,166,221))
    path({{106,-30},{116,-30},{122,-30}})

    local pond=model(root,'JardimDaAgua');x,z=126,-115;y=ground(x,z)
    disk(pond,'BaseDaFonte',Vector3.new(x,y+.25,z),8,.5,stone,Enum.Material.Sandstone)
    local water=disk(pond,'AguaRasa',Vector3.new(x,y+.65,z),6.7,.13,Color3.fromRGB(82,168,166),Enum.Material.Glass)
    water.Transparency=.22;water.CastShadow=false
    for i=1,20 do
        local a=i*math.pi/10
        part(pond,'Borda',Vector3.new(.6,1.25,2.5),CFrame.new(x+math.cos(a)*7.1,y+.65,z+math.sin(a)*7.1)*CFrame.Angles(0,-a,0),stone,Enum.Material.Sandstone,true)
    end
    disk(pond,'Pedestal',Vector3.new(x,y+1.3,z),1.3,2,stone,Enum.Material.Sandstone)
    disk(pond,'TacaDaFonte',Vector3.new(x,y+2.4,z),2.5,.35,stone,Enum.Material.Sandstone)
    disk(pond,'AguaDaTaca',Vector3.new(x,y+2.6,z),2.15,.1,Color3.fromRGB(107,193,180),Enum.Material.Glass)
    for _,side in ipairs({-1,1})do planter(pond,x+side*10,z+4,Color3.fromRGB(230,176,194))end
    path({{120,-78},{130,-92},{126,-105}})
    -- Compact garden compositions frame the four plots without occupying their paths.
    for index,site in ipairs({{-95,-101},{94,103},{-100,88},{86,-107}})do
        local gx,gz=site[1],site[2]
        local garden=model(root,'CanteiroDaVila'..index)
        for row=1,2 do
            local cz=gz+(row-1)*7
            for i=-7,7 do
                local px=gx+i
                local gy=ground(px,cz)
                part(garden,'TerraPreparada',Vector3.new(1.1,.16,4.8),CFrame.new(px,gy+.07,cz),Color3.fromRGB(101,76,53),Enum.Material.Ground)
                for _,side in ipairs({-1,1})do part(garden,'BordaDeMadeira',Vector3.new(1.1,.4,.25),CFrame.new(px,gy+.22,cz+side*2.5),wood)end
                if i%2==0 then
                    for j=-1,1 do
                        local fy=ground(px,cz+j*1.4)
                        for petal=1,4 do
                            local a=petal*math.pi/2
                            local f=part(garden,'Petala',Vector3.new(.55,.3,.55),CFrame.new(px+math.cos(a)*.3,fy+.9,cz+j*1.4+math.sin(a)*.3),index%2==0 and Color3.fromRGB(240,193,103)or Color3.fromRGB(215,154,182),Enum.Material.SmoothPlastic)
                            f.Shape=Enum.PartType.Ball
                        end
                        part(garden,'Haste',Vector3.new(.12,.8,.12),CFrame.new(px,fy+.4,cz+j*1.4),green)
                    end
                end
            end
        end
        for i=-2,2 do
            local px,pz=gx+i*4,gz-5;local py=ground(px,pz)
            part(garden,'Mourao',Vector3.new(.4,2.7,.4),CFrame.new(px,py+1.2,pz),wood)
            if i<2 then for rail=1,2 do part(garden,'Travessa',Vector3.new(4.1,.22,.2),CFrame.new(px+2,py+rail*.85,pz),trim)end end
        end
        planter(garden,gx-10,gz+3,Color3.fromRGB(235,205,130))
    end
    -- Two orchard pockets give the western farm route a readable occupied edge.
    local orchard=model(root,'PomaresDaVila')
    local TreeKit=require(script.Parent.ForestTreeKit)
    for row,site in ipairs({{-163,43},{-166,-49}})do
        for j=1,6 do
            local ox=site[1]+(j%2)*14;local oz=site[2]+math.floor((j-1)/2)*16
            TreeKit.clone(j%3+1,orchard,Vector3.new(ox,ground(ox,oz),oz),.36+(j%3)*.03,j*.7)
        end
        for j=0,5 do
            local ox,oz=site[1]-10,site[2]-8+j*12;local oy=ground(ox,oz)
            part(orchard,'MouraoDoPomar',Vector3.new(.45,3,.45),CFrame.new(ox,oy+1.4,oz),wood)
            if j<5 then for rail=1,2 do part(orchard,'CercaDoPomar',Vector3.new(.25,.25,12.1),CFrame.new(ox,oy+rail*.95,oz+6),trim)end end
        end
        crate(orchard,CFrame.new(site[1]+20,ground(site[1]+20,site[2])+ .1,site[2]))
    end
    path({{-110,32},{-132,37},{-151,43}})
    path({{-131,-28},{-144,-36},{-153,-49}})
    -- A substantial potting barn anchors the farm side of the village.
    local barn=model(root,'CasaDoJardim');x,z=-147,112
    local floorY=ground(x,z)
    for _,dx in ipairs({-13,13})do for _,dz in ipairs({-11,11})do floorY=math.max(floorY,ground(x+dx,z+dz))end end
    local origin=CFrame.new(x,floorY+.2,z)*CFrame.Angles(0,math.pi/2,0)
    local function beam(name,size,offset,color,material,collision)
        return part(barn,name,size,origin*offset,color,material,collision)
    end
    beam('PisoDePedra',Vector3.new(27,.55,23),CFrame.new(0,0,0),stone,Enum.Material.Cobblestone,true)
    for _,side in ipairs({-1,1})do
        for _,front in ipairs({-1,1})do
            local pos=(origin*CFrame.new(side*12,0,front*10)).Position
            local bottom=ground(pos.X,pos.Z)-.2
            part(barn,'Fundacao',Vector3.new(1.2,floorY+1-bottom,1.2),CFrame.new(pos.X,(bottom+floorY+1)/2,pos.Z),stone,Enum.Material.Sandstone,true)
            beam('Pilar',Vector3.new(.65,10,.65),CFrame.new(side*12,5,front*10),trim,nil,true)
        end
        beam('ParedeLateral',Vector3.new(.35,8.5,20),CFrame.new(side*12,4.5,0),Color3.fromRGB(165,92,65),Enum.Material.WoodPlanks,true)
        for k=-2,2 do beam('Friso',Vector3.new(.18,8.6,.22),CFrame.new(side*12.2,4.5,k*4),trim)end
        beam('Telhado',Vector3.new(14.4,.5,25),CFrame.new(side*6.3,12,0)*CFrame.Angles(0,0,-side*.32),Color3.fromRGB(129,72,57),Enum.Material.WoodPlanks)
        beam('TravessaDoFrontao',Vector3.new(12.8,.4,.45),CFrame.new(side*5.8,11.8,10.8)*CFrame.Angles(0,0,-side*.32),trim)
    end
    beam('ParedeDosFundos',Vector3.new(24,9,.4),CFrame.new(0,4.7,-10),Color3.fromRGB(165,92,65),Enum.Material.WoodPlanks,true)
    beam('Cumeeira',Vector3.new(.65,.65,25.5),CFrame.new(0,14.3,0),trim)
    beam('BancadaDeCultivo',Vector3.new(18,.4,3),CFrame.new(0,3,-6),wood,nil,true)
    for _,side in ipairs({-1,1})do for _,front in ipairs({-1,1})do beam('PeDaBancada',Vector3.new(.4,3,.4),CFrame.new(side*8,1.5,-6+front),wood)end end
    for k=-2,2 do
        local pos=(origin*CFrame.new(k*3.3,3.2,-6)).Position
        planter(barn,pos.X,pos.Z,k%2==0 and Color3.fromRGB(235,190,102)or Color3.fromRGB(215,151,181),pos.Y)
    end
    for k=1,3 do crate(barn,origin*CFrame.new(-8,.5,1+k*2.4))end
    for _,side in ipairs({-1,1})do
        local pos=(origin*CFrame.new(side*10,.3,13)).Position
        planter(barn,pos.X,pos.Z,Color3.fromRGB(238,203,111),floorY+.3)
    end
    local signPos=(origin*CFrame.new(0,9.5,10.7)).Position
    local sign=require(script.Parent.SignKit).create(barn,'Nome','CASA DO JARDIM',signPos,13,green)
    sign:PivotTo(CFrame.new(sign:GetPivot().Position)*origin.Rotation)
    path({{-106,82},{-119,99},{-134,112}})
    -- Garden courts connect the secondary landmarks into a walkable neighborhood.
    for i,site in ipairs({{-126,-78},{128,-30},{126,-115},{-122,12}})do
        local cx,cz=site[1],site[2]
        local court=model(root,'PatioDeJardinagem'..i)
        for dx=-11,11,3 do for dz=-8,8,3 do
            if (dx/12)^2+(dz/9)^2<1 then
                local py=ground(cx+dx,cz+dz)
                local region=Region3.new(Vector3.new(cx+dx-2,py-4,cz+dz-2),Vector3.new(cx+dx+2,py+2,cz+dz+2)):ExpandToGrid(4)
                workspace.Terrain:ReplaceMaterial(region,4,Enum.Material.Grass,Enum.Material.Ground)
                workspace.Terrain:ReplaceMaterial(region,4,Enum.Material.LeafyGrass,Enum.Material.Ground)
            end
        end end
        for _,side in ipairs({-1,1})do
            local bx,bz=cx+side*12,cz+7;local by=ground(bx,bz)
            local cf=CFrame.new(bx,by,bz)*CFrame.Angles(0,side*.3,0)
            part(court,'Assento',Vector3.new(4.5,.3,1.5),cf*CFrame.new(0,1.6,0),trim)
            part(court,'Encosto',Vector3.new(4.5,1.3,.23),cf*CFrame.new(0,2.2,.65),wood)
            for _,leg in ipairs({-1,1})do part(court,'PeDoBanco',Vector3.new(.3,1.6,1.2),cf*CFrame.new(leg*1.8,.8,0),wood)end
            planter(court,bx+side*3,bz,Color3.fromRGB(239,184,115))
        end
    end
    -- Keep existing trees clear of the new nursery shelving and its arrival path.
    for _,tree in ipairs(workspace:GetDescendants())do
        if tree:IsA('Model') and (tree.Name=='Arvore' or tree:GetAttribute('ArteFloresta')==true) then
            local p=tree:GetPivot().Position
            if (math.abs(p.X+126)<13 and math.abs(p.Z+78)<12) or (math.abs(p.X+147)<19 and math.abs(p.Z-112)<19) then
                if not tree:GetAttribute('BeforeNurseryPivot')then tree:SetAttribute('BeforeNurseryPivot',tree:GetPivot())end
                local targetZ=p.Z>60 and 143 or -96
                tree:PivotTo(tree:GetPivot()+Vector3.new(-181-p.X,0,targetZ-p.Z))
            end
        end
    end
    root:SetAttribute('Ready',true)
    return root
end
return L
