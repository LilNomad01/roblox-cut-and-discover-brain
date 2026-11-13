-- Native topographic map from baked Terrain samples. No secret coordinates or new remotes.
local Players=game:GetService('Players')
local Run=game:GetService('RunService')
local Input=game:GetService('UserInputService')
local editorPreview=not Run:IsRunning()
local previewSignal
local player=Players.LocalPlayer
local playerGui
if editorPreview then
    -- Native Studio UI preview, using the same renderer and Terrain data as Play.
    -- It has no character, progression, network requests or rewards.
    previewSignal=Instance.new('BindableEvent')
    player={GetAttribute=function()return nil end,GetAttributeChangedSignal=function()return previewSignal.Event end}
    playerGui=game:GetService('StarterGui')
else playerGui=player:WaitForChild('PlayerGui')end
local Data=require(game.ReplicatedStorage:WaitForChild('Shared'):WaitForChild('WorldMapData'))
local old=playerGui:FindFirstChild('TopographicRadar')
if old then old:Destroy()end
local C={paper=Color3.fromRGB(255,245,213),ink=Color3.fromRGB(53,48,36),green=Color3.fromRGB(68,117,78),gold=Color3.fromRGB(226,187,91),water=Color3.fromRGB(72,139,151)}
local heights,materials={},{}
for z,row in ipairs(Data.rows)do
    heights[z]={};materials[z]={}
    for x=1,Data.nx do
        local start=(x-1)*3+1
        heights[z][x]=tonumber(row:sub(start,start+1),16)-32
        materials[z][x]=row:sub(start+2,start+2)
    end
end
local function sample(x,z)
    local u=(x-Data.minX)/(Data.maxX-Data.minX)*(Data.nx-1)+1
    local v=(z-Data.minZ)/(Data.maxZ-Data.minZ)*(Data.nz-1)+1
    if u<1 or v<1 or u>Data.nx or v>Data.nz then return -4,'v'end
    local ix,iz=math.min(math.floor(u),Data.nx-1),math.min(math.floor(v),Data.nz-1)
    local tx,tz=u-ix,v-iz
    local a=heights[iz][ix]*(1-tx)+heights[iz][ix+1]*tx
    local b=heights[iz+1][ix]*(1-tx)+heights[iz+1][ix+1]*tx
    return a*(1-tz)+b*tz,materials[math.clamp(math.floor(v+.5),1,Data.nz)][math.clamp(math.floor(u+.5),1,Data.nx)]
end
local function make(class,parent,name,properties)
    local o=Instance.new(class);o.Name=name
    for k,v in pairs(properties or{})do o[k]=v end
    o.Parent=parent;return o
end
local function corner(o,r)make('UICorner',o,'Corner',{CornerRadius=UDim.new(0,r)})end
local function outline(o,color,width)make('UIStroke',o,'Outline',{Color=color,Thickness=width,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})end
local function text(parent,name,value,pos,size,fontSize,color)
    return make('TextLabel',parent,name,{Text=value,Position=pos,Size=size,BackgroundTransparency=1,TextColor3=color or C.ink,TextSize=fontSize,Font=Enum.Font.FredokaOne})
end
local function button(parent,name,value,pos,size)
    local b=make('TextButton',parent,name,{Text=value,Position=pos,Size=size,BackgroundColor3=C.paper,TextColor3=C.ink,TextSize=16,Font=Enum.Font.FredokaOne,AutoButtonColor=true,Selectable=true,BorderSizePixel=0})
    corner(b,10);outline(b,C.ink,2);return b
