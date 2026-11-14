# Validação — Fama de Jardineiro (MON-05)

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108` · **Ambiente:** Play no Studio (PC), store `_Studio`

**Preparação do teste:**
- No servidor, o personagem de teste recebeu todos os cortadores até o Imperial GX e 250.000 moedas, só para cumprir o requisito.
- Antes do teste: 20.654 moedas e o cortador Básico.
- Depois do teste as moedas voltaram a 20.654. **A Fama 1 continua no save de teste do Studio.**

| Teste | Resultado |
|---|---|
| Sem o Mega e o Imperial, o botão "⭐ Fama" fica escondido | ✅ |
| Com o Imperial, o botão mostra "⭐ Fama: você pode renascer!" | ✅ |
| Painel (clique real): Fama 0, bônus +0% → +25%, requisitos ✅ Imperial GX e ✅ 200.000 (tem 250.000), perde e mantém | ✅ (screenshot) |
| 1º clique em RENASCER: "TEM CERTEZA? CLIQUE DE NOVO", nada muda (moedas 250.000, fama 0) | ✅ |
| 2º clique: **Fama 1 · Jardineiro Famoso**, +25%; a próxima estrela pede 320.000; "⭐ Fama 1! Bom recomeço!" | ✅ (screenshot) |
| Servidor: Moedas=0, Comprados=Basico, Cortador=Basico, Multiplicador=1, SacoMax=50, Saco=0, FamaEstrelas=1, BonusFama=0.25 | ✅ |
| **Mantido:** Nivel=6, BonusPets=1.9 | ✅ |
| `leaderstats.Fama=1` e "⭐ 1" sobre a cabeça | ✅ |
| Renascer de novo: recusado ("Compre o Imperial GX primeiro.") | ✅ |
| Tufo dourado depois de renascer: **pagou 57** = 9 × 1 × (1 + 1,9 + 0,03 + **0,25**) × 2 | ✅ bônus aplicado |
| **Persistência:** reiniciar o Play mantém FamaEstrelas=1, Comprados=Basico, leaderstats e a estrela | ✅ |
| Console sem erros de script | ✅ |

## Não testado

- Renascer sem a preparação de teste, ou seja, comprando de verdade até o Imperial GX. O custo de tempo foi estimado só pelo modelo de balanceamento.
- A estrela vista por outro jogador e o aviso para os outros (precisa de 2 jogadores).
- O modelo do carrinho trocando na hora para o Básico: o atributo muda, mas o visual montado não foi conferido.
- Celular e servidor publicado.
