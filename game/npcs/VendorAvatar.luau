-- Roblox assets already worn by the supplied project's avatar. IDs were read
-- from Humanoid:GetAppliedDescription(); no catalog IDs are invented.
-- [Claude 2026-11-11] cada NPC ganhou visual próprio (cores, proporções e acessórios feitos de peças
-- nativas). Os IDs do catálogo continuam os mesmos de antes; nada novo foi inventado.
-- Avatar.create(tipo): "Jardineiro" (padrão), "Guto", "Lia" ou "Teca".
local Players=game:GetService("Players")
local Storage=game:GetService("ServerStorage")
local Avatar={}
local templates={}

local function rgb(r,g,b) return Color3.fromRGB(r,g,b) end
-- peça presa (WeldConstraint) a uma parte do corpo; acompanha a animação procedural
local function prop(model,base,name,size,cf,color,material,shape)
    local p=Instance.new("Part")
    p.Name,p.Size,p.Color=name,size,color
    if shape then p.Shape=shape end
    p.CFrame=cf
    p.CanCollide,p.CanTouch,p.CanQuery,p.Massless=false,false,false,true
    p.Anchored=false
    p.Material=material or Enum.Material.SmoothPlastic
    p.TopSurface,p.BottomSurface=Enum.SurfaceType.Smooth,Enum.SurfaceType.Smooth
    p.Parent=model
    local w=Instance.new("WeldConstraint") w.Part0,w.Part1,w.Parent=base,p,p
    return p
end
local CYL=Enum.PartType.Cylinder
local BALL=Enum.PartType.Ball
local DEITADO=CFrame.Angles(0,0,math.pi/2) -- cilindro com o eixo na vertical

local LOOKS={
    Jardineiro={
        nome="Jardineiro", papel="Serviços do jardim",
        pele=rgb(218,175,132), cabelo=rgb(95,72,48), camisa=rgb(66,109,82), calca=rgb(58,82,128),
        altura=1.03, largura=.95,
    },
    Guto={
        nome="Guto", papel="Mochileiro · mochilas",
        pele=rgb(198,140,99), cabelo=rgb(52,38,30), camisa=rgb(99,202,112), calca=rgb(120,98,70),
        altura=1.0, largura=1.02,
    },
    Lia={
        nome="Lia", papel="Exploradora · equipamentos",
        pele=rgb(232,190,150), cabelo=rgb(150,82,45), camisa=rgb(90,175,235), calca=rgb(70,80,95),
        altura=.98, largura=.9,
    },
    Teca={
        nome="Teca", papel="Botânica · trocas e pesquisa",
        pele=rgb(141,96,66), cabelo=rgb(40,30,25), camisa=rgb(155,220,126), calca=rgb(90,70,60),
        altura=.96, largura=.92,
    },
}
Avatar.Looks=LOOKS