end
local gui=make('ScreenGui',playerGui,'TopographicRadar',{ResetOnSpawn=false,IgnoreGuiInset=false,DisplayOrder=14,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
gui:SetAttribute('EditorOnlyNavigationPreview',editorPreview)
local mini=make('Frame',gui,'MiniRadar',{AnchorPoint=Vector2.new(1,1),BackgroundColor3=C.paper,Size=UDim2.fromOffset(186,222),Position=UDim2.new(1,-18,1,-14),BorderSizePixel=0})
corner(mini,22);outline(mini,C.ink,3)
local miniTitle=text(mini,'Title','EXPLORAR',UDim2.fromOffset(10,7),UDim2.new(1,-20,0,22),15)
local circle=make('CanvasGroup',mini,'Terrain',{Position=UDim2.fromOffset(11,34),Size=UDim2.fromOffset(164,164),BackgroundColor3=C.green,BorderSizePixel=0})
make('UICorner',circle,'Circle',{CornerRadius=UDim.new(1,0)})
local rim=make('Frame',mini,'Rim',{Position=circle.Position,Size=circle.Size,BackgroundTransparency=1})
make('UICorner',rim,'Circle',{CornerRadius=UDim.new(1,0)});outline(rim,C.ink,2)
text(mini,'North','N',UDim2.new(.5,-8,0,35),UDim2.fromOffset(16,18),13,C.paper)
local rangeLabel=text(mini,'Scale','RAIO 240',UDim2.new(0,10,1,-23),UDim2.new(1,-20,0,18),11,C.green)
local openMini=make('TextButton',mini,'OpenMap',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text='',Selectable=true})
openMini.ZIndex=8
local hint=text(mini,'OpenHint','MAPA  ·  N',UDim2.new(0,10,0,7),UDim2.new(1,-20,0,22),11,C.green)
hint.TextXAlignment=Enum.TextXAlignment.Right;miniTitle.TextXAlignment=Enum.TextXAlignment.Left;miniTitle.Size=UDim2.fromOffset(95,22)

local shade=make('Frame',gui,'AtlasOverlay',{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(12,27,25),BackgroundTransparency=.2,Visible=false,BorderSizePixel=0,Active=true})
local panel=make('Frame',shade,'Atlas',{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(820,650),BackgroundColor3=C.paper,BorderSizePixel=0})
corner(panel,26);outline(panel,C.ink,4)
local panelScale=make('UIScale',panel,'ResponsiveScale',{Scale=1})
local title=text(panel,'Title','ATLAS DO JARDINEIRO',UDim2.fromOffset(24,16),UDim2.fromOffset(670,32),26)
title.TextXAlignment=Enum.TextXAlignment.Left
local subtitle=text(panel,'Subtitle','RELEVO, CAMINHOS E SUA POSIÇÃO',UDim2.fromOffset(25,48),UDim2.fromOffset(650,22),12,C.green)
subtitle.TextXAlignment=Enum.TextXAlignment.Left
local close=button(panel,'Close','×',UDim2.new(1,-65,0,18),UDim2.fromOffset(44,44))
close.BackgroundColor3=Color3.fromRGB(225,115,91);close.TextColor3=C.paper;close.TextSize=28
local largeCanvas=make('CanvasGroup',panel,'WorldTerrain',{Position=UDim2.fromOffset(24,84),Size=UDim2.fromOffset(510,510),BackgroundColor3=C.green,BorderSizePixel=0})
corner(largeCanvas,16)
local mapBorder=make('Frame',panel,'MapBorder',{Position=largeCanvas.Position,Size=largeCanvas.Size,BackgroundTransparency=1})
corner(mapBorder,16);outline(mapBorder,C.ink,2)
text(panel,'MapNorth','N',UDim2.fromOffset(264,89),UDim2.fromOffset(30,25),20,C.paper)
local where=text(panel,'Where',editorPreview and'MAPA GERAL'or'VILA',UDim2.fromOffset(556,87),UDim2.fromOffset(236,28),20,C.green)
where.TextXAlignment=Enum.TextXAlignment.Left
local detail=text(panel,'Description','Curvas de nível a cada 8 studs.\nO mapa acompanha o terreno real.',UDim2.fromOffset(556,122),UDim2.fromOffset(232,62),13)
detail.Font=Enum.Font.Gotham;detail.TextWrapped=true;detail.TextXAlignment=Enum.TextXAlignment.Left
local centerButton=button(panel,'CenterPlayer','◎  MINHA POSIÇÃO',UDim2.fromOffset(556,199),UDim2.fromOffset(236,42))
local overview=button(panel,'Overview','VER O MUNDO',UDim2.fromOffset(556,250),UDim2.fromOffset(236,40))
local zoomIn=button(panel,'ZoomIn','+',UDim2.fromOffset(556,301),UDim2.fromOffset(110,36))
local zoomOut=button(panel,'ZoomOut','−',UDim2.fromOffset(682,301),UDim2.fromOffset(110,36))
local scaleText=text(panel,'MapScale','',UDim2.fromOffset(556,346),UDim2.fromOffset(236,22),12,C.green)
text(panel,'PlacesTitle','LUGARES DA VILA',UDim2.fromOffset(556,386),UDim2.fromOffset(236,24),15)
local legend=text(panel,'Legend','▲ Você  ·  ≈ Água\nV Vila  ·  F Fazenda  ·  B Floresta\nE Estufa  ·  M Moinho',UDim2.fromOffset(556,510),UDim2.fromOffset(236,74),13)
legend.Font=Enum.Font.Gotham;legend.TextXAlignment=Enum.TextXAlignment.Left
local footer=text(panel,'Footer','NORTE FIXO  ·  SEUS PASSOS EM TEMPO REAL',UDim2.fromOffset(24,609),UDim2.fromOffset(770,20),12,C.green)

local function renderer(canvas,n)
    local r={canvas=canvas,n=n,cells={},lines={},markers={},center=Vector2.zero,radius=240,dirty=true}
    local raster=make('Frame',canvas,'AltitudeBands',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1})
    local contours=make('Frame',canvas,'ContourLines',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=2})
    for z=1,n do r.cells[z]={};for x=1,n do
        r.cells[z][x]=make('Frame',raster,'TerrainCell',{Position=UDim2.fromScale((x-1)/n,(z-1)/n),Size=UDim2.new(1/n,1,1/n,1),BorderSizePixel=0})
    end end
    r.arrow=text(canvas,'Player','▲',UDim2.fromScale(.5,.5),UDim2.fromOffset(20,24),20,Color3.fromRGB(255,250,221))
    r.arrow.Visible=true
    r.arrow.TextColor3=Color3.fromRGB(255,216,63);r.arrow.TextSize=26
    r.arrow.AnchorPoint=Vector2.new(.5,.5);r.arrow.ZIndex=6;r.arrow.TextStrokeTransparency=.1;r.arrow.TextStrokeColor3=C.ink
    for _,poi in ipairs(Data.places)do
        local b=text(canvas,'Place_'..poi.code,poi.code,UDim2.new(),UDim2.fromOffset(19,19),11,C.paper)
        b.AnchorPoint=Vector2.new(.5,.5);b.BackgroundColor3=C.ink;b.BackgroundTransparency=.12;b.ZIndex=4;corner(b,9)
        table.insert(r.markers,{ui=b,data=poi})
    end
    local function line(a,b,major,index)
        local f=r.lines[index]
        if not f then f=make('Frame',contours,'AltitudeContour',{AnchorPoint=Vector2.new(.5,.5),BorderSizePixel=0,ZIndex=2});r.lines[index]=f end
        f.Parent=contours;f.ZIndex=2
        local size=canvas.AbsoluteSize
        local delta=Vector2.new((b.X-a.X)*size.X,(b.Y-a.Y)*size.Y)
        f.Position=UDim2.fromScale((a.X+b.X)/2,(a.Y+b.Y)/2);f.Size=UDim2.fromOffset(delta.Magnitude,major and 1.5 or 1)
        f.Rotation=math.deg(math.atan2(delta.Y,delta.X));f.BackgroundColor3=Color3.fromRGB(238,220,153)
        f.BackgroundTransparency=major and .2 or .57;f.Visible=true
    end
    function r.project(x,z)return Vector2.new(.5+(x-r.center.X)/(r.radius*2),.5+(z-r.center.Y)/(r.radius*2))end
    function r.draw()
        if canvas.AbsoluteSize.X<1 then return end
        local h,kind={},{}
        for z=0,n do h[z]={};kind[z]={};for x=0,n do
            h[z][x],kind[z][x]=sample(r.center.X+(x/n-.5)*r.radius*2,r.center.Y+(z/n-.5)*r.radius*2)
        end end
        local contourStep=r.radius>650 and 32 or(r.radius>350 and 16 or 8)
        if canvas==largeCanvas then
            detail.Text=string.format('Curvas de nível a cada %d studs.\nO mapa acompanha o terreno real.',contourStep)
            scaleText.Text=string.format('Área visível: %d studs',math.floor(r.radius*2))
        end
        local used=0
        for z=1,n do for x=1,n do
            local values={h[z-1][x-1],h[z-1][x],h[z][x],h[z][x-1]}
            local altitude=(values[1]+values[2]+values[3]+values[4])/4
            local material=kind[z][x]
            local color
            if material=='w'then color=C.water elseif material=='v'then color=Color3.fromRGB(226,218,179)else
                local band=math.max(0,altitude)
                color=Color3.fromRGB(91,145,92):Lerp(Color3.fromRGB(202,197,143),math.clamp(band/145,0,1))
                -- Terrain materials are noisy at this scale; altitude and slope carry the relief.
                local forest=math.clamp((-r.center.Y-(z/n-.5)*r.radius*2-170)/160,0,1)
                color=color:Lerp(Color3.fromRGB(55,111,79),forest*.28)
                local slope=(values[2]-values[4])*.006
                color=color:Lerp(slope>0 and Color3.new(1,1,1)or Color3.new(0,0,0),math.min(math.abs(slope),.12))
            end
            r.cells[z][x].BackgroundColor3=color
            if material~='w'and material~='v'then
                local low,high=math.min(table.unpack(values)),math.max(table.unpack(values))
                for level=math.ceil(math.max(low,1)/contourStep)*contourStep,high,contourStep do
                    local points={Vector2.new((x-1)/n,(z-1)/n),Vector2.new(x/n,(z-1)/n),Vector2.new(x/n,z/n),Vector2.new((x-1)/n,z/n)}
                    local crossings={}
                    for edge=1,4 do
                        local nextEdge=edge%4+1;local a,b=values[edge],values[nextEdge]
                        if(a<level)~=(b<level)then table.insert(crossings,points[edge]:Lerp(points[nextEdge],(level-a)/(b-a)))end
                    end
                    for edge=1,#crossings-1,2 do
                        if used<1200 then used+=1;line(crossings[edge],crossings[edge+1],level%(contourStep*4)==0,used)end
                    end
                end
            end
        end end
        -- Recognizable four garden plots, drawn at their real footprint and position.
        r.plotFrames=r.plotFrames or {}
        for index,plot in ipairs({{-48,-48},{48,-48},{-48,48},{48,48}})do
            local f=r.plotFrames[index]
            if not f then f=make('Frame',canvas,'GardenPlot'..index,{BackgroundColor3=Color3.fromRGB(114,166,88),BorderSizePixel=0,ZIndex=3});outline(f,Color3.fromRGB(240,226,181),1.5);r.plotFrames[index]=f end
            local p=r.project(plot[1],plot[2]);f.AnchorPoint=Vector2.new(.5,.5);f.Position=UDim2.fromScale(p.X,p.Y)
            f.Size=UDim2.fromScale(50/(r.radius*2),50/(r.radius*2))
        end
        for _,route in ipairs(Data.routes or{})do
        local stride=route.water and r.radius>650 and 3 or 1
        for i=1,#route.points-1,stride do
            local a,b=route.points[i],route.points[math.min(i+stride,#route.points)]
            used+=1;line(r.project(a[1],a[2]),r.project(b[1],b[2]),false,used)
            local f=r.lines[used]
            f.Parent=canvas;f.ZIndex=3
            f.BackgroundColor3=route.water and Color3.fromRGB(103,200,193)or Color3.fromRGB(223,208,150)
            f.BackgroundTransparency=route.water and .03 or .08
            f.Size=UDim2.fromOffset(f.Size.X.Offset,route.water and 5 or 2)
        end end
        for i=used+1,#r.lines do r.lines[i].Visible=false end
        for _,entry in ipairs(r.markers)do
            local p=r.project(entry.data.x,entry.data.z)
            entry.ui.Position=UDim2.fromScale(p.X,p.Y);entry.ui.Visible=p.X>.04 and p.X<.96 and p.Y>.04 and p.Y<.96
        end
        r.dirty=false
    end
    return r
end
local miniMap=renderer(circle,28)
local bigMap
local follow=false
local function characterRoot()
    if editorPreview then
        -- A clearly labelled editor-only navigation sample; never a replicated character.
        return {Position=Vector3.new(48,3,-27),CFrame=CFrame.Angles(0,.4,0)}
    end
    return player.Character and player.Character:FindFirstChild('HumanoidRootPart')
end
local function viewportSize()
    local v=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.zero
    if v.X<320 or v.Y<240 then v=gui.AbsoluteSize end
    if v.X<320 or v.Y<240 then v=Vector2.new(1280,720)end
    return v
end
local function openedElsewhere()
    if player:GetAttribute('MenuJogadorAberto')==true or player:GetAttribute('LojaAberta')==true or player:GetAttribute('SkillTreeOpen')==true then return true end
    local viewport=viewportSize()
    for _,name in ipairs({'OfflineAviso','PremiosGui','MissoesGui','FamaGui','OficinaGui','PlayerMenuGui','LojaCortadoresGui'})do
        local screen=playerGui:FindFirstChild(name)
        if screen and screen:IsA('ScreenGui')and screen.Enabled then
            for _,child in ipairs(screen:GetChildren())do
                if child:IsA('GuiObject')and child.Visible and child.AbsoluteSize.X>viewport.X*.4 and child.AbsoluteSize.Y>viewport.Y*.3 then return true end
            end
        end
    end
    return false
end
local function openMap(value)
    if value and openedElsewhere()then return false end
    shade.Visible=value;mini.Visible=not value and not openedElsewhere()
    if value then
        if not bigMap then bigMap=renderer(largeCanvas,64)end
        local root=characterRoot();bigMap.center=root and Vector2.new(root.Position.X,root.Position.Z)or Vector2.zero;bigMap.radius=280;bigMap.dirty=true;follow=root~=nil
    end
    return true
end
openMini.Activated:Connect(function()openMap(true)end)
close.Activated:Connect(function()openMap(false)end)
centerButton.Activated:Connect(function()
    local root=characterRoot();if root and bigMap then follow=true;bigMap.center=Vector2.new(root.Position.X,root.Position.Z);bigMap.radius=280;bigMap.dirty=true end
end)
overview.Activated:Connect(function()if bigMap then follow=false;bigMap.center=Vector2.new(0,(Data.minZ+Data.maxZ)/2);bigMap.radius=(Data.maxZ-Data.minZ)/2+30;bigMap.dirty=true end end)
zoomIn.Activated:Connect(function()if bigMap then bigMap.radius=math.max(120,bigMap.radius*.65);bigMap.dirty=true end end)
zoomOut.Activated:Connect(function()if bigMap then bigMap.radius=math.min(1300,bigMap.radius/ .65);bigMap.dirty=true end end)
local placeButtons={}
for i,poi in ipairs({Data.places[1],Data.places[2]})do
    local b=button(panel,'Locate_'..poi.code,poi.name,UDim2.fromOffset(556,420+(i-1)*40),UDim2.fromOffset(236,34))
    table.insert(placeButtons,b)
    b.Activated:Connect(function()if bigMap then follow=false;bigMap.center=Vector2.new(poi.x,poi.z);bigMap.radius=260;bigMap.dirty=true end end)
end
local inputConnection=Input.InputBegan:Connect(function(input,processed)
    if processed or Input:GetFocusedTextBox()then return end
    if input.KeyCode==Enum.KeyCode.N then openMap(not shade.Visible)
    elseif input.KeyCode==Enum.KeyCode.Escape and shade.Visible then openMap(false)end
end)
local function visibility()
    if openedElsewhere()then shade.Visible=false;mini.Visible=false else mini.Visible=not shade.Visible end
end
local attributeConnections={}
for _,name in ipairs({'MenuJogadorAberto','LojaAberta','SkillTreeOpen'})do table.insert(attributeConnections,player:GetAttributeChangedSignal(name):Connect(visibility))end
local north=panel.MapNorth
local placesTitle=panel.PlacesTitle
local responsiveObjects={title,subtitle,close,largeCanvas,mapBorder,where,detail,centerButton,overview,zoomIn,zoomOut,scaleText,placesTitle,legend,footer,north}
for _,b in ipairs(placeButtons)do table.insert(responsiveObjects,b)end
local defaults={}
for _,o in ipairs(responsiveObjects)do defaults[o]={position=o.Position,size=o.Size}end
local function rectangle(o,x,y,w,h)o.Position=UDim2.fromOffset(x,y);o.Size=UDim2.fromOffset(w,h)end
local function placeMini(v,scale)
    local w,h=186*scale,222*scale
    local occupied={}
    for _,screen in ipairs(playerGui:GetChildren())do
        if screen~=gui and screen:IsA('ScreenGui')and screen.Enabled then
            for _,o in ipairs(screen:GetDescendants())do
                if o:IsA('GuiButton')or(o:IsA('Frame')and(o.Name=='Quest'or o.Name=='Moedas'or o.Name=='Nivel'or o.Name=='Saco'or o.Name=='XP'))then
                    local visible=o.Visible;local parent=o.Parent
                    while visible and parent and parent~=screen do
                        if parent:IsA('GuiObject')and not parent.Visible then visible=false end
                        parent=parent.Parent
                    end
                    if visible and o.AbsoluteSize.X>5 and o.AbsoluteSize.Y>5 then
                        table.insert(occupied,{o.AbsolutePosition-gui.AbsolutePosition,o.AbsoluteSize})
                    end
                end
            end
        end
    end
    local candidates={Vector2.new(v.X-w-18,v.Y-h-14),Vector2.new(110,v.Y-h-14),Vector2.new((v.X-w)/2,8),Vector2.new(104,v.Y*.3),Vector2.new(v.X-w-18,v.Y*.32)}
    local best,bestCost
    for _,p in ipairs(candidates)do
        p=Vector2.new(math.clamp(p.X,8,math.max(8,v.X-w-8)),math.clamp(p.Y,8,math.max(8,v.Y-h-8)))
        local cost=0
        for _,r in ipairs(occupied)do
            local a,b=r[1],r[2]
            local dx=math.max(0,math.min(p.X+w+6,a.X+b.X)-math.max(p.X-6,a.X))
            local dy=math.max(0,math.min(p.Y+h+6,a.Y+b.Y)-math.max(p.Y-6,a.Y))
            cost+=dx*dy
        end
        if not bestCost or cost<bestCost then best,bestCost=p,cost end
    end
    mini.AnchorPoint=Vector2.zero;mini.Position=UDim2.fromOffset(best.X,best.Y)
    mini:SetAttribute('HUDOverlapArea',bestCost)
end
local function layout()
    local v=viewportSize()
    for _,o in ipairs(responsiveObjects)do o.Position=defaults[o].position;o.Size=defaults[o].size;o.Visible=true end
    title.TextSize=26;legend.Text='▲ Você  ·  ≈ Água\nV Vila  ·  F Fazenda  ·  B Floresta\nE Estufa  ·  M Moinho'
    local portrait=v.X<650 and v.X<v.Y
    local short=v.Y<520 and not portrait
    panel.Size=UDim2.fromOffset(820,650)
    if portrait then
        panel.Size=UDim2.fromOffset(410,660);title.TextSize=21
        rectangle(title,20,12,320,32);rectangle(close,350,12,42,42)
        rectangle(where,21,49,360,22);subtitle.Visible=false;detail.Visible=false;placesTitle.Visible=false;footer.Visible=false
        rectangle(largeCanvas,24,85,362,362);rectangle(mapBorder,24,85,362,362);rectangle(north,191,89,28,24)
        rectangle(centerButton,24,461,362,48);rectangle(overview,24,520,242,48)
        rectangle(zoomIn,278,520,48,48);rectangle(zoomOut,338,520,48,48)
        rectangle(legend,24,576,362,34);legend.Text='V Vila  ·  F Fazenda  ·  B Floresta\nE Estufa  ·  M Moinho'
        rectangle(scaleText,24,616,362,22)
        for _,b in ipairs(placeButtons)do b.Visible=false end
    elseif short then
        panel.Size=UDim2.fromOffset(760,430);title.TextSize=22
        rectangle(title,18,9,640,30);rectangle(close,698,9,44,44)
        subtitle.Visible=false;detail.Visible=false;placesTitle.Visible=false;footer.Visible=false
        rectangle(largeCanvas,18,54,352,352);rectangle(mapBorder,18,54,352,352);rectangle(north,180,58,28,24)
        rectangle(where,393,65,340,26);rectangle(centerButton,393,108,340,52);rectangle(overview,393,171,340,52)
        rectangle(zoomIn,393,235,162,48);rectangle(zoomOut,571,235,162,48)
        rectangle(scaleText,393,294,340,24);rectangle(legend,393,332,340,62)
        for _,b in ipairs(placeButtons)do b.Visible=false end
    end
    panelScale.Scale=math.min(1,(v.X-24)/panel.Size.X.Offset,(v.Y-24)/panel.Size.Y.Offset)
    hint.Text=Input.TouchEnabled and'MAPA'or'MAPA  ·  N'
    local mobile=Input.TouchEnabled or v.Y<650
    local scale=mobile and .72 or 1
    local s=mini:FindFirstChild('ResponsiveScale')or make('UIScale',mini,'ResponsiveScale',{})
    s.Scale=scale
    placeMini(v,scale)
    miniMap.dirty=true;if bigMap then bigMap.dirty=true end
end
local cameraConnection
local function watchCamera()
    if cameraConnection then cameraConnection:Disconnect()end
    if workspace.CurrentCamera then cameraConnection=workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(layout)end
    layout()
end
local workspaceConnection=workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(watchCamera)
watchCamera();visibility()
local resizeConnection=gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout)
local elapsed,lastDraw=0,0
local heartbeatConnection=Run.Heartbeat:Connect(function(dt)
    elapsed+=dt;lastDraw+=dt;if elapsed<.1 then return end;elapsed=0
    if openedElsewhere()then shade.Visible=false;mini.Visible=false else mini.Visible=not shade.Visible end
    local root=characterRoot();if not root then return end
    local position=Vector2.new(root.Position.X,root.Position.Z)
    local heading=math.deg(math.atan2(root.CFrame.LookVector.X,-root.CFrame.LookVector.Z))
    if(position-miniMap.center).Magnitude>8 then miniMap.center=position;miniMap.dirty=true end
    local region=player:GetAttribute('RegiaoAtual')or(root.Position.Z<-140 and 'Floresta' or 'Vila')
    where.Text=editorPreview and 'VILA · PRÉVIA DO EDITOR'or region:upper()
    if bigMap and follow and(position-bigMap.center).Magnitude>8 then bigMap.center=position;bigMap.dirty=true end
    for _,r in ipairs(bigMap and{miniMap,bigMap}or{miniMap})do
        local p=r.project(position.X,position.Y);r.arrow.Position=UDim2.fromScale(p.X,p.Y);r.arrow.Rotation=heading
        r.arrow.Visible=p.X>=0 and p.X<=1 and p.Y>=0 and p.Y<=1
    end
    if lastDraw>.9 then
        lastDraw=0
        if mini.Visible then
            placeMini(viewportSize(),mini.ResponsiveScale.Scale)
            if miniMap.dirty then miniMap.draw()end
        end
        if shade.Visible and bigMap and bigMap.dirty then bigMap.draw()end
    end
    if bigMap then scaleText.Text=string.format('Área visível: %d studs',math.floor(bigMap.radius*2))end
end)

gui.Destroying:Connect(function()
    inputConnection:Disconnect();workspaceConnection:Disconnect();resizeConnection:Disconnect();heartbeatConnection:Disconnect()
    if cameraConnection then cameraConnection:Disconnect()end
    for _,connection in ipairs(attributeConnections)do connection:Disconnect()end
    if previewSignal then previewSignal:Destroy()end
end)

-- Local controller API also lets other navigation buttons open the same atlas.
return {
    Open=function()
        local opened=openMap(true)
        if opened and bigMap then task.defer(function()if gui.Parent then bigMap.draw()end end)end
        return opened
    end,
    Close=function()
        local closed=openMap(false)
        if editorPreview then task.defer(function()if gui.Parent then miniMap.draw()end end)end
        return closed
    end,
}
