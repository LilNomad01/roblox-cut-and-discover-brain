# Validação — postura de segurar (foice e enxada)

**Data:** 2026-11-11 · **IA:** Claude · Play solo PC no Studio.

## Método

1. Poses congeladas pelo mesmo `AnimFerramentas.pose` em `PreSimulation`. Para a captura, o atributo `FerramentaManual` foi tirado **só no cliente de teste**, para o `Animador` não sobrescrever. Posições da lâmina medidas em relação ao `HumanoidRootPart`.
2. Combinações de ombro, cotovelo e giro testadas numericamente até a lâmina ficar rente ao chão sem atravessá-lo.
3. Depois da mudança, Play normal com o `Animador` real (incluindo o IK da mão esquerda).

## Resultados

| Verificação | Resultado |
|---|---|
| Foice parada (jogo real) | base da lâmina em y = −3,0 (rente ao chão), cabo na diagonal (`depois-foice-segurar-jogo.jpg`; antes: `antes-foice-segurar.jpg`) |
| Enxada parada | ponta em y ≈ −2,9 (`depois-enxada-segurar.jpg`; antes: `antes-enxada-segurar.jpg`) |
| Janela de contato | diferença 0 entre o módulo antigo e o novo (6.029 amostras, as 3 ferramentas) |
| Corte em Play | enxada +2 e foice +4 quadrados por golpe (`Saco 0 → 6`), iguais aos limites de antes |
| Console | sem erros |
| Fonte | `AnimFerramentas` `7304/744078194`, igual no Studio e no repositório |

## Não testado

Avaliação em vídeo do golpe completo, celular e outros tipos de corpo de avatar. A mão esquerda fica a ~1,2 stud da pegada (o IK não foi alterado).
