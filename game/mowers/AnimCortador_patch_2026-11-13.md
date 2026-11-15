# Patch em `StarterPlayer.StarterPlayerScripts.JuiceCliente.AnimCortador` (2026-11-13, Claude)

**Por quê:** a v2 dos cortadores de empurrar tem a carcaça em duas peças: `Carcaca`, a parte de trás reta, e `CarcacaFrente`, a frente redonda. O script só fazia a `Carcaca` vibrar; sem o patch, a frente ficaria parada e apareceria uma emenda tremendo.

**Backup do script original:** `ServerStorage.CortadoresBackup_20261113.AnimCortador`.
**Tamanho depois do patch:** 9255 bytes.

## Trechos alterados

Em `montar`, logo depois do ramo de `Carcaca`/`Carroceria`:

```lua
elseif p.Name == "CarcacaFrente" then -- [Claude 2026-11-13] frente redonda do deck vibra junto
	est.carcacaFrente = { p = p, w = weldLocal(p, root) }
```

Em `pecas`:

```lua
if est.carcacaFrente then table.insert(l, est.carcacaFrente) end
```

Em `passo`, a vibração vira uma variável e é aplicada às duas peças:

```lua
local tremor = CFrame.new(math.sin(t * 61) * vib * 0.5, math.sin(t * 47) * vib + bob, 0) * CFrame.Angles(math.sin(t * 53) * vib * 0.3, 0, 0)
est.carcaca.w.C0 = est.carcaca.c0 * tremor
if est.carcacaFrente then
	local rel = est.carcaca.c0:Inverse() * est.carcacaFrente.c0
	est.carcacaFrente.w.C0 = est.carcaca.c0 * tremor * rel
end
```

**Prova em Play:** com o Turbo, o cliente criou **11** welds `AnimLocal`: lâmina, carcaça, frente, 4 pneus e 4 aros.
