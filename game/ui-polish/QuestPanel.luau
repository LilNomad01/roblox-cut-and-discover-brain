-- Interactive Roblox adaptation of assets/ui/missao-painel.blend.
-- Text stays native and readable; no uploaded texture or fixed progress image.
-- [Claude 2026-11-10] Polimento (mesmo visual): card abaixo das moedas sem encostar, barra de
-- progresso mais grossa com degradê, pulso no contador, entrada ao trocar de missão, barra dourada
-- ao concluir e card oculto enquanto menu/loja/árvore estiverem abertos.
local Panel={}
local UIS=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local Players=game:GetService("Players")
local GREEN_A,GREEN_B=Color3.fromRGB(147,218,113),Color3.fromRGB(96,190,92)
local GOLD_A,GOLD_B=Color3.fromRGB(255,222,120),Color3.fromRGB(232,170,64)
local function tween(obj,time,props,style)
    local t=TweenService:Create(obj,TweenInfo.new(time,style or Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props)
    t:Play() return t
end
function Panel.build(parent)
    local previous=parent:FindFirstChild("ExplorationQuestHUD")
    if previous then previous:Destroy() end
    local gui=Instance.new("ScreenGui") gui.Name="ExplorationQuestHUD" gui.ResetOnSpawn=false
    -- mesmo espaço de coordenadas do HUD de moedas (HUDCortaGrama também ignora o inset)
    gui.IgnoreGuiInset=true
    gui.DisplayOrder=12 gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.Parent=parent
    local card=Instance.new("Frame") card.Name="Quest" card.AnchorPoint=Vector2.new(1,0)
    card.Position=UDim2.new(1,-16,0,100) card.Size=UDim2.fromOffset(284,184)
    card.BackgroundColor3=Color3.fromRGB(23,49,44) card.BackgroundTransparency=.08 card.BorderSizePixel=0 card.Parent=gui
    local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,14) corner.Parent=card
    local stroke=Instance.new("UIStroke") stroke.Color=Color3.fromRGB(201,161,78) stroke.Transparency=.35 stroke.Thickness=1.5 stroke.Parent=card
    local offset=Instance.new("UIScale") offset.Name="Entrada" offset.Parent=card
    local function label(name,text,y,height,size,color)
        local t=Instance.new("TextLabel") t.Name=name t.Text=text t.Position=UDim2.fromOffset(16,y)
        t.Size=UDim2.new(1,-32,0,height) t.BackgroundTransparency=1 t.TextColor3=color or Color3.fromRGB(249,239,211)
        t.TextSize=size t.Font=Enum.Font.GothamMedium t.TextXAlignment=Enum.TextXAlignment.Left
        t.TextYAlignment=Enum.TextYAlignment.Center t.TextWrapped=true t.Parent=card return t
    end
    local category=label("Category","MISSÃO ATUAL",9,20,11,Color3.fromRGB(232,189,101))
    local title=label("Title","Cuide do jardim",33,25,18) title.Font=Enum.Font.GothamBold
    local objective=label("Objective","Corte a grama do seu terreno",63,38,13)
    local count=label("Count","0 / 64 cortes",106,18,12,Color3.fromRGB(170,200,178))
    count.Font=Enum.Font.GothamBold
    local countScale=Instance.new("UIScale") countScale.Parent=count
    local track=Instance.new("Frame") track.Name="Track" track.Position=UDim2.fromOffset(16,128)
    track.Size=UDim2.new(1,-32,0,10) track.BackgroundColor3=Color3.fromRGB(14,30,27) track.BorderSizePixel=0 track.Parent=card
    local trackStroke=Instance.new("UIStroke") trackStroke.Color=Color3.fromRGB(61,85,71) trackStroke.Thickness=1 trackStroke.Parent=track
    local fill=Instance.new("Frame") fill.Name="Fill" fill.Position=UDim2.new() fill.Size=UDim2.fromScale(0,1)
    fill.BackgroundColor3=Color3.new(1,1,1) fill.BorderSizePixel=0 fill.Parent=track
    local fillGradient=Instance.new("UIGradient") fillGradient.Color=ColorSequence.new(GREEN_A,GREEN_B) fillGradient.Parent=fill
    for _,v in ipairs({track,fill}) do local c=Instance.new("UICorner") c.CornerRadius=UDim.new(1,0) c.Parent=v end
    local footer=label("Footer","Explore e encontre recompensas",148,23,11,Color3.fromRGB(183,206,184))
    local toggle=Instance.new("TextButton") toggle.Name="Collapse" toggle.Text="−" toggle.TextSize=20
    toggle.Font=Enum.Font.GothamBold toggle.TextColor3=Color3.fromRGB(244,218,158)
    toggle.AnchorPoint=Vector2.new(1,0) toggle.Position=UDim2.new(1,0,0,0) toggle.Size=UDim2.fromOffset(44,44)
    toggle.BackgroundTransparency=1 toggle.Parent=card
    local collapsed=false
    -- topo do card: logo abaixo da pílula de moedas do HUD principal (com folga de 12 px)
    local function topAnchor(compact)
        local hud=parent:FindFirstChild("HUDCortaGrama")
        local coins=hud and hud:FindFirstChild("Moedas")
        if coins and coins:IsA("GuiObject") and coins.Visible and coins.AbsoluteSize.Y>0 then
            -- AbsolutePosition desconta a barra do topo; mede relativo ao próprio ScreenGui do card
            return math.floor(coins.AbsolutePosition.Y+coins.AbsoluteSize.Y-gui.AbsolutePosition.Y+12)
        end
        return compact and 96 or 136
    end
    local function layout()
        local viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
        local compact=viewport.X<900 or viewport.Y<600
        local width=compact and 196 or 284
        card.Position=UDim2.new(1,-12,0,topAnchor(compact))
        card.Size=UDim2.fromOffset(width,collapsed and 44 or (compact and 116 or 184))
        for _,v in ipairs({title,objective,count,track,footer}) do v.Visible=not collapsed end
        footer.Visible=not collapsed and not compact
        title.Position=UDim2.fromOffset(16,compact and 28 or 33)
        title.Size=UDim2.new(1,-32,0,compact and 20 or 25) title.TextSize=compact and 15 or 18
        objective.Position=UDim2.fromOffset(16,compact and 49 or 63)
        objective.Size=UDim2.new(1,-32,0,compact and 28 or 38) objective.TextSize=compact and 11 or 13
        count.Position=UDim2.fromOffset(16,compact and 79 or 104) count.TextSize=compact and 11 or 12
        track.Position=UDim2.fromOffset(16,compact and 99 or 126)
        track.Size=UDim2.new(1,-32,0,compact and 8 or 10)
        toggle.Text=collapsed and "+" or "−"
    end
    toggle.Activated:Connect(function() collapsed=not collapsed layout() end)
    local cameraConnection
    local function cameraChanged()
        if cameraConnection then cameraConnection:Disconnect() end
        if workspace.CurrentCamera then cameraConnection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layout) end
        layout()
    end
    local workspaceConnection=workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(cameraChanged)
    -- o HUD de moedas pode ser criado depois; reposiciona quando ele aparecer ou mudar de tamanho
    local hudConnections={}
    local function watchHud(hud)
        if hud.Name~="HUDCortaGrama" then return end
        local coins=hud:WaitForChild("Moedas",10)
        if coins and coins:IsA("GuiObject") then
            table.insert(hudConnections,coins:GetPropertyChangedSignal("AbsolutePosition"):Connect(layout))
            table.insert(hudConnections,coins:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout))
            layout()
        end
    end
    local childConnection=parent.ChildAdded:Connect(function(child) task.spawn(watchHud,child) end)
    local existing=parent:FindFirstChild("HUDCortaGrama")
    if existing then task.spawn(watchHud,existing) end
    -- card some enquanto menu, loja ou árvore estão abertos (não fica por trás do painel)
    local player=Players.LocalPlayer
    local function refreshVisibility()
        gui.Enabled=not (player:GetAttribute("MenuJogadorAberto")==true or player:GetAttribute("LojaAberta")==true
            or player:GetAttribute("SkillTreeOpen")==true)
    end
    local attrConnections={}
    for _,name in ipairs({"MenuJogadorAberto","LojaAberta","SkillTreeOpen"}) do
        table.insert(attrConnections,player:GetAttributeChangedSignal(name):Connect(refreshVisibility))
    end
    refreshVisibility()
    gui.Destroying:Connect(function()
        workspaceConnection:Disconnect() childConnection:Disconnect()
        if cameraConnection then cameraConnection:Disconnect() end
        for _,c in ipairs(hudConnections) do c:Disconnect() end
        for _,c in ipairs(attrConnections) do c:Disconnect() end
    end)
    cameraChanged()
    return {gui=gui,card=card,category=category,title=title,objective=objective,count=count,countScale=countScale,
        fill=fill,fillGradient=fillGradient,footer=footer,entrance=offset}
