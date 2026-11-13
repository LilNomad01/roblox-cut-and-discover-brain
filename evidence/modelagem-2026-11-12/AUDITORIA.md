# Revisão de modelagem — auditoria (2026-11-12)

**Pedido do usuário:** "dar uma geral completa no jogo para arrumar o que está mal modelado, faça pesquisas de como as coisas são na vida real e como jogos normalmente costumam retratar". As referências estão em [brain 21](../../brain/21_REFERENCIAS_HUD_E_ARTE.md).

**Método:**
- capturas no Studio: lobby visto de cima, praça, lote, floresta, fazenda;
- vitrine temporária dos 8 modelos de cortador (apagada depois);
- conferência de peças e malhas por script.

## Arrumado nesta rodada

| Problema | Onde | O que foi feito | Prova |
|---|---|---|---|
| A Oficina ficava **no meio da estrada norte** (PathZ), bloqueando a passagem | lobby | movida para a grama entre a estrada e a cerca dos lotes (x −13, z 32), de frente para a estrada, sem colidir com nada | captura |
| As ferramentas penduradas na Oficina **atravessavam o painel** e apareciam atrás | lobby | cada uma fica na frente do painel com 0,1 de folga (a Foice tinha 0,86 de meia-profundidade) | medição |
| Celeiro de **telhado simples**, sem os detalhes típicos | fazenda | refeito com telhado **gambrel** (parte baixa 60°, alta 25°), **quinas brancas**, portas duplas abertas com **"X" branco**, **porta do palheiro** com X e feno, **cata-vento** | capturas |
| Fardos pequenos e **em pé**, como tambores | fazenda | medida real 4×5 pés × 0,8 = **3,6 × 4,4 studs**, **deitados**; o fardo empilhado que flutuava foi para o chão | captura |
| Poço com uma **tábua solta** no lugar do telhado | fazenda | telhado de **duas águas**, **sarilho com manivela**, corda e balde | — |
| Cerca de 2 ripas | fazenda | **3 ripas** (cerca rural de 3 trilhos) | captura |
| Caçamba da fazenda era uma **caixa reta** | fazenda | **laterais inclinadas** (topo 7,2 × fundo 4,8), faixa, ganchos. O prompt de venda continua no fundo | captura |

As receitas estão em `game/farm/Fazenda_v2.build.luau` (rodada depois de `Fazenda.build.luau`) e em `game/tool-rarity/OficinaFerramentas.build.luau` (posição nova).

## Encontrado, ainda não arrumado

| Gravidade | Problema | Onde | Detalhe |
|---|---|---|---|
| **Alta** | **Cortador_Elétrico e Cortador_Turbo aparecem só como duas varetas brancas** (só a lâmina renderiza) | `ServerStorage.GameAssets.Mowers` | as 9 peças existem; a malha da carcaça dá **"Failed to load mesh asset"** (`AssetService:CreateMeshPartAsync`). As malhas são da conta LilNomad00 (upload do Blender). Provável moderação ou upload que falhou |
| **Alta** | **Cortador_Trator aparece como uma caixa roxa com uma roda** | idem | 5 peças; as malhas também não carregam |
| **Alta** | **Off-Road, Colheitadeira e Imperial GX não têm modelo** | idem | o GameServer procura `Cortador_<Id>` e, sem ele, usa o MowerLv antigo; os 3 cortadores mais caros parecem um cortador básico |
| Média | Caçambas dos 4 lotes são **caixas retas**; caçamba real tem laterais inclinadas | lotes | modelo da HUD/Codex; dá para aplicar o mesmo tratamento da fazenda |
| Média | **Placa escura grande** no canto de cada lote parece um painel vazio | lotes | conferir se é placa com texto só em Play |
| Baixa | Um **pinheiro com galho atravessando a copa** na entrada da floresta | floresta | modelo de árvore da prévia |
| Baixa | **Placa do arco de entrada da floresta sem texto** no Edit | floresta | conferir em Play |

## Rodada 2 (2026-11-12, "Yes, fix them")

| Item | Resultado | Prova (Play no Studio) |
|---|---|---|
| Caçambas dos 4 lotes | refeitas com forma de caçamba de entulho (fundo 2/3 do topo, pontas inclinadas, ganchos); o `Corpo` invisível mantém a venda | 40 de grama vendidos na caçamba do lote = +80 moedas; captura |
| Placa escura dos lotes | era o **verso** da placa; o letreiro agora aparece dos dois lados e acompanha o texto do GameServer | os 4 lotes com frente = verso ("Barbosaa / SEU JARDIM" e "LOTE N • LIVRE"); captura |
| Pinheiro com galho atravessando | **não mexido**: a floresta está sendo alterada por outra pessoa agora (aviso `CriptaDasRaizes`, 19.674 tufos) | — |
| Placa do arco da floresta | o texto é colocado em Play (no Edit fica vazia) | — |

Ver `game/lot-props/README.md`.

## Cortadores: resolvido em 2026-11-12

O usuário escolheu "Remodel in Studio". Ver `game/mowers/README.md` e `evidence/mowers-2026-11-12/VALIDACAO.md`.

## (histórico) Decisão pendente (do usuário): cortadores

Duas saídas para os cortadores sem malha:

1. **Reenviar as malhas do Blender** (as originais do usuário/Codex) e conferir a moderação no Creator Hub. Mantém o estilo das entregas em Blender.
2. **Remodelar em peças no Studio**, seguindo as referências do brain 21:
   - empurrar: rodas traseiras maiores, guidão a ~45°, saco atrás;
   - trator: rodas traseiras ~1,6× as dianteiras, banco e volante;
   - colheitadeira: plataforma com molinete, cabine alta, tanque e tubo de descarga.

   É mais rápido e não depende de upload, mas o visual fica "de peças".
