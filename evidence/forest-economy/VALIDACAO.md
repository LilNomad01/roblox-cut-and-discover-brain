# Validação do comércio — 2026-11-10

Base de implementação: `997d839`, branch `ai/forest-economy`. Place inspecionado e editado: `106412085364108`, universe `10775723165`, nome `corte e descubra (colaboração para programar)`. Não foi carregado nenhum arquivo V1–V9 sobre o place.

## Resultado observado

- **Compilação:** 15 fontes Luau, incluindo testes, compiladas pelo Luau oficial 0.746.
- **Regras puras:** `Forest commerce: 50 assertions passed`, em `tests/transactions.luau`.
- **Integração em Play:** `Passed=48`, `Result="PASS 48 checks"`, no Script temporário `ForestAcceptance`, utilizando Scripts normais no servidor e cliente. A execução final ocorreu após a correção das árvores e placas.
- **Regressão de UI:** `PASS forest/main shop modal transition and shared state`, após a correção de `LojaAberta`.
- **Conferência final em Edit:** as 11 fontes de `manifest.json` correspondem ao código do Studio, desconsiderando apenas espaços finais.
- **Estado da build:** alterações permanecem no Studio em Edit. Nenhuma publicação. O agente não salvou um arquivo `.rbxl`; essa operação exige o usuário no Studio.

## Verificações reais em Play

O teste integrado comprovou compra e replay de mochilas, recusa de preço extra enviado pelo cliente, saldo insuficiente, bônus sem acumulação, troca de cortador com grama excedente preservada e bloqueio de nova coleta. As vendas de entrada e centro usaram 2 moedas por unidade; repetir a venda não pagou novamente nem concedeu XP. Venda e compra fora de alcance foram recusadas.

A caçamba da cabana recusou venda antes do contrato e aceitou depois. Flores foram coletadas uma vez por jogador; o contrato consumiu três, pagou 120 moedas uma única vez e liberou o depósito. A troca botânica consumiu cogumelos e concedeu kit. Compras de lanterna, bússola e marcador passaram; a lanterna criou luz real e a removeu ao guardar. O kit consumiu uma unidade e não repetiu o consumo sem estoque.

O gnomo permaneceu oculto inicialmente. O teste usou `GameServerGanchos.CortarPorLamina`, a rota existente de corte, para revelar o matagal. A descoberta abriu a loja exclusiva e pagou XP apenas uma vez. A missão concedeu 90 moedas uma vez; a aparência consumiu três cogumelos e um fragmento. A captura de perfil incluiu a extensão comercial e o mundo preservou quatro lotes.

Testes adicionais observaram `Before=true`, `After=true`, `Tools=true`, `CapacityStable=true` para mochila, ferramentas e capacidade após respawn. Com entrada simulada pelas ferramentas de Studio, E abriu Guto, X fechou a janela e Esc também fechou. M abriu o menu do jogador e fechou o comércio. A regressão final conferiu abertura da Loja principal, fechamento do comércio e preservação correta do atributo compartilhado.

A imagem `comercio-em-play.png` mostra a banca e o depósito de Guto, mochila nas costas e botão de equipamentos. O saldo elevado da imagem pertence ao teste em Play, com persistência desativada; foi descartado ao parar Play.

## Falhas encontradas e tratamento

1. O teste inicial chamou `require` pelo comando MCP, cujo cache não compartilhou a sessão dos Scripts normais. Foi substituído por Scripts reais de servidor/cliente. A duplicata temporária do RemoteEvent criada por esse comando foi removida e todas essas instâncias foram descartadas ao parar Play.
2. Uma rodada do teste enviou ativações com intervalo de 0,35 s, abaixo da proteção de 0,4 s dos equipamentos. O kit foi recusado corretamente. O teste passou a esperar 0,55 s e foi reexecutado em uma sessão nova: 48 verificações passaram.
3. O fechamento assíncrono da loja florestal podia limpar `LojaAberta` depois de abrir a Loja principal. Foi corrigido preservando o estado do próximo modal; o teste específico passou em uma nova sessão.
4. Durante uma rodada anterior, o Studio avisou sobre conteúdo indisponível de alguns IDs de equipamentos já existentes. Nenhum ID novo de animação, áudio ou modelo foi inventado nesta atualização. O log da última sessão de regressão não contém esse aviso nem erro de execução do jogo.

## Critérios ainda pendentes

- Interações completas por toque e controle físico; layout e desempenho em celulares reais.
- Multiplayer de ponta a ponta. O isolamento foi comprovado nas regras com estados distintos, não com dois clientes simultâneos.
- Reconexão com salvamento, porque `PersistenceEnabled=false` permanece. Integração com o perfil foi verificada; persistência não foi ativada nem testada.
- Auditoria dos direitos dos assets previamente existentes e revisão artística final pelo usuário.
- Salvamento do arquivo do place pelo usuário no Studio.

Nenhum desses itens está declarado concluído. Scripts temporários, saldos e recursos de teste foram descartados ao parar Play. Os backups dos seis scripts originais permanecem em `ServerStorage.ForestCommerceBackup_20261110`.
