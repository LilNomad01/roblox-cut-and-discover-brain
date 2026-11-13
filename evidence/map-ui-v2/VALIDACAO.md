# Mapa aéreo e posicionamento do radar — 2026-11-13

Place 106412085364108; universo 10775723165. Base local f464cf9, branch ai/forest-economy. A cópia foi reaberta durante o trabalho com versão 135. Save final comprovado pela ferramenta: **Team Create versão 138**, sem publicação.

## Escopo aplicado

- Renderer abstrato substituído por capturas aéreas do próprio cenário. Árvores, caminhos, prédios e relevo passam a aparecer como no mundo existente.
- Textura detalhada da vila composta por quatro capturas nativas e leve nitidez, sem geração por IA. Assets enviados pela integração autenticada do Studio, na conta do criador.
- Radar completo no canto inferior esquerdo, depois da barra lateral. Usa o tamanho útil do ScreenGui, posição proporcional, âncora e seleção de espaços livres; evita o recorte inferior causado pelo esquema anterior.
- Atlas com nomes de locais, zoom, centralização, visão geral, atalhos de região e arraste. Os modos local e geral têm enquadramentos diferentes.
- Seta com contorno e aro; mini destinos em emblemas. Atlas acima dos widgets comuns enquanto aberto e oculto diante dos menus.
- Nenhuma edição nos controladores dos menus aprovados, em preços, inventário, capacidade, recompensas ou persistência. Outros trabalhos do jogo encontrados na cópia reaberta foram preservados.

## Testes efetivamente executados

- N abriu o mapa por entrada de teclado do Studio.
- Cliques reais pelos caminhos das instâncias: zoom de 480 para 336 studs; visão geral 1852; centralização 400; Vila 380; fechamento por X.
- Arraste por entrada de mouse alterou a posição projetada da textura de `{0.5,0},{0.5,0}` para aproximadamente `{0.5928,0},{0.5,0}`. O mapa não contém código para mover o personagem.
- Indicador centralizado e mudança de orientação de aproximadamente -90° observadas no teste de navegação.
- Radar no viewport útil 986 × 430: posição (96,216), tamanho 164 × 196, dentro dos quatro limites, margem inferior 18 e área calculada de sobreposição com controles igual a zero.
- Imagens carregadas em Play; ContentProvider retornou Success para os assets iniciais; textura HD da vila confirmou IsLoaded=true após a troca.
- Prêmios e OfflineAviso bloquearam abertura do atlas. Os estados temporariamente alterados para esses testes foram restaurados. Nenhum resgate foi acionado pelos testes.
- DisplayOrder 90 com atlas aberto e 14 no radar; widgets comuns deixaram de cobrir os controles do mapa.
- Console da última sessão sem erros dos scripts do mapa. Compilação Luau, validação do BRAIN e diff check registrados no fechamento.
- Captura interrompida por desconexão do Studio deixou MapCaptureBackup. Ao reabrir o mesmo place, restauramos câmera, atmosfera e Enabled dos ScreenGuis antes de continuar.
- Antes do save final: prévia da floresta Ready, nenhuma prévia temporária de radar em StarterGui e nenhum MapCaptureBackup pendente.

## Evidência visual

Capturas reais de Play:

- atlas-polished-play.png: vila com textura detalhada e controles finais.
- world-polished-play.png: visão geral com painel ajustado ao mundo vertical.
- radar-polished-play.png: radar inteiro dentro da tela e destinos em emblemas.

As demais imagens desta pasta são etapas intermediárias preservadas. A base cartográfica é estática; não equivale a uma câmera de vigilância nem atualiza cada tufo cortado.

## Revisão e trabalho pendente

Primeira rodada: 7,5/10. Segunda rodada: **7,3/10**, após textura HD, enquadramento, emblemas e contorno da seta. A ferramenta encerrou a iteração por limite de tempo. Não declarar a meta 8/10 atingida.

Pendências apontadas: definição das capturas ainda limitada; cabeçalho indica a região do jogador mesmo na visão geral, sem seleção explícita do modo; bússola e emblemas ainda podem disputar atenção com a seta. Esses ajustes exigem nova rodada visual.

Não testados nesta tarefa: aparelho móvel, multitouch físico, desempenho móvel, multiplayer e persistência entre sessões. Não atribuir os testes desktop a esses cenários.
