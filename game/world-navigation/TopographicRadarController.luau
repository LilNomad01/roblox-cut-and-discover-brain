-- Native aerial map of the actual place, with live player navigation. No new remotes.
local Players=game:GetService('Players')
local Run=game:GetService('RunService')
local Input=game:GetService('UserInputService')
local editorPreview=not Run:IsRunning()
local player=Players.LocalPlayer
local playerGui=editorPreview and game.StarterGui or player:WaitForChild('PlayerGui')
local Data=require(game.ReplicatedStorage.Shared.WorldMapData)
local Images=require(game.ReplicatedStorage.Shared.WorldMapImages)
local old=playerGui:FindFirstChild('TopographicRadar');if old then old:Destroy()end
local C={paper=Color3.fromRGB(255,245,213),ink=Color3.fromRGB(53,48,36),green=Color3.fromRGB(56,100,73),gold=Color3.fromRGB(255,214,71),water=Color3.fromRGB(74,164,199)}
local connections={}
local function connect(signal,fn)local c=signal:Connect(fn);table.insert(connections,c);return c end
local function make(class,parent,name,p)
    local o=Instance.new(class);o.Name=name
    for k,v in pairs(p or{})do o[k]=v end
    o.Parent=parent;return o
end
local function corner(o,r)make('UICorner',o,'Corner',{CornerRadius=UDim.new(0,r)})end
local function border(o,w,color)make('UIStroke',o,'Outline',{Thickness=w,Color=color or C.ink,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})end
local function text(parent,name,value,size,color)
    return make('TextLabel',parent,name,{Text=value,TextSize=size,TextColor3=color or C.ink,BackgroundTransparency=1,Font=Enum.Font.FredokaOne,BorderSizePixel=0})
end
local function rect(o,x,y,w,h)o.Position=UDim2.fromOffset(x,y);o.Size=UDim2.fromOffset(w,h)end
local function button(parent,name,value)
    local o=make('TextButton',parent,name,{Text=value,TextSize=15,TextColor3=C.ink,Font=Enum.Font.FredokaOne,BackgroundColor3=C.paper,AutoButtonColor=true,Selectable=true,BorderSizePixel=0})
    corner(o,10);border(o,2);return o
