-- Modular native wood signs; labels remain readable from either approach.
local S={}
local function piece(parent,name,size,cf,color,material)
    local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
    p.Material=material or Enum.Material.Wood;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=parent
    return p
end
function S.create(parent,name,text,pos,width,accent)
    width=math.clamp(width or 8,5,12)
    local m=Instance.new('Model');m.Name=name;m:SetAttribute('WorldSign',true)
    local query=RaycastParams.new();query.FilterType=Enum.RaycastFilterType.Include;query.FilterDescendantsInstances={workspace.Terrain}
    local hit=workspace:Raycast(Vector3.new(pos.X,220,pos.Z),Vector3.new(0,-300,0),query)
    local floorY=hit and hit.Position.Y or .8
    local brown=Color3.fromRGB(119,77,44)
    local panel=piece(m,'Tabua',Vector3.new(width,2.3,.36),CFrame.new(pos),brown)
    for _,side in ipairs({-1,1})do
        piece(m,'Borda',Vector3.new(width+.16,.15,.4),CFrame.new(pos+Vector3.new(0,side*1.12,0)),Color3.fromRGB(173,125,70))
        piece(m,'Suporte',Vector3.new(.22,1.65,.24),CFrame.new(pos+Vector3.new(side*(width*.5-.35),0,.24)),Color3.fromRGB(63,66,58),Enum.Material.Metal)
        local bottom=pos.Y-1.15
        local h=math.max(.5,bottom-floorY)
        piece(m,'Poste',Vector3.new(.35,h,.35),CFrame.new(pos.X+side*width*.33,floorY+h/2,pos.Z+.28),brown)
        for _,y in ipairs({-.7,.7})do
            local pin=piece(m,'Prego',Vector3.new(.12,.12,.1),CFrame.new(pos+Vector3.new(side*(width*.5-.35),y,-.23)),Color3.fromRGB(80,79,67),Enum.Material.Metal)
            pin.Shape=Enum.PartType.Ball
        end
    end
    piece(m,'Faixa',Vector3.new(.18,1.65,.4),CFrame.new(pos+Vector3.new(-width/2+.75,0,0)),accent or Color3.fromRGB(232,182,81))
    for _,face in ipairs({Enum.NormalId.Front,Enum.NormalId.Back})do
        local gui=Instance.new('SurfaceGui');gui.Face=face;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=45;gui.ZOffset=.05;gui.LightInfluence=.65;gui.MaxDistance=0;gui.Parent=panel
        local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(.85,.78);t.Position=UDim2.fromScale(.1,.11);t.BackgroundTransparency=1
        t.Font=Enum.Font.FredokaOne;t.TextScaled=true;t.TextWrapped=true;t.TextColor3=Color3.fromRGB(255,244,208);t.TextStrokeColor3=Color3.fromRGB(69,47,31);t.TextStrokeTransparency=.4;t.Text=text;t.Parent=gui
    end
    m.PrimaryPart=panel;m.Parent=parent
    return m
end
return S
