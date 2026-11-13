-- Local biome grading and a few water accents; never modifies server Lighting.
local Players=game:GetService('Players')
local Tween=game:GetService('TweenService')
local Run=game:GetService('RunService')
local p=Players.LocalPlayer
local effect=Instance.new('ColorCorrectionEffect');effect.Name='ForestBiomeLocal';effect.Parent=game.Lighting
local root=workspace:WaitForChild('GameWorld'):WaitForChild('FlorestaEsquecida')
local gate
local function feedback()
    local hrp=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
    if not gate or not hrp or (hrp.Position-gate.Position).Magnitude>80 then return end
    local gui=Instance.new('ScreenGui');gui.Name='ForestDiscovery';gui.ResetOnSpawn=false;gui.Parent=p.PlayerGui
    local t=Instance.new('TextLabel');t.AnchorPoint=Vector2.new(.5,.5);t.Position=UDim2.fromScale(.5,.21);t.Size=UDim2.fromOffset(0,0)
    t.BackgroundColor3=Color3.fromRGB(244,211,123);t.TextColor3=Color3.fromRGB(61,78,54);t.Text='PASSAGEM DESCOBERTA';t.Font=Enum.Font.FredokaOne;t.TextScaled=true;t.Parent=gui
    local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(0,16);corner.Parent=t
    local stroke=Instance.new('UIStroke');stroke.Thickness=3;stroke.Color=Color3.fromRGB(54,77,49);stroke.Parent=t
    task.wait(.35)
    Tween:Create(t,TweenInfo.new(.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(.52,0,0,48)}):Play()
    task.delay(2.6,function()if gui.Parent then gui:Destroy()end end)
end
-- Scenery is built in stages; one slow discovery must not block local biome grading.
task.spawn(function()
    local cave=root:WaitForChild('CriptaDasRaizes',60)
    if not cave then return end
    gate=cave:WaitForChild('TampaDeRaizes',30)
    if not gate then return end
    cave:GetAttributeChangedSignal('Open'):Connect(function()if cave:GetAttribute('Open')then feedback()end end)
end)
task.spawn(function()
local stream=root:WaitForChild('RiachoNatural',60)
if not stream then return end
for _,foam in ipairs(stream:GetChildren())do
    if foam:IsA('BasePart') and foam:GetAttribute('WaterCurrent')then
        local base=foam.CFrame
        Tween:Create(foam,TweenInfo.new(3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,-1),{CFrame=base*CFrame.new(0,0,-3)}):Play()
        Tween:Create(foam,TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Transparency=.9}):Play()
    end
end
end)
local elapsed=0
Run.Heartbeat:Connect(function(dt)
    elapsed+=dt;if elapsed<.2 then return end;elapsed=0
    local h=p.Character and p.Character:FindFirstChild('HumanoidRootPart');if not h then return end
    local inside=math.abs(h.Position.X)<300 and h.Position.Z<-90 and h.Position.Z>-830
    local t=inside and math.clamp((-h.Position.Z-90)/150,0,1)or 0
    effect.TintColor=Color3.new(1,1,1):Lerp(Color3.fromRGB(232,246,236),t*.55)
    effect.Brightness=-.018*t;effect.Contrast=.035*t;effect.Saturation=-.04*t
end)
script.Destroying:Connect(function()effect:Destroy()end)
