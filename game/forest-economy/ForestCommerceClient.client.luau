-- Cartoon merchant UI, field map and local feedback. Rewards remain server-owned.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local GuiService=game:GetService("GuiService")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer
local remote=RS:WaitForChild("ForestCommerce")
local Catalog=require(RS.Shared.ForestCommerceCatalog)
local gui=Instance.new("ScreenGui") gui.Name="ForestCommerceUI" gui.ResetOnSpawn=false
-- Default inset respects the Roblox top bar and device safe area.
gui.DisplayOrder=85 gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.Parent=player:WaitForChild("PlayerGui")
local closeEvent=Instance.new("BindableEvent") closeEvent.Name="Close" closeEvent.Parent=gui
local function new(class,props,parent)
    local v=Instance.new(class)
    for k,value in pairs(props) do v[k]=value end
    v.Parent=parent
    return v
end
local border=Color3.fromRGB(40,48,50)
local function round(v,r)
    new("UICorner",{CornerRadius=UDim.new(0,r or 14)},v)
    new("UIStroke",{Color=border,Thickness=3,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},v)
end
local function text(parent,value,size,pos,box)
    return new("TextLabel",{Text=value,Font=Enum.Font.FredokaOne,TextSize=size,TextColor3=border,
        BackgroundTransparency=1,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,
        Position=pos,Size=box},parent)
end
local function button(parent,value,color,pos,size,callback)
    local b=new("TextButton",{Text=value,Font=Enum.Font.FredokaOne,TextSize=16,TextColor3=border,
        BackgroundColor3=color,Position=pos,Size=size,AutoButtonColor=true,Selectable=true},parent)
    round(b,10) b.Activated:Connect(callback)
    return b
end
local dim=new("TextButton",{Text="",BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.48,Size=UDim2.fromScale(1,1),Visible=false,AutoButtonColor=false},gui)
local window=new("Frame",{Name="Window",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(.94,0,.86,0),BackgroundColor3=Color3.fromRGB(255,246,220)},dim)
round(window,20)
new("UISizeConstraint",{MaxSize=Vector2.new(690,650)},window)
local header=new("Frame",{Size=UDim2.new(1,0,0,88),BackgroundColor3=Color3.fromRGB(115,209,124)},window) round(header,18)
local title=text(header,"",21,UDim2.fromOffset(16,8),UDim2.new(1,-80,0,32))
local subtitle=text(header,"",13,UDim2.fromOffset(16,41),UDim2.new(1,-32,0,40))
local status=text(window,"",14,UDim2.fromOffset(16,94),UDim2.new(1,-32,0,45))
local list=new("ScrollingFrame",{Name="Products",Position=UDim2.fromOffset(12,145),Size=UDim2.new(1,-24,1,-159),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=6,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},window)
new("UIListLayout",{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder},list)
new("UIPadding",{PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,8),PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,8)},list)
local state={backpack=0,equipment={},kits=0,flowers=0,mushrooms=0,mapFragments=0,known={},collected={}}
local vendorId,mapOpen,opening=nil,false,0
local inventoryOpen=false
local previousSelection
local function close(silent)
    opening+=1
    local wasVisible=dim.Visible
    dim.Visible=false vendorId=nil mapOpen=false inventoryOpen=false
    player:SetAttribute("ForestShopOpen",false)
    if wasVisible then player:SetAttribute("LojaAberta",false) end
    if previousSelection and previousSelection.Parent then GuiService.SelectedObject=previousSelection end
    previousSelection=nil
    if not silent then remote:FireServer("close") end
end
closeEvent.Event:Connect(function() close() end)
dim.Activated:Connect(function() close() end)
button(header,"X",Color3.fromRGB(255,133,116),UDim2.new(1,-58,0,10),UDim2.fromOffset(46,46),function() close() end)
local function clearList()
    for _,v in ipairs(list:GetChildren()) do if v:IsA("GuiObject") then v:Destroy() end end
end
local function owned(id,p)
    if p.kind=="backpack" then return (state.backpack or 0)>=p.level end
    if p.kind=="equipment" then return state.equipment[id] end
    return (id=="contract" and state.contract==2) or (id=="gnomeQuest" and state.gnomeQuest)
        or (id=="gnomeSkin" and state.gnomeSkin) or (id=="caveHint" and state.caveHint)
