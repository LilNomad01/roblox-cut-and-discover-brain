-- Run as a temporary server Script in a fresh Studio Play session.
-- This test refuses persistence-enabled games. Test balances exist only in Play.
local RS=game:GetService("ReplicatedStorage")
local P=require(game.ServerScriptService.CorteEDescubra.Profiles)
local S=require(game.ServerScriptService.CorteEDescubra.ForestCommerceService)
local E=require(game.ServerScriptService.Economia)
local Data=require(game.ServerScriptService.CorteEDescubra.ForestCommerceData)
local Catalog=require(RS.Shared.ForestCommerceCatalog)
local p=game.Players:GetPlayers()[1]
assert(not require(RS.Shared.GameConfig).PersistenceEnabled,"Run only with persistence disabled")
assert(p and p:GetAttribute("ProfileReady") and P.active(p),"Wait for player readiness")
local testRemote=Instance.new("RemoteEvent") testRemote.Name="ForestAcceptanceTransport" testRemote.Parent=RS
local ack
local connection=testRemote.OnServerEvent:Connect(function(who,token) if who==p then ack=token end end)
local count=0
local function check(ok,message)
    assert(ok,message)
    count+=1
    script:SetAttribute("Passed",count)
end
local function waitFor(token)
    local deadline=os.clock()+5
    repeat task.wait(.05) until ack==token or os.clock()>deadline
    assert(ack==token,"Client bridge timeout: "..token)
end
local sequence=0
local function request(...)
    sequence+=1
    local token=tostring(sequence)
    ack=nil testRemote:FireClient(p,token,...)
    waitFor(token)
end
local world=workspace.GameWorld.FlorestaEsquecida.ComercioDaFloresta
local function near(model)
    p.Character:PivotTo(CFrame.new(model.PrimaryPart.Position+Vector3.new(0,3,3)))
    task.wait(.1)
end
local function shop(id)
    near(world[id.."_Acampamento"])
    S.open(p,id)
