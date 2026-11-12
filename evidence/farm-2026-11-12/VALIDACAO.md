# Validação — região Fazenda Abandonada

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108` · **Ambiente:** Edit e Play no Studio (PC)

| Teste | Resultado |
|---|---|
| Construção: 330 quadrados, 864 peças, portão em z 242; o espaço estava livre (só árvores perto de z 203) | ✅ |
| Visão no Edit: campo cercado, celeiro, feno, trator, poço, espantalho, portão e estrada de terra | ✅ (screenshot) |
| Servidor: "[Fazenda] PRONTA: 330 quadrados de grama" | ✅ |
| Acesso pela Fama 1 (o jogador está no nível 7): `FazendaLiberada=true` | ✅ |
| **Caçamba da fazenda (E real):** saco 183 → 0 | ✅ |
| **Carrinho (movimento real) numa passada:** 9 quadrados cortados, +78 de grama = **8,67 por quadrado**. Fator 4,38 (cortador 1 × (1 + ajudantes 3 + rank 0,03 + fama 0,25 + álbum 0,1)) × 2 = 8,76 | ✅ grama 2× |
| **Bloqueio** (`FazendaTesteBloqueio`, só no Studio): jogador dentro do campo foi levado para (0, 5,9, 226), fora do portão, com aviso; `FazendaLiberada=false` e depois de volta a true | ✅ |
| **Rebrota:** 317 → 320 (20 s) → 330 (30 s); cada quadrado volta 45 s depois do corte | ✅ |
| Título "🌾 FAZENDA ABANDONADA / Só o carrinho corta aqui · a grama vale 2× · caçamba ao lado do celeiro" ao entrar, com rastro cortado atrás | ✅ (screenshot) |
| Console sem erros de script | ✅ |

## Não testado

- Tufo dourado na fazenda (1%).
- Rebrota rápida na Chuva.
- Vários jogadores cortando juntos.
- Celular.
- Bloqueio de um jogador de verdade abaixo do nível 10 e sem Fama (só pelo atributo de teste).
