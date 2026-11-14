# Validação — jogar com amigos (PAD-08)

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108` · **Ambiente:** Play no Studio (PC), 1 jogador

| Teste | Resultado |
|---|---|
| Sem amigos: `AmigosNoServidor=0`, `BonusAmigos=0`, selo "👥 Convidar amigos (+10% cada)" | ✅ |
| `AmigoTeste=3` (só no Studio): 3 amigos, bônus 0,30, nomes listados, selo "👥 3 amigos aqui · +30% grama" | ✅ |
| `AmigoTeste=1`: bônus 0,10, selo verde "1 amigo aqui · +10% grama" acima de Missões/Prêmios | ✅ (screenshot) |
| **Tufo dourado cortado com 3 amigos: pagou 58 moedas** = 9 × (1 + 1,9 + 0,03 + 0,30) × 2. Sem amigos pagava 53 | ✅ o bônus entra no fator da grama |
| Grama por corte com e sem amigos | ⚠️ inconclusivo: as aparas e o corte de fechamento variam mais que 10% numa passada |
| Console sem erros de script | ✅ |

## Não testado

- **Amizade real entre 2 jogadores** (`IsFriendsWith`) e os avisos de "amigo entrou". Precisa de Team Test ou do servidor publicado com 2 contas amigas.
- **Janela de convite** (`PromptGameInvite`): no Studio o convite não abre.
- "Ajudar no jardim do amigo": não implementado (ver README).
