# Lobby e navegação topográfica

Alteração visual instalada no place `106412085364108`. Reutiliza os sistemas existentes; não cria economia, comerciantes, remotes ou recompensas.

## Instalação e responsabilidades

- `LobbyLife.luau`: ModuleScript em `ServerScriptService.CorteEDescubra.LobbyLife`. GameServer chama `build(world)` depois de LobbyGardenArt. A raiz `GameWorld.LobbyVillageLife` é idempotente; somente ela pertence a este construtor.
- `QuestPanel.luau`: substitui o ModuleScript homônimo em StarterPlayerScripts, mantendo as interfaces build/update e os dados das missões. Não substitui os menus de Prêmios, Missões ou PlayerMenu.
- `TopographicRadar.client.luau`: LocalScript em StarterPlayerScripts. Requer o ModuleScript `TopographicRadarController` no mesmo pai.
- `WorldMapData.generated.luau`: ModuleScript `ReplicatedStorage.Shared.WorldMapData`, gerado por `bake-map.luau` no editor. Amostra 13.192 pontos do Terrain; não contém segredos nem progresso de jogadores.
- WorldGeography usa raycasts exclusivos de Terrain e calcula a base orientada do tronco. `startGrounding()` também atende árvores criadas depois do carregamento.
- ForestScenery usa `WorldGeography.height` para a caverna antiga; nunca consulta o teto da construção anterior para definir sua base.

## Uso

Clique no radar ou pressione **N**. O atlas oferece zoom, visão do mundo e centralização no jogador. Norte permanece fixo; o triângulo amarelo representa posição e direção do personagem. O mapa não teleporta nem revela descobertas secretas. Oculta-se durante os menus existentes, inclusive o aviso de progresso offline.

O mapa compacto atualiza posição a 10 Hz e redesenha terreno somente quando necessário, no máximo aproximadamente uma vez por segundo. O atlas usa 4.096 células; o radar compacto, 784. Curvas de nível usam marching squares, com intervalo dependente do zoom.

## Prévia e atualização

No editor, um clone novo do controlador pode mostrar uma prévia nativa com posição **simulada e identificada como prévia**. Essa prévia cria temporariamente `StarterGui.TopographicRadar`; destrua-a antes de salvar ou iniciar Play. Em Play, posição e orientação vêm exclusivamente do HumanoidRootPart real.

Depois de alterar Terrain ou caminhos públicos, executar novamente bake-map em Edit e exportar a nova Source. O módulo de dados não se atualiza sozinho. Nunca enviar coordenadas de segredos para o cliente como pontos de interesse.

## Backup e rollback

`ServerStorage.WorldNavigationBackup_20261113` guarda fontes anteriores, pivôs das árvores e o Terrain da região da caverna. A correção de Terrain ficou limitada à gruta antiga; o mapa completo não foi refeito. Não restaurar Terrain sobre jogadores ou durante Play. Para reverter arte adicional, remover LobbyVillageLife e sua chamada; para remover o radar, remover os dois scripts e WorldMapData. Restaurar fontes pelo backup somente após conferir contribuições posteriores de outras IAs.

Ver evidências e limites em `evidence/world-navigation/VALIDACAO.md`. Multiplayer, celular e persistência entre sessões continuam pendentes de validação.
