local Data=require("../ForestCommerceData")
local Catalog=require("../ForestCommerceCatalog")
local assertions=0
local function check(condition,message)
    assert(condition,message)
    assertions+=1
end
local function buy(state,id,coins)
    return Data.transact(state,id,Catalog.Products[id],coins)
end

local a,b=Data.new(),Data.new()
check(Data.valid(a),"Default profile must validate")
check(Data.collect(a,"flower_1","flower"),"First collection must succeed")
check(not Data.collect(a,"flower_1","flower"),"Collection must be idempotent")
check(a.flowers==1 and b.flowers==0,"Players must not share resources")
check(not Data.collect(a,"unknown","coins"),"Reject unknown resource kinds")

local coins=100000
for level,pack in ipairs(Catalog.Backpacks) do
    local ok,nextCoins=buy(a,"backpack"..level,coins)
    check(ok and a.backpack==level and nextCoins==coins-pack.price,"Backpack purchase must charge the catalog price")
    coins=nextCoins
    check(Catalog.capacity(50,a.backpack)==50+pack.bonus,"Only best backpack bonus applies")
    check(Catalog.capacity(100,a.backpack)-Catalog.capacity(50,a.backpack)==50,"Changing equipment must preserve the same additive bonus")
    local replay,replayCoins=buy(a,"backpack"..level,coins)
    check(not replay and replayCoins==coins,"Duplicate purchase must not charge")
end
local ok,nextCoins=buy(b,"backpack1",249)
check(not ok and nextCoins==249 and b.backpack==0,"Insufficient funds must leave state unchanged")
check(not buy(a,"backpack1",coins),"Lower backpack must not replace the best level")

ok,coins=buy(a,"lantern",coins)
check(ok and a.equipment.lantern,"Equipment must unlock once")
check(not buy(a,"lantern",coins),"Reject duplicate equipment")
check(not b.equipment.lantern,"Equipment ownership must be per player")
check(not buy(a,"gnomeQuest",coins),"Gnome rewards require discovery")
a.gnomeFound=true
check(not buy(a,"gnomeQuest",coins),"Gnome quest requires artifacts")
a.artifacts=3
ok,nextCoins=buy(a,"gnomeQuest",coins)
check(ok and nextCoins==coins+90 and a.gnomeQuest,"Gnome quest must grant exact reward")
check(not buy(a,"gnomeQuest",nextCoins),"Gnome quest reward cannot repeat")

ok,coins=buy(b,"contract",0)
check(ok and coins==0 and b.contract==1,"Accepting a contract must not pay")
check(not buy(b,"contract",coins),"Contract requires three flowers")
for i=1,3 do Data.collect(b,"flower_"..i,"flower") end
ok,coins=buy(b,"contract",coins)
check(ok and coins==120 and b.flowers==0 and b.cabinRepaired,"Contract must consume resources and repair cabin bin")
check(not buy(b,"contract",coins),"Contract reward cannot repeat")

a.mushrooms=6 a.mapFragments=1
ok,nextCoins=buy(a,"gnomeSkin",coins)
check(ok and a.gnomeSkin and a.mushrooms==3 and a.mapFragments==0 and nextCoins==coins,"Skin exchange must consume exact materials")
check(not buy(a,"gnomeSkin",coins),"Cosmetic exchange cannot repeat")
ok,nextCoins=buy(a,"tradeKit",coins)
check(ok and a.mushrooms==0 and a.kits==1 and nextCoins==coins,"Botanical exchange must grant a usable kit")
a.kits=99
check(not buy(a,"kit",coins),"Kit limit must not overcharge")
a.flowers=1
check(not buy(a,"sellFlower",1000000000) and a.flowers==1,"Reject currency overflow without consuming flowers")
check(not buy(a,"backpack1",0/0),"Reject NaN currency")
check(not buy(a,"backpack1",-1),"Reject negative currency")
check(not buy(a,"backpack1",1.5),"Reject fractional currency")
check(Data.valid(a) and Data.valid(b),"All successful transitions must preserve profile validity")
local invalid=Data.new() invalid.backpack=6
check(not Data.valid(invalid),"Reject out-of-range backpack")
invalid=Data.new() invalid.equipment.admin=true
check(not Data.valid(invalid),"Reject unknown equipment")
invalid=Data.new() invalid.known.secretCoordinates=true
check(not Data.valid(invalid),"Reject unknown navigation targets")
print("Forest commerce: "..assertions.." assertions passed")
