-- Temporary normal server Script, in a fresh Play with persistence disabled.
local p=game.Players:GetPlayers()[1]
local config=require(game.ReplicatedStorage.Shared.GameConfig)
assert(not config.PersistenceEnabled,'Test only with persistence disabled')
local forest=workspace.GameWorld.FlorestaEsquecida
local cave=forest.CriptaDasRaizes
local gate=cave.TampaDeRaizes
local cut=game.ServerStorage.GameServerGanchos.CortarPorLamina
local passed=0
local function check(ok,msg)assert(ok,msg);passed+=1;script:SetAttribute('Passed',passed)end
local function move(pos)p.Character:PivotTo(CFrame.new(pos+Vector3.new(0,3.3,0)));task.wait(.08)end
local ok,err=xpcall(function()
    check(cave:GetAttribute('RequiredClumps')==12,'Exactly twelve authored clumps')
    check(gate.CanCollide and not cave:GetAttribute('Open'),'Entrance starts sealed')
    check(not workspace:FindFirstChild('ForestEditorPreview'),'Editor preview removed in Play')
    p:SetAttribute('FerramentaAtiva','Unha');p:SetAttribute('Saco',0)
    move(Vector3.new(-190,.8,-430))
    cut:Invoke(p,{Vector3.new(-190,.8,-430)},2,3,1,false,{'Alta'})
    check(not cave:GetAttribute('Open') and gate.CanCollide,'Unrelated cutting never reveals entrance')
    local far=cut:Invoke(p,{Vector3.new(-215,.8,-452)},1,3,1,false,{'Alta'})
    check(far==0,'Reject blade samples outside player range')
    local total=0
    for dx=-4.2,4.2,4.2 do for dz=-6,6,4 do
        local point=Vector3.new(-215+dx,.8,-452+dz)
        move(point)
        local n=cut:Invoke(p,{point},.6,3,1,false,{'Alta'})
        check(n==1,'Required clump accepts legitimate blade trace '..(total+1))
        total+=1
        if total==11 then check(not cave:GetAttribute('Open') and gate.CanCollide,'Eleven clumps cannot open the passage')end
    end end
    task.wait(1.15)
    check(cave:GetAttribute('Open') and not gate.CanCollide and gate.Transparency==1,'Last clump opens shared passage after reveal timeline')
    local sack,xp,coins=p:GetAttribute('Saco'),p:GetAttribute('XP'),p:GetAttribute('Moedas')
    local point=Vector3.new(-210.8,.8,-446);move(point)
    cut:Invoke(p,{point},.6,3,1,false,{'Alta'})
    check(p:GetAttribute('Saco')==sack and p:GetAttribute('XP')==xp and p:GetAttribute('Moedas')==coins,'Finishing cut never duplicates rewards')
    local q=RaycastParams.new();q.FilterType=Enum.RaycastFilterType.Include;q.FilterDescendantsInstances={workspace.Terrain,cave}
    for _,step in ipairs(cave:GetChildren())do
        if step.Name=='DegrauNatural'then
            local top=step.Position+Vector3.yAxis*(step.Size.Y*.5+.15)
            local ceiling=workspace:Raycast(top+Vector3.yAxis*.2,Vector3.yAxis*5.5,q)
            check(not ceiling,'Safe standing headroom above stair '..step.Position.Z)
        end
    end
    local floor=cave.PisoDaCamara
    check(floor.Position.Y< -25,'Chamber truly below surface')
    local roof=workspace:Raycast(Vector3.new(-215,-18,-511),Vector3.yAxis*40,q)
    check(roof and roof.Position.Y<0,'Chamber has real overburden, not an open surface clearing')
    local chest
    for _,v in ipairs(forest.SegredosRecompensas:GetDescendants())do if v:IsA('ProximityPrompt') and v:GetAttribute('ForestSecretId')=='cripta_raizes_bau'then chest=v end end
    check(chest and chest.Enabled,'Reward prompt unlocked by the authored cuts')
    local chestPoint=chest.Parent:IsA("Attachment") and chest.Parent.WorldPosition or chest.Parent.Position
    move(chestPoint)
    script:SetAttribute('ChestPoint',chestPoint)
    script:SetAttribute('CoinsBeforeChest',p:GetAttribute('Moedas'))
    script:SetAttribute('XPBeforeChest',p:GetAttribute('XP'))
    script:SetAttribute('State','AwaitingRealInteraction')
    script:SetAttribute('Result','PASS '..passed..' checks; await E')
end,debug.traceback)
if not ok then script:SetAttribute('Result','FAIL '..tostring(err));warn(err)end