end
local function render()
    if not vendorId then return end
    clearList()
    local vendor=Catalog.Vendors[vendorId]
    header.BackgroundColor3=Color3.fromRGB(table.unpack(vendor.color))
    title.Text=vendor.icon.." "..vendor.name
    subtitle.Text=vendor.dialogue
    status.Text=string.format("%s moedas • Saco %s / %s\n🌼 %d  🍄 %d  🗺 %d  🔎 %d%s",tostring(player:GetAttribute("Moedas") or 0),tostring(player:GetAttribute("Saco") or 0),tostring(player:GetAttribute("SacoMax") or 50),state.flowers,state.mushrooms,state.mapFragments,state.kits,state.temporary and " • Progresso desta sessão" or "")
    local first
    for i,id in ipairs(Catalog.Order[vendorId]) do
        local p=Catalog.Products[id]
        local card=new("Frame",{Size=UDim2.new(1,-4,0,151),BackgroundColor3=Color3.fromRGB(255,252,237),LayoutOrder=i},list) round(card,13)
        text(card,p.icon,30,UDim2.fromOffset(10,8),UDim2.fromOffset(42,42))
        text(card,p.name,17,UDim2.fromOffset(58,8),UDim2.new(1,-70,0,38))
        local effect=p.effect
        if p.kind=="backpack" then
            local item=require(RS.ConfigJogo).ItemPorId(player:GetAttribute("Cortador") or "Basico")
            effect=effect.." Capacidade com seu cortador: "..Catalog.capacity(item.Saco,p.level).."."
        end
        if id=="contract" then effect..=" ("..math.min(state.flowers,3).."/3 flores; "..((state.contract or 0)==0 and "não iniciado" or "em pesquisa")..")" end
        if id=="gnomeQuest" then effect..=" ("..math.min(state.artifacts or 0,3).."/3 relíquias)" end
        text(card,effect,13,UDim2.fromOffset(12,48),UDim2.new(1,-24,0,48))
        local bought=owned(id,p)
        local label=bought and "COMPRADO" or p.price>0 and ("COMPRAR • "..p.price) or id=="contract" and (state.contract==0 and "ACEITAR CONTRATO" or "ENTREGAR FLORES") or "TROCAR / RECEBER"
        if p.kind=="backpack" and state.backpack==p.level then label="EQUIPADA" end
        if p.kind=="equipment" and bought then label="NO INVENTÁRIO" end
        local b
        b=button(card,label,bought and Color3.fromRGB(209,217,202) or Color3.fromRGB(table.unpack(vendor.accent)),UDim2.new(0,12,1,-51),UDim2.new(1,-24,0,44),function()
            if bought then return end
            b.Interactable=false b.Text="AGUARDE..."
            remote:FireServer("buy",id)
            task.delay(2,function() if b.Parent then b.Interactable=true b.Text=label end end)
        end)
        b.Interactable=not bought
        if not first and not bought then first=b end
    end
    if UIS.GamepadEnabled and first then GuiService.SelectedObject=first end
end
local function mapRender()
    clearList()
    title.Text="📍 Mapa de campo" subtitle.Text="Somente locais visitados. Equipe o marcador para mudar sua marca."
    status.Text="● Você   ◆ Seu marcador   ■ Comerciantes conhecidos"
    header.BackgroundColor3=Color3.fromRGB(118,184,220)
    local map=new("Frame",{Name="FieldMap",Size=UDim2.new(1,-5,0,370),BackgroundColor3=Color3.fromRGB(206,225,164)},list) round(map,12)
    local function point(pos,label,color)
        local x=math.clamp((pos.X+300)/600,.08,.92)
        local y=math.clamp((-pos.Z-177)/648,.08,.92)
        local dot=text(map,label,13,UDim2.fromScale(x,y),UDim2.fromOffset(100,42))
        dot.AnchorPoint=Vector2.new(.5,.5) dot.TextColor3=color dot.TextXAlignment=Enum.TextXAlignment.Center
    end
    for id,pos in pairs(state.known or {}) do point(pos,"■ "..id,border) end
    if state.marker then point(state.marker,"◆ Marca",Color3.fromRGB(145,63,182)) end
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then point(root.Position,"● Você",Color3.fromRGB(31,96,156)) end
end
local function inventoryRender()
    clearList()
    title.Text="🎒 Equipamentos de exploração"
    subtitle.Text="Lanterna e bússola: equipe ou guarde. Marcador e kit: use aqui."
    status.Text="Seus equipamentos comprados • Kits disponíveis: "..state.kits
    header.BackgroundColor3=Color3.fromRGB(118,184,220)
    local first
    for i,id in ipairs({"lantern","compass","marker","kit"}) do
        if state.equipment[id] or (id=="kit" and state.kits>0) then
            local product=Catalog.Products[id]
            local card=new("Frame",{Size=UDim2.new(1,-4,0,140),BackgroundColor3=Color3.fromRGB(255,252,237),LayoutOrder=i},list)
            round(card,13)
            text(card,product.icon.." "..product.name,18,UDim2.fromOffset(12,8),UDim2.new(1,-24,0,28))
            text(card,product.effect,13,UDim2.fromOffset(12,37),UDim2.new(1,-24,0,42))
            local label=(id=="marker" or id=="kit") and "USAR" or "EQUIPAR / GUARDAR"
            local b=button(card,label,Color3.fromRGB(255,211,92),UDim2.new(0,12,1,-51),UDim2.new(1,-24,0,44),function()
                close()
                remote:FireServer("equip",id)
            end)
            first=first or b
        end
    end
    if UIS.GamepadEnabled and first then GuiService.SelectedObject=first end
