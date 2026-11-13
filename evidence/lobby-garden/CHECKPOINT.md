# Lobby — checkpoint de implementação, 2026-11-12

**Entrega parcial.** Base `ca0ec73`, branch `ai/forest-economy`, place `106412085364108`. Alterações aplicadas diretamente à cópia atual em Edit. O Studio fechou/desconectou durante Play; não foi possível concluir revisão, voltar a Edit ou confirmar novo save. Não foi publicada atualização.

## Evidências visuais

- `antes-aerea.png` e `antes-caminho.png`: imagens reais fornecidas pelo usuário.
- `aerea.png`, `praca.png`, `horta-2.png`, `estufa-2.png`, `floresta-2.png`: capturas reais intermediárias no Studio; não representam todas as correções posteriores.
- `praca-checkpoint.png`: praça após adicionar vasos e estações externas. Posteriormente, pétalas foram ampliadas e placas configuradas com distância ilimitada.
- A base da estufa foi fechada, recebeu degraus e o telhado recebeu caixilhos após `estufa-2.png`; visto diretamente no Studio, mas a captura final não foi exportada antes da desconexão.

Não usar imagens intermediárias como prova de acabamento final. A primeira revisão visual marcou 6/10; foram feitos ajustes posteriores, ainda sem nova avaliação final.

## Verificações executadas

1. Builder em Edit retornou `Ready=true`; última construção inspecionada tinha 2.053 descendentes, incluindo modelos e GUIs.
2. Prévia da floresta regenerada, retornando `PreviewState=Ready`.
3. Uma sessão normal de Play foi iniciada na janela atual, sem teste multiplayer.
4. Servidor confirmou uma única `LobbyGardenReform`, pronta; prévia exclusiva do editor ausente; floresta de runtime presente.
5. Servidor confirmou as bases em `(±48, 0.3, ±48)` e os quatro spawns em `(±48, 4, -27)` / `(±48, 4, 69)`, preservados.
6. Console informou fazenda com 330 quadrados, protótipo com 256 clusters e floresta com 19.674 tufos.

## Limites e próximo teste

- O console emitiu `Infinite yield possible on 'Workspace.GameWorld.FlorestaEsquecida:WaitForChild("CriptaDasRaizes")'` em `WorldAmbience`, linha 9, durante a construção da floresta. Não houve confirmação de que a espera terminou antes da desconexão.
- A consulta ao cliente falhou com `Client datamodel is not available in Edit mode`; depois, a lista de instâncias conectadas ficou vazia. Não afirmar que a animação do moinho passou.
- Não houve novo teste completo de corte, venda, compras, missões, baús ou respawn nesta reforma do lobby. Validações anteriores pertencem aos seus checkpoints.
- Desempenho mobile, persistência e multiplayer continuam pendentes. O usuário fará multiplayer; não abrir múltiplos clientes.
- Novo save e versão final não confirmados. Reabrir a cópia atual, conferir o que permaneceu no Team Create, terminar a revisão e salvar pela ferramenta disponível.

## Preservação

Sem mudanças em preços, saldo, dados, mochilas, inventário, corrida ou animações do personagem. Nenhum comerciante, remote ou interação fictícia foi adicionado. Posições e dimensões das bases dos quatro lotes foram preservadas; mudanças físicas se limitam a decoração, acabamentos e circulação ambiental.
