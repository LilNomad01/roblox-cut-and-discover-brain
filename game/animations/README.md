# Animações — postura de segurar a foice e a enxada

**Data:** 2026-11-11 · **IA:** Claude · **Place:** `106412085364108` · **Pedido do usuário:** melhorar as animações. Reclamação já registrada no brain: "foice segurada horizontalmente e pouco natural".

Backup: `ServerStorage.AnimationBackup_20261111.AnimFerramentas`.

## Diagnóstico (poses congeladas em Play e medidas em relação ao corpo)

| Ferramenta | Antes | Problema |
|---|---|---|
| Foice | lâmina 5 studs à frente, **na altura do quadril** (y ≈ 0 em relação ao centro do corpo; chão ≈ −3) | cabo na horizontal, como vara presa na cintura |
| Enxada | cabeça a 4,3 studs à frente, **na altura do peito** (y ≈ +0,9) | erguida na horizontal, como arma |

## Mudança (`ReplicatedStorage.Shared.AnimFerramentas`, cópia completa em `AnimFerramentas.luau`)

- `SEGURA_FOICE` (novo) e `SEGURA_CABO`: a ferramenta desce na diagonal e a lâmina/cabeça descansa perto do chão, à frente. Medido no jogo: base da lâmina da foice em y ≈ −3,0; ponta da enxada em y ≈ −2,9.
- Mudam só a postura parada (`A.Segurar`) e o **primeiro e o último quadro** dos clipes da foice e da enxada. Assim o golpe começa e termina na mesma postura, sem salto.
- **O corte não muda.** O servidor (`BladeSweep`) e a previsão do cliente só usam a janela de contato (`FerramentasConfig.janela`). Comparação numérica entre o módulo antigo e o novo, em 6.029 amostras dentro das janelas das três ferramentas: diferença máxima **0**.
- Cortador de unha e carrinho: sem mudança.

## Observação

A mão esquerda fica a ~1,2 stud da pegada do cabo na postura nova. O IK da mão esquerda (`ArmIK.secondaryGrip`) é anterior a esta mudança e não foi alterado. Se a mão solta incomodar, vale ajustar o alcance do IK numa próxima etapa.
