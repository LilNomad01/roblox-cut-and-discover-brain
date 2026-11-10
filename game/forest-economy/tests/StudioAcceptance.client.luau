local RS=game:GetService("ReplicatedStorage")
local transport=RS:WaitForChild("ForestAcceptanceTransport")
transport.OnClientEvent:Connect(function(token,...)
    RS.ForestCommerce:FireServer(...)
    task.wait(.55) -- Respect the server equipment action guard (0.4 seconds).
    transport:FireServer(token)
end)
transport:FireServer("ready")
