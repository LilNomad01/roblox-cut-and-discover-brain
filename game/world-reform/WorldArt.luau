-- Shared visual construction for runtime and editor preview. No player economy.
local A={}
local Terrain=workspace.Terrain
local C={rock=Color3.fromRGB(100,116,112),shadow=Color3.fromRGB(71,88,87),moss=Color3.fromRGB(93,135,76),fern=Color3.fromRGB(89,150,75),wood=Color3.fromRGB(113,78,48)}
local function part(parent,name,size,cf,color,material,collide,class)
    local p=Instance.new(class or 'Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
    p.Material=material or Enum.Material.Slate;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=collide==true;p.Parent=parent
    return p
end
local function folder(parent,name)
    local f=Instance.new('Folder');f.Name=name;f.Parent=parent;return f
end
function A.rock(parent,pos,scale,yaw)
    local m=Instance.new('Model');m.Name='RochaEstratificada';m.Parent=parent
    for i=1,3 do
        local s=Vector3.new(3.8-i*.52,1.1+i*.35,2.8-i*.24)*scale
        local p=part(m,'Estrato',s,CFrame.new(pos+Vector3.new((i-2)*.22*scale,(i-1)*.56*scale,0))*CFrame.Angles(.05*i,yaw,.10*(i-2)),C.rock:Lerp(C.shadow,i*.13),Enum.Material.Slate,false,i==2 and 'CornerWedgePart' or 'WedgePart')
        p.CastShadow=scale>1.5
    end
    part(m,'Musgo',Vector3.new(1.8,.18,1.4)*scale,CFrame.new(pos+Vector3.new(-.3,1.3,.1)*scale)*CFrame.Angles(.1,yaw,.13),C.moss,Enum.Material.Grass,false,'WedgePart')
    return m
end
local function fern(parent,pos,scale,yaw)
    local m=Instance.new('Model');m.Name='Samambaia';m.Parent=parent
    for i=0,5 do
        local a=yaw+i*math.pi/3
        for j=1,2 do
            local cf=CFrame.new(pos)*CFrame.Angles(0,a,0)*CFrame.new(0,.30*j*scale,-.4*j*scale)*CFrame.Angles(-.38,0,.18)
            local p=part(m,'Fronda',Vector3.new(.6,.1,1.3)*scale,cf,C.fern:Lerp(C.moss,j*.2),Enum.Material.LeafyGrass,false,'WedgePart');p.CastShadow=false
        end
    end
end
local function flowers(parent,pos,scale)
    for i=1,3 do
        local p=pos+Vector3.new(math.sin(i*3)*scale,.45*scale,math.cos(i*3)*scale)
        part(parent,'FlorDaPradaria',Vector3.new(.6,.16,.6)*scale,CFrame.new(p),i==2 and Color3.fromRGB(237,191,99) or Color3.fromRGB(200,155,214),Enum.Material.SmoothPlastic,false)
        part(parent,'Haste',Vector3.new(.09,.6,.09)*scale,CFrame.new(p-Vector3.yAxis*.3*scale),C.fern,Enum.Material.Grass,false)
    end
end
function A.flowerPatch(parent,pos,scale) flowers(parent,pos,scale) end
function A.plantPatch(parent,pos,scale,yaw)
    fern(parent,pos,scale,yaw)
    flowers(parent,pos+Vector3.new(1.6,0,.6),scale)
    A.rock(parent,pos+Vector3.new(-1,0,-.9),scale*.55,yaw)
end
function A.grassBlend(x,z)
    local front=175+math.sin(x*.018)*17+math.noise(x*.024,19)*24
    local width=278+math.noise(z*.013,35)*22
    local a=math.clamp((-z-front)/64,0,1)
    local b=math.clamp((width-math.abs(x))/34,0,1)
    local function smooth(t)return t*t*(3-2*t)end
    return smooth(a)*smooth(b),.38+.62*math.min(a,b)
end
function A.foundation()
    -- Shared, saved Terrain already supplies the floor and organic biome blend.
    -- No rectangular slabs, isolated dirt squares or global flattening during Play.
end
function A.transition(root,scenery)
    -- Replace the old bead-like border with grouped botanical planting.
    for _,p in ipairs(root:GetDescendants())do
        if p:IsA('BasePart')and(p.Name=='FlorDaBorda'or p.Name=='PedraDaBorda')then p:Destroy()end
    end
    local f=folder(root,'TransicaoPradariaMata')
    local pack=game.ReplicatedStorage.GramaAssets.GrassPack
    local rng=Random.new(2031)
    for i=1,115 do
        local t=rng:NextNumber();local z=-88-t*139
        local width=17+t*28;local x=(i%2==0 and -1 or 1)*rng:NextNumber(10,width)
        if scenery.commerceReserved and scenery.commerceReserved(x,z,14) then continue end
        local y=scenery.height(x,z)
        if i%6==0 then A.rock(f,Vector3.new(x,y+.05,z),rng:NextNumber(.6,1.2),i*.7)
        elseif i%3==0 then fern(f,Vector3.new(x,y,z),.5+t*.5,i)
        else
            local template=pack:FindFirstChild('Grass_A01_'..(t>.7 and 'TALL' or 'SHORT'))
            if template then
                local p=template:Clone();p.Name='RelvaDeTransicao';p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false
                p.Size*=.45+t*.45;p.CFrame=CFrame.new(x,y+p.Size.Y/2-.08,z)*CFrame.Angles(0,i*2.4,0);p.Parent=f
            end
            if t<.65 and i%4==0 then flowers(f,Vector3.new(x,y,z),.7) end
        end
        if i%25==0 then task.wait()end
    end
    for i=1,15 do
        local z=-112-i*6.4;local x=(i%2==0 and -1 or 1)*(20+math.sin(i)*7)
        scenery.hero(root.ArvoresModulares,i%5+1,x,z,.28+i*.025,i*.8)
    end
end
function A.water(root,scenery)
    local f=folder(root,'RiachoNatural')
    -- Native water occupies a carved continuous channel; no translucent rectangles.
    for z=-756,-336,4 do
        local x,w=scenery.riverX(z),scenery.riverHalfWidth(z)
        local depth=2.5+math.sin(z*.04)*.7
        Terrain:FillBlock(CFrame.new(x,-4,z),Vector3.new(w*2+8,8,6),Enum.Material.Ground)
        Terrain:FillBlock(CFrame.new(x,2,z),Vector3.new(w*2,10,6),Enum.Material.Air)
        Terrain:FillBlock(CFrame.new(x,-depth*.5,z),Vector3.new(w*2,depth,6),Enum.Material.Water)
        -- Bank shape and material alternate, with deliberately unequal margins.
        for side=-1,1,2 do
            local bx=x+side*(w+1.4)
            Terrain:FillBall(Vector3.new(bx,-2.1,z),3.2+math.sin(z*.13+side)*.65,Enum.Material.Ground)
        end
        if z%16==0 then task.wait() end
    end
    -- Water caps taper into reed pools at both ends.
    for _,z in ipairs({-756,-336})do
        Terrain:FillBall(Vector3.new(scenery.riverX(z),-3,z),9,Enum.Material.Ground)
        Terrain:FillBlock(CFrame.new(scenery.riverX(z),0,z),Vector3.new(13,5,10),Enum.Material.Air)
        Terrain:FillBlock(CFrame.new(scenery.riverX(z),-1.5,z),Vector3.new(12,2.5,9),Enum.Material.Water)
    end
    Terrain.WaterColor=Color3.fromRGB(58,129,123);Terrain.WaterTransparency=.32;Terrain.WaterReflectance=.18;Terrain.WaterWaveSize=.11;Terrain.WaterWaveSpeed=7
    for i=1,42 do
        local z=-750+i*9.6;local x=scenery.riverX(z);local w=scenery.riverHalfWidth(z);local side=i%2==0 and -1 or 1
        if math.abs(z+460)<12 then continue end
        local bx=x+side*(w+1.8)
        if i%3==0 then A.rock(f,Vector3.new(x+side*w*.65,-.35,z),.6+i%4*.18,i)
        else fern(f,Vector3.new(bx,scenery.height(bx,z),z),.7,i) end
        if i%7==0 then
            local foam=part(f,'Correnteza',Vector3.new(1.5,.025,2.2),CFrame.new(x+.8,.03,z)*CFrame.Angles(0,.2,0),Color3.fromRGB(195,224,203),Enum.Material.SmoothPlastic,false)
            foam.Transparency=.72;foam:SetAttribute('WaterCurrent',true)
        end
    end
end
function A.oldCave(root,scenery)
    local cave=root.DescobertasDaMata.GrutaDasPedrasAzuis
    for _,p in ipairs(cave:GetChildren())do
        if p:IsA('BasePart') and (p.Name=='RochaDaEncosta' or p.Name=='RochedoDoPortal' or p.Name=='ArcoIrregular' or p.Name=='MusgoDoPortal')then p:Destroy()end
    end
    -- Broad, angled geological layers emerge from the hillside around the real opening.
    for i=0,4 do for _,side in ipairs({-1,1})do
        A.rock(cave,Vector3.new(-67+side*(9.3+i*1.5),1+i*.75,-707-i*4),2+i*.15,side*.5+i*.2)
    end end
    for i=0,3 do
        local p=part(cave,'LajeFraturada',Vector3.new(8,3.2,8),CFrame.new(-76+i*5.8,11.8+math.sin(i)*.9,-709-i*.3)*CFrame.Angles(.07,.1*i,(i-1.4)*.07),C.rock:Lerp(C.shadow,i*.08),Enum.Material.Slate,true,'WedgePart')
        fern(cave,p.Position+Vector3.new(-1,1.7,1),.7,i)
    end
end
function A.blockGrass(x,z)
    return (x>-224 and x<-206 and z>-464 and z<-440)
end
function A.underground(root,scenery,spawnGrass,addSecret)
    local cave=Instance.new('Model');cave.Name='CriptaDasRaizes';cave.Parent=root
    local x,z=-215,-452
    -- A solid subsurface body provides a ceiling, continuous walls and a safety floor.
    Terrain:FillBlock(CFrame.new(x,-24,-486),Vector3.new(57,48,100),Enum.Material.Rock)
    Terrain:FillBlock(CFrame.new(x,-1.2,-486),Vector3.new(57,4,100),Enum.Material.Grass)
    for i=0,20 do
        local sy=.65-i*1.2;local sz=-443-i*2
        Terrain:FillBlock(CFrame.new(x,sy+4.7,sz),Vector3.new(12,10,3.2),Enum.Material.Air)
        part(cave,'DegrauNatural',Vector3.new(11.5,1.2,2.2),CFrame.new(x,sy-.6,sz),i%3==0 and C.rock or C.shadow,Enum.Material.Slate,true)
    end
    -- Tunnel and a side niche, then the wider underground chamber.
    Terrain:FillBlock(CFrame.new(x,-19.3,-490),Vector3.new(12,11,22),Enum.Material.Air)
    Terrain:FillBlock(CFrame.new(x+7,-20,-487),Vector3.new(15,9,7),Enum.Material.Air)
    Terrain:FillBall(Vector3.new(x,-20,-511),15,Enum.Material.Air)
    part(cave,'PisoDaCamara',Vector3.new(33,1,32),CFrame.new(x,-26.5,-511),C.shadow,Enum.Material.Slate,true)
    part(cave,'PisoDoTunel',Vector3.new(12,1,17),CFrame.new(x,-24.7,-487),C.shadow,Enum.Material.Slate,true)
    part(cave,'PisoDoNicho',Vector3.new(15,1,7),CFrame.new(x+7,-24.7,-487),C.shadow,Enum.Material.Slate,true)
    for i=1,3 do part(cave,'LigacaoTunel',Vector3.new(11.5,.6,2.2),CFrame.new(x,-24.5-i*.6,-493-i*2),C.shadow,Enum.Material.Slate,true) end
    local gate=part(cave,'TampaDeRaizes',Vector3.new(14,.45,22),CFrame.new(x,1,-452),Color3.fromRGB(94,142,70),Enum.Material.Grass,true)
    gate:SetAttribute('UndergroundEntrance',true)
    local core=part(cave,'CoracaoDasRaizes',Vector3.new(2.4,7,2.2),CFrame.new(x,-21.7,-519)*CFrame.Angles(.08,.3,.13),Color3.fromRGB(97,181,165),Enum.Material.Glass,false,'WedgePart')
    local light=Instance.new('PointLight');light.Color=Color3.fromRGB(133,217,185);light.Range=26;light.Brightness=1.4;light.Parent=core
    for i=1,16 do
        local a=i*2.4;local radius=11+i%3
        local pos=Vector3.new(x+math.cos(a)*radius,-25.8,-511+math.sin(a)*radius)
        A.rock(cave,pos,.65+i%3*.25,a)
        local m=part(cave,'CogumeloLuminoso',Vector3.new(.8,.28,.8),CFrame.new(pos+Vector3.yAxis*.8),Color3.fromRGB(126,208,177),Enum.Material.Neon,false);m.Shape=Enum.PartType.Ball
    end
    for i=1,9 do
        local sz=-445-i*6
        part(cave,'RaizAntiga',Vector3.new(.3,4,1),CFrame.new(x+(i%2==0 and -5.5 or 5.5),-i*1.6,sz)*CFrame.Angles(.3,0,.2),C.wood,Enum.Material.Wood,false)
    end
    local panel=require(script.Parent.SignKit).create(cave,'MemoriaAntiga','A floresta cresceu.\nAs raizes guardaram a memoria.',Vector3.new(x,-22,-523),8,Color3.fromRGB(119,190,166))
    -- The underground sign has a rock mount rather than surface-height posts.
    for _,v in ipairs(panel:GetChildren())do if v.Name=='Poste'then v:Destroy()end end
    local required={}
    local secret=addSecret({id='cripta_raizes_bau',kind='chest',rarity='Lendario',x=x+6,z=-514,groundY=-26,
        cutPoint=Vector3.new(x,.8,z),cutRadius=15,revealAt=12,gate=gate,requiredGrass=required})
    addSecret({id='cripta_raizes_reliquia',kind='artifact',x=x-6,z=-515,groundY=-26,
        cutPoint=Vector3.new(x,.8,z),cutRadius=15,revealAt=12,requiredGrass=required})
    local n=0
    for dx=-4.2,4.2,4.2 do for dz=-6,6,4 do
        local ok,rec=spawnGrass(x+dx,z+dz,true)
        assert(ok and rec,'Entrance requires all twelve authored clumps')
        required[rec.id]=true;n+=1
    end end
    cave:SetAttribute('RequiredClumps',n)
    for i=1,5 do A.rock(cave,Vector3.new(x+(i%2==0 and -8 or 8),.5,z+(i-3)*3),.45,i)end
    return secret
end
function A.revealGate(gate)
    if gate:GetAttribute('Revealing')then return end
    gate:SetAttribute('Revealing',true)
    local Tween=game:GetService('TweenService')
    task.delay(.2,function()
        if not gate.Parent then return end
        local dust=Instance.new('ParticleEmitter');dust.Color=ColorSequence.new(Color3.fromRGB(158,145,104));dust.Lifetime=NumberRange.new(.35,.55);dust.Speed=NumberRange.new(2,5);dust.SpreadAngle=Vector2.new(80,80);dust.Rate=0;dust.Size=NumberSequence.new(.22);dust.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.25),NumberSequenceKeypoint.new(1,1)});dust.Parent=gate;dust:Emit(16)
    end)
    task.delay(.55,function()
        if not gate.Parent then return end
        Tween:Create(gate,TweenInfo.new(.45,Enum.EasingStyle.Cubic,Enum.EasingDirection.InOut),{Transparency=1}):Play()
    end)
    task.delay(1,function()
        if not gate.Parent then return end
        gate.CanCollide=false;gate.CanQuery=false;gate.Parent:SetAttribute('Open',true)
        local falling=Instance.new('ParticleEmitter');falling.EmissionDirection=Enum.NormalId.Bottom;falling.Lifetime=NumberRange.new(.35);falling.Speed=NumberRange.new(2,3);falling.Size=NumberSequence.new(.12);falling.Rate=0;falling.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.4),NumberSequenceKeypoint.new(1,1)});falling.Parent=gate;falling:Emit(6)
    end)
end
function A.polish(root,scenery)
    local f=folder(root,'AfloramentosDaMata')
    for i=1,26 do
        local a=i*2.399;local x=math.cos(a)*(125+i%5*24);local z=-244-i*18
        if not scenery.onPath(x,z,8) and not scenery.inRiver(x,z,14) and not A.blockGrass(x,z) and not scenery.commerceReserved(x,z,18) then
            A.rock(f,Vector3.new(x,scenery.height(x,z),z),.7+i%4*.3,a)
        end
    end
end
return A
