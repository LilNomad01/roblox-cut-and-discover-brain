# Animações — foice e enxada apoiadas no ombro, sem atravessar o corpo

**Data:** 2026-11-11 · **IA:** Claude · **Place:** `106412085364108`

## Histórico

1. **Primeira versão (commit `b72dc17`):** ferramenta na diagonal, com a lâmina rente ao chão. O usuário reprovou: "a animação da foice e da enxada estão péssimas".
2. **Versão atual:** pedido do usuário, com foto de referência de um homem carregando a enxada no ombro:
   - segurar a enxada e a foice apoiadas no ombro;
   - nada atravessando o corpo;
   - apertar o número da ferramenta de novo tira o item da mão.

3. **Golpe da enxada reto (rodada 3):** o usuário relatou que "o movimento de ação da enxada está de lado". Desde a versão original, ela batia ~2,3 studs à esquerda do corpo. Agora ela:
   - sobe pelo lado do ombro;
   - passa por cima da cabeça;
   - desce reto à frente (contato ~4,8 studs à frente, no centro);
   - levanta pela frente e volta ao ombro.

## Mudanças

| Onde | O quê |
|---|---|
| `ReplicatedStorage.Shared.AnimFerramentas` (cópia completa: `AnimFerramentas.luau`) | `SEGURA_CABO` e `SEGURA_FOICE` novos: mão direita na frente do peito, cabo na diagonal, cabeça da enxada ou lâmina da foice atrás e acima do ombro direito. Enxada: golpe refeito, reto à frente, com chaves novas em 0,10, 0,58 e 0,70. Foice: ajuste de ombro e pulso em 0,14, 0,30 e 0,46. |
| `Animador` | Na postura parada, a mão esquerda fica livre (IK desligado). **Bug corrigido:** depois do respawn, o personagem parava de animar. |
| `FerramentasServer` | Apertar o número da ferramenta que está na mão guarda o item (`FerramentaAtiva = "Nenhuma"`). Vale para as teclas 1 a 4, incluindo o carrinho. |
| `GameServer` | Com a mão vazia, o objetivo mostra "Escolha uma ferramenta: teclas 1 a 4". |

Os trechos exatos dos três scripts estão em [PATCHES.md](PATCHES.md).

## Como as poses foram achadas

Foi usada cinemática direta com as juntas reais do personagem em Play:

- cadeia `HumanoidRootPart → Root → Waist → ombro → cotovelo → pulso → PegadaMao → Corpo`, com `C0 · Transform · C1⁻¹`;
- o cabo inteiro (do pé até a lâmina) e a lâmina foram amostrados contra as caixas do tronco, da cabeça, das coxas, das canelas e do braço esquerdo.

A busca escolheu o menor desvio da lâmina que ainda deixasse o golpe sem colisões.

## Efeito no corte

**O trajeto da lâmina mudou** dentro da janela de contato: ~0,87 stud em média, nas duas ferramentas. O servidor (`BladeSweep`) e a previsão do cliente usam o mesmo módulo, então continuam consistentes. Em Play, o ganho por golpe em grama nova continuou igual ao de antes: foice +4 e enxada +2.

Evidência: [`evidence/animations-2026-11-11/VALIDACAO.md`](../../evidence/animations-2026-11-11/VALIDACAO.md).
