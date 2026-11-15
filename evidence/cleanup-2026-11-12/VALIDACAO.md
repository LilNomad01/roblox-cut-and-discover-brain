# Limpeza P0-08 a P0-11

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "4. Faça após o 3".

Nada foi apagado. Tudo o que saiu foi **movido** para `ServerStorage.LimpezaBackup_20261112`, com os scripts desligados, e pode ser devolvido.

| Item | Antes | Feito | Prova |
|---|---|---|---|
| **P0-09** `Workspace."Sprint on shift"` duplicado | 2 scripts idênticos (fonte igual), os dois ativos: cada personagem ganhava 2 `SprintScript` | 1 movido para o backup | Play: **1** `SprintScript` no personagem |
| **P0-10** `Workspace.Script` | `print("Hello world!")` | movido | Play: "Hello world!" sumiu do console |
| **P0-10** `Workspace._VerFerramentas` | 3 Handles + 3 Parts de depuração, sem referência em script | movido | busca textual: nenhuma referência |
| **P0-10** remotes `Remotes.CortarGrama / ComprarUpgrade / AtualizarDados` | sem uso em nenhum script | movidos para `LimpezaBackup.RemotesLegados` | busca textual: nenhuma referência. **A pasta `Remotes` continua**: Skills e ForestGrassStream são criados nela durante o jogo |
| **P0-11** TextureIDs `73347833975287`, `120034081281408`, `94694536609432`, `135566642687046` | relatados como "não carregam" | conferidos: os 4 são da conta **LilNomad00 (id 3046107195), a mesma criadora do jogo**, então não há problema de permissão | Play: `ContentProvider:PreloadAsync` deu **Success** nos 4 |
| **P0-08** `MaxPlayers` 60 × 4 lotes (o 5º jogador é expulso pelo GameServer) | `Players.MaxPlayers = 60` | **não dá para mudar por script** ("Property is read only") | precisa do usuário (abaixo) |

## Para o usuário fazer (P0-08)

No Studio, abra **Game Settings → Places → (o place) → Server Size** (ou no Creator Hub, em *Configure Place*). Coloque **4** e salve. Com isso, cada servidor terá no máximo 4 jogadores, um por lote, e ninguém será expulso por falta de lote.

## Observação

O console ainda mostra "Asset id 12946311200 should reference a Folder Instance named R15Anim". É um pacote de animação R15 referenciado em algum lugar com o tipo errado. Não quebra o jogo e não foi mexido.
