-- Temporary client bridge for StudioTestService. Never ship this LocalScript.
local RS=game:GetService('ReplicatedStorage')
local remote=RS:WaitForChild('WorldMPTransport',60)
if not remote then return end
local p=game.Players.LocalPlayer
local Tween=game:GetService('RunService')
local controls=require(p.PlayerScripts:WaitForChild('PlayerModule')):GetControls()
remote.OnClientEvent:Connect(function(token,action,arg)
    local ok,result=xpcall(function()
        local forest=workspace.GameWorld.FlorestaEsquecida
        if action=='gate' then
            local c=forest.CriptaDasRaizes
            return c:GetAttribute('Open')==true and not c.TampaDeRaizes.CanCollide
        elseif action=='claim' then
            local prompt
            for _,v in ipairs(forest.SegredosRecompensas:GetDescendants())do
                if v:IsA('ProximityPrompt')and v:GetAttribute('ForestSecretId')==arg then prompt=v break end
            end
            assert(prompt,'Missing reward prompt')
            local target=prompt.Parent:IsA('Attachment') and prompt.Parent.WorldPosition or prompt.Parent.Position
            local camera=workspace.CurrentCamera
            camera.CameraType=Enum.CameraType.Scriptable
            camera.CFrame=CFrame.lookAt(p.Character.HumanoidRootPart.Position+Vector3.new(0,2,3),target)
            task.wait(.3)
            prompt:InputHoldBegin();task.wait(.35);prompt:InputHoldEnd();task.wait(.3)
            camera.CameraType=Enum.CameraType.Custom
            return true
        elseif action=='walk' then
            controls:Disable()
            local hum=p.Character:FindFirstChildOfClass('Humanoid')
            local root=p.Character.HumanoidRootPart
            local deadline=os.clock()+26
            local success,err=pcall(function()
                for _,point in ipairs(arg)do
                    hum:MoveTo(point)
                    repeat
                        Tween.Heartbeat:Wait()
                        assert(os.clock()<deadline,'Walk route timeout at '..tostring(root.Position)..' toward '..tostring(point))
                        assert(hum.Health>0,'Character died on route')
                    until (Vector2.new(root.Position.X-point.X,root.Position.Z-point.Z)).Magnitude<1.2
                    assert(math.abs(root.Position.Y-point.Y)<5,'Incorrect floor on route')
                end
            end)
            hum:Move(Vector3.zero,false);controls:Enable()
            if not success then error(err)end
            return {position=root.Position,health=hum.Health}
        end
        error('Unknown test action')
    end,debug.traceback)
    remote:FireServer(token,ok,result)
end)
remote:FireServer('ready',true)