end
local function show(id,isMap,isInventory)
    opening+=1 local token=opening
    local hud=player.PlayerGui:FindFirstChild("HUDCortaGrama")
    local closeShop=hud and hud:FindFirstChild("FecharLoja")
    if closeShop then closeShop:Fire() end
    local controller=require(player.PlayerScripts.PlayerMenu.PlayerMenuController)
    controller.fechar()
    -- Existing close tweens finish before a different shop becomes visible.
    task.delay(.3,function()
        if token~=opening then return end
        vendorId,mapOpen=id,isMap==true
        inventoryOpen=isInventory==true
        previousSelection=GuiService.SelectedObject
        player:SetAttribute("ForestShopOpen",true) player:SetAttribute("LojaAberta",true)
        dim.Visible=true
        if mapOpen then mapRender() elseif inventoryOpen then inventoryRender() else render() end
    end)
end
local inventoryButton=button(gui,"🎒 Explorar",Color3.fromRGB(255,221,112),UDim2.new(1,-154,.45,0),UDim2.fromOffset(142,42),function()
    if dim.Visible and inventoryOpen then close() else show(nil,false,true) end
end)
inventoryButton.Visible=false
local function updateInventoryButton()
    inventoryButton.Visible=(next(state.equipment)~=nil or state.kits>0)
        and not dim.Visible and not player:GetAttribute("MenuJogadorAberto") and not player:GetAttribute("LojaAberta")
end
dim:GetPropertyChangedSignal("Visible"):Connect(updateInventoryButton)
for _,attribute in ipairs({"MenuJogadorAberto","LojaAberta"}) do
    player:GetAttributeChangedSignal(attribute):Connect(updateInventoryButton)
end
for _,attr in ipairs({"Moedas","Saco","SacoMax"}) do player:GetAttributeChangedSignal(attr):Connect(function() if vendorId and dim.Visible then render() end end) end
for _,attr in ipairs({"MenuJogadorAberto","SkillTreeOpen"}) do
    player:GetAttributeChangedSignal(attr):Connect(function() if player:GetAttribute(attr) and dim.Visible then close() end end)