end
function Panel.update(view,state,player)
    local forest=player:GetAttribute("RegiaoAtual")=="Floresta Esquecida"
    local cuts=forest and (player:GetAttribute("ForestGrassCut") or 0) or state.count
    local total=forest and 150 or 64
    local newTitle=forest and "Floresta Esquecida" or "Cuide do jardim"
    -- missão trocou: o card entra de novo, com um leve "pop"
    if view.lastTitle and view.lastTitle~=newTitle and view.entrance then
        view.entrance.Scale=.86
        tween(view.entrance,.32,{Scale=1},Enum.EasingStyle.Back)
    end
    view.title.Text=newTitle
    view.objective.Text=forest and "Abra caminho pelo matagal" or state.objective
    if UIS.TouchEnabled then view.objective.Text=view.objective.Text:gsub("Use F","Toque em CORTAR") end
    local done=cuts>=total
    view.count.Text=done and string.format("✓ %d / %d cortes",math.min(cuts,total),total) or string.format("%d / %d cortes",cuts,total)
    -- contador pulsa a cada avanço
    if view.lastCuts and cuts>view.lastCuts and view.countScale and view.lastTitle==newTitle then
        view.countScale.Scale=1.18
        tween(view.countScale,.22,{Scale=1},Enum.EasingStyle.Back)
    end
    view.fill:TweenSize(UDim2.fromScale(math.clamp(cuts/total,0,1),1),Enum.EasingDirection.Out,Enum.EasingStyle.Cubic,.22,true)
    if view.fillGradient then
        view.fillGradient.Color=done and ColorSequence.new(GOLD_A,GOLD_B) or ColorSequence.new(GREEN_A,GREEN_B)
    end
    view.count.TextColor3=done and Color3.fromRGB(255,222,120) or Color3.fromRGB(170,200,178)
    view.footer.Text=forest and string.format("%d segredos descobertos",player:GetAttribute("ForestSecrets") or 0) or "Corte, descubra e volte para vender"
    view.lastCuts,view.lastTitle=cuts,newTitle
end
return Panel
