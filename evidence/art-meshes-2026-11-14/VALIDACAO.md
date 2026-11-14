# Validação: arte em malha (cortadores e objetos)

**Data:** 2026-11-14 · **IA:** Claude · **Place:** `106412085364108` · **Ambiente:** Edit e Play no Studio (PC)

| Teste | Resultado |
|---|---|
| Vitrine no Edit: 6 cortadores novos ao lado dos antigos | ✅ capturas (formas arredondadas e texturas; os antigos eram blocos) |
| Orientação dos dirigidos (volante à frente do banco, frente = −Z) | ✅ os 4 conferidos por código |
| **Elétrico** em Play, no lote do jogador (Plot02) | ✅ cortou 6 quadrados com W real. AnimCortador: 6 welds (lâmina, carcaça, 4 rodas); IK das 2 mãos |
| **Mini Trator** em Play | ✅ sentado no `AssentoMotorista`; andou 21 studs; cortou (12/64) |
| Caçambas novas nos 4 lotes e na Fazenda | ✅ capturas, com placa VENDER e área dourada |
| **Venda na caçamba nova do lote** (Play, pisando na área dourada) | ✅ saco 3176 → 0, +6.360 moedas |
| Celeiro, poço, fenos e plantação | ✅ capturas; em Play estão presentes (60 pés de milho, celeiro novo) |
| Console | sem erros. Aparecem avisos "No asset content representation found": o Roblox procura versões alternativas das texturas geradas, e elas aparecem normalmente |

## Nota

O teste com o Básico no Plot04 não cortou, porque nesta sessão **o lote do jogador era o Plot02**. Não era problema dos modelos. No Plot02 tudo cortou.

## Efeitos no personagem (Studio)

O personagem ficou como estava (Imperial, mesma lista de compras). O saco de teste foi restaurado e depois **vendido de verdade** no teste da caçamba (+6.360 moedas). A recompensa offline ("Bem-vindo de volta", +3.734) apareceu na tela.

## Não testado

- Off-Road, Colheitadeira, Imperial e Turbo em Play. Usam a mesma montagem do Trator e do Elétrico.
- Celular e desempenho das texturas no celular.