end
UIS.InputBegan:Connect(function(input)
    if dim.Visible and (input.KeyCode==Enum.KeyCode.Escape or input.KeyCode==Enum.KeyCode.ButtonB) then close() end
end)
player.CharacterRemoving:Connect(function() close() end)
local compass=text(gui,"",15,UDim2.fromScale(.5,.17),UDim2.new(.8,0,0,42))
compass.AnchorPoint=Vector2.new(.5,0) compass.BackgroundColor3=Color3.fromRGB(252,232,171) compass.BackgroundTransparency=.1
compass.TextXAlignment=Enum.TextXAlignment.Center compass.Visible=false round(compass,10)
local compassElapsed=0
RunService.Heartbeat:Connect(function(dt)
    compassElapsed+=dt if compassElapsed<.15 then return end compassElapsed=0
    local char=player.Character local root=char and char:FindFirstChild("HumanoidRootPart")
    local tool=char and char:FindFirstChildWhichIsA("Tool")
    compass.Visible=root~=nil and tool~=nil and tool:GetAttribute("ForestEquipment")=="compass" and not dim.Visible
    if not compass.Visible then return end
    local nearest,distance
    for id,pos in pairs(state.known or {}) do
        local d=(pos-root.Position).Magnitude
        if not distance or d<distance then nearest,distance=id,d end
    end
    if not nearest then compass.Text="🧭 Visite um comerciante para registrar um destino." return end
    local dir=root.CFrame:VectorToObjectSpace(state.known[nearest]-root.Position)
    local heading=math.abs(dir.X)>math.abs(dir.Z) and (dir.X>0 and "À DIREITA" or "À ESQUERDA") or (dir.Z<0 and "À FRENTE" or "ATRÁS")
    compass.Text=string.format("🧭 %s • %s • %d studs",nearest,heading,math.floor(distance))
end)
local function applyPersonalWorld()
    local forest=workspace:FindFirstChild("GameWorld") and workspace.GameWorld:FindFirstChild("FlorestaEsquecida")
    local world=forest and forest:FindFirstChild("ComercioDaFloresta")
    if not world then return end
    for _,model in ipairs(world:GetChildren()) do
        local id=model:GetAttribute("ForestResourceId")
        if id and state.collected[id] then
            for _,v in ipairs(model:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier=1 elseif v:IsA("ProximityPrompt") then v.Enabled=false end
            end
        end
        if model:GetAttribute("ForestBinId")=="Teca" then
            for _,v in ipairs(model:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    v.ActionText=state.cabinRepaired and "Vender grama" or "Depósito danificado"
                    v.ObjectText=state.cabinRepaired and "Depósito restaurado" or "Conclua a pesquisa de Teca"
                elseif v:IsA("BasePart") and v:GetAttribute("ForestRepairDecoration") then v.LocalTransparencyModifier=state.cabinRepaired and 1 or 0 end
            end
            local board=model:FindFirstChild("PlacaVenda") local surface=board and board:FindFirstChildWhichIsA("SurfaceGui")
            local label=surface and surface:FindFirstChildWhichIsA("TextLabel")
            if label then label.Text=state.cabinRepaired and "VENDA DE GRAMA" or "DEPÓSITO DANIFICADO" end
        end
    end
end
remote.OnClientEvent:Connect(function(action,data)
    if action=="state" then state=data updateInventoryButton() applyPersonalWorld() if dim.Visible then if mapOpen then mapRender() elseif inventoryOpen then inventoryRender() else render() end end
    elseif action=="open" then if Catalog.Vendors[data] then show(data,false) end
    elseif action=="map" then show(nil,true)
    elseif action=="result" then if vendorId then render() end
    elseif action=="clues" then
        for _,part in ipairs(data) do
            if part and part.Parent then
                local h=Instance.new("Highlight") h.Name="ForestKitClue" h.Adornee=part h.DepthMode=Enum.HighlightDepthMode.Occluded
                h.FillColor=Color3.fromRGB(255,204,84) h.FillTransparency=.55 h.Parent=part Debris:AddItem(h,12)
            end
        end
    elseif action=="sale" then
        local popup=text(gui,string.format("🌿 %s de grama  +%s moedas",data.amount,data.gain),20,UDim2.fromScale(.5,.6),UDim2.new(.9,0,0,62))
        popup.AnchorPoint=Vector2.new(.5,.5) popup.TextXAlignment=Enum.TextXAlignment.Center popup.TextStrokeTransparency=.3
        popup.TextColor3=Color3.fromRGB(255,228,117) popup.TextStrokeColor3=border
        TweenService:Create(popup,TweenInfo.new(.45,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),{Position=UDim2.fromScale(.5,.49)}):Play()
        task.delay(1.3,function() TweenService:Create(popup,TweenInfo.new(.3),{TextTransparency=1,TextStrokeTransparency=1}):Play() end) Debris:AddItem(popup,1.7)
        local bin=data.bin local floor=bin and bin.PrimaryPart
        if floor then
            local base=floor.CFrame
            local tw=TweenService:Create(floor,TweenInfo.new(.2,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out,0,true),{CFrame=base*CFrame.new(0,-.12,0)}) tw:Play()
        end
        -- EfeitoVenda already supplies the existing coin sound and particles.
    end
end)
-- Listen for readiness even when the forest takes longer to initialize.
local synced=false
local function requestSync()
    if not synced and player:GetAttribute("ProfileReady") then
        synced=true remote:FireServer("sync")
    end
end
player:GetAttributeChangedSignal("ProfileReady"):Connect(requestSync)
requestSync()
workspace.DescendantAdded:Connect(function(v)
    if v.Name=="ComercioDaFloresta" then task.delay(1,applyPersonalWorld) end
end)

-- A light local idle on two details; no physics or reward state changes.
local animatedGnomes=setmetatable({}, {__mode="k"})
local function gnomeIdle(model)
    if not model:IsA("Model") or model:GetAttribute("ForestMerchantId")~="Nilo" or animatedGnomes[model] then return end
    animatedGnomes[model]=true
    for _,name in ipairs({"Barba","BolsaDeReliquias"}) do
        local detail=model:FindFirstChild(name)
        if detail and detail:IsA("BasePart") then
            TweenService:Create(detail,TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
                {CFrame=detail.CFrame*CFrame.new(0,.035,0)*CFrame.Angles(0,0,.018)}):Play()
        end
    end
end
workspace.DescendantAdded:Connect(function(v)
    if v:IsA("Model") and (v.Name=="Nilo_GnomoColecionador" or v:GetAttribute("ForestNPC")) then task.defer(gnomeIdle,v) end
end)
local world=workspace:FindFirstChild("GameWorld")
local forest=world and world:FindFirstChild("FlorestaEsquecida")
if forest then for _,v in ipairs(forest:GetDescendants()) do gnomeIdle(v) end end
