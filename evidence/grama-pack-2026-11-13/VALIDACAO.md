# Validação: toda a grama como a da área de teste

**Data:** 2026-11-13 · **IA:** Claude · **Place:** `106412085364108` · **Ambiente:** Edit e Play no Studio (PC)

**Pedido do usuário:** "deixe toda a grama como a da area de teste".

## Situação antes

| Onde | Grama | Corte |
|---|---|---|
| Área de teste (`CutPrototypeZone`) | tufos do **Grass Pack** (A01–A06, estados TALL/SHORT/STUBBLE), escala 0,9–1,1 | máscara contínua no cliente (protótipo) |
| Floresta | Grass Pack (`ForestGrassClient`, do Codex) | servidor |
| **4 lotes** (64 quadrados de 4×4 cada) | **tufo antigo**, um MeshPart por quadrado com o filho "Cortada" | servidor (`GameServer.setTileCut`) |
| **Fazenda** (330 quadrados) | **tufo antigo** | servidor (`FazendaServidor`) |

## O que mudou

Novo `StarterPlayerScripts.GramaPackCliente` (`game/grass/GramaPackCliente.client.luau`). Ele troca **só o visual** nos lotes e na Fazenda:
- o tufo antigo e a "Cortada" de cada quadrado ficam escondidos **só no cliente** (`LocalTransparencyModifier`);
- cada quadrado ganha **9 tufos do Grass Pack**, com a mesma escala da área de teste e manchas de cor iguais às da Floresta;
- o estado vem do servidor, sem lógica nova:
  - inteiro → TALL;
  - cortado → SHORT;
  - "Corte Rente" → STUBBLE;
- o tufo alto achata ao ser cortado e volta crescendo na rebrota;
- a grama entre a câmera e o personagem fica translúcida (é uma parede de 6 a 10 studs, como na área de teste).

**O corte, o saco, as moedas, as missões, o tufo dourado e a rebrota não mudaram:** tudo continua no servidor.

## Testes (Play no Studio)

| Teste | Resultado |
|---|---|
| Tufos criados | **5.274** = 4 lotes × 576 + Fazenda 330 × 9 ✅ |
| Visual do lote e da Fazenda | igual ao da área de teste ✅ (capturas) |
| Cortador Básico no Plot04 (W real) | saco **53 → 88**, 6 quadrados cortados. Os 6 ficaram com 9 tufos baixos e nenhum alto ✅ |
| Mais passadas | 18/64 cortes; saco até 197; tufo dourado apareceu ✅ |
| Câmera atrás do personagem | o personagem aparece através da grama translúcida ✅ (captura) |
| Console | sem erros novos ✅ |
| FPS | **inconclusivo:** 15 FPS com e sem a grama nova (o Studio fica travado em 15 quando está em segundo plano) |

**Efeito no seu personagem:** os cortes de teste contaram de verdade. O personagem passou do nível 8 para o 9, e o saco ficou em 197 (dados do Studio).

## Observações

- **Faixa cortada pouco visível:** o tufo alto (até ~10 studs) debruça sobre os quadrados vizinhos. Vista de cima, uma faixa de 4 studs cortada fica escondida. É o mesmo comportamento da área de teste ("parede de grama").
  - Se o progresso precisar aparecer mais, dá para baixar a escala só nos lotes (por exemplo 0,6–0,75).
  - A área de teste e a Floresta não foram tocadas.
- **Desempenho:** a pesquisa de APIs (`brain/22`) recomenda reaproveitar tufos com `BulkMoveTo` em vez de clonar. É a próxima otimização, se o celular sofrer.
- **Não testado:** celular, multiplayer (outros jogadores cortando), Fazenda cortando e "Corte Rente" (STUBBLE). O código é o mesmo, mas não vi em Play.
