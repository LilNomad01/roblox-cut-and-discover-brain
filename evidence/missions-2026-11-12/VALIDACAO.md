# Validação — Quadro do Jardineiro (PAD-05)

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108` · **Ambiente:** Play no Studio (PC), store `_Studio`

Todos os eventos abaixo vieram do jogo real: corte com o carrinho, venda na caçamba, ninho pelo `PetsAcao` e coleta pelo botão do painel com clique do mouse. Nada foi forçado por código.

| Teste | Resultado |
|---|---|
| Painel abre e mostra rank, 3 trilhas, metas e prêmios | ✅ (screenshot do painel) |
| Venda com saco cheio conta (1/3) | ✅ |
| Corte no lote conta (0 → 7 → 19 → 95/150) | ✅ |
| 3ª venda deixa a missão pronta: `MissoesProntas=1`, bolinha "1" no botão, cartão verde com COLETAR | ✅ |
| Clique real em COLETAR: moedas 15.994 → 16.144 (+150), XP +30, 1 selo, trilha avançou para "Choque 1 ninho" | ✅ |
| Coletar de novo a mesma trilha | ✅ recusado ("Essa missão ainda não terminou.") |
| Chocar ninho conta (1/1) | ✅ |
| Vender o saco 6 vezes (a meta "x" do ciclo 0) e coletar | ✅ +300 |
| **Subida de rank** no 3º selo: Aprendiz → **Ajudante**, `BonusMissoes=0.03`, `RankJardineiro=1` | ✅ |
| Ciclo 2 da trilha: "Venda o saco **4** vezes", prêmio **225**, 40 XP | ✅ |
| **Persistência:** parar e iniciar o Play de novo: selos=3, rank Ajudante, progressos 95/150 e 0/4 mantidos | ✅ |
| Quadro físico: E no lobby abre o painel | ✅ (depois da correção abaixo) |
| Console sem erros de script | ✅ |

## Problemas achados e corrigidos

1. **E no quadro não abria nada.** Com `StreamingEnabled`, o prompt chegava depois de o script procurá-lo. Correções:
   - o cliente usa `ProximityPromptService.PromptTriggered`;
   - o modelo agora é `ModelStreamingMode = Atomic`.
2. **Botão fora da tela em telas baixas.** Ele ficava abaixo de "Prêmios" e passou para a mesma linha, à esquerda.

## Não testado

- Trilha Floresta (cortes na floresta e baús/segredos) e missões de jardim completo e de tufo dourado. Os ganchos estão nos mesmos pontos já validados do PAD-02 e do PAD-04, mas sem Play desta vez.
- Efeito numérico do +3% na grama: verificado só no código. Com aparas e corte de fechamento, a diferença fica pequena demais para medir num teste curto.
- Visual 3D do quadro: a captura do Studio saiu preta (limitação conhecida). Precisa de olhada do usuário.
- Celular, controle, multiplayer e servidor publicado.
