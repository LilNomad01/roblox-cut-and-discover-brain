# Validação — cortadores remodelados

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108` · **Ambiente:** Edit e Play no Studio (PC)

**Preparação do teste:** o personagem recebeu no servidor todos os cortadores, só para o teste. Depois, o original (Básico, `Comprados=Basico`, ×1) foi devolvido.

| Teste | Resultado |
|---|---|
| Vitrine no Edit: os 8 lado a lado, vistos de trás e da frente | ✅ (capturas). O molinete da colheitadeira estava em pé e foi corrigido para deitado na plataforma |
| **Elétrico** (empurrar): monta na frente do personagem, `Manopla` e `Lamina` presentes, IK das duas mãos com peso 1 | ✅ (captura) |
| Elétrico cortando (W real, uma passada): **+13 quadrados** | ✅ |
| Básico na mesma situação (comparação): +7 quadrados | ✅ |
| **Mini Trator** (dirigido): `Dirigivel=true`, sentado no "AssentoMotorista", W real: **andou 36,8 e cortou +14** | ✅ (captura) |
| **Off-Road** (dirigido pelo atributo novo): sentado, andou 25,6 | ✅ (captura) |
| **Colheitadeira** (dirigida): sentada, andou 14,5 | ✅ (captura) |
| **Imperial** (dirigido): sentado, visual azul e dourado com coroa | ✅ (captura) |
| Console sem erros dos scripts alterados | ✅ |

## Observações

- `Humanoid:Move` por script parou de mover o personagem nesta sessão; os testes usaram o W real.
- Durante o teste, o evento automático **"Hora do Dobro"** começou sozinho (ciclo do PAD-06). É a primeira prova do ciclo automático em Play.
- **Aviso novo, não é deste trabalho:** `WorldAmbience` espera `FlorestaEsquecida.CriptaDasRaizes` ("Infinite yield"), e a floresta caiu de 25.180 para 19.674 tufos. Parece outra pessoa (Codex?) mexendo na floresta ao mesmo tempo.

## Não testado

- Turbo cortando (usa a mesma base do Elétrico).
- Off-Road, Colheitadeira e Imperial **cortando** (só a direção foi testada; a lâmina segue o mesmo caminho do Trator).
- O tamanho da Colheitadeira (×1,25) num lote de 32×32 pode apertar perto da cerca.
- Celular.
