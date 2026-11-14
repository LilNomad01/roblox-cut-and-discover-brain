# Validação: cortadores v2 (mais detalhe)

**Data:** 2026-11-13 · **IA:** Claude · **Place:** `106412085364108` · **Ambiente:** Edit e Play no Studio (PC)

**Preparação do teste:** só durante o teste, o personagem recebeu `Comprados=Basico,Turbo,Trator`. No fim, voltou para `Cortador=Basico` e `Comprados=Basico`.

| Teste | Resultado |
|---|---|
| Vitrine no Edit (temporária, apagada depois): os 6 modelos novos | ✅ capturas (rodas com cubo e porcas, frente redonda, capô chanfrado, escapamento) |
| **Turbo** em Play: monta como ferramenta, modelo v2 (`Autor` v2, 74 peças) | ✅ |
| Turbo: o AnimCortador criou **11** welds `AnimLocal` (lâmina, carcaça, frente redonda, 4 pneus, 4 aros) | ✅ o patch da frente redonda funciona |
| Turbo cortando (W, A e S reais): saco **79 → 141** | ✅ |
| **Trator** em Play: sentado no `AssentoMotorista`, `Dirigivel=true` | ✅ |
| Trator na grama do lote (W real, 2,5 s): andou **35,8** e o saco foi **141 → 167** | ✅ |
| Console: sem erros dos scripts alterados | ✅ (só o aviso antigo de R15Anim) |

## Achado (não é da v2)

**O trator não sai do lugar quando nasce na beirada do lote:** o `LoadCharacter` pôs o personagem na entrada do Plot01 (z −27). As rodas da frente ficaram contra o degrau de **0,2** entre a `Base` (topo 0,6) e o `Lawn` (topo 0,8). O `LinearVelocity` só empurra no plano, e o trator ficou parado com velocidade-alvo 18 (o servidor recebia o W). Depois de colocado 4 studs à frente, já sobre a grama, ele andou normalmente.

A geometria das rodas é a mesma da v1, então o problema já existia. Correção sugerida: a rampa/chanfro na borda do `Lawn`, ou um pequeno empurrão para cima (`LinearVelocity` com eixo Y ou `VectorForce`) quando a roda da frente encosta.

## MOD-01 corrigido (mesmo dia)

- **Causa:** as rodas dos dirigidos não giram, elas deslizam (o `LinearVelocity` empurra no plano). Na quina do degrau, a força que sobe pela roda era menor que o atrito máximo da borracha (atrito 1,0, e a conta pede > 0,92). Teste rápido: com atrito 0,05 nas rodas, ele subiu e andou 40.
- **Patch:** `MowerMount.vehicle` agora dá atrito 0,05 a toda peça `Roda*`:
  ```lua
  if part.Name:match("^Roda") then part.CustomPhysicalProperties = PhysicalProperties.new(0.9, 0.05, 0.1, 100, 1) end
  ```
  Vale para todos os veículos. Backup em `ServerStorage.CortadoresBackup_20261113.MowerMount`.
- **Play (Plot04, saindo do ponto onde nasce, sem ajuda):**
  - Trator: andou 23,9 e o saco foi 550 → 611; atrito lido 0,05;
  - **Colheitadeira v2:** sentada, andou 22,5; numa faixa ainda não cortada, o saco foi 611 → 655.
- Console sem erros novos.

## Não testado

- Elétrico, Off-Road e Imperial em Play nesta rodada (a Colheitadeira foi testada junto com o MOD-01). Eles usam as mesmas funções de construção do Turbo e do Trator; na v1, todos foram testados.
- Celular.
