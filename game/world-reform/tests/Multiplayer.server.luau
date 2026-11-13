-- Temporary StudioTestService harness. Remove before saving the place.
local STS=game:GetService('StudioTestService')
local ok,args=pcall(function()return STS:GetTestArgs()end)
if not ok or type(args)~='table' or args.suite~='WorldReform' then return end
local config=require(game.ReplicatedStorage.Shared.GameConfig)
assert(not config.PersistenceEnabled,'Never run fixtures with persistence enabled')
local RS=game.ReplicatedStorage
local remote=Instance.new('RemoteEvent');remote.Name='WorldMPTransport';remote.Parent=RS
local ack,ready={},{}
remote.OnServerEvent:Connect(function(p,token,success,result)
    if token=='ready'then ready[p]=true else ack[p]={token=token,ok=success,result=result}end
end)
local ended=false
local function finish(value)if ended then return end;ended=true;STS:EndTest(value)end
task.delay(115,function()finish({ok=false,error='World MP watchdog timeout'})end)
local count=0
local function check(ok,msg)assert(ok,msg);count+=1;script:SetAttribute('Passed',count)end
local function await(fn,seconds,msg)
    local untilTime=os.clock()+seconds
    repeat if fn()then return end task.wait(.1)until os.clock()>untilTime
    error(msg)
end
local seq=0
local function request(p,action,arg)
    seq+=1;local token=tostring(seq);ack[p]=nil
    remote:FireClient(p,token,action,arg)
    await(function()return ack[p] and ack[p].token==token end,action=='walk' and 30 or 5,'Client timeout: '..action)
    assert(ack[p].ok,tostring(ack[p].result));return ack[p].result
end
local function root(p)return p.Character and p.Character:FindFirstChild('HumanoidRootPart')end
local function near(p,pos)p.Character:PivotTo(CFrame.new(pos+Vector3.new(0,3.2,0)));task.wait(.12)end
local passed,result=xpcall(function()
    await(function()
        local list=game.Players:GetPlayers()
        if #list<2 then return false end
        for _,p in ipairs(list)do if not ready[p]or not p:GetAttribute('ProfileReady')or not root(p)then return false end end
        return workspace.GameWorld:FindFirstChild('FlorestaEsquecida') and workspace.GameWorld.FlorestaEsquecida:GetAttribute('GrassCount')
    end,55,'Two clients/forest did not become ready')
    local players=game.Players:GetPlayers();local p1,p2=players[1],players[2]
    local forest=workspace.GameWorld.FlorestaEsquecida;local cave=forest.CriptaDasRaizes;local gate=cave.TampaDeRaizes
    check(#players==2,'Two real simulated clients')
    check(not workspace:FindFirstChild('ForestEditorPreview'),'No preview in multiplayer')
    check(#workspace.GameWorld.Plots:GetChildren()==4,'Four plots preserved')
    local cut=game.ServerStorage.GameServerGanchos.CortarPorLamina
    for _,p in ipairs(players)do p:SetAttribute('FerramentaAtiva','Unha');p:SetAttribute('Saco',0);p:SetAttribute('Moedas',100)end
    near(p2,Vector3.new(-192,.8,-430))
    cut:Invoke(p2,{Vector3.new(-192,.8,-430)},2,3,1,false,{'Alta'})
    check(not cave:GetAttribute('Open'),'Unrelated player cuts do not open the cave')
    local n=0
    for dx=-4.2,4.2,4.2 do for dz=-6,6,4 do
        n+=1;local p=n%2==0 and p2 or p1;local point=Vector3.new(-215+dx,.8,-452+dz)
        near(p,point)
        check(cut:Invoke(p,{point},.6,3,1,false,{'Alta'})==1,'Alternating player cut '..n)
        if n==11 then check(not cave:GetAttribute('Open'),'Twelve distinct clumps required')end
    end end
    task.wait(1.4)
    check(request(p1,'gate')and request(p2,'gate'),'Both clients observe the same opened passage')
    near(p1,Vector3.new(-215,.8,-440))
    local down={}
    for i=2,20,2 do table.insert(down,Vector3.new(-215,.65-i*1.2+3.1,-443-i*2))end
    table.insert(down,Vector3.new(-215,-21.1,-490));table.insert(down,Vector3.new(-215,-22.9,-504))
    local walked=request(p1,'walk',down)
    check(walked.health>0 and walked.position.Y< -20,'Player physically descends stairs and reaches chamber')
    local function reward(id)
        for _,v in ipairs(forest.SegredosRecompensas:GetDescendants())do if v:IsA('ProximityPrompt')and v:GetAttribute('ForestSecretId')==id then return v end end
        error('Missing reward '..id)
    end
    local chest=reward('cripta_raizes_bau');local relic=reward('cripta_raizes_reliquia')
    local function point(prompt)return prompt.Parent:IsA('Attachment') and prompt.Parent.WorldPosition or prompt.Parent.Position end
    local balances={}
    for _,p in ipairs(players)do balances[p]=p:GetAttribute('Moedas') end
    for _,p in ipairs(players)do
        near(p,point(chest)+Vector3.new(0,-2.5,4))
        request(p,'claim','cripta_raizes_bau');task.wait(.2)
        check(p:GetAttribute('Moedas')==balances[p]+110,'Each player receives own chest reward')
        request(p,'claim','cripta_raizes_bau');task.wait(.2)
        check(p:GetAttribute('Moedas')==balances[p]+110,'Repeated chest interaction cannot duplicate reward')
        near(p,point(relic)+Vector3.new(0,-2.5,4))
        request(p,'claim','cripta_raizes_reliquia');task.wait(.2)
        check(p:GetAttribute('Moedas')==balances[p]+145,'Each player receives own collectible relic reward')
        request(p,'claim','cripta_raizes_reliquia');task.wait(.2)
        check(p:GetAttribute('Moedas')==balances[p]+145,'Repeated relic interaction cannot duplicate reward')
    end
    near(p1,Vector3.new(-215,-26,-504))
    local up={Vector3.new(-215,-21.1,-490)}
    for i=20,0,-2 do table.insert(up,Vector3.new(-215,.65-i*1.2+3.1,-443-i*2))end
    table.insert(up,Vector3.new(-215,4,-438))
    local exited=request(p1,'walk',up)
    check(exited.health>0 and exited.position.Z> -440,'Player physically exits without teleporting')
    local old=p2.Character;old.Humanoid.Health=0
    await(function()return p2.Character and p2.Character~=old and root(p2)end,12,'Respawn failed')
    check(cave:GetAttribute('Open')and p2:GetAttribute('Moedas')==balances[p2]+145,'Respawn preserves opening and rewards')
    check(p1:GetAttribute('ForestClaimedSecrets')==p2:GetAttribute('ForestClaimedSecrets'),'Both players retain independent claim lists')
    return {ok=true,checks=count,players=#players,grass=forest:GetAttribute('GrassCount'),secrets=forest:GetAttribute('SecretsCount')}
end,debug.traceback)
if not passed then finish({ok=false,checks=count,error=tostring(result)})else finish(result)end