local function acessorios(kind,rig,look)
    local head=rig:FindFirstChild("Head")
    local torso=rig:FindFirstChild("UpperTorso")
    local hand=rig:FindFirstChild("RightHand")
    local root=rig.PrimaryPart
    local up=head.CFrame
    -- referência alinhada ao corpo (frente = -Z do HumanoidRootPart)
    local function noCorpo(pos) return root.CFrame.Rotation+pos end
    if kind=="Jardineiro" then
        prop(rig,head,"AbaChapeu",Vector3.new(.12,2.65,2.65),up*CFrame.new(0,.7,0)*DEITADO,rgb(197,169,111),Enum.Material.Fabric,CYL)
        prop(rig,head,"CopaChapeu",Vector3.new(.7,1.8,1.8),up*CFrame.new(0,1.05,0)*DEITADO,rgb(177,146,88),Enum.Material.Fabric,CYL)
        prop(rig,head,"FitaChapeu",Vector3.new(.14,1.84,1.84),up*CFrame.new(0,.8,0)*DEITADO,rgb(61,92,69),Enum.Material.Fabric,CYL)
        -- macacão: peitilho e alças por cima da camisa
        local t=torso.CFrame
        prop(rig,torso,"Peitilho",Vector3.new(1.1,.8,.08),t*CFrame.new(0,-.25,-torso.Size.Z/2-.03),look.calca,Enum.Material.Fabric)
        for _,sx in ipairs({-.42,.42}) do
            prop(rig,torso,"Alca",Vector3.new(.16,1.1,.06),t*CFrame.new(sx,.25,-torso.Size.Z/2-.03),look.calca,Enum.Material.Fabric)
        end
        prop(rig,torso,"BolsoFerramentas",Vector3.new(.45,.32,.09),t*CFrame.new(0,-.2,-torso.Size.Z/2-.08),rgb(44,62,98),Enum.Material.Fabric)
        -- rastelo na mão direita, em pé ao lado do corpo
        local hp=hand.Position
        local cabo=prop(rig,hand,"CaboRastelo",Vector3.new(.16,3.6,.16),noCorpo(hp+Vector3.new(0,-.1,0)),rgb(140,98,60),Enum.Material.Wood)
        local base=cabo.CFrame*CFrame.new(0,-1.8,0)
        prop(rig,hand,"BarraRastelo",Vector3.new(1.6,.16,.16),base,rgb(120,124,130),Enum.Material.Metal)
        for i=-3,3 do
            prop(rig,hand,"DenteRastelo",Vector3.new(.06,.3,.06),base*CFrame.new(i*.24,-.2,-.04),rgb(150,154,160),Enum.Material.Metal)
        end
    elseif kind=="Guto" then
        -- boné verde com aba amarela
        prop(rig,head,"Bone",Vector3.new(1.5,.9,1.5),up*CFrame.new(0,.78,.04),look.camisa,Enum.Material.Fabric,BALL)
        prop(rig,head,"AbaBone",Vector3.new(1.1,.1,.85),up*CFrame.new(0,.62,-.85)*CFrame.Angles(math.rad(-8),0,0),rgb(255,211,74),Enum.Material.Fabric)
        prop(rig,head,"BotaoBone",Vector3.new(.2,.14,.2),up*CFrame.new(0,1.23,.04),rgb(255,211,74),Enum.Material.Fabric,BALL)
        -- alças da mochila na frente do peito
        local t=torso.CFrame
        for _,sx in ipairs({-.38,.38}) do
            prop(rig,torso,"AlcaMochila",Vector3.new(.2,1.15,.08),t*CFrame.new(sx,.15,-torso.Size.Z/2-.03),rgb(255,211,74),Enum.Material.Fabric)
        end
        prop(rig,torso,"Cantil",Vector3.new(.38,.5,.38),t*CFrame.new(.75,-.55,-.2)*DEITADO,rgb(80,120,150),Enum.Material.Metal,CYL)
    elseif kind=="Lia" then
        -- chapéu de exploradora: aba larga, copa e fita laranja
        prop(rig,head,"AbaChapeu",Vector3.new(.1,2.5,2.5),up*CFrame.new(0,.72,0)*DEITADO,rgb(196,170,120),Enum.Material.Fabric,CYL)
        prop(rig,head,"CopaChapeu",Vector3.new(.75,1.45,1.45),up*CFrame.new(0,1.05,0)*DEITADO,rgb(184,156,104),Enum.Material.Fabric,CYL)
        prop(rig,head,"FitaChapeu",Vector3.new(.16,1.49,1.49),up*CFrame.new(0,.85,0)*DEITADO,rgb(255,168,71),Enum.Material.Fabric,CYL)
        -- rabo de cavalo
        prop(rig,head,"RaboDeCavalo",Vector3.new(.45,.8,.45),up*CFrame.new(0,-.1,.62),look.cabelo,Enum.Material.SmoothPlastic,BALL)
        -- lenço laranja no pescoço e binóculo pendurado
        local t=torso.CFrame
        prop(rig,torso,"Lenco",Vector3.new(.35,1.25,1.0),t*CFrame.new(0,torso.Size.Y/2-.05,0)*DEITADO,rgb(255,168,71),Enum.Material.Fabric,CYL)
        for _,sx in ipairs({-.13,.13}) do
            prop(rig,torso,"Binoculo",Vector3.new(.38,.2,.2),t*CFrame.new(sx,-.15,-torso.Size.Z/2-.12)*CFrame.Angles(0,math.pi/2,0),rgb(45,52,60),Enum.Material.Metal,CYL)
        end
    elseif kind=="Teca" then
        -- chapéu de palha com flores e coque
        prop(rig,head,"AbaChapeu",Vector3.new(.1,2.3,2.3),up*CFrame.new(0,.7,0)*DEITADO,rgb(222,196,128),Enum.Material.Fabric,CYL)
        prop(rig,head,"CopaChapeu",Vector3.new(.6,1.4,1.4),up*CFrame.new(0,.98,0)*DEITADO,rgb(210,182,112),Enum.Material.Fabric,CYL)
        local flores={rgb(191,147,228),rgb(255,150,190),rgb(255,221,94)}
        for i,c in ipairs(flores) do
            local a=math.rad(-40+i*28)
            prop(rig,head,"FlorChapeu",Vector3.new(.3,.3,.3),up*CFrame.new(math.sin(a)*.72,.92,-math.cos(a)*.72),c,Enum.Material.SmoothPlastic,BALL)
        end
        prop(rig,head,"Coque",Vector3.new(.6,.6,.6),up*CFrame.new(0,.15,.6),look.cabelo,Enum.Material.SmoothPlastic,BALL)
        -- regador na mão direita
        local hp=hand.Position
        local corpo=prop(rig,hand,"Regador",Vector3.new(.75,.7,.7),noCorpo(hp+Vector3.new(0,-.55,0))*DEITADO,rgb(120,170,160),Enum.Material.Metal,CYL)
        prop(rig,hand,"BicoRegador",Vector3.new(.12,.12,.8),noCorpo(hp+Vector3.new(0,-.45,-.6))*CFrame.Angles(math.rad(-30),0,0),rgb(110,160,150),Enum.Material.Metal)
        prop(rig,hand,"AlcaRegador",Vector3.new(.08,.35,.45),noCorpo(hp+Vector3.new(0,-.08,0)),rgb(95,140,130),Enum.Material.Metal)
    end
