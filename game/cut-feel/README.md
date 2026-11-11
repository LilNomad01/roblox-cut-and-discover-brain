# Corte mais fluido — fase 1: carrinho no lote

**Data:** 2026-11-10 · **IA:** Claude · **Place:** `106412085364108` · **Pedido do usuário:** "o ato de cortar a grama está pouco fluido" (todas as áreas; blocos, atraso, pouco feedback e ritmo irregular).

## Causas encontradas no código

| Sintoma | Causa |
|---|---|
| Ritmo irregular | O cliente envia `CutIntent` a cada 0,16 s, mas o servidor exigia 0,22 s desde o último corte. Metade dos pedidos era recusada e o corte real acontecia a cada 0,32 s. |
| Falhas na grama | A cada pedido, o servidor cortava o quadrado **mais perto da lâmina naquele instante**. Os quadrados atravessados entre dois pedidos ficavam para trás, e o último trecho antes de parar nunca era processado (o cliente só envia com input de movimento). |
| Atraso | Nenhuma previsão no cliente: a grama só muda depois da ida e volta ao servidor. |
| Blocos | O servidor troca o quadrado 4×4 alto pelo "Cortada" num único quadro. |
| Pouco feedback | 3 partículas de neon por corte, com limite; as aparas do `AnimCortador` saem ao andar, cortando ou não. |

## Mudanças

### Servidor — `CorteEDescubra.GameServer` (cópia em `game/forest-economy/integration/…GameServer.luau`)

- `lotMowerCut(player,s,root,equipped)`: corta os quadrados que **a lâmina percorreu** desde o último pedido (`lotSegDist`, segmento × área do quadrado), na ordem da passagem.
- **Orçamento:** `largura / intervalo` quadrados por segundo, acumulando até 3×. É o mesmo ritmo médio de projeto do nível (L1: 4,5/s), sem ganho extra de economia.
- **Faixa:** `LOT_CUT_REACH=0`. Largura 1 corta só o quadrado sob o centro da lâmina; cada +1 de largura alarga a faixa 2 studs para cada lado.
- **Parada:** no `Heartbeat`, quando o movimento deixa de ser válido, o servidor fecha o último trecho com a posição que ele conhece.
- Corte Rente (`closeCut`, depois do jardim concluído) mantém o intervalo antigo.

### Cliente — `StarterPlayer.StarterPlayerScripts.LotCutFeel` (novo, `LotCutFeel.client.luau`)

- Aplica a mesma regra (trajeto, faixa, orçamento) e **prevê** o corte na hora:
  - a grama alta abaixa em 0,16 s (clone local);
  - a grama cortada aparece já;
  - saem 10 aparas e toca o som `Corte`.
- Confirma quando o servidor mostra a "Cortada". Se o servidor não confirmar em 0,8 s, a grama volta.
- Não prevê a menos de 0,4 stud da divisa entre quadrados (`EDGE_MARGIN`), onde cliente e servidor podem escolher lados diferentes, nem com o saco cheio, parado ou com o jardim concluído.
- Nada replica. Moedas, XP e saco continuam só no servidor.

## Fase 2 — ferramentas manuais (unha, enxada, foice)

**Causa do atraso:** o `FerramentasCliente` anima na hora, mas o servidor só calcula o corte no **fim** da janela do golpe (0,43–0,46 s depois do F). Som e aparas só vinham depois da resposta do servidor (`Contato`).

| Onde | Mudança |
|---|---|
| `ReplicatedStorage.Shared.LotCutPreview` (novo, `LotCutPreview.luau`) | Módulo só de cliente com o visual de previsão, confirmação e recusa (extraído do `LotCutFeel`) e `swing()`, que acompanha o golpe quadro a quadro com a regra do servidor: filtros de alcance, altura e direção do `FerramentasServer`; área do quadrado × `largura/2`; `maxTiles` na ordem do toque; dano por `forca × raridade`. Margem de 0,3 stud na divisa dos quadrados. |
| `StarterPlayerScripts.FerramentasCliente` (cópia em `integration/`) | Chama `Preview.swing` no golpe e `previa.sample(base, ponta)` a cada quadro da janela. Ignora o feedback tardio do `Contato` quando o local já tocou. |
| `StarterPlayerScripts.LotCutFeel` | Passa a usar o módulo; lógica do carrinho igual à da fase 1. |
| `CorteEDescubra.GameServer` → `CortarPorLamina` | Com mais quadrados tocados que `maxTiles`, escolhe **na ordem do toque** (antes, pelo mais perto). Quantidade e economia iguais. |

