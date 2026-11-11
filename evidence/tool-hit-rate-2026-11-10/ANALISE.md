# Taxa de acerto das ferramentas manuais no lote — 2026-11-10

**IA:** Claude · **Place:** `106412085364108` · **Modo:** Play solo PC. O jogo não foi alterado; as simulações usam o mesmo código do servidor (`BladeSweep`, `FerramentasConfig` e o filtro do `FerramentasServer`) só para calcular.

## Sintoma

No playtest dos P0, a foice, a enxada e a unha erravam boa parte dos golpes no lote. Golpes reais da foice gravados no servidor: 7 golpes renderam 4 quadrados, e **os 4 primeiros, parado na borda do gramado, renderam 0**, mesmo com a lâmina passando visualmente sobre a grama.

## Causa

`GameServer` → `CortarPorLamina` (rota usada pelo `FerramentasServer`) só conta um quadrado do lote se o traço da lâmina passar a no máximo `largura/2` do **centro** dele:

```lua
local c=Vector2.new(-18+col*4,-18+row*4) -- centros numa grade de 4 studs
if d<=raio then ... end                  -- raio = largura/2: unha 0,45; foice 0,8; enxada 1,1
```

Os quadrados visuais têm 4×4 studs, mas a área que conta é um círculo de 0,45 a 1,1 stud em volta do centro. O acerto depende de o jogador estar "alinhado" com a grade. Exemplo medido: com o jogador em z local +4,7, o arco da foice passa em z ≈ 1,0–2,2, entre as fileiras de centros z = 2 e z = −2, e não acerta nada.

## Medição (2.888 golpes simulados por ferramenta, posições a cada 1 stud e 8 direções, lote inteiro sem cortes)

| Ferramenta | Raio | maxTiles | Força | **Hoje:** golpes que acertam | Hoje: quadrados/golpe | **Teste por área do quadrado:** acertam | Quadrados/golpe |
|---|---|---|---|---|---|---|---|
| Unha | 0,45 | 1 | 0,34 (3 acertos por quadrado) | **10%** | 0,10 | 100% | 1,00 |
| Enxada | 1,10 | 2 | 1,0 | **53%** | 0,53 | 100% | 1,97 |
| Foice | 0,80 | 4 | 1,0 | 86% | 1,57 | 100% | 4,00 |

Com a unha, cortar um quadrado exige 3 acertos; com 10% de acerto, isso dá cerca de 30 golpes por quadrado.

## Correção proposta (aguardando decisão do usuário)

Em `CortarPorLamina`, trocar "distância ao centro ≤ raio" por "o traço da lâmina toca o quadrado de 4×4, expandido pelo raio". O teto `maxTiles` continua limitando o ganho por golpe. A validação continua 100% no servidor, e a floresta (`FOREST.cutTrace`) não muda.

Efeito: com os tetos atuais, o ganho por golpe sobe (foice 1,57 → 4; enxada 0,53 → 2). Se isso deixar as ferramentas fortes demais em relação ao carrinho, dá para reduzir `maxTiles` no `FerramentasConfig` (ex.: foice 2–3). **Decisão de balanceamento do usuário.**

Não medido: taxa de acerto na floresta (outra rota de corte, com tufos a cada 1,5 stud).
