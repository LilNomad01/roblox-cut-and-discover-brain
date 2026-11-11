# Progressão, moedas, XP, PH e balanceamento

## Economia existente em código (V9, `ReplicatedStorage.ConfigJogo`)

- `PrecoGrama = 2` moedas por unidade vendida.
- `GramaPorPlaca = 1` base por placa cortada, antes de multiplicadores.
- `XPPorPlaca = 5` por placa (validar caminho ativo e anti-dupe).
- `XPParaNivel(n) = floor(60 * n^1.4)`; screenshot exibe nível 1 → 2: `0/60 XP`.
- `RecompensaNivel(n) = 25 * n`.

**Nota:** há também outro módulo `GameConfig` com parâmetros diferentes, como `CellReward=2`, `JobReward=40`, `TutorialReward=15`, `CrateReward=10` e níveis próprios. Isso indica coexistência de sistemas antigos/novos. **Antes de calibrar, identificar qual módulo o gameplay ativo utiliza.** Não misturar tabelas de sistemas paralelos.

## Loja de cortadores na V9 (`ConfigJogo.Itens`)

| ID | Nome | Preço | Corte | Saco |
|---|---|---:|---:|---:|
| `Basico` | Cortador Básico | 0 | 1× | 50 |
| `Eletrico` | Cortador Elétrico | 400 | 2× | 100 |
| `Turbo` | Cortador Turbo | 2.500 | 4× | 250 |
| `Trator` | Mini Trator | 15.000 | 10× | 800 |
| `OffRoad` | Trator Off-Road | 32.000 | 14× | 1.200 |
| `Colheitadeira` | Colheitadeira | 65.000 | 18× | 1.800 |
| `Mega` | Mega Cortador | 100.000 | 30× | 3.000 |
| `Imperial` | Imperial GX | 250.000 | 45× | 5.000 |

**Atenção:** os três extras `OffRoad`, `Colheitadeira`, `Imperial` foram adicionados à configuração em V8. Sua lógica/compra foi escrita, mas **os modelos 3D exclusivos não foram comprovados**; uso de visual fallback possível. Economia não foi balanceada em Play.

## Ferramentas manuais e raridades

- `CortadorUnha`, `Enxada`, `Foice` × `Comum`, `Incomum`, `Raro`, `Lendario`, `Mitologico`.
- Na V9, `FerramentasConfig.KitInicial` dá as versões **Comuns** das três manuais.
- Multiplicadores de raridade previstos: 1,00 / 1,15 / 1,30 / 1,50 / 1,75.
- Compra/evolução de raridade **não concluída**; modelos não implicam que o sistema de progressão funcione.
- Os carrinhos/máquinas não podem virar irrelevantes em relação à foice; largura, modo contínuo, mobilidade e resistência da grama precisam diferenciar.

## PH — pontos de habilidade

- São **separados de moedas, XP e Robux**.
- `SkillDefinitions` da V9 documenta marcos sugeridos de concessão de PH: níveis `2,4,6,8,10,12,15,18,22,26`.
- Cada fonte de PH deve ser creditada **uma única vez**, com ledger/idempotência. PH gasto pelo servidor, verificado contra requisitos e saldo.
- Não permitir compra de habilidade com `status=Planned`, mesmo que o botão exista.
- Evitar reset total em uma migração de perfil.

## Balanceamento aplicado (2026-11-11, Claude)

`XPParaNivel` passou de `60·n^1,4` para `110·n^1,4`, e os preços dos cortadores foram ajustados:

| Cortador | Elétrico | Turbo | Trator | Off-Road | Colheitadeira | Mega | Imperial |
|---|---:|---:|---:|---:|---:|---:|---:|
| Preço novo | 800 | 3.200 | 16.000 | 47.000 | 75.000 | 140.000 | 360.000 |

Modelo de jogador eficiente: nível 10 em ~32 min, Turbo em 15 min, Imperial em ~4h30 (nível 25). Validado em Play no Studio (perfil salvo continua válido, loja mostra preços novos). Detalhes e modelo: `game/balance/`.

**As tabelas abaixo (V9) ficaram desatualizadas nos preços.** Falta uma sessão real cronometrada.

## Balanceamento ainda necessário

Problema relatado desde fases anteriores: **níveis sobem rápido demais**, sons e feedback pouco satisfatórios. Fazer teste de 30–60 min com métricas: `xp/min`, `moedas/min`, `cortes válidos/min`, `tempo por upgrade`, `tempo por área`, abandono de tutorial e FPS mobile.

Metas históricas **NÃO medidas**: enxada em 1–3 min, foice em 8–12 min, carrinho em 20–30, motorizado em 45–70, trator em 90–150. Outra fórmula proposta anteriormente `100 + 35(L-1) + 6(L-1)^2` era **alternativa de design, não a fórmula em uso**. Não adotar sem comparar à `ConfigJogo` real.

## Anti-exploit

- XP/grama/saco somente quando a unidade muda de estado por corte legítimo.
- Segunda passada `SHORT→STUBBLE` não deve duplicar XP/grama automaticamente; qualquer bônus de habilidade exige regra específica.
- Recompensas de baú/quest/nível idempotentes e server-side.
- Limite de capacidade do saco antes de conceder item.
- Não confiar em RemoteEvent informando quantidade cortada ou moedas.

## Planejado: mochilas e venda distribuída na floresta (2026-11-10)

A loja do NPC Guto poderá vender bônus fixos de capacidade de saco, integrados à capacidade de cada máquina. Os 5 níveis e preços **são provisórios**; não duplicar módulo de moeda/XP nem somar bônus das mochilas anteriores. Três caçambas reutilizarão a transação existente do lobby. Ver [especificação completa](17_COMERCIANTES_CACAMBAS_MOCHILAS.md). Estado: **PLANEJADO**, aguardando baseline e implementação/testes.
