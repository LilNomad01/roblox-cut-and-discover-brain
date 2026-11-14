# Prêmios (diária, tempo jogado, códigos, grupo) e grama dourada

**Data:** 2026-11-11 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "Sim, os três": os itens PAD-01, PAD-02 e PAD-03 do brain 20. A instrução de seguir sem pedir autorização continua valendo, então **os valores foram escolhidos pelo Claude** e ficam todos em `RecompensasConfig`.

**Backup:** `ServerStorage.RecompensasBackup_20261111` (GameServer, ProfileData, Economia, VendorIdle).

## O que o jogador vê

- **Botão "🎁 Prêmios"** no canto direito, com bolinha vermelha quando há algo para pegar. Ele abre um painel com três partes.
- **Prêmio diário** com sequência de 7 dias:

  | Dia | 1 | 2 | 3 | 4 | 5 | 6 | 7 🏆 |
  |---|---:|---:|---:|---:|---:|---:|---:|
  | Moedas (base) | 150 | 250 | 400 | 600 | 900 | 1.300 | 2.000 |

  - O valor é **multiplicado pelo multiplicador do cortador equipado** (1× no Básico, 45× no Imperial), para acompanhar a fase do jogo.
  - Pular um dia volta para o dia 1. Depois do dia 7, o ciclo recomeça.
  - O dia muda à meia-noite UTC (21h em Brasília).
- **Tempo jogado nesta sessão:** 5 min = 100, 15 min = 250, 30 min = 500, 60 min = 1.000 moedas, também × o cortador. Recomeça a cada sessão.
- **Códigos:** campo de texto que aceita maiúsculas ou minúsculas e ignora espaços. Cada jogador resgata cada código uma vez. Códigos iniciais: `BEMVINDO` (500), `CORTEEDESCUBRA` (1.000), `FLORESTA` (1.500). O prazo de validade (`expira`) é opcional.
- **Grama dourada:**
  - **2 tufos dourados por serviço** do lote, com brilho e cor dourada;
  - **1% de chance** de um corte na floresta sair dourado.

  Cada um paga, **na hora e em moedas**, o valor de 9 tufos extras (× cortador × ajudantes × grupo) e dá +20 XP. Quem corta vê uma explosão dourada, o texto "✨ TUFO DOURADO! +N" e ouve o som "Desbloqueio" (já existente). Pagar em moedas evita perder o prêmio com o saco cheio.
- **Bônus de grupo (+10% de grama):** **desligado**, porque o id do grupo não foi informado e não foi inventado. Para ligar, preencha `RecompensasConfig.GrupoId`.

## Arquivos

| Studio | Cópia aqui |
|---|---|
| `CorteEDescubra.RecompensasConfig` (novo, só servidor: os códigos não vão para o cliente) | `RecompensasConfig.luau` |
| `CorteEDescubra.RecompensasData` (novo, regras puras e validação) | `RecompensasData.luau` |
| `CorteEDescubra.RecompensasServidor` (novo, `RemoteFunction RecompensasAcao`) | `RecompensasServidor.server.luau` |
| `CorteEDescubra.TufoDourado` (novo, `RemoteEvent TufoDouradoFX`) | `TufoDourado.luau` |
| `StarterPlayerScripts.RecompensasCliente` (novo) | `RecompensasCliente.client.luau` |

### Trechos em scripts existentes

`GameServer`, com 5 ganchos marcados `[Claude 2026-11-11]`:

```lua
local TufoDourado=require(script.Parent.TufoDourado) -- topo
TufoDourado.sortearLote(s)                           -- fim do resetJob (novo serviço)
TufoDourado.aoCortarLote(player,s,id,tile)           -- cutIds, depois de setTileCut(tile,true)
TufoDourado.aoCortarLote(player,s,cell.id,tile)      -- golpe das ferramentas manuais
TufoDourado.aoCortarFloresta(player,Vector3.new(g.x,g.groundY,g.z)) -- primeiro corte de um tufo da floresta
```

`ProfileData`: `RecompensasData` e, em `validExtensions`:

```lua
        and (profile.Recompensas==nil or RecompensasData.valid(profile.Recompensas))
```

`Economia.EncherSaco`: a grama passa a considerar o grupo:

```lua
	local bonusGrupo = tonumber(p:GetAttribute("BonusGrupo")) or 0
	local mult = (p:GetAttribute("Multiplicador") or 1) * (1 + math.clamp(bonusPets, 0, 10) + math.clamp(bonusGrupo, 0, 1))
```

`VendorIdle` e `PetsCliente`: `PremiosAberto` entrou na lista de janelas (uma janela por vez; esconde o balão dos NPCs).

**Salvo no perfil:** `profile.Recompensas = { version=1, ultimoDia, sequencia, codigos = { CODIGO=true } }`.

## Efeito no balanceamento

- **Grama dourada:** cerca de +28% de grama no lote (2 de 64 tufos valendo 10×) e cerca de +9% na floresta.
- **Diária:** de 1 a 10 minutos de jogo, conforme o dia da sequência.
- **Tempo jogado:** cerca de +10% para quem joga uma hora seguida.

O modelo de `game/balance/` ainda não inclui esses bônus.

## Como criar um código

Em `RecompensasConfig.Codigos`, adicione por exemplo:

```lua
NATAL2026 = { moedas = 2000, expira = os.time({ year = 2026, month = 12, day = 31, hour = 23 }) },
```

Depois publique o jogo.

## Rebrota do lote e progresso offline (PAD-04, 2026-11-12)

**Pedido:** próximo item priorizado do brain 20, feito sob a instrução "continue os passos sem pedir autorização". Backup em `ServerStorage.RebrotaBackup_20261111`.

- **A grama do lote volta a crescer.** Quando o jardim é concluído (64 tufos), o servidor espera **20 s** e começa um serviço novo: tufos visíveis de novo, 2 tufos dourados sorteados de novo e a mensagem "🌱 A grama do seu jardim cresceu de novo!". Se um baú foi revelado e ainda não foi pego, a rebrota espera a coleta, por até **3 min**, para não sumir com o baú.
- **Progresso offline.** Ao entrar, quem ficou fora **10 min ou mais** ganha `6,4 moedas/min × multiplicador do cortador`, com **teto de 4 h** (cerca de 5% do ritmo de quem joga ativo). Perfil novo não ganha nada. O cálculo usa `profile.lastSaveTime` e acontece uma vez por sessão. O cliente mostra o aviso "Enquanto você estava fora..." uma única vez.
- Valores em `RecompensasConfig.Offline = { minimoMin = 10, maximoMin = 240, moedasPorMin = 6.4 }`.

Trecho novo no `GameServer` (antes de `cutIds`), chamado nas duas linhas de bônus de conclusão (`Economia.AddXP(player,40) agendarRebrota(player,s)`):

```lua
local REBROTA_SEGUNDOS=20
local function agendarRebrota(player,s)
    local job=s.job
    task.spawn(function()
        task.wait(REBROTA_SEGUNDOS)
        local limite=os.clock()+180
        while sessions[player]==s and s.job==job and job.secretRevealed and not job.secretClaimed and os.clock()<limite do task.wait(5) end
        if sessions[player]~=s or s.job~=job or not player.Parent then return end
        resetJob(s)
        sync(player,"🌱 A grama do seu jardim cresceu de novo!")
    end)
end
```

O texto do objetivo concluído passou a ser "Jardim restaurado! A grama volta a crescer em instantes."