end
local ok,err=xpcall(function()
    waitFor("ready")
    local d=P.get(p).ForestEconomy
    -- Keep the same profile table referenced by existing respawn callbacks.
    table.clear(d)
    for k,v in pairs(Data.new()) do d[k]=v end
    p:SetAttribute("MochilaNivel",0) E.RecalcularCapacidade(p)
    p:SetAttribute("Moedas",100000) p:SetAttribute("Saco",0)
    shop("Guto")
    request("buy","backpack1")
    check(p:GetAttribute("Moedas")==99750 and p:GetAttribute("SacoMax")==75,"Backpack price/capacity")
    request("buy","backpack1")
    check(p:GetAttribute("Moedas")==99750 and d.backpack==1,"Duplicate backpack must not charge")
    request("buy","backpack2",0)
    check(d.backpack==1,"Reject extra client price argument")
    p:SetAttribute("Moedas",0)
    request("buy","backpack2")
    check(d.backpack==1 and p:GetAttribute("Moedas")==0,"Reject insufficient funds")
    p:SetAttribute("Moedas",99750)
    request("buy","backpack2")
    check(d.backpack==2 and p:GetAttribute("Moedas")==98850 and p:GetAttribute("SacoMax")==125,"Backpack upgrade")
    E.RecalcularCapacidade(p) E.RecalcularCapacidade(p)
    check(p:GetAttribute("SacoMax")==125,"No capacity accumulation")
    E.Comprar(p,"Eletrico")
    check(p:GetAttribute("SacoMax")==175,"Equipment base plus backpack")
    p:SetAttribute("Saco",150) E.Comprar(p,"Basico")
    check(p:GetAttribute("Saco")==150 and p:GetAttribute("SacoMax")==125,"Preserve overfilled grass after downgrade")
    check(E.EncherSaco(p,10)==0 and p:GetAttribute("Saco")==150,"Block further collection while overfilled")
    p.Character:PivotTo(CFrame.new(0,5,0))
    check(S.sell(p,"Guto")==0 and p:GetAttribute("Saco")==150,"Reject remote-distance sale")
    request("buy","backpack3")
    check(d.backpack==2,"Reject remote-distance purchase")
    near(world.CacambaFloresta_Guto)
    local coins,xp=p:GetAttribute("Moedas"),p:GetAttribute("XP")
    check(S.sell(p,"Guto")==300,"Entrance quote equals village price")
    check(S.sell(p,"Guto")==0 and p:GetAttribute("Moedas")==coins+300,"Sale cannot repeat")
    check(p:GetAttribute("XP")==xp and p:GetAttribute("Saco")==0,"Sale grants no extra XP")
    near(world.CacambaFloresta_Lia) p:SetAttribute("Saco",10)
    check(S.sell(p,"Lia")==20,"Central quote equals village price")
    near(world.CacambaFloresta_Teca) p:SetAttribute("Saco",10)
    check(S.sell(p,"Teca")==0 and p:GetAttribute("Saco")==10,"Cabin bin locked before contract")
    for i=1,3 do
        local id="forest_resource_"..i
        near(world["Coletavel_"..id])
        check(S.collect(p,id),"Collect authored flower "..i)
        check(not S.collect(p,id),"Do not duplicate flower "..i)
    end
    shop("Teca") coins=p:GetAttribute("Moedas")
    request("buy","contract")
    check(d.contract==1 and p:GetAttribute("Moedas")==coins,"Accept contract without reward")
    request("buy","contract")
    check(d.contract==2 and d.flowers==0 and d.cabinRepaired and p:GetAttribute("Moedas")==coins+120,"Contract resources and reward")
    request("buy","contract")
    check(p:GetAttribute("Moedas")==coins+120,"Contract reward cannot repeat")
    near(world.CacambaFloresta_Teca)
    check(S.sell(p,"Teca")==20,"Repaired cabin bin sells")
    d.mushrooms=3 shop("Teca") request("buy","tradeKit")
    check(d.mushrooms==0 and d.kits==1,"Botanical material exchange")
    shop("Lia")
    for _,id in ipairs({"lantern","compass","marker"}) do
        coins=p:GetAttribute("Moedas") request("buy",id)
        check(d.equipment[id] and p:GetAttribute("Moedas")==coins-Catalog.Products[id].price,"Exploration equipment purchase: "..id)
    end
    request("equip","lantern")
    check(p.Character.HumanoidRootPart:FindFirstChild("ForestLantern")~=nil,"Lantern produces real light")
    request("equip","lantern")
    check(p.Character.HumanoidRootPart:FindFirstChild("ForestLantern")==nil,"Lantern switches off on unequip")
    request("equip","compass")
    check(p.Character:FindFirstChild("Bússola simples")~=nil,"Compass equips through custom UI route")
    request("equip","marker")
    check(p.Character:FindFirstChild("Marcador de trilha")~=nil,"Marker is usable")
    request("equip","kit")
    check(d.kits==0,"Kit consumes exactly one unit")
    request("equip","kit")
    check(d.kits==0,"Consumed kit cannot repeat")
    local forest=workspace.GameWorld.FlorestaEsquecida
    local gnome=forest:FindFirstChild("Nilo_GnomoColecionador",true)
    check(gnome~=nil,"Reuse existing gnome")
    local prompt=gnome:FindFirstChildWhichIsA("ProximityPrompt",true)
    check(prompt and not prompt.Enabled,"Gnome remains hidden before clearing")
    S.discoverGnome(p,gnome.PrimaryPart.Position,false)
    check(not d.gnomeFound,"Hidden gnome cannot unlock commerce")
    local scenery=require(game.ServerScriptService.CorteEDescubra.ForestScenery)
    local gpos=gnome.PrimaryPart.Position
    local ground=Vector3.new(gpos.X,scenery.height(gpos.X,gpos.Z),gpos.Z)
    p.Character:PivotTo(CFrame.new(ground+Vector3.new(0,3,0)))
    p:SetAttribute("Saco",0)
    local cut=game.ServerStorage.GameServerGanchos.CortarPorLamina
    for x=-8,8,4 do
        for z=-8,8,4 do
            cut:Invoke(p,{ground+Vector3.new(x,0,z)},3,3,16,false,{"Alta"})
            if prompt.Enabled then break end
        end
        if prompt.Enabled then break end
    end
    check(prompt.Enabled,"Existing legitimate blade-cut route reveals gnome")
    S.discoverGnome(p,ground,true)
    check(d.gnomeFound and d.known.Nilo,"Discovered gnome opens exclusive shop")
    local gainedXP=p:GetAttribute("XP")
    S.discoverGnome(p,ground,true)
    check(p:GetAttribute("XP")==gainedXP,"Discovery XP cannot repeat")
    d.artifacts=3 coins=p:GetAttribute("Moedas")
    request("buy","gnomeQuest")
    check(d.gnomeQuest and p:GetAttribute("ForestGnomeTrade") and p:GetAttribute("Moedas")==coins+90,"Gnome quest reward")
    request("buy","gnomeQuest")
    check(p:GetAttribute("Moedas")==coins+90,"Gnome quest cannot repeat")
    d.mushrooms=3 d.mapFragments=1
    request("buy","gnomeSkin")
    check(d.gnomeSkin and d.mushrooms==0 and d.mapFragments==0,"Exclusive cosmetic exchange")
    check(Data.valid(d),"Final profile is valid")
    local copy=require(game.ServerScriptService.CorteEDescubra.ProfileData).capture(p,P.get(p))
    check(copy.ForestEconomy.backpack==2 and copy.ForestEconomy.gnomeFound,"Existing profile captures commerce extension")
    check(#workspace.GameWorld.Plots:GetChildren()==4,"Preserve four village plots")
    script:SetAttribute("Result","PASS "..count.." checks")
end,debug.traceback)
connection:Disconnect()
local client=p.PlayerGui:FindFirstChild("ForestAcceptanceClient")
if client then client:Destroy() end
testRemote:Destroy()
if not ok then script:SetAttribute("Result","FAIL "..tostring(err)) warn(err) end