end

local function build(kind)
    local look=LOOKS[kind] or LOOKS.Jardineiro
    local d=Instance.new("HumanoidDescription")
    d.Head,d.Torso=10725826963,376532000
    d.LeftArm,d.RightArm=376530220,376531012
    d.LeftLeg,d.RightLeg=376531300,376531703
    d.HairAccessory="376524487"
    d.HeightScale,d.WidthScale,d.DepthScale=look.altura,look.largura,.94
    d.BodyTypeScale,d.ProportionScale=.15,0
    d.HeadColor,d.LeftArmColor,d.RightArmColor=look.pele,look.pele,look.pele
    d.TorsoColor=look.camisa
    d.LeftLegColor,d.RightLegColor=look.calca,look.calca
    local rig=Players:CreateHumanoidModelFromDescriptionAsync(d,Enum.HumanoidRigType.R15)
    d:Destroy() rig.Name="VendorAvatarTemplate"
    for _,v in ipairs(rig:GetDescendants()) do
        if v:IsA("LuaSourceContainer") then v:Destroy()
        elseif v:IsA("BasePart") then
            v.CanCollide,v.CanTouch,v.CanQuery,v.Massless=false,false,false,true
            if v.Parent:IsA("Accessory") then
                -- sem a textura própria, a cor do cabelo de cada NPC aparece (a malha continua a mesma)
                v.Color=look.cabelo
                if v:IsA("MeshPart") then v.TextureID="" end
                local sm=v:FindFirstChildOfClass("SpecialMesh") if sm then sm.TextureId="" sm.VertexColor=Vector3.new(1,1,1) end
            end
        end
    end
    -- mangas: os braços de cima usam a cor da camisa
    for _,n in ipairs({"LeftUpperArm","RightUpperArm"}) do
        local a=rig:FindFirstChild(n) if a then a.Color=look.camisa end
    end
    local root=rig:FindFirstChild("HumanoidRootPart") assert(root,"Avatar has no root")
    root.Anchored=true rig.PrimaryPart=root
    local hum=rig:FindFirstChildOfClass("Humanoid")
    hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
    hum.BreakJointsOnDeath=false hum.WalkSpeed=0
    acessorios(kind,rig,look)
    rig:SetAttribute("AvatarVendedor",true)
    rig:SetAttribute("NpcTipo",kind)
    rig:SetAttribute("NpcNome",look.nome)
    rig:SetAttribute("NpcPapel",look.papel)
    rig.Parent=Storage.GameAssets
    return rig
end

function Avatar.create(kind)
    kind=LOOKS[kind] and kind or "Jardineiro"
    if not templates[kind] then templates[kind]=build(kind) templates[kind].Name="VendorAvatarTemplate_"..kind end
    local clone=templates[kind]:Clone() clone.Name="LobbyGardenerNPC" return clone
end
return Avatar
