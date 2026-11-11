# Validação — corte fluido do carrinho no lote (fase 1)

**Data:** 2026-11-10 · **IA:** Claude · **Place:** `106412085364108` · Play solo PC no Studio, com input real de teclado.

## Método

Um monitor local, criado só para o teste, registrava por quadrado do lote:
- quando o cliente previu (grama alta oculta localmente);
- quando o servidor confirmou ("Cortada" visível);
- se a previsão voltou sem confirmação (recusa).

Rota: W atravessando o lote, passo lateral, S de volta e diagonal (W+D) até parar.

## Iterações

| Versão | Previstos | Recusas | Cortados sem previsão | Previsão → servidor | Resultado no mapa |
|---|---|---|---|---|---|
| 1: alcance 0,75 stud | 19 | **6** | 4 | média 733 ms | faixa larga, com sobras alternadas |
| 2: alcance 0 (só o quadrado sob a lâmina) | 18 | **8** | 6 | média 316 ms | faixas contínuas; recusas na divisa x=0 (spawn) |
| 3: + margem de 0,4 na divisa | 15 | **2** | 8 | média 253 ms | recusas só onde o jogador parou |
| 4: + servidor fecha o trecho final ao parar | 17 | **0** | 8 | média 266 ms (máx. 403) | faixas contínuas, incluindo o fim de cada faixa |

Mapa final (X = cortado; linhas 1..8):

```text
.XX.X...
..X.X...
..X.X...
..X.X.XX
..X.XXX.
..X.XX..
..XXX...
.XXXX...
```

Faixas contínuas nas colunas 3 e 5, diagonal sem falhas, e os quadrados das viradas (linhas 1 e 8) cortados.

## Outras verificações

- **Economia:** 25 quadrados → `Saco=25`, `Nível 2`, `XP=65` (5 XP por quadrado, igual a antes).
- **Saco cheio:** `Saco` forçado a 50/50 só na sessão de teste e passada com S. Resultado: 0 novas previsões, 0 cortes, 0 recusas.
- **Console:** sem erros dos scripts alterados. Aviso `Infinite yield … WaitForChild("FlorestaEsquecida")` vem de `WorldAmbience` (script novo do Codex, reforma do mundo), não desta mudança.
- **Fontes:** `LotCutFeel` no Studio e no repositório com hash igual (`7844/440889861`). No `GameServer`, o diff da mudança é idêntico nos dois lados (−12 linhas `782452436`, +56 linhas `473531929`). O arquivo completo do Studio difere do repositório porque contém a reforma do mundo do Codex, ainda não publicada.

## Limitações

- Latência medida no Studio. Em servidor publicado, o tempo até a confirmação sobe com o ping, mas a previsão cobre esse tempo (timeout de 0,8 s).
- Sem teste em mobile, controle ou com 2 jogadores.
- A captura de tela com câmera forçada saiu escura durante o Play, por isso não há imagem.
