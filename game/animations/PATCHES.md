# Patches fora do `AnimFerramentas` (2026-11-11, Claude)

Os três scripts abaixo contêm trabalho de outras IAs que não está publicado neste repositório. Por isso aqui ficam **só os trechos alterados**, como estão no Studio (place `106412085364108`). Backups no Studio:

- `ServerStorage.ShoulderCarryBackup_20261111`: `Animador`, `FerramentasServer` e `AnimFerramentas` antes da postura de ombro.
- `ServerStorage.SwingClipBackup_20261111`: `AnimFerramentas` antes do ajuste do golpe e `Animador` antes da correção da cache.

## 1. `StarterPlayerScripts.FerramentasCliente.Animador`

### a) Postura parada: mão esquerda livre

No ramo `hold` do `PreSimulation`, a chamada `ArmIK.secondaryGrip(char)` foi trocada por:

```lua
-- [Claude 2026-11-11] ferramenta apoiada no ombro: só a mão direita segura. A pegada da mão
-- esquerda (IK) só vale durante o golpe; parado, ela puxaria o braço esquerdo através do peito.
local hum = char:FindFirstChildOfClass("Humanoid")
local nativo = hum and hum:FindFirstChild("IKMaoEsquerda")
if nativo then nativo.Enabled = false end
```

O ramo do golpe continua chamando `ArmIK.secondaryGrip(char)`.

### b) Correção: personagem parava de animar depois do respawn

**Bug anterior a esta tarefa.** `juntasDe` guardava as juntas na cache no primeiro quadro depois do `CharacterAdded`. Nesse momento os membros ainda não tinham chegado ao cliente, e a cache ficava vazia para sempre. Efeito em Play: depois de morrer e renascer, a ferramenta ficava sem postura e o golpe não movia o braço (ombro girava no máximo ~7°).

```lua
local TOTAL_JUNTAS = 0
for _ in pairs(A.Juntas) do TOTAL_JUNTAS += 1 end
local cacheInfo = setmetatable({}, { __mode = "k" }) -- [char] = { n = juntas achadas, em = os.clock() }
local function juntasDe(char: Model)
	local c = cache[char]
	local info = cacheInfo[char]
	if c and info then
		local valido = info.n >= TOTAL_JUNTAS or os.clock() - info.em < 1
		if valido then
			for _, j in pairs(c) do
				if not j:IsDescendantOf(char) then valido = false break end
			end
		end
		if valido then return c end
	end
	c = {}
	local n = 0
	for nome, peca in pairs(A.Juntas) do
		local p = char:FindFirstChild(peca)
		local j = p and p:FindFirstChild(nome)
		if j and (j:IsA("AnimationConstraint") or j:IsA("Motor6D")) then c[nome] = j n += 1 end
	end
	cache[char] = c
	cacheInfo[char] = { n = n, em = os.clock() }
	return c
end
```

A cache é refeita quando falta junta (no máximo uma vez por segundo) ou quando uma junta guardada saiu do personagem.

## 2. `ServerScriptService.CorteEDescubra.FerramentasServer`: apertar o número de novo guarda o item

No `Equipar.OnServerEvent`, logo depois de `local tipo = Cfg.PorSlot[slot]` / `if not tipo then return end`:

```lua
-- [Claude 2026-11-11] apertar o número da ferramenta que já está na mão guarda o item (mão vazia)
if player:GetAttribute("FerramentaAtiva") == tipo then
	limparManual(player.Character)
	limparMochila(player)
	removerCortador(player)
	player:SetAttribute("FerramentaAtiva", "Nenhuma")
	return
end
```

`"Nenhuma"` não destaca nenhum botão da barra. No respawn, ela também não equipa nada. O `GameServer` não monta o carrinho quando a ferramenta ativa não é `"Cortador"`.

## 3. `GameServer`: objetivo com a mão vazia

```lua
local ativa=player:GetAttribute("FerramentaAtiva")
local objective=ativa=="Cortador" and "Empurre o cortador pela grama"
    or ativa=="Nenhuma" and "Escolha uma ferramenta: teclas 1 a 4" -- [Claude 2026-11-11] mão vazia
    or "Use F ou clique para cortar com a ferramenta"
```
