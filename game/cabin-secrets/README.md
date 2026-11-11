# Cabana Esquecida e segredos da floresta

**Data:** 2026-11-11 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "melhorar cabana e segredos da floresta, deixar mais bonita e satisfatória de explorar". Depois da auditoria, ele escolheu as quatro frentes: cabana por fora, interior explorável, descoberta satisfatória e pistas com relíquias únicas.

**Backup:** `ServerStorage.CabanaBackup_20261111.GameServer`.

## Auditoria (antes)

**Cabana:**
- caixa de madeira escura com vidro claro liso nas janelas;
- por dentro, vazia e escura;
- empenas abertas (dava para ver o céu de dentro);
- pilares da varanda sem telhado;
- a "lanterna" era um cubo amarelo flutuando.

**Segredos (17, mais o gnomo Nilo):**
- o baú ou a relíquia só aparecia quando o jogador cortava a grama em volta, com uma bolinha amarela por 3 s;
- a coleta mostrava só um aviso de moedas;
- as 5 relíquias eram o mesmo pedestal cinza com uma placa verde;
- não havia pistas no mundo.

## O que mudou

| Arquivo (Studio) | Cópia aqui | Mudança |
|---|---|---|
| `CorteEDescubra.CabanaDetalhes` (novo) | `CabanaDetalhes.luau` | Cabana por fora e por dentro (lista abaixo). Só decoração. |
| `CorteEDescubra.ReliquiasDaFloresta` (novo) | `ReliquiasDaFloresta.luau` | Visual próprio de cada relíquia (lista abaixo). Id desconhecido usa o pedestal antigo. |
| `StarterPlayerScripts.SegredosDaFloresta` (novo) | `SegredosDaFloresta.client.luau` | Pistas, revelação, feixe e coleta (lista abaixo). |
| `GameServer` | trechos abaixo | Ganchos pequenos. |

### Cabana (`CabanaDetalhes`)

**Por fora:**
- janelas com luz âmbar;
- porta entreaberta;
- telhadinho da varanda com lanterna pendurada (o cubo some);
- fumaça na chaminé;
- empenas fechadas;
- trepadeiras, musgo e flores nas floreiras;
- lenha empilhada e cerca velha com um sarrafo caído;
- caminho de pedras até a trilha.

**Por dentro:**
- terreno removido do interior e piso de tábuas;
- tapete;
- lareira acesa;
- mesa com vela, livro e caneca, e cadeira;
- estante com livros;
- cama de palha;
- barris e caixotes;
- mapa na parede;
- luz quente.

### Relíquias (`ReliquiasDaFloresta`)

| Relíquia | Visual novo |
|---|---|
| Diário da cabana | aberto sobre um toco |
| Pedra rúnica | menir com runas brilhantes nos dois lados |
| Relíquia da nascente | ânfora com água brilhante |
| Flor do orvalho | flor de cristal |
| Relíquia da cripta | orbe âmbar preso entre raízes |

### Segredos no cliente (`SegredosDaFloresta`)

- **Pista:** vaga-lumes acima do mato onde há um segredo escondido. Ficam deslocados até 3,5 studs e indicam só a região.
- **Revelação:**
  - som "Desbloqueio" (já existia no jogo);
  - explosão de folhas e brilhos;
  - o baú sobe do chão.
- **Feixe:** enquanto você não coleta, um feixe de luz na cor da raridade fica visível de longe.
- **Coleta:**
  - a tampa abre 70°;
  - chuva de moedas;
  - som "Moeda";
  - aviso "SEGREDO ENCONTRADO! Segredos da floresta: n / 17".

## Ganchos no `GameServer`

```lua
local Reliquias=require(script.Parent.ReliquiasDaFloresta) -- [Claude 2026-11-11] visual próprio das relíquias
```

Em `forestAddSecret`, ramo das relíquias:

```lua
-- [Claude 2026-11-11] cada relíquia com visual próprio (ReliquiasDaFloresta); id desconhecido = pedestal antigo
if not Reliquias.build(visibleModel,info.id,point) then -- no chão de verdade (terreno ou cripta)
    forestPart(visibleModel,"Pedestal",...)   -- visual antigo, inalterado
    forestPart(visibleModel,"Simbolo",...)
end
```

Depois de `table.insert(FOREST.secrets,secret)`:

```lua
-- [Claude 2026-11-11] registro público do segredo, para pistas e efeitos no cliente (SegredosDaFloresta).
-- Só posição/tipo/estado; a recompensa continua validada aqui no servidor.
if info.kind~="gnome" then
    local reg=game.ReplicatedStorage:FindFirstChild("SegredosDaFloresta")
    if not reg then reg=Instance.new("Folder") reg.Name="SegredosDaFloresta" reg.Parent=game.ReplicatedStorage end
    local c=Instance.new("Configuration") c.Name=info.id
    c:SetAttribute("Tipo",info.kind) c:SetAttribute("Raridade",info.rarity or "")
    c:SetAttribute("Ponto",point) c:SetAttribute("Revelado",secret.revealed)
    c.Parent=reg
    secret.registro=c
    visibleModel:SetAttribute("SegredoId",info.id)
end
```

Em `forestRevealSecret`, logo depois de `secret.revealed=true ...`:

```lua
if secret.registro then secret.registro:SetAttribute("Revelado",true) end -- [Claude 2026-11-11] efeitos no cliente
```

Depois de `Art.polish(root,Scenery)`:

```lua
-- [Claude 2026-11-11] cabana por fora e por dentro (só decoração)
do local ok,err=pcall(function() require(script.Parent.CabanaDetalhes).decorate(root) end) if not ok then warn("[Cabana] "..tostring(err)) end end
```

## Regras respeitadas

- **Nenhuma recompensa mudou:** valores, XP, regra de revelação, idempotência e prompts continuam iguais.
- **O registro público não entrega o que ainda falta encontrar.** A posição exata dos segredos já chegava ao cliente pelos modelos (escondidos com `Transparency=1`); as pistas mostram só a região.
- **Sem IDs inventados:** Fire, Smoke, luzes e partículas são nativos, e os sons já existiam no `AudioConfig`.
- **Gnomo Nilo não foi alterado:** continua sem pista e sem feixe.
- **Escopo:** não foi refeito nada da reforma V19 do Codex (riacho, montanhas, cavernas).

## Limitações

- O tufo de mato cortável que já nascia dentro da cabana continua lá. Removê-lo exigiria mexer no sistema de grama.
- A revelação é compartilhada entre os jogadores: quando alguém revela um segredo, os vaga-lumes daquele lugar somem para todos. A coleta continua sendo individual.
- Os baús continuam sendo posicionados pela altura-base da floresta; não mexi nisso.
- A prévia do editor (`ForestEditorPreview`, do Codex) não mostra estas mudanças; elas aparecem no Play.
