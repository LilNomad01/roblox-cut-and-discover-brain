# Reforma visual do lobby — checkpoint

Base: `ca0ec73`, place `106412085364108`, 2026-11-12.

`LobbyGardenArt` é um ModuleScript em `ServerScriptService.CorteEDescubra`. `GameServer` chama `start(world)` imediatamente depois de obter o mundo existente. A arte fica em `GameWorld.LobbyGardenReform`; sua presença evita reconstrução no Play. Os quatro lotes, seus spawns, NPCs e serviços continuam nos caminhos originais.

`LobbyGardenAmbience.client.luau` fica em `StarterPlayer.StarterPlayerScripts`. Anima somente o rotor ancorado do moinho, localmente, a 24 Hz. A execução no cliente ainda precisa ser confirmada.

## Conteúdo aplicado

- Praça com árvore, bordadura floral, vasos, bancos e luminárias.
- Quadros existentes de missões e ranking voltados para a praça, com seus elementos preservados.
- Horta, moinho, compostagem, ferramentas, caixas e carrinho decorativo.
- Estufa com base fechada, degraus, abertura lateral e canteiros.
- Recanto coberto, abrigo de sementes, bancadas e hortas menores nas bordas dos jardins.
- Pavimentos e meios-fios em tons quentes; dimensões e posições das bases dos lotes preservadas.
- Trilhas pintadas no Terrain, sem plataformas suspensas. `forestPath` foi corrigido na integração do GameServer.
- Placas de madeira com postes assentados no Terrain e texto nas duas faces. `MaxDistance=0` evita o desaparecimento observado nas capturas do editor.

As novas hortas, estufa e bancadas são decoração. Não anunciam colheita, compras ou serviços novos. A fazenda funcional existente foi preservada.

## Retomada segura

O Studio desconectou durante a verificação de Play. Não repetir a instalação integral sem verificar a cópia reaberta. Primeiro confirmar `LobbyGardenReform.Ready`, fontes instaladas, floresta em Edit e estado de Play. A última versão de save conhecida continua sendo 19; nenhum novo save foi confirmado neste checkpoint.

Backups em `ServerStorage.WorldReformV19Backup`: `LobbyBeforeGardenReform`, `PlotSignsBeforeGardenReform`, `LobbyVisualProps`, módulos anteriores e pivôs de árvores em `BeforeGardenPivot`. `GameWorld.GardenGroundOriginal` guarda a cor anterior de Ground. Os caminhos alteram materiais em regiões limitadas; o backup de Terrain anterior à reforma permanece com 35 blocos.

Para atualizar um builder no editor, substituir sua instância de ModuleScript, preservando a anterior no backup: alterar apenas `Source` não invalida o cache de `require`. Reconstruir somente `LobbyGardenReform`; não reconstruir o mundo nem os lotes. A prévia da floresta deve ser regenerada pelo instalador existente para usar o `forestPath` atual.

Validação e limites: [checkpoint](../../evidence/lobby-garden/CHECKPOINT.md).

## Atualização após a retomada

A cópia reaberta mantinha os fontes e o cenário do checkpoint. A atualização atual foi salva no Team Create, versão **112**, sem publicar. O regador-monumento, jardins de quatro paletas, passeio externo, pergolados, pomares, sebes dos lotes e jardim externo da estufa estão implementados. Os painéis funcionais foram reposicionados ao lado da avenida norte, preservando prompts e nomes. Os quatro bancos e postes originais da praça são reutilizados, evitando pares duplicados.

Os letreiros dos lotes ganharam uma face traseira. Sua legenda acompanha o texto original em runtime; a fonte de propriedade continua sendo o serviço existente. Flores decorativas antigas em forma de bolas, fora das áreas funcionais dos lotes, ficam ocultas e são substituídas por conjuntos botânicos. O atributo `GardenOriginalTransparency` permite restaurá-las.

A espera pela caverna e pelo riacho em `WorldAmbience` agora ocorre em tarefas separadas com limite de tempo. Assim, a construção gradual da floresta não bloqueia a iluminação regional local.

Play confirmou inicialização, posições preservadas, letreiros sincronizados, dez pontos de circulação sem bloqueios e animação local do moinho. O retorno a Edit restaurou a prévia sem duplicação. A revisão visual final depende de capturar a viewport atual; as imagens v4 são anteriores à última organização paisagística.
