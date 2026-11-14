--[[
	ServerScriptService.CorteEDescubra.PlacaLoteVerso  [Claude 2026-11-12]
	A placa de cada lote (Plot.PlotSign.Panel) só tinha texto na face de dentro do lote; quem vinha da calçada via
	um painel escuro vazio (achado da auditoria de modelagem). Este script copia o letreiro para a face de trás e
	mantém as duas iguais quando o GameServer troca o texto ("LOTE LIVRE" <-> nome do dono).
]]
local Plots = workspace:WaitForChild("GameWorld"):WaitForChild("Plots")

local function ligar(plot)
	local sign = plot:WaitForChild("PlotSign", 30)
	local panel = sign and sign:WaitForChild("Panel", 10)
	local frente = panel and panel:WaitForChild("Label", 10)
	if not frente or panel:FindFirstChild("LabelVerso") then return end
	local verso = frente:Clone()
	verso.Name = "LabelVerso"
	verso.Face = frente.Face == Enum.NormalId.Front and Enum.NormalId.Back or Enum.NormalId.Front
	verso.Parent = panel
	local tf = frente:FindFirstChildWhichIsA("TextLabel", true)
	local tv = verso:FindFirstChildWhichIsA("TextLabel", true)
	if not tf or not tv then return end
	local function copiar() tv.Text = tf.Text end
	tf:GetPropertyChangedSignal("Text"):Connect(copiar)
	copiar()
end

for _, plot in ipairs(Plots:GetChildren()) do task.spawn(ligar, plot) end
Plots.ChildAdded:Connect(function(plot) task.spawn(ligar, plot) end)