A unha (força 0,34) mostra aparas pequenas nos acertos que ainda não cortam; o corte é previsto no 3º acerto, como no servidor.

## Fase 3 — Floresta Esquecida (carrinho e ferramentas)

**Causas:** o servidor bloqueava o carrinho na floresta por 0,19 s, mas o cliente pede a cada 0,16 s, então os cortes saíam em lotes a cada ~385 ms (medido). O último trecho antes de parar era perdido. As ferramentas só cortavam no fim da janela do golpe. Não havia previsão; o visual do Codex (`render(g,true)`: tween, folhas e som) já era bom, mas só disparava com a atualização do servidor.

| Onde | Mudança |
|---|---|
| `GameServer` → `forestMowerCut` (novo) | Carrinho na floresta com orçamento (até `4+nível` tufos por 0,19 s, acumula até 2×) e também chamado quando o jogador para. |
| `GameServer` → `FOREST.cutTrace` | Com mais tufos tocados que o limite, escolhe **na ordem do toque**. Quantidade igual. |
| `StarterPlayerScripts.ForestGrassClient` (arquivo do Codex, `game/grass-feel/`) | Uma linha no handler do stream (limpa a previsão quando o servidor responde) e um bloco no fim: previsão do carrinho e das ferramentas usando o próprio `render(g,true)`. O estágio previsto é o mesmo que o servidor manda, então não há segunda animação nem som. Sem confirmação em 0,9 s, o tufo volta. Contadores de QA `PrevisoesCorte` e `PrevisoesRecusadas` na pasta `Floresta_MatagalLocal` (local). |
| `Shared.LotCutPreview.swing` | Na floresta, repassa as amostras da lâmina para `P.forestTool` (registrado pelo `ForestGrassClient`). |

Para não errar, o cliente fica conservador em três pontos:
- **Carrinho:** não prevê na borda do alcance (margem de 0,6).
- **Ferramentas:** não prevê a última vaga do golpe (foice 3 de 4, enxada 1 de 2).
- **Unha:** não prevê a queda (precisa de vários golpes); dá só o feedback na hora.

O servidor cuida desses casos com a animação normal.

**Atenção ao balanceamento:** o carrinho na floresta passa a cortar no ritmo de projeto (0,19 s). Na prática isso é cerca de 2× o ritmo efetivo anterior (~0,38 s, causado pelo descompasso).

## Rollback

- Fase 3: `GameServerBeforeForestCutFeel_20261110` → `GameServer`; `ForestGrassClientBeforeCutFeel_20261110` → `ForestGrassClient`; `LotCutPreviewBeforeForest_20261110` → `Shared.LotCutPreview`.
- Fase 1: `ServerStorage.GameServerBeforeLotCutFeel_20261110` → `CorteEDescubra.GameServer`; apague `LotCutFeel`.
- Fase 2: `GameServerBeforeToolCutFeel_20261110` → `GameServer`; `FerramentasClienteBeforeToolCutFeel_20261110` → `FerramentasCliente`; `LotCutFeelBeforeModule_20261110` → `LotCutFeel`; apague `Shared.LotCutPreview`.

## Pendências

- O som `Corte` é o provisório (`snap.wav` nativo). Um som real de corte de grama continua pendente no `AudioConfig`.
- Ainda não testado: mobile, servidor publicado com ping real, 2 jogadores.
- Avaliar o balanceamento do carrinho na floresta (ritmo de projeto restaurado).