end
local gui=make('ScreenGui',playerGui,'TopographicRadar',{IgnoreGuiInset=false,ResetOnSpawn=false,DisplayOrder=14,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
gui:SetAttribute('EditorOnlyNavigationPreview',editorPreview)
local mini=make('Frame',gui,'MiniRadar',{BackgroundColor3=C.paper,BorderSizePixel=0,AnchorPoint=Vector2.new(1,1)})
corner(mini,18);border(mini,3)
local miniTitle=text(mini,'Title','EXPLORAR',13)
miniTitle.TextXAlignment=Enum.TextXAlignment.Left
local miniHint=text(mini,'OpenHint','N  ↗',11,C.green);miniHint.TextXAlignment=Enum.TextXAlignment.Right
local circle=make('CanvasGroup',mini,'Terrain',{BackgroundColor3=C.green,BorderSizePixel=0,ClipsDescendants=true})
make('UICorner',circle,'Circle',{CornerRadius=UDim.new(1,0)})
local rim=make('Frame',mini,'Rim',{BackgroundTransparency=1,BorderSizePixel=0})
make('UICorner',rim,'Circle',{CornerRadius=UDim.new(1,0)});border(rim,2)
local miniNorth=text(mini,'North','N',12,C.paper);miniNorth.ZIndex=5;miniNorth.TextStrokeTransparency=.25
local miniRegion=text(mini,'Region','VILA',11,C.green);miniRegion.TextTruncate=Enum.TextTruncate.AtEnd
local openMini=make('TextButton',mini,'OpenMap',{Size=UDim2.fromScale(1,1),Text='',BackgroundTransparency=1,Selectable=true,ZIndex=8})

local shade=make('Frame',gui,'AtlasOverlay',{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(13,27,24),BackgroundTransparency=.2,BorderSizePixel=0,Visible=false,Active=true})
local panel=make('Frame',shade,'Atlas',{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BackgroundColor3=C.paper,BorderSizePixel=0})
corner(panel,22);border(panel,3)
local title=text(panel,'Title','MAPA DO MUNDO',25);title.TextXAlignment=Enum.TextXAlignment.Left
local subtitle=text(panel,'Subtitle','Vista aérea real · arraste para explorar',12,C.green);subtitle.Font=Enum.Font.Gotham;subtitle.TextXAlignment=Enum.TextXAlignment.Left
local close=button(panel,'Close','×');close.TextSize=26;close.TextColor3=C.paper;close.BackgroundColor3=Color3.fromRGB(218,112,89)
local largeCanvas=make('CanvasGroup',panel,'WorldTerrain',{BackgroundColor3=C.green,BorderSizePixel=0,ClipsDescendants=true})
corner(largeCanvas,14)
local mapBorder=make('Frame',panel,'MapBorder',{BackgroundTransparency=1,BorderSizePixel=0});corner(mapBorder,14);border(mapBorder,2)
local north=text(panel,'MapNorth','N',19,C.paper);north.TextStrokeTransparency=.2;north.ZIndex=5
local where=text(panel,'Where','VILA',16,C.green);where.TextXAlignment=Enum.TextXAlignment.Left
local centerButton=button(panel,'CenterPlayer','MINHA POSIÇÃO')
local overview=button(panel,'Overview','MUNDO INTEIRO')
local villageButton=button(panel,'Village','VILA')
local forestButton=button(panel,'Forest','FLORESTA')
local zoomIn=button(panel,'ZoomIn','+');zoomIn.TextSize=24
local zoomOut=button(panel,'ZoomOut','−');zoomOut.TextSize=24
local scaleText=text(panel,'MapScale','',11,C.green)
local legend=text(panel,'Legend','▲ Você\n● Lugares da vila\n\nÁrvores, caminhos e\nconstruções do jogo.',12)
legend.Font=Enum.Font.Gotham;legend.TextXAlignment=Enum.TextXAlignment.Left;legend.TextYAlignment=Enum.TextYAlignment.Top
local footer=text(panel,'Footer','',11,C.green);footer.Font=Enum.Font.Gotham

local function rootPart()
    if editorPreview then
        -- Clearly labelled editor-only navigation sample, never a replicated character.
        return {Position=Vector3.new(48,3,-27),CFrame=CFrame.Angles(0,.4,0)}
    end
    return player.Character and player.Character:FindFirstChild('HumanoidRootPart')
end
local function viewport()
    -- ScreenGui coordinates are authoritative. Camera dimensions include different inset rules.
    local v=gui.AbsoluteSize
    if v.X<100 or v.Y<100 then v=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(986,488)end
    return v
end
local function otherModal()
    if not editorPreview and(player:GetAttribute('MenuJogadorAberto')or player:GetAttribute('LojaAberta')or player:GetAttribute('SkillTreeOpen'))then return true end
    local v=viewport()
    for _,name in ipairs({'PetsGui','AlbumGui','OfflineAviso','PremiosGui','MissoesGui','FamaGui','OficinaGui','PlayerMenuGui','LojaCortadoresGui'})do
        local screen=playerGui:FindFirstChild(name)
        if screen and screen:IsA('ScreenGui')and screen.Enabled then
            for _,o in ipairs(screen:GetChildren())do if o:IsA('GuiObject')and o.Visible and o.AbsoluteSize.X>v.X*.4 and o.AbsoluteSize.Y>v.Y*.3 then return true end end
        end
    end
    return false
end
local function renderer(canvas,compact)
    local r={center=Vector2.zero,radius=compact and 160 or 240,tiles={},markers={}}
    for i,tile in ipairs(Images.tiles)do
        local o=make('ImageLabel',canvas,'Aerial_'..tile.name,{Image=tile.image,BackgroundTransparency=1,BorderSizePixel=0,AnchorPoint=Vector2.new(.5,.5),ZIndex=1+i,ScaleType=Enum.ScaleType.Stretch})
        table.insert(r.tiles,{ui=o,data=tile})
    end
    for _,place in ipairs(Data.places)do
        local o=text(canvas,'Place_'..place.code,compact and'●'or place.name:upper(),compact and 10 or 12,C.paper)
        o.AnchorPoint=Vector2.new(.5,.5);o.TextStrokeColor3=C.ink;o.TextStrokeTransparency=0;o.ZIndex=6
        if compact then o.Text=place.code;o.BackgroundColor3=C.ink;o.BackgroundTransparency=.05;o.TextColor3=C.paper;corner(o,8);border(o,1,C.paper)end
        o.Size=compact and UDim2.fromOffset(16,16)or UDim2.fromOffset(150,20)
        table.insert(r.markers,{ui=o,data=place})
    end
    local loading=text(canvas,'Loading','CARREGANDO MAPA…',13,C.paper);loading.Size=UDim2.fromScale(1,1);loading.ZIndex=9
    local ring=make('Frame',canvas,'PlayerRing',{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(24,24),BackgroundColor3=C.ink,BackgroundTransparency=.15,BorderSizePixel=0,ZIndex=7});corner(ring,12)
    r.arrow=text(canvas,'Player','▲',21,C.gold);r.arrow.Size=UDim2.fromOffset(22,24);r.arrow.AnchorPoint=Vector2.new(.5,.5);r.arrow.ZIndex=8;r.arrow.TextStrokeColor3=C.ink;r.arrow.TextStrokeTransparency=1
    make('UIStroke',r.arrow,'DirectionalOutline',{Color=C.ink,Thickness=2,ApplyStrokeMode=Enum.ApplyStrokeMode.Contextual})
    border(ring,1,C.paper)
    function r.project(x,z)
        local aspect=math.max(.1,canvas.AbsoluteSize.X/math.max(1,canvas.AbsoluteSize.Y))
        return Vector2.new(.5+(x-r.center.X)/(r.radius*2*aspect),.5+(z-r.center.Y)/(r.radius*2))
    end
    function r.draw(position,heading)
        local aspect=math.max(.1,canvas.AbsoluteSize.X/math.max(1,canvas.AbsoluteSize.Y))
        for i,entry in ipairs(r.tiles)do
            local tile,o=entry.data,entry.ui;local p=r.project(tile.x,tile.z)
            o.Position=UDim2.fromScale(p.X,p.Y);o.Size=UDim2.fromScale((tile.halfX or tile.radius)/r.radius/aspect,(tile.halfZ or tile.radius)/r.radius)
            o.Visible=i==1 or r.radius<430
        end
        local arrow=r.project(position.X,position.Y)
        local ready=r.tiles[1].ui.IsLoaded;loading.Visible=not ready
        local inside=ready and arrow.X>=0 and arrow.X<=1 and arrow.Y>=0 and arrow.Y<=1
        r.arrow.Visible=inside;ring.Visible=inside
        r.arrow.Position=UDim2.fromScale(arrow.X,arrow.Y);ring.Position=r.arrow.Position;r.arrow.Rotation=heading
        local occupied={}
        local overviewMode=not compact and r.radius>500
        r.arrow.TextSize=overviewMode and 15 or 21
        ring.Size=UDim2.fromOffset(overviewMode and 16 or 24,overviewMode and 16 or 24)
        for _,entry in ipairs(r.markers)do
            local o,place=entry.ui,entry.data
            local px,pz=place.x,place.z
            if not compact and r.radius>500 then
                if place.code=='B'then pz=-530;o.Text='FLORESTA ESQUECIDA'
                elseif place.code=='V'then pz=105;o.Text='VILA'
                else o.Text=place.name:upper()end
            else o.Text=compact and place.code or place.name:upper()end
            local p=r.project(px,pz)
            local pixel=Vector2.new(p.X*canvas.AbsoluteSize.X,p.Y*canvas.AbsoluteSize.Y)
            local visible=p.X>.07 and p.X<.93 and p.Y>.07 and p.Y<.93
            if r.radius>500 and place.code~='V'and place.code~='F'and place.code~='B'then visible=false end
            if(pixel-Vector2.new(arrow.X*canvas.AbsoluteSize.X,arrow.Y*canvas.AbsoluteSize.Y)).Magnitude<(compact and 24 or 28)then visible=false end
            for _,q in ipairs(occupied)do if(pixel-q).Magnitude<(compact and 16 or 46)then visible=false end end
            o.Visible=visible;o.Position=UDim2.fromScale(p.X,p.Y)
            if visible then table.insert(occupied,pixel)end
        end
    end
    return r
end
local miniMap=renderer(circle,true)
local bigMap=renderer(largeCanvas,false)
local follow=true
local layout
local function open(value)
    if value and otherModal()then return false end
    shade.Visible=value;mini.Visible=not value and not otherModal();gui.DisplayOrder=value and 90 or 14
    if value then local root=rootPart();if root then bigMap.center=Vector2.new(root.Position.X,root.Position.Z)end;bigMap.radius=240;follow=true end
    if layout then layout()end
    return true
end
connect(openMini.Activated,function()open(true)end)
connect(close.Activated,function()open(false)end)
connect(centerButton.Activated,function()local root=rootPart();if root then follow=true;bigMap.center=Vector2.new(root.Position.X,root.Position.Z);bigMap.radius=200;if layout then layout()end end end)
connect(overview.Activated,function()follow=false;bigMap.center=Vector2.new(0,-256);bigMap.radius=926;if layout then layout()end end)
connect(zoomIn.Activated,function()bigMap.radius=math.max(80,bigMap.radius*.7);if layout then layout()end end)
connect(zoomOut.Activated,function()bigMap.radius=math.min(1100,bigMap.radius/.7);if layout then layout()end end)
connect(villageButton.Activated,function()follow=false;bigMap.center=Vector2.zero;bigMap.radius=190;if layout then layout()end end)
connect(forestButton.Activated,function()follow=false;bigMap.center=Vector2.new(0,-530);bigMap.radius=330;if layout then layout()end end)
-- Panning changes only the map camera; it never moves the character.
largeCanvas.Active=true
local drag
connect(largeCanvas.InputBegan,function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        drag={input=input,start=Vector2.new(input.Position.X,input.Position.Y),center=bigMap.center};follow=false
    end
end)
connect(Input.InputChanged,function(input)
    if not drag or not shade.Visible then return end
    if input.UserInputType==Enum.UserInputType.MouseMovement or input==drag.input then
        local delta=Vector2.new(input.Position.X,input.Position.Y)-drag.start
        local c=drag.center-delta*(bigMap.radius*2/math.max(1,largeCanvas.AbsoluteSize.Y))
        bigMap.center=Vector2.new(math.clamp(c.X,Data.minX-300,Data.maxX+300),math.clamp(c.Y,Data.minZ-300,Data.maxZ+300))
    end
end)
connect(Input.InputEnded,function(input)
    if drag and(input==drag.input or input.UserInputType==Enum.UserInputType.MouseButton1)then drag=nil end
end)

connect(Input.InputBegan,function(input,processed)
    if processed or Input:GetFocusedTextBox()then return end
    if input.KeyCode==Enum.KeyCode.N then open(not shade.Visible)elseif input.KeyCode==Enum.KeyCode.Escape and shade.Visible then open(false)end
end)

local function obstacles()
    local list={}
    for _,screen in ipairs(playerGui:GetChildren())do
        if screen~=gui and screen:IsA('ScreenGui')and screen.Enabled then
            for _,o in ipairs(screen:GetDescendants())do
                if o:IsA('GuiButton')or(o:IsA('Frame')and(o.Name=='Quest'or o.Name=='Moedas'or o.Name=='Nivel'or o.Name=='Saco'or o.Name=='XP'or o.Name=='DynamicThumbstickFrame'))then
                    local visible=o.Visible;local p=o.Parent
                    while visible and p and p~=screen do if p:IsA('GuiObject')and not p.Visible then visible=false end;p=p.Parent end
                    if visible and o.AbsoluteSize.X>5 and o.AbsoluteSize.Y>5 then table.insert(list,{o.AbsolutePosition-gui.AbsolutePosition,o.AbsoluteSize})end
                end
            end
        end
    end
    return list
end
local function layoutMini(v)
    local list=obstacles();local best,bestCost,bestD
    for _,d in ipairs(v.X<600 and{112,96,80}or{144,128,112,96,80})do
        local w,h=d+20,d+52
        local candidates={Vector2.new(96,v.Y-h-18),Vector2.new(v.X-w-16,v.Y-h-110),Vector2.new(v.X-w-16,102),Vector2.new(96,120),Vector2.new((v.X-w)/2,10)}
        for _,p in ipairs(candidates)do
            p=Vector2.new(math.clamp(p.X,12,math.max(12,v.X-w-12)),math.clamp(p.Y,12,math.max(12,v.Y-h-12)))
            local cost=0
            for _,r in ipairs(list)do local a,s=r[1],r[2];local dx=math.max(0,math.min(p.X+w+8,a.X+s.X)-math.max(p.X-8,a.X));local dy=math.max(0,math.min(p.Y+h+8,a.Y+s.Y)-math.max(p.Y-8,a.Y));cost+=dx*dy end
            if not bestCost or cost<bestCost then best,bestCost,bestD=p,cost,d end
            if cost==0 then break end
        end
        if bestCost==0 then break end
    end
    local w,h=bestD+20,bestD+52
    mini.Size=UDim2.fromOffset(w,h)
    -- Use scale coordinates and a bottom-right anchor; no UIScale can push offsets off-screen.
    mini.Position=UDim2.fromScale((best.X+w)/v.X,(best.Y+h)/v.Y)
    rect(miniTitle,10,5,w-58,22);rect(miniHint,w-47,5,37,22)
    miniHint.Text=Input.TouchEnabled and'↗'or'N ↗'
    rect(circle,10,29,bestD,bestD);rim.Position=circle.Position;rim.Size=circle.Size
    rect(miniNorth,w/2-10,30,20,18);rect(miniRegion,8,h-21,w-16,17)
    mini:SetAttribute('HUDOverlapArea',bestCost);mini:SetAttribute('MapDiameter',bestD)
end
layout=function()
    local v=viewport();if v.X<100 or v.Y<100 then return end
    local w,h=math.min(900,v.X-28),math.min(680,v.Y-28)
    if bigMap.radius>500 and v.X>=580 then w=math.min(w,(h-94)*1280/1792+241)end
    panel.Size=UDim2.fromOffset(w,h)
    local portrait=v.X<580
    rect(title,20,12,w-86,30);title.TextSize=portrait and 20 or 25
    rect(close,w-58,12,40,40);rect(subtitle,21,43,w-90,20)
    local side=portrait and 0 or math.clamp(w*.23,165,210)
    local mapW=w-36-(side>0 and side+16 or 0)
    local mapH=h-(portrait and 220 or 94)
    rect(largeCanvas,18,74,mapW,mapH);mapBorder.Position=largeCanvas.Position;mapBorder.Size=largeCanvas.Size
    rect(north,18+mapW/2-12,78,24,24)
    if portrait then
        rect(where,20,h-135,w-40,19)
        rect(centerButton,18,h-59,w-140,38);rect(overview,18,h-106,w-36,32)
        rect(zoomIn,w-112,h-59,40,38);rect(zoomOut,w-62,h-59,40,38)
        legend.Visible=false;scaleText.Visible=false;footer.Visible=false;villageButton.Visible=false;forestButton.Visible=false
    else
        local x=mapW+34;local bw=w-x-18
        rect(where,x,80,bw,24);rect(centerButton,x,119,bw,38);rect(overview,x,168,bw,38)
        rect(zoomIn,x,218,(bw-10)/2,36);rect(zoomOut,x+(bw+10)/2,218,(bw-10)/2,36)
        rect(scaleText,x,265,bw,25)
        rect(villageButton,x,304,(bw-8)/2,32);rect(forestButton,x+(bw+8)/2,304,(bw-8)/2,32)
        villageButton.TextSize=12;forestButton.TextSize=12;villageButton.Visible=true;forestButton.Visible=true
        rect(legend,x,352,bw,105);legend.Visible=h>500;scaleText.Visible=true
        rect(footer,20,h-21,mapW,17);footer.Visible=h>500
    end
    layoutMini(v)
end
connect(gui:GetPropertyChangedSignal('AbsoluteSize'),layout)
local elapsed,positionClock=0,0
local function update()
    local root=rootPart();if not root then return end
    local position=Vector2.new(root.Position.X,root.Position.Z)
    local heading=math.deg(math.atan2(root.CFrame.LookVector.X,-root.CFrame.LookVector.Z))
    local region=editorPreview and'PRÉVIA · VILA'or(player:GetAttribute('RegiaoAtual')or(root.Position.Z<-140 and'Floresta'or'Vila'))
    where.Text=region:upper();miniRegion.Text=region:upper()
    if otherModal()then shade.Visible=false;mini.Visible=false else mini.Visible=not shade.Visible end
    gui.DisplayOrder=shade.Visible and 90 or 14
    miniMap.center=position
    if follow then bigMap.center=position end
    if mini.Visible then miniMap.draw(position,heading)end
    if shade.Visible then bigMap.draw(position,heading)end
    scaleText.Text=string.format('ZOOM · %d STUDS',math.floor(bigMap.radius*2))
    footer.Text=editorPreview and'PRÉVIA DO EDITOR · POSIÇÃO SIMULADA'or'▲ SUA POSIÇÃO E DIREÇÃO EM TEMPO REAL'
end
connect(Run.Heartbeat,function(dt)
    elapsed+=dt;positionClock+=dt
    if elapsed>.1 then elapsed=0;update()end
    if positionClock>1 then positionClock=0;if mini.Visible then layoutMini(viewport())end end
end)
layout();update()
gui.Destroying:Connect(function()for _,c in ipairs(connections)do c:Disconnect()end end)
-- Local controller API also lets other navigation buttons open the same atlas.
return {Open=function()local ok=open(true);update();return ok end,Close=function()local ok=open(false);update();return ok end}
