# Validação — NPCs (visual, animação, conversa e placa de nome)

**Data:** 2026-11-11 · **IA:** Claude · Play solo no PC, no Studio (place `106412085364108`).

| Verificação | Resultado |
|---|---|
| Comerciantes de frente | `LookVector` de Guto, Lia e Teca = (0, 0, 1), na direção do balcão (antes: −Z, de costas: `antes-guto-de-costas.jpg`) |
| Visual próprio | Capturas `depois-*.jpg`. Cada NPC tem acessórios próprios (macacão e rastelo, boné com mochila, chapéu de exploradora com lenço, chapéu com flores e regador) e cabelo da sua cor depois da correção da textura (`depois-teca.jpg` foi tirada **antes** dessa correção e ainda mostra o cabelo loiro). |
| Rastelo | base dos dentes em y = 0,91; sola dos pés em 0,90 (antes da correção: 0,71) |
| Conversa do jardineiro | registro dos balões ao chegar perto: "De volta ao trabalho? Gosto de ver!" (1,5 s) → "Faltam 64 tufos para terminar este jardim." (6,1 s) → dica (10,6 s); cada fala ~3,6 s |
| Conversa dos comerciantes | Guto: fala de primeira visita, depois "Seu saco está em 0 de 50. Uma mochila maior ajuda!" (`depois-guto-fala.jpg`). Lia e Teca: dicas do catálogo. |
| Loja aberta | com `ForestShopOpen` ligado, o balão do Guto sumiu e a conversa não recomeçou ao fechar |
| Animação parada (juntas, perto) | Teca a 17 studs: ombro 7°→55° e pulso 0°→74° (regando). Guto: ombro 9°→26° e corpo virado ~10° para o jogador. Lia: ombro até 138° (mão na testa). Jardineiro: braço esquerdo até 134° (enxuga a testa). |
| Longe (> 120 studs) | o NPC para de ser animado (economia) |
| Placa e balão no toldo | ficavam atrás do toldo; corrigido puxando 3 studs na direção da câmera (`depois-guto-fala.jpg`) |
| Fontes | `VendorAvatar` 9800/304671473, `VendorIdle` 13044/956342069, `NpcFalas` 3338/834547056, iguais no Studio e no repositório |
| Console | sem erros de script (só o aviso de asset `R15Anim`, que já existia) |

## Observações

- A captura de tela do Studio **não desenha `BillboardGui` com `AlwaysOnTop`**. Isso também explica por que o selo do jardineiro não aparecia nas capturas. Por isso o balão passou a usar `AlwaysOnTop = false`, que também evita atravessar paredes.
- O cartão de região "Floresta Esquecida" cobre o balão por alguns segundos depois de um teleporte para a floresta.

## Não testado

- **Multiplayer:** o jardineiro calado para quem não é dono do lote foi verificado só pela leitura do código, não com 2 jogadores.
- **Celular** (tamanho da placa e do balão) e **controle**.
- **Prompt E real:** o fechamento do balão ao usar o prompt não foi testado pela tecla; a loja aberta foi simulada pelo atributo.
- **Desempenho** com muitos jogadores.
