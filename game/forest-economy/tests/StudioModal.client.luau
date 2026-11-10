-- Run on the client after opening Guto through the real server-side shop.
local p=game.Players.LocalPlayer
local hud=p.PlayerGui.HUDCortaGrama
task.wait(.5)
assert(p:GetAttribute("ForestShopOpen"),"Open forest shop before running this test")
assert(not p:GetAttribute("MenuJogadorAberto"),"Forest shop must close player menu")
hud.AbrirLoja:Fire()
task.wait(.4)
assert(not p:GetAttribute("ForestShopOpen"),"Main shop must close forest shop")
assert(p:GetAttribute("LojaAberta"),"Forest close must not clear main shop state")
hud.FecharLoja:Fire()
task.wait(.3)
assert(not p:GetAttribute("LojaAberta"),"Main shop must release its modal state")
print("PASS forest/main shop modal transition and shared state")
