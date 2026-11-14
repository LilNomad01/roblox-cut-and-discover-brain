# Transição Vila → Floresta Esquecida

**Data:** 2026-11-10 · **IA:** Claude · **Place:** `106412085364108` · **Pedido do usuário:** melhorar a transição do mapa.

Backups: `ServerStorage.TransitionBackup_20261110` (GameServer, ForestScenery, Musica, WorldAmbience).

## Problemas encontrados

| Problema | Causa |
|---|---|
| Ao entrar na floresta, só aparecia um aviso genérico, sem acento ("Voce entrou na Floresta Esquecida…") | `Economia.Notificar` no `GameServer` |
| A música não trocava na floresta | `JuiceCliente.Musica` só trocava para "Natureza" perto da `WorldGrassZones` (zona de teste) |
| O arco de entrada (z=−181, quase na fronteira da região, z=−177) era só dois postes e uma viga | sem nome nem luz; a placa "FLORESTA ESQUECIDA" fica de lado, entre árvores |
| A trilha de entrada tinha bordas retas de placas sobre a grama | trilha feita de Parts retangulares |
| Aviso "Infinite yield … FlorestaEsquecida" no console | `WorldAmbience` esperava a floresta (construída em runtime) sem prazo |

## Mudanças

| Onde | Mudança |
|---|---|
| `StarterPlayerScripts.RegionTitleCard` (novo, `RegionTitleCard.client.luau`) | Banner "FLORESTA ESQUECIDA / Corte o matagal e procure segredos" ao cruzar o portal, e "VILA / De volta ao seu jardim" na volta. Mesmo estilo do "PASSAGEM DESCOBERTA" (dourado, FredokaOne, contorno escuro), entrada com mola, saída em 2,6 s, som `Whoosh` existente. Não aparece ao entrar no jogo. |
| `CorteEDescubra.GameServer` | Remove o aviso de texto antigo. Na construção da floresta, decora as bordas da trilha de entrada com pedras e flores (seed fixa, sem colisão nem consulta). Cópia em `game/forest-economy/integration/`. |
| `CorteEDescubra.ForestScenery` | O arco ganha placa pendurada no centro da viga ("FLORESTA ESQUECIDA" do lado da vila, "VILA" do lado da mata) e duas lanternas com `PointLight`. Cópia em `game/forest-economy/integration/`. |
| `JuiceCliente.Musica` | `RegiaoAtual == "Floresta Esquecida"` conta como área Natureza, e a troca acontece na hora em que o atributo muda (antes, só no laço de 1,5 s). |
| `StarterPlayerScripts.WorldAmbience` | `WaitForChild('FlorestaEsquecida', math.huge)`, sem o aviso. |

`Musica` e `WorldAmbience` não estão no repositório (scripts do Studio). As mudanças são duas linhas marcadas com `[Claude 2026-11-10]`.

Observação: a prévia estática da floresta no editor (`ForestEditorPreview`, do Codex) usa um módulo derivado e **não** mostra a placa, as lanternas nem as bordas; elas aparecem em Play.
