# Lobby e navegação aérea

Instalado no place `106412085364108`. O mapa aéreo substitui o renderer de células/curvas do HUD anterior; árvores, gruta e LobbyLife continuam com as implementações ambientais já existentes.

## Instalação

- `TopographicRadar.client.luau`: LocalScript em StarterPlayerScripts. Requer o ModuleScript `TopographicRadarController` no mesmo pai.
- `TopographicRadarController.luau`: cria radar e atlas, sem remotes, preços, recompensas ou gravações de dados. A raiz TopographicRadar é idempotente.
- `WorldMapImages.luau`: ModuleScript `ReplicatedStorage.Shared.WorldMapImages`. Contém os IDs e limites geográficos das imagens nativas.
- `WorldMapData.generated.luau`: ModuleScript `ReplicatedStorage.Shared.WorldMapData`. O novo HUD usa seus lugares públicos e limites, sem ler coordenadas de segredos. O bake antigo fica preservado como fonte geográfica, mas já não desenha o fundo do HUD.
- `LobbyLife.luau`, QuestPanel e integrações de WorldGeography/ForestScenery pertencem à etapa ambiental anterior. Esta alteração de UI não os modifica.

## Controles

N ou clique no radar abre o atlas; X/Esc fecha. Há zoom, visão geral, centralização no jogador, atalhos Vila/Floresta e arraste do mapa. Arrastar altera somente o centro cartográfico; não move o personagem. O triângulo acompanha posição e direção do HumanoidRootPart a 10 Hz. Norte permanece fixo.

O radar usa ScreenGui.AbsoluteSize e coordenadas proporcionais com âncora inferior direita. Não usa UIScale no posicionamento. Avalia obstáculos dos HUDs existentes e reduz o diâmetro quando necessário. O atlas usa DisplayOrder 90 enquanto aberto; volta a 14 no radar e se oculta diante dos menus existentes, incluindo o aviso offline. Os menus aprovados não são redesenhados.

## Capturas do próprio jogo

As bases são screenshots verticais do cenário existente. A vila usa mosaico de quatro capturas, 1900 × 1900 pixels antes do processamento do Roblox. Mundo e floresta têm imagens próprias. PNGs, originais e recibo estão em assets/world-map-v2. Nenhuma imagem foi gerada por IA.

A geografia é uma captura estática. Cortes de grama, eventos e construções permanentes posteriores não alteram automaticamente essa imagem. Posição e direção do jogador são dinâmicas. Depois de mudanças permanentes no cenário, recapturar, enviar novos assets e atualizar somente WorldMapImages.

Para recapturar: usar câmera vertical com norte no topo e FOV calculado por `2*atan(raio/altura)`. Ocultar StarterGui e atmosfera somente durante a captura, guardando os estados. Restaurar em seguida. `ServerStorage.MapCaptureBackup`, quando existir, contém os estados de uma captura interrompida e deve ser restaurado/removido antes de salvar. Nesta entrega a restauração foi conferida.

## Backup, prova e limites

`ServerStorage.WorldMapUIBackup_20261113` conserva o controlador anterior. Evidência em evidence/map-ui-v2/VALIDACAO.md. Último save confirmado: versão 138, sem publicação. Última revisão visual: 7,3/10; meta 8 não atingida antes do limite de tempo da revisão. Restam nitidez, indicação explícita do modo selecionado e hierarquia dos marcadores. Celular físico e desempenho móvel continuam pendentes.
