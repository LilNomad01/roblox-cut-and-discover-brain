-- Edit-only geographic snapshot. Contains public terrain and landmarks, never secret state.
assert(not game:GetService('RunService'):IsRunning(),'Bake the map in Edit mode')
local nx,nz=97,136
local minX,maxX,minZ,maxZ=-640,640,-1152,640
local query=RaycastParams.new();query.FilterType=Enum.RaycastFilterType.Include
query.FilterDescendantsInstances={workspace.Terrain};query.IgnoreWater=false
local rows={}
for iz=0,nz-1 do
    local row={};local z=minZ+(maxZ-minZ)*iz/(nz-1)
    for ix=0,nx-1 do
        local x=minX+(maxX-minX)*ix/(nx-1)
        local hit=workspace:Raycast(Vector3.new(x,500,z),Vector3.new(0,-900,0),query)
        local h=hit and hit.Position.Y or -4
        local kind='g'
        if not hit or hit.Material==Enum.Material.Water then kind='w'
        elseif hit.Material==Enum.Material.LeafyGrass then kind='l'
        elseif hit.Material==Enum.Material.Rock or hit.Material==Enum.Material.Slate then kind='r'
        elseif hit.Material==Enum.Material.Ground or hit.Material==Enum.Material.Mud then kind='d'end
        table.insert(row,string.format('%02x%s',math.clamp(math.floor(h+.5)+32,0,255),kind))
    end
    table.insert(rows,'[=['..table.concat(row)..']=],')
    if iz%10==0 then task.wait()end
end
local scenery=require(game.ServerScriptService.CorteEDescubra.ForestScenery)
local river={}
for z=-748,-340,12 do
    local x=scenery.riverX(z)
    table.insert(river,string.format('{%.2f,%d}',x,z))
end
local source=string.format([[-- Baked from the current Terrain; geographic information only.
return {
version=1,nx=%d,nz=%d,minX=%d,maxX=%d,minZ=%d,maxZ=%d,
rows={
%s
},
places={
{name='Vila',code='V',x=0,z=0},
{name='Fazenda',code='F',x=0,z=270},
{name='Entrada da floresta',code='B',x=0,z=-165},
{name='Estufa',code='E',x=126,z=39},
{name='Moinho',code='M',x=-137,z=-31},
{name='Casa do jardim',code='J',x=-147,z=112},
},
routes={
{points={{-85,0},{85,0}}},
{points={{-106,82},{-119,99},{-134,112}}},
{points={{-110,32},{-132,37},{-151,43}}},
{points={{0,-106},{47,-106},{82,-101},{101,-82},{106,-47},{106,0},{106,47},{101,82},{82,101},{39,106},{30,139},{0,149},{-30,139},{-39,106},{-82,101},{-101,82},{-106,47},{-106,0},{-106,-47},{-101,-82},{-82,-101},{-47,-106},{0,-106}}},
{points={{85,0},{102,6},{108,24},{118,39}}},
{points={{85,-1},{101,-19},{112,-48},{120,-78},{130,-92},{126,-105}}},
{points={{-85,0},{-104,-7},{-119,-19},{-131,-28}}},
{points={{-104,-7},{-109,13},{-110,32}}},
{points={{0,85},{24,95},{52,100},{76,104},{94,105}}},
{points={{0,85},{19,100},{28,120},{25,147},{9,172},{0,204}}},
{points={{0,85},{0,-83},{-6,-111},{-12,-135},{0,-165},{3,-206}}},
{points={%s},water=true},
}
}
]],nx,nz,minX,maxX,minZ,maxZ,table.concat(rows,'\n'),table.concat(river,','))
local shared=game.ReplicatedStorage:WaitForChild('Shared')
local previous=shared:FindFirstChild('WorldMapData')
if previous then
    previous.Name='WorldMapData_BeforeBake'
    previous.Parent=game.ServerStorage:WaitForChild('WorldNavigationBackup_20261113')
end
local module=Instance.new('ModuleScript');module.Name='WorldMapData';module.Source=source;module.Parent=shared
return {samples=nx*nz,sourceBytes=#source}
