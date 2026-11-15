local DataStoreService=game:GetService("DataStoreService")
local HttpService=game:GetService("HttpService")
local RunService=game:GetService("RunService")
local Config=require(game.ReplicatedStorage.Shared.GameConfig)
local Rules=require(script.Parent.Rules)
local ProfileData=require(script.Parent.ProfileData)
local Profiles={}
local store
local token=HttpService:GenerateGUID(false)
local sessions={}
local lease=180
local finais=0 -- [Claude 2026-11-11] salvamentos finais (saída do jogador) ainda gravando
local function retry(callback)
    local last
    for attempt=1,3 do
        local ok,value=pcall(callback)
        if ok then return true,value end
        last=value
        if attempt<3 then task.wait(2^(attempt-1)) end
    end
    warn("Falha no DataStore: "..tostring(last))
    return false
end
-- [Claude 2026-11-11] perfil só em memória (persistência desligada, ou Studio sem acesso às APIs)
local function temporario(player,motivo)
    if motivo then warn("[Perfil] "..motivo.." — perfil TEMPORÁRIO (não salva) para "..player.Name) end
    local p=Rules.newProfile() sessions[player]={profile=p,expires=math.huge,temporario=true}
    player:SetAttribute("PerfilTemporario",true)
    return p
end
-- [Claude 2026-11-11] no Studio o jogo usa um DataStore separado ("_Studio"), para testes não tocarem os dados dos jogadores
local function nomeStore()
    return Config.DataStoreName..(RunService:IsStudio() and "_Studio" or "")
end
function Profiles.load(player)
    if not Config.PersistenceEnabled then return temporario(player) end
    store=store or DataStoreService:GetDataStore(nomeStore())
    if RunService:IsStudio() then
        local ok,err=pcall(function() return store:GetAsync("__acesso_studio") end)
        if not ok and tostring(err):find("Studio access to APIs is not allowed",1,true) then
            return temporario(player,"Studio sem acesso às APIs (Game Settings > Security)")
        end
    end
    -- [Claude 2026-11-11] se outro servidor ainda segura a sessão (troca rápida de servidor), espera ~24 s antes de desistir
    local ok,data
    for tentativa=1,8 do
        if not player.Parent then return nil end
        ok,data=retry(function()
        return store:UpdateAsync(tostring(player.UserId),function(old)
            local now=os.time()
            if old~=nil and not Rules.validProfile(old) then return nil end
            if old and old.session and (type(old.session)~="table" or type(old.session.expires)~="number"
                or old.session.expires~=old.session.expires or (old.session.token~=token and old.session.expires>now and not RunService:IsStudio())) then return nil end -- [Claude 2026-11-11] no Studio (store "_Studio") a sessão de um teste anterior pode ser assumida
            local profile=old and ProfileData.migrate(old) or (old==nil and Rules.newProfile())
            if not profile then return nil end
            profile.session={token=token,expires=now+lease}
            return profile
        end)
        end)
        if ok and data and data.session and data.session.token==token then break end
        if tentativa<8 then task.wait(3) end
    end
    if not ok or not data or not data.session or data.session.token~=token then return nil end
    sessions[player]={profile=data,expires=data.session.expires}
    return data
end
function Profiles.get(player)
    local session=sessions[player]
    return session and session.profile
end
function Profiles.active(player)
    local session=sessions[player]
    return session~=nil and not session.closing and os.time()<session.expires-15
end
-- [Claude 2026-11-11] o BindToClose espera estes salvamentos: quando o servidor fecha, o jogador sai antes
-- (PlayerRemoving) e o salvamento final dele ainda está gravando; sem esperar, o servidor fechava no meio
function Profiles.pendentes()
    return finais
end
local salvar
function Profiles.save(player,release)
    if not release then return salvar(player,false) end
    finais+=1
    local ok,res=pcall(salvar,player,true)
    finais-=1
    if not ok then warn("[Perfil] erro no salvamento final: "..tostring(res)) return false end
    return res
end
salvar=function(player,release)
    local session=sessions[player]
    if not session then return true end
    if release then session.closing=true end
    while session.saving do task.wait(.05) end
    if sessions[player]~=session then return true end
    if not Config.PersistenceEnabled or session.temporario then
        if release then sessions[player]=nil end
        return true
    end
    session.saving=true
    local snapshot=ProfileData.capture(player,session.profile)
    snapshot.saveRevision=HttpService:GenerateGUID(false)
    snapshot.lastSaveTime=os.time()
    snapshot.session=nil
    if not release then snapshot.session={token=token,expires=os.time()+lease} end
    local ok,saved=retry(function()
        return store:UpdateAsync(tostring(player.UserId),function(old)
            if not old or not old.session or old.session.token~=token then return nil end
            if not Rules.validProfile(snapshot) then return nil end
            return snapshot
        end)
    end)
    session.saving=false
    if ok and saved and saved.saveRevision==snapshot.saveRevision then
        if release then sessions[player]=nil else session.expires=saved.session.expires end
        return true
    end
    if not release and player.Parent then player:Kick("Não foi possível salvar com segurança. Entre novamente em instantes.") end
    return false
end
return Profiles
