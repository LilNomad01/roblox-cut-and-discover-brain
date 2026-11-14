# Lotes: caçambas em forma real e placa com texto dos dois lados

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "Yes, fix them" (itens restantes da auditoria `evidence/modelagem-2026-11-12/AUDITORIA.md`).

## Caçambas dos 4 lotes (`CacambasLote.build.luau`)

- **Antes:** uma caixa verde reta.
- **Agora:** formato de caçamba de entulho (brain 21: topo 3,4 m, fundo 2,24 m):
  - **fundo = 2/3 do topo**;
  - **pontas inclinadas** com reforços e **ganchos de içamento**;
  - **laterais em trapézio**, feitas de uma placa central e duas cunhas;
  - frisos escuros;
  - rodinhas sob o fundo e a faixa amarela ajustada ao trapézio.
- **Nada da lógica mudou:** o `Corpo` original ficou **invisível** e continua com o prompt de venda, a placa "VENDER" e a colisão. As peças novas ficam em `Cacamba.Forma` e não colidem.
- **Backup:** `ServerStorage.CacambasBackup_20261112`.

## Placa do lote (`PlacaLoteVerso.server.luau`)

- **Antes:** o letreiro ("LOTE N • LIVRE" ou "Nome / SEU JARDIM") só existia na face de dentro do lote. Quem vinha da calçada via um painel marrom vazio.
- **Agora:** o script `CorteEDescubra.PlacaLoteVerso` copia o letreiro para a face de trás e repete toda troca de texto feita pelo GameServer.

## Não mexido (de propósito)

**Pinheiro `08_ConiferaInclinada`:** o tronco esculpido inclinado a 69° atravessa a copa, que está reta. Ele pertence à floresta, que está sendo alterada por outra pessoa neste momento: `WorldAmbience` espera `CriptaDasRaizes`, e a floresta caiu para 19.674 tufos. Fica para quem cuida da floresta, para evitar conflito.
