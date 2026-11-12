# Validação — raridade das ferramentas / Oficina (MON-04, parte 2)

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108` · **Ambiente:** Play no Studio (PC), store `_Studio`

| Teste | Resultado |
|---|---|
| Ao entrar: as 3 ferramentas são Comum, sem materiais e sem `FerramentasExtras` | ✅ |
| **Queda real de 🌿:** carrinho na Floresta (71 tufos) deu 1 fibra | ✅ (4% esperado, ~2,8; dentro do acaso) |
| Bancada do lobby: **E abre o painel** com materiais, 3 cartões e custos com ✅/⬜ | ✅ (screenshot; o 3D renderizou desta vez) |
| Materiais de teste (`OficinaTeste=500`, só no Studio) e **4 cliques reais em EVOLUIR na Enxada**: Comum → Mitológico | ✅ |
| Custos descontados certos: fibra 501 → 16 (15+50+120+300), cristal 500 → 474 (3+8+15), pó 502 → 462 (10+30) | ✅ |
| Com a Enxada na mão: o modelo trocou na hora para **`Enxada_Mitologico`** e `BonusFerramenta=1` | ✅ |
| Cartão "Mitológico · Na mão: grama +100% · +2 quadrado/golpe · MÁXIMA" | ✅ (screenshot) |
| **Quadrados extras:** Foice Mitológica, 1º golpe = **5 cortes** (teto da Comum é 4) | ✅ |
| Grama por corte com a Foice Mitológica: 7,4 a 9 (com o carrinho, sem bônus de ferramenta, era ~4,4) | ✅ coerente com +100% |
| **Persistência:** depois de reiniciar o Play, Enxada e Foice Mitológicas, materiais mantidos | ✅ |
| Com o carrinho, `BonusFerramenta=0` | ✅ |
| Console sem erros de script | ✅ |

## Notas do teste

- O primeiro teste de golpe deu 0 cortes porque **o lote do jogador mudou entre sessões** (Plot03, não o Plot04 dos testes anteriores). Não era um bug do código.
- O save de teste do Studio ficou com a Enxada e a Foice Mitológicas e os materiais de teste.

## Não testado

- Queda de 💎 por baú ou segredo, e de ✨ por tufo dourado, nesta sessão. Usam os mesmos eventos já validados nas missões e conquistas.
- Unha evoluída.
- Visual de cada raridade na mão (só o nome do modelo foi conferido).
- Celular e multiplayer.
