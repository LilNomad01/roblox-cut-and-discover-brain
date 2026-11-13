-- One lightweight local animation for the decorative windmill; no gameplay state.
local Run=game:GetService('RunService')
local root=workspace:WaitForChild('GameWorld'):WaitForChild('LobbyGardenReform')
local rotor=root:WaitForChild('RecantoDaHorta'):WaitForChild('MoinhoDaHorta'):WaitForChild('Rotor')
local base=rotor:GetPivot();local elapsed,step=0,0
local connection
connection=Run.Heartbeat:Connect(function(dt)
    if not rotor.Parent then connection:Disconnect();return end
    elapsed+=dt;step+=dt
    if step<1/24 then return end
    step=0;rotor:PivotTo(base*CFrame.Angles(0,0,elapsed*.18))
end)
