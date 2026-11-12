# Validação — clima e eventos do servidor (PAD-06)

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108` · **Ambiente:** Play no Studio (PC)

Os eventos foram iniciados com `EventoForcar` no servidor. Todo o resto veio do jogo real: corte com o carrinho, venda na caçamba, baú aberto com E e tufo dourado cortado.

| Teste | Resultado |
|---|---|
| ⏰ Hora do Dobro: atributos `EventoAtual=dobro`, `EventoGrama=2`, relógio 2:58 | ✅ |
| Faixa "⏰ Hora do Dobro / Toda grama cortada vale 2× / 2:39" | ✅ (screenshot) |
| Mesma passada no lote: **normal 7 cortes = 32 de grama (4,57/corte)**; **com o Dobro, 7 cortes ≥ 50** (o saco de 50 encheu, ≥ 7,1/corte) | ✅ coerente com 2× (limitado pelo saco) |
| Ao parar o evento, os atributos voltam a 1 e a faixa some | ✅ |
| 🌧️ Chuva: `EventoRebrota=5`, `EventoDouradoMult=2`, emissor de chuva ligado no cliente | ✅ |
| Jardim completo com a chuva, com baú revelado: espera o baú (como no PAD-04) | ✅ |
| Depois de pegar o baú: **em ~4 s** o lote voltou com 64 tufos e **4 dourados** (normal: 20 s e 2) | ✅ |
| ✨ Vento Dourado: `EventoDouradoMult=3`, sem rebrota rápida, brilho ligado e chuva desligada | ✅ |
| Tufo dourado cortado: **pagou 53 moedas = 9 × 2,93 × 2**. O 2,93 já inclui o +3% do rank das missões | ✅ |
| Missão "Corte 150 tufos" chegou a 150/150 e foi coletada (+150), passando para "Complete 2 jardins" | ✅ |
| Console sem erros de script | ✅ |

## Ajuste depois do teste

- A faixa ficava no meio da tela em janelas baixas. Ela subiu (y 142 → 84) e agora também escala pela altura da tela.
- Esse ajuste ainda não foi conferido em Play.

## Não testado

- Ciclo automático completo: 4 min até o primeiro evento e intervalos de 7 a 11 min. Os eventos foram forçados.
- Dourado da floresta durante o Vento Dourado.
- Visual da chuva e do brilho: a captura 3D do Studio sai preta.
- Celular, multiplayer e servidor publicado.
