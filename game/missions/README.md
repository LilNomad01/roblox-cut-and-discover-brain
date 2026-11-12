# Quadro do Jardineiro — missões com recompensas permanentes (PAD-05)

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "Yes, PAD-05" (item 5 do [brain 20](../../brain/20_PADROES_JOGOS_SIMILARES.md)). Os valores foram escolhidos pelo Claude, que segue a instrução de não pedir autorização. Todos ficam em `MissoesConfig`.

**Backup:** `ServerStorage.MissoesBackup_20261112` (Economia, GameServer, TufoDourado, PetsServidor, ProfileData, VendorIdle, PetsCliente, RecompensasCliente).

## O que o jogador vê

- **Botão "📋 Missões"** no HUD, à esquerda de "🎁 Prêmios". Uma bolinha vermelha mostra quantas missões estão prontas.
- **Quadro físico no lobby**, perto do spawn, com 3 papéis e uma placa. Apertar **E** ("Ver missões") abre o mesmo painel.
- **Painel com 3 trilhas**, cada uma com uma missão ativa, barra de progresso e botão **COLETAR**:

  | Trilha | Missão 1 | Missão 2 | Missão 3 |
  |---|---|---|---|
  | 🌱 Jardim | cortar 150 tufos (150 💰) | completar 2 jardins (200) | cortar 3 tufos dourados (250) |
  | 🌲 Floresta | cortar 100 tufos na Floresta (200) | abrir 1 baú ou segredo (250) | cortar 300 tufos na Floresta (350) |
  | 💰 Negócios | vender o saco 3× (150) | chocar 1 ninho (250) | vender o saco 6× (300) |

  - Depois da 3ª missão, a trilha volta à 1ª num **ciclo** novo.
  - Metas marcadas "x" multiplicam por (1 + ciclo); as demais somam +ciclo.
  - O prêmio cresce 50% por ciclo e é **× multiplicador do cortador**. O XP é 30 + 10 por ciclo.
  - A venda só conta com o saco **pelo menos meio cheio**, para impedir vender 1 de grama repetidas vezes.
- **Selos e rank (recompensa permanente):**
  - cada missão coletada dá 1 selo;
  - a cada 3 selos o jogador sobe de rank (Aprendiz → Ajudante → Podador → Jardineiro → Paisagista → Mestre Jardineiro → Guardião do Bosque → Lenda da Floresta…);
  - **cada rank dá +3% de grama para sempre**, até o rank 20 (+60%).
- **Avisos:**
  - "📋 Missão pronta" quando uma missão termina;
  - ao coletar, o painel mostra o prêmio e o cartão pula;
  - quando sobe de rank, aparece o aviso "🏅 Novo rank".

## Arquivos

| Studio | Cópia aqui |
|---|---|
| `CorteEDescubra.MissoesConfig` (novo) | `MissoesConfig.luau` |
| `CorteEDescubra.MissoesData` (novo: formato salvo e validação) | `MissoesData.luau` |
| `CorteEDescubra.MissoesSinal` (novo: `BindableEvent`, sem dependência circular) | `MissoesSinal.luau` |
| `CorteEDescubra.MissoesServidor` (novo, `RemoteFunction MissoesAcao`) | `MissoesServidor.server.luau` |
| `StarterPlayerScripts.MissoesCliente` (novo) | `MissoesCliente.client.luau` |
| `Workspace.GameWorld.Lobby.QuadroMissoes` (modelo, atômico no streaming) | receita em `QuadroMissoes.build.luau` |

**Salvo no perfil:** `profile.Missoes = { version=1, selos, trilhas = { {i, c, p} x3 } }`, validado pelo `ProfileData`.

**Atributos:**
- `BonusMissoes`: a `Economia` soma este bônus na grama;
- `RankJardineiro`;
- `MissoesProntas`;
- `MissoesAberto`: modal local, uma janela por vez.

### Ganchos em scripts existentes (`MissoesSinal.contar(player, tipo, qtd)`)

| Script | Onde | Tipo |
|---|---|---|
| `Economia.CortarGrama` | todo tufo cortado (lote, floresta, protótipo) | `corte` |
| `Economia.Vender` | depois da venda (qtd = fração do saco) | `venda` |
| `Economia.EncherSaco` | `+ math.clamp(BonusMissoes, 0, 1)` no multiplicador | — |
| `GameServer` | primeiro corte de um tufo da floresta | `floresta` |
| `GameServer` | baú do lote coletado; segredo/baú da floresta coletado | `descoberta` |
| `GameServer` | bônus de jardim completo (as 2 linhas `ecoBonus`) | `jardim` |
| `TufoDourado` | tufo dourado pago | `dourado` |
| `PetsServidor` | ninho chocado | `ninho` |

`VendorIdle`, `PetsCliente` e `RecompensasCliente`: `MissoesAberto` entrou na lista de janelas.

## Cuidados

- Os segredos da floresta são **18 por jogador** e não voltam. Por isso a missão "descoberta" também aceita o baú do lote (25% dos serviços). Num ciclo alto, ela pode ficar lenta para quem já achou tudo na floresta.
- O tufo dourado ainda **não** soma `BonusMissoes` (nem o grupo). É um ajuste simples se quiser.
- O modelo de `game/balance/` ainda não inclui o bônus de rank.
