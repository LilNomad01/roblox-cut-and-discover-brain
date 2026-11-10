local SkillRules=require(script.Parent.SkillRules)
local Config=require(game.ReplicatedStorage.ConfigJogo)
local ForestData=require(script.Parent.ForestCommerceData)
local Data={}
local function integer(v,max)
    return type(v)=="number" and v==v and v>=0 and v<=max and v%1==0
end
function Data.copy(value)
    if type(value)~="table" then return value end
    local copy={}
    for key,item in pairs(value) do copy[key]=Data.copy(item) end
    return copy
end
function Data.defaultEconomy(coins,mowerLevel)
    local ids={"Basico","Eletrico","Turbo"}
    local level=math.clamp(mowerLevel or 1,1,3)
    local owned={}
    for i=1,level do table.insert(owned,ids[i]) end
    return {Moedas=coins or 0,Nivel=1,XP=0,Comprados=table.concat(owned,","),Cortador=ids[level]}
end
function Data.validEconomy(d)
    if type(d)~="table" or not integer(d.Moedas,1000000000) or not integer(d.Nivel,10000) or d.Nivel<1
        or not integer(d.XP,1000000000) or d.XP>=Config.XPParaNivel(d.Nivel)
        or type(d.Comprados)~="string" or #d.Comprados>128 or type(d.Cortador)~="string" then return false end
    local owned={}
    for id in d.Comprados:gmatch("[^,]+") do
        if not Config.ItemPorId(id) or owned[id] then return false end
        owned[id]=true
    end
    return owned.Basico==true and owned[d.Cortador]==true
end
function Data.validExtensions(profile)
    return Data.validEconomy(profile.Economy) and SkillRules.valid(profile.SkillData)
        and (profile.ForestEconomy==nil or ForestData.valid(profile.ForestEconomy))
end
function Data.migrate(profile)
    local p=Data.copy(profile)
    if p.schemaVersion==1 then
        p.Economy=p.Economy or Data.defaultEconomy(p.coins,p.mowerLevel)
        p.SkillData=p.SkillData or SkillRules.new()
        p.schemaVersion=2
    end
    if p.schemaVersion~=2 or not Data.validExtensions(p) then return nil end
    return p
end
function Data.capture(player,profile)
    local snapshot=Data.copy(profile)
    if player:GetAttribute("ProfileReady") then
        for _,key in ipairs({"Moedas","Nivel","XP","Comprados","Cortador"}) do
            snapshot.Economy[key]=player:GetAttribute(key)
        end
    end
    return snapshot
end
return Data

