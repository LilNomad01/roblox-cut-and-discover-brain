# Rankings globais e conquistas (PAD-07)

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "continue essa e as próximas sem autorização". Este é o item 7 do [brain 20](../../brain/20_PADROES_JOGOS_SIMILARES.md). Os valores foram escolhidos pelo Claude e ficam em `ConquistasConfig`.

**Backup:** `ServerStorage.RankingBackup_20261112` (MissoesServidor, ProfileData).

## O que o jogador vê

- **Placar "🏆 MELHORES JARDINEIROS"** no lobby, do outro lado do spawn, de frente para o Quadro de Missões.
  - Tem 3 colunas com o top 10 global: ✂️ tufos cortados, 📦 baús e segredos e 📋 selos de missão.
  - Os 3 primeiros ganham medalhas 🥇🥈🥉.
  - Atualiza a cada 2 min.
- **Conquistas:** botão "🏆 Conquistas" no cabeçalho do Quadro do Jardineiro. A lista tem 15 conquistas, cada uma com cadeado, barra de progresso e prêmio, além do resumo das estatísticas do jogador.
- **Quando uma meta é batida:** aparece o aviso "🏆 Conquista: … +N moedas". O prêmio é pago uma vez só e multiplicado pelo cortador.

| Estatística | Conquistas (meta → moedas base) |
|---|---|
| Tufos cortados | 100 → 100 · 1.000 → 400 · 10.000 → 2.000 · 100.000 → 10.000 |
| Jardins completos | 1 → 100 · 10 → 600 · 50 → 3.000 |
| Tufos dourados | 1 → 100 · 25 → 800 · 100 → 4.000 |
| Baús e segredos | 1 → 100 · 10 → 800 · 30 → 3.000 |
| Selos de missão | 3 → 200 · 15 → 1.500 |

## Badges

O jogo **não tem badges criados**, e nenhum id foi inventado. Cada conquista tem `BadgeId = nil`.

Para ligar um badge:

1. crie o badge no Creator Hub;
2. ponha o id na conquista em `ConquistasConfig`;
3. publique o jogo.

A partir daí, o servidor entrega o badge junto com a conquista (`BadgeService:AwardBadge`).

## Arquivos

| Studio | Cópia aqui |
|---|---|
| `ReplicatedStorage.Shared.ConquistasConfig` (novo) | `ConquistasConfig.luau` |
| `CorteEDescubra.EstatisticasData` (novo: formato e validação) | `EstatisticasData.luau` |
| `CorteEDescubra.EstatisticasServidor` (novo, `RemoteFunction ConquistasAcao`) | `EstatisticasServidor.server.luau` |
| `StarterPlayerScripts.ConquistasCliente` (novo) | `ConquistasCliente.client.luau` |
| `Workspace.GameWorld.Lobby.QuadroRanking` (modelo, atômico no streaming) | receita em `QuadroRanking.build.luau` |

**Salvo no perfil:**
- `profile.Estatisticas = { version=1, cortes, dourados, descobertas, jardins, vendas }`;
- `profile.Conquistas = { [id]=true }`.

Os dois são validados no `ProfileData`. Os selos são lidos de `profile.Missoes.selos`.

**Contagem:** usa os mesmos eventos do `MissoesSinal` (PAD-05). O `MissoesServidor` passou a emitir `"selo"` quando uma missão é coletada.

**Rankings:**
- Cada estatística tem um `OrderedDataStore`: `CorteEDescubra_Rank_<stat>_v1`. No Studio o nome ganha o sufixo `_Studio`, para não misturar com o jogo publicado.
- O valor de cada jogador é gravado a cada 3 min, ao sair e no fechamento do servidor, sempre com `UpdateAsync` que guarda o maior valor.
- O top 10 é lido a cada 2 min.
- Ids de teste local (negativos) ficam de fora.

## Cuidados

- As estatísticas começam do zero para quem já jogava antes, porque não existia contagem.
- Os nomes no placar usam o DisplayName de quem está no servidor e `GetNameFromUserIdAsync` para os outros.
