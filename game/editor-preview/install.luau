-- Run once from the Studio Command Bar in Edit mode.
-- Reuses the installed forest builders; never starts GameServer or player services.
local RunService = game:GetService("RunService")
assert(not RunService:IsRunning(), "Stop Play before installing the editor preview")
local folder = game.ServerScriptService.CorteEDescubra
local server = folder.GameServer
local source = server.Source
assert(not folder.ForestScenery.Source:find("workspace.GameWorld.FlorestaEsquecida.ArvoresModulares",1,true),
    "Install the ForestScenery integration update before building the editor preview")
local function section(first, last)
    local a = assert(source:find(first, 1, true), "Missing source marker: " .. first)
    local b = assert(source:find(last, a + #first, true), "Missing source marker: " .. last)
    return source:sub(a, b - 1)
end
local cleanup = [==[-- Editor scenery is visual only. Remove it before any runtime builders start.
local editorPreview = workspace:FindFirstChild("ForestEditorPreview")
if editorPreview and editorPreview:GetAttribute("EditorOnlyForestPreview") == true then
    editorPreview:Destroy()
end
]==]
local prelude = [==[-- Generated from installed GameServer helpers by game/editor-preview/install.luau.
-- Edit-only visual snapshot. Gameplay remains owned by the original runtime builders.
local M = {}
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local PREVIEW = "ForestEditorPreview"
local BACKUP = "ForestEditorPreviewBackup_Reform20"
function M.build()
    assert(not RunService:IsRunning(), "Editor preview cannot run during Play")
    local existing = workspace:FindFirstChild(PREVIEW)
    if existing then
        assert(existing:GetAttribute("EditorOnlyForestPreview") == true, "Preview name belongs to another object")
        assert(existing:GetAttribute("PreviewState") == "Ready", "Previous build incomplete; restore before rebuilding")
        return existing
    end
    local backup = ServerStorage:FindFirstChild(BACKUP)
    if not backup then
        backup = Instance.new("Folder")
        backup.Name = BACKUP
        backup.Parent = ServerStorage
        local region = Region3int16.new(Vector3int16.new(-76,-16,-210),Vector3int16.new(76,42,-20))
        local terrain = workspace.Terrain:CopyRegion(region)
        terrain.Name = "OriginalTerrain"
        terrain.Parent = backup
        backup:SetAttribute("TerrainCorner", Vector3.new(-76,-16,-210))
        local world = workspace:FindFirstChild("GameWorld")
        local decor = world and world:FindFirstChild("Decoracao")
        local trees = decor and decor:FindFirstChild("Arvores")
        if trees then
            for _,tree in ipairs(trees:GetChildren()) do
                if tree:IsA("Model") then
                    local saved = Instance.new("ObjectValue")
                    saved.Name = "OriginalTree"
                    saved.Value = tree
                    saved:SetAttribute("Pivot",tree:GetPivot())
                    saved:SetAttribute("GroundedAfterTerrain",tree:GetAttribute("GroundedAfterTerrain"))
                    saved.Parent = backup
                end
            end
        end
        backup:SetAttribute("Ready",true)
    end
    assert(backup:GetAttribute("Ready") == true, "Terrain backup incomplete; no terrain changes allowed")
    local world = Instance.new("Model")
    world.Name = PREVIEW
    world:SetAttribute("EditorOnlyForestPreview",true)
    world:SetAttribute("PreviewState","Building")
    world.Parent = workspace
    local sceneryModule = script.Parent.ForestScenery:Clone()
    sceneryModule.Parent = script.Parent
    local Scenery = require(sceneryModule)
    sceneryModule:Destroy()
    local Art = require(script.Parent.WorldArt)
    local Signs = require(script.Parent.SignKit)
    local GrassStyle=require(game.ReplicatedStorage.Shared.ForestVisualStyle)
    local worldModule=script.Parent.ForestCommerceWorld:Clone()
    worldModule.Parent=script.Parent
    local World = require(worldModule)
    local Catalog = require(game.ReplicatedStorage.Shared.ForestCommerceCatalog)
    Scenery.commerceReserved = World.reserved
    local Commerce = {reserved=World.reserved}
    function Commerce.build(root,scenery)
        local function noop() end
        return World.build(root,scenery,Catalog,noop,noop,noop)
    end
    local FOREST = {grass={},buckets={},secrets={},cellSize=9}
    local forestRng = Random.new(20261108)
]==]
local grass = section("local function forestBuck(", "local forestStream=")
grass ..= "local forestDistant={}\nlocal function forestGrassSet(rec,stage) rec.stage=stage end\n"
grass ..= section("local function forestGrassSpawn(", "local function forestChest(")
local secret = [==[
local function forestAddSecret(parent,info)
    local placementY=info.groundY or forestGroundY
    local point = Vector3.new(info.x,info.groundY or Scenery.height(info.x,info.z),info.z)
    local model
    if info.kind == "gnome" then
        model = Scenery.gnome(parent,point)
        model.Name = "Nilo_GnomoColecionador"
    elseif info.kind == "chest" then
        model = forestChest(parent,info.x,info.z,info.rarity)
        if info.groundY then model:PivotTo(model:GetPivot()+Vector3.new(0,placementY-forestGroundY,0)) end
    else
        model = Instance.new("Model") model.Name="Artefato_"..info.id model.Parent=parent
        forestPart(model,"Pedestal",Vector3.new(3.3,2.3,3.3),CFrame.new(info.x,placementY+1.2,info.z),fColors.stone,Enum.Material.Slate,false)
        forestPart(model,"Simbolo",Vector3.new(1.2,2.2,.5),CFrame.new(info.x,placementY+3,info.z),Color3.fromRGB(103,198,172),Enum.Material.Neon,false)
    end
    if not info.visible then
        for _,item in ipairs(model:GetDescendants()) do
            if item:IsA("BasePart") then item.Transparency=1 end
        end
    end
    local record={model=model,id=info.id,point=point}
    table.insert(FOREST.secrets,record)
    return record
end
]==]
local suffix = [==[
    forestBuild()
    worldModule:Destroy()
    -- Reuse the existing distant grass mesh coverage for an affordable editor overview.
    -- Nearby animated grass and real cut stages still stream only during Play.
    local library = game.ReplicatedStorage.GramaAssets.GrassPack
    local coverage = Instance.new("Folder") coverage.Name="Matagal_Previa" coverage.Parent=world
    local cells,blades = 0,0
    for _,g in pairs(forestDistant) do
        local template = library:FindFirstChild("Grass_"..g.variant.."_TALL")
        if template then
            local chunk=Instance.new("Model") chunk.Name="Cobertura"
            for i=1,4 do
                local offset=GrassStyle.offset(g.x,g.z,i)
                if bit32.band(g.distantMask or 15,2^(i-1)) == 0 then continue end
                local p=template:Clone()
                p.Name="MatoPrevia"
                p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=false
                p.Size=Vector3.new(template.Size.X*1.95,template.Size.Y*(g.heightFactor or 1),template.Size.Z*1.95)
                local blend=math.clamp(.5+math.noise(g.x*.021,g.z*.021)*1.4,0,1)
                p.Color=Color3.fromRGB(105,172,66):Lerp(Color3.fromRGB(155,202,89),blend)
                p.CFrame=CFrame.new(g.x+offset.X,g.groundY-.08+p.Size.Y/2,g.z+offset.Z)*CFrame.Angles(0,g.rotation+i*1.7,0)
                p.Parent=chunk blades+=1
            end
            chunk.Parent=coverage cells+=1
            if cells%25==0 then task.wait() end
        end
    end
    for _,g in ipairs(FOREST.grass) do
        if g.important then
            local template=library:FindFirstChild("Grass_"..g.variant.."_TALL")
            local p=template:Clone();p.Name="MatoDaEntrada";p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
            p.Size=Vector3.new(template.Size.X*1.28,template.Size.Y,template.Size.Z*1.28)*g.scale
            p.CFrame=CFrame.new(g.x,g.groundY+p.Size.Y/2-.08,g.z)*CFrame.Angles(0,g.rotation,0);p.Parent=coverage;blades+=1
        end
    end
    for _,item in ipairs(world:GetDescendants()) do
        if item:IsA("ProximityPrompt") then item.Enabled=false
        elseif item:IsA("BaseScript") then item.Enabled=false
        elseif item:IsA("BasePart") then item.Anchored=true item.CanTouch=false end
    end
    world:SetAttribute("PreviewGrassMeshes",blades)
    world:SetAttribute("PreviewState","Ready")
    world:SetAttribute("PreviewNote","Visual do editor; grama simplificada. Regenerado no Play; edicoes nesta previa nao mudam os builders.")
    return world
end
function M.restore()
    assert(not RunService:IsRunning(), "Stop Play before restoring terrain")
    local backup=assert(ServerStorage:FindFirstChild(BACKUP),"No editor preview backup")
    assert(backup:GetAttribute("Ready") == true,"Incomplete backup")
    local corner=backup:GetAttribute("TerrainCorner")
    workspace.Terrain:PasteRegion(backup.OriginalTerrain,Vector3int16.new(corner.X,corner.Y,corner.Z),true)
    for _,saved in ipairs(backup:GetChildren()) do
        if saved:IsA("ObjectValue") and saved.Value then
            saved.Value:PivotTo(saved:GetAttribute("Pivot"))
            saved.Value:SetAttribute("GroundedAfterTerrain",saved:GetAttribute("GroundedAfterTerrain"))
        end
    end
    local preview=workspace:FindFirstChild(PREVIEW)
    if preview and preview:GetAttribute("EditorOnlyForestPreview") == true then preview:Destroy() end
end
return M
]==]
local generated = prelude
    .. section("local function forestPart(", "local function forestBuck(")
    .. grass
    .. section("local function forestChest(", "local function forestAddSecret(")
    .. secret
    .. section("local function forestBuild()", "-- Clients request proximity snapshots;")
    .. suffix
local module=folder:FindFirstChild("ForestEditorPreview")
assert(not module, "Editor preview module already installed; inspect before replacing")
local backup=Instance.new("Script") backup.Name="GameServerBeforeEditorPreview_Reform20" backup.Enabled=false
backup.Source=source backup.Parent=game.ServerStorage
module=Instance.new("ModuleScript") module.Name="ForestEditorPreview" module.Source=generated module.Parent=folder
if not source:find(cleanup,1,true) then server.Source=cleanup..source end
return {module=module:GetFullName(),sourceLength=#generated,installed=true}
