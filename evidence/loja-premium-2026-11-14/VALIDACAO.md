# Validação: Loja Premium, Analytics e Configs

**Data:** 2026-11-14 · **IA:** Claude · **Place:** `106412085364108` · **Ambiente:** Edit e Play no Studio (PC). DataStore `_Studio`, perfil real (não temporário).

**Fontes:** os tamanhos no Studio são iguais aos do repositório. LojaConfig 4222, LojaData 1743, Analytics 2406, LiveConfig 1343, LojaServidor 11425 e LojaCliente 12653 bytes.

| Teste | Resultado |
|---|---|
| PolicyService no Studio | `OvosPagosRestritos=false` (não restrito) ✅ |
| 7 passes (simulados com `LojaTestePasses`) | `MultMoedasLoja` 1→2; `SacoMax` **1050→2100**; `VagasPetsExtra` 2; `VenderQualquerLugar`; `TilesLoja` 2; `FerramentaCelestial`; `BonusLoja` 0,6; **WalkSpeed 16→20,8**; placa VIP na cabeça ✅ |
| BoostMoedas (`TesteProduto`, mesmo caminho do ProcessReceipt) | `MultMoedasLoja` 4, acaba em 1799 s ✅ |
| **Venda pelo botão "Vender aqui"** (remote real) | 100 de grama = **800 moedas** (preço 2 × passe 2 × boost 2) ✅ |
| BoostGrama / BoostXP | `BoostGrama` 2 (fator de grama 10,02), `MultXPLoja` 2 ✅ |
| OvoCelestial | entregou uma Coruja (sorteio) e equipou ✅ |
| FenixGarantida | entregou a Fênix; **5 equipados** com o passe; BonusPets 6,25 ✅ |
| PacoteMateriais | fibra 63→163 (+100), cristal e pó +10 ✅ |
| Painel: aba Passes | passes comprados aparecem como "✓ SEU" (captura) ✅ |
| Painel: aba Ovos | as 7 chances com bônus, somando 100%; compra direta da Fênix; "Em breve" sem IDs (captura) ✅ |
| Botão 💎 PREMIUM no HUD | na grade direita, abaixo de Fama; chip "x2" com boost ativo ✅ |
| AnalyticsService | o console mostra `LogOnboardingFunnelStepEvent`, `LogCustomEvent` e `LogEconomyEvent` disparados ✅ |
| ConfigService | consultado; as chaves ainda não existem no Dashboard ("Config value not found"), então valem os padrões ✅ |
| Console | sem erros dos scripts novos ou alterados ✅ |

**Correção durante o teste:** as abas apareciam em ordem alfabética. O `UIListLayout` agora usa `SortOrder = LayoutOrder`.

## Limpeza

- Os 2 ajudantes dados pelo teste (Fênix e Coruja) foram **soltos**.
- O atributo de teste foi removido.
- **Ficou no perfil do Studio (`_Studio`):**
  - +100 fibras, +10 cristais e +10 pós;
  - os boosts de 30 min, que expiram sozinhos.
  - O perfil dos jogadores reais não foi tocado.

## Não testado

- Compra real com Robux: precisa dos IDs criados pelo dono. No Studio, o prompt do Roblox é só um teste.
- Recibo repetido: só por leitura do código, porque sem ID não há ProcessReceipt real.
- Jogador restrito: só por leitura do código, porque o Studio não é restrito.
- Ferramentas Celestiais cortando com a ferramenta de mão. O atributo e o patch estão ok, mas não vi a aura nem os +2 quadrados em Play.
- Celular e multiplayer.
