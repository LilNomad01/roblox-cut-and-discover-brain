-- One continuous height field replaces the old rectangular preservation seams.
-- Edit-only operation; backups precede every terrain footprint expansion.
local G={}
local peaks={
    {-435,-170,100,178,145,.25}, {-445,43,126,158,168,-.5},
    {-365,290,112,181,140,.6}, {-208,420,145,171,145,-.18},
    {-24,465,110,180,125,.2}, {155,415,162,160,175,.5},
    {350,326,122,176,137,-.5}, {450,110,146,147,190,.2},
    {432,-160,102,150,175,-.3}, {432,-390,82,145,172,.4},
    {-430,-420,77,143,167,.4}, {-204,-973,131,158,123,.1},
    {21,-991,168,190,123,0}, {255,-969,122,155,140,-.18},
}
local function smooth(t)t=math.clamp(t,0,1);return t*t*t*(t*(t*6-15)+10)end
local function peakHeight(x,z)
    local h=0
    for i,p in ipairs(peaks)do
        local dx,dz=x-p[1],z-p[2]
        local u=dx*math.cos(p[6])+dz*math.sin(p[6])
        local v=-dx*math.sin(p[6])+dz*math.cos(p[6])
        local core=math.max(0,1-math.abs(u/p[4])^1.35-math.abs(v/p[5])^1.7)
        local broken=1+.07*math.noise(x*.024,z*.024,i)+.035*math.sin(u*.065+i)
        local candidate=p[3]*core^1.38*broken
        -- Smooth maxima avoid knife-thin seams where neighboring ridges meet.
        local k=8;local blend=math.max(k-math.abs(h-candidate),0)/k
        h=math.max(h,candidate)+blend*blend*k*.25
    end
    return math.max(0,h-2)
end
function G.height(x,z)
    local radius=Vector2.new(x,z).Magnitude
    local village=smooth((radius-116)/85)
    local forestFront=1-smooth((z+140)/80)
    local forestBack=smooth((z+920)/105)
    local edge=251+math.noise(z*.009,7)*19
    local forestSide=1-smooth((math.abs(x)-edge)/115)
    local forestCore=forestFront*forestBack*forestSide
    local forestRise=smooth((-z-86)/110)
    local base=.8*forestRise
    local meadow=(2.8+math.noise(x*.012,z*.012)*3.2)*village*(1-forestCore)
    local mountains=peakHeight(x,z)*village*(1-forestCore)
    local h=base+meadow+mountains
    -- The four plots, road junction and spawns all sit on one flat, solid grade.
    if radius<116 then h=0 end
    -- Preserve the existing farm's authored floor without a rectangular terrain seam.
    local farm=Vector2.new((x-10)/140,(z-270)/87).Magnitude
    local farmBlend=1-smooth((farm-.9)/.6)
    h=h*(1-farmBlend)+2.8*farmBlend
    -- The existing test garden meets the meadow on a shallow organic apron.
    local test=Vector2.new(x,z-118).Magnitude
    local testBlend=(1-smooth((test-17)/22))*smooth((z-85)/17)
    h=h*(1-testBlend)+2.05*testBlend
    return h
end
local paths={
    {{0,82},{0,101},{0,118},{8,151},{-6,180},{0,206}},
    {{-82,0},{-103,-11},{-119,-35},{-131,-62},{-117,-94},{-81,-120},{-36,-133},{0,-140}},
}
local function onMeadowPath(x,z)
    local p=Vector2.new(x,z)
    for _,path in ipairs(paths)do for i=1,#path-1 do
        local a,b=Vector2.new(table.unpack(path[i])),Vector2.new(table.unpack(path[i+1]))
        local d=b-a;local t=math.clamp((p-a):Dot(d)/d:Dot(d),0,1)
        if (p-a-d*t).Magnitude<2.5+math.noise(x*.15,z*.15)*.6 then return true end
    end end
    return false
