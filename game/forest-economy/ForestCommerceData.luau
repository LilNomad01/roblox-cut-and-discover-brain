-- Pure profile extension and transaction rules; no Instances, network or yields.
local D={}
local function int(v,max)
    return type(v)=="number" and v==v and v>=0 and v<=max and v%1==0
end
local function flags(t,max)
    if type(t)~="table" then return false end
    local n=0
    for k,v in pairs(t) do
        n+=1
        if n>max or type(k)~="string" or #k>80 or v~=true then return false end
    end
    return true
end
function D.new()
    return {version=1,backpack=0,equipment={},kits=0,flowers=0,mushrooms=0,mapFragments=0,
        known={},collected={},claimed={},gnomeFound=false,gnomeQuest=false,gnomeSkin=false,caveHint=false,
        contract=0,cabinRepaired=false,artifacts=0}
end
function D.valid(s)
    if type(s)~="table" or s.version~=1 or not int(s.backpack,5) or not int(s.kits,99)
        or not int(s.flowers,999) or not int(s.mushrooms,999) or not int(s.mapFragments,999)
        or not int(s.contract,2) or not int(s.artifacts,1000) then return false end
    for _,k in ipairs({"gnomeFound","gnomeQuest","gnomeSkin","caveHint","cabinRepaired"}) do
        if type(s[k])~="boolean" then return false end
    end
    if not flags(s.known,4) or not flags(s.collected,64) or not flags(s.claimed,128) or not flags(s.equipment,3) then return false end
    for k in pairs(s.known) do if k~="Guto" and k~="Lia" and k~="Teca" and k~="Nilo" then return false end end
    for k in pairs(s.equipment) do if k~="lantern" and k~="compass" and k~="marker" then return false end end
    return true
end
function D.collect(s,id,kind)
    if s.collected[id] then return false end
    local field=({flower="flowers",mushroom="mushrooms",map="mapFragments"})[kind]
    if not field or s[field]>=999 then return false end
    s.collected[id]=true
    s[field]+=1
    return true
end
function D.transact(s,id,p,coins)
    if not p or not int(coins,1000000000) then return false,coins,"Produto inválido." end
    if p.vendor=="Nilo" and not s.gnomeFound then return false,coins,"Encontre Nilo primeiro." end
    if coins<p.price then return false,coins,"Moedas insuficientes." end
    local nextCoins=coins-p.price
    if p.kind=="backpack" then
        if s.backpack>=p.level then return false,coins,"Você já possui este nível ou um melhor." end
        s.backpack=p.level
    elseif p.kind=="equipment" then
        if s.equipment[id] then return false,coins,"Equipamento já comprado." end
        s.equipment[id]=true
    elseif p.kind=="kit" then
        if s.kits>=99 then return false,coins,"Você já carrega 99 kits." end
        s.kits+=1
    elseif p.kind=="flower" then
        if s.flowers<1 or coins>999999960 then return false,coins,"Traga uma flor do orvalho." end
        s.flowers-=1 nextCoins=coins+40
    elseif p.kind=="trade" then
        if s.mushrooms<3 or s.kits>=99 then return false,coins,"Traga 3 cogumelos e deixe espaço para um kit." end
        s.mushrooms-=3 s.kits+=1
    elseif p.kind=="contract" then
        if s.contract==2 then return false,coins,"Contrato concluído." end
        if s.contract==0 then s.contract=1 return true,coins,"Contrato aceito: entregue 3 flores do orvalho." end
        if s.flowers<3 or coins>999999880 then return false,coins,"A pesquisa precisa de 3 flores do orvalho." end
        s.flowers-=3 s.contract=2 s.cabinRepaired=true nextCoins=coins+120
    elseif p.kind=="gnomeQuest" then
        if s.gnomeQuest or s.artifacts<3 or coins>999999910 then return false,coins,"Registre 3 relíquias. Recompensa única." end
        s.gnomeQuest=true nextCoins=coins+90
    elseif p.kind=="skin" then
        if s.gnomeSkin or s.mushrooms<3 or s.mapFragments<1 then return false,coins,"Precisa de 3 cogumelos e 1 fragmento; aparência única." end
        s.mushrooms-=3 s.mapFragments-=1 s.gnomeSkin=true
    elseif p.kind=="hint" then
        if s.caveHint or s.mushrooms<1 then return false,coins,"Traga 1 cogumelo. Pista única." end
        s.mushrooms-=1 s.caveHint=true
        return true,nextCoins,"Nilo: siga as pedras azuis após o tronco oco. Corte o matagal diante das raízes na encosta."
    else
        return false,coins,"Produto indisponível."
    end
    return true,nextCoins,p.kind=="contract" and "Pesquisa concluída! +120 moedas. Caçamba restaurada." or "Troca concluída!"
end
return D
