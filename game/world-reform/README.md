# Reforma ambiental — checkpoint de terreno

Base documental: `bd17159`, place `106412085364108`. O Studio contém correções posteriores do Claude, preservadas nas integrações exportadas; não substituir essas fontes por versões antigas.

## Estado

Terreno contínuo aplicado no editor, com base sólida de pelo menos 64 studs. O material superficial foi separado das antigas faixas de rocha. Lotes e spawns mantêm suas coordenadas. A prévia da floresta é reconstruída a partir dos mesmos módulos do Play.

A reforma visual completa do lobby foi solicitada em seguida e está em andamento. Multiplayer será testado pelo usuário; o teste automatizado foi encerrado e seus dois scripts temporários foram removidos do Studio. Não considerar essa tentativa como aprovação multiplayer.

## Fontes

- `WorldGeography.luau`: relevo contínuo e vegetação de pradaria, aplicado somente em Edit.
- `WorldArt.luau`: cenário compartilhado do editor/Play, riacho e cavernas já montadas.
- `ForestVisualStyle.luau`: módulo puro em `ReplicatedStorage.Shared`, com offsets orgânicos de vegetação distante.
- `SignKit.luau`: sinalização de madeira.
- `WorldAmbience.client.luau`: controlador local já instalado de cor e pequenos detalhes ambientais.
- Integrações em `game/forest-economy/` e renderer em `game/grass-feel/`.

## Backup

`ServerStorage.WorldReformV19Backup` contém 35 TerrainRegions, fontes anteriores, pivôs decorativos e cópia do lobby anterior à nova reforma. Cada TerrainRegion possui atributo `Corner`, em células. Restaurar por `Terrain:PasteRegion(region, Vector3int16.new(corner.X,corner.Y,corner.Z), true)` em Edit, um bloco por vez com yield. Restaurar também as fontes e pivôs correspondentes; não misturar terreno antigo com builders novos.

Nenhuma migração de banco ou ativação de persistência foi feita. Não publicar até a revisão da versão final.

## Evidências

Consultar `evidence/world-reform/CHECKPOINT_TERRAIN.md`. As imagens `consolidado-*` registram o checkpoint mais recente de terreno; os demais prefixos guardam iterações e relatos anteriores, não são a entrega final do novo lobby.