end
local function surface(x,z,h,slope)
    local edge=285+math.noise(z*.013,17)*23
    local forest=smooth((-z-105)/145)*(1-smooth((math.abs(x)-edge)/70))
    local exposure=math.noise(x*.014,z*.014,31)+math.noise(x*.031,z*.031,14)*.3
    local rocky=h>102+exposure*24 or (h>42 and slope>.68 and exposure>.12)
    if rocky then return Enum.Material.Rock end
    if onMeadowPath(x,z) then return Enum.Material.Ground end
    -- The entrance path is painted into the terrain, with irregular soft shoulders.
    if z<-83 and z>-228 then
        local center=math.sin((z+86)*.035)*4
        local width=4.4+math.noise(x*.15,z*.12)*.9
        if math.abs(x-center)<width then return Enum.Material.Ground end
    end
    return forest+math.noise(x*.037,z*.037)*.24>.68 and Enum.Material.LeafyGrass or Enum.Material.Grass
end
function G.build()
    assert(not game:GetService('RunService'):IsRunning(),'Geography is an Edit operation')
    local backup=assert(game.ServerStorage:FindFirstChild('WorldReformV19Backup'),'V19 backup required')
    assert(backup:GetAttribute('State')=='Ready' and backup:GetAttribute('ExtendedNorthBackup')==true,'Complete bounded terrain backup first')
    if workspace:GetAttribute('WorldGeographyRevision')==21 then return end
    local terrain=workspace.Terrain;local count=0
    workspace:SetAttribute('WorldGeographyBuildState','Building')
    -- At least 64 studs of solid support prevent thin-terrain LOD gaps.
    for x=-640,576,64 do for z=-1152,576,64 do
        local region=Region3.new(Vector3.new(x,-64,z),Vector3.new(x+64,184,z+64))
        local mats,occ=terrain:ReadVoxels(region,4)
        for ix=1,16 do for iz=1,16 do
            local px,pz=x+(ix-.5)*4,z+(iz-.5)*4
            local h=G.height(px,pz)
            local slope=math.max(math.abs(G.height(px+4,pz)-h),math.abs(G.height(px,pz+4)-h))/4
            local top=surface(px,pz,h,slope)
            for iy=1,62 do
                local y=-64+(iy-.5)*4
                local fill=math.clamp((h-y)/4,0,1)
                occ[ix][iy][iz]=fill
                mats[ix][iy][iz]=fill<=0 and Enum.Material.Air or top
            end
        end end
        terrain:WriteVoxels(region,4,mats,occ);count+=1
        workspace:SetAttribute('WorldGeographyBuildTiles',count);task.wait()
    end end
    workspace:SetAttribute('WorldGeographyRevision',21)
    workspace:SetAttribute('WorldGeographyBuildState','Ready')
    backup:SetAttribute('ReformedTiles',count)
end
function G.finish()
    local Art=require(script.Parent.WorldArt)
    local f=workspace:FindFirstChild("WorldLandscape")
    if not f then
        f=Instance.new("Folder");f.Name="WorldLandscape";f:SetAttribute("WorldRevision",21);f.Parent=workspace
        for i,p in ipairs(peaks)do
            for j=1,6 do
                local x=p[1]+math.cos(j*2.4+i)*p[4]*.38
                local z=p[2]+math.sin(j*2.4+i)*p[5]*.35
                Art.rock(f,Vector3.new(x,G.height(x,z)-2.2,z),2+j%3*.5,j*.7+i)
            end
            task.wait()
        end
    end
    for _,rock in ipairs(f:GetChildren())do
        if rock:IsA("Model")then
            local cf,size=rock:GetBoundingBox()
            local hit=workspace:Raycast(Vector3.new(cf.X,230,cf.Z),Vector3.new(0,-300,0),groundQuery)
            if hit then rock:PivotTo(rock:GetPivot()+Vector3.new(0,hit.Position.Y-(cf.Y-size.Y/2)-1,0))end
        end
    end
    local q=RaycastParams.new();q.FilterType=Enum.RaycastFilterType.Include;q.FilterDescendantsInstances={workspace.Terrain}
    local meadow=f:FindFirstChild("PradariaIntegrada")
    if not meadow then
        meadow=Instance.new("Folder");meadow.Name="PradariaIntegrada";meadow.Parent=f
        local points={{-97,-18},{-111,-41},{-140,-57},{-126,-83},{-99,-114},{-62,-126},{-33,-143},
            {14,100},{-18,139},{20,160},{-23,180},{16,199},{112,20},{128,-31},{117,-78},{-114,47}}
        local scenery=require(script.Parent.ForestScenery)
        for i,p in ipairs(points)do
            local hit=workspace:Raycast(Vector3.new(p[1],200,p[2]),Vector3.new(0,-300,0),groundQuery)
            if hit then
                Art.plantPatch(meadow,hit.Position,.55+i%3*.12,i)
                if i%4==0 then scenery.hero(meadow,i%4+1,p[1]+7,p[2]+5,.32,i*.6)end
            end
        end
    end
    if not f:FindFirstChild("BordasDaVila")then
        local beds=Instance.new("Folder");beds.Name="BordasDaVila";beds.Parent=f
        local positions={}
        for _,side in ipairs({-1,1})do
            for i,v in ipairs({-64,-43,-24,24,43,64})do
                table.insert(positions,Vector2.new(side*(79+math.sin(i*2)*1.3),v))
                table.insert(positions,Vector2.new(v,side*(79+math.cos(i*2)*1.3)))
            end
            for _,v in ipairs({-60,-38,38,60})do table.insert(positions,Vector2.new(side*14,v))end
        end
        for i,p in ipairs(positions)do
            local hit=workspace:Raycast(Vector3.new(p.X,100,p.Y),Vector3.new(0,-160,0),groundQuery)
            if hit then Art.flowerPatch(beds,hit.Position,.42+i%3*.08)end
        end
    end
    local backup=game.ServerStorage.WorldReformV19Backup
    local savedProps=backup:FindFirstChild("ContinuousGradeProps")
    if not savedProps then savedProps=Instance.new("Folder");savedProps.Name="ContinuousGradeProps";savedProps.Parent=backup end
    local function settle(object)
        local cf,size
        if object:IsA("Model")then cf,size=object:GetBoundingBox()
        elseif object:IsA("BasePart")then cf,size=object.CFrame,object.Size
        else return end
        local hit=workspace:Raycast(Vector3.new(cf.X,230,cf.Z),Vector3.new(0,-300,0),groundQuery)
        if not hit then return end
        if not object:GetAttribute("ContinuousGradeGrounded")then
            local saved=Instance.new("ObjectValue");saved.Value=object;saved:SetAttribute("Pivot",object:GetPivot());saved.Parent=savedProps
        end
        object:PivotTo(object:GetPivot()+Vector3.new(0,hit.Position.Y-(cf.Y-size.Y/2)-.05,0))
        object:SetAttribute("ContinuousGradeGrounded",true)
    end
    for _,name in ipairs({"Flores","Juncos"})do
        local f=workspace.GameWorld.Decoracao:FindFirstChild(name)
        if f then for _,v in ipairs(f:GetChildren())do settle(v)end end
    end
    for _,v in ipairs(workspace.GameWorld.Tufos:GetChildren())do settle(v)end
    for _,v in ipairs(workspace:GetChildren())do if v:IsA("Model")and v.Name=="Arvore"then settle(v)end end
    for _,tree in ipairs(workspace.GameWorld.Decoracao.Arvores:GetChildren())do
        if tree:IsA("Model")then
            local cf,size=tree:GetBoundingBox();local p=cf.Position
            local hit=workspace:Raycast(Vector3.new(p.X,250,p.Z),Vector3.new(0,-350,0),q)
            if hit then tree:PivotTo(tree:GetPivot()+Vector3.new(0,hit.Position.Y-(p.Y-size.Y/2)-.08,0))end
        end
    end
end
return G
