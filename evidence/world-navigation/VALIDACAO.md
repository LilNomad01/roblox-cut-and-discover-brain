# Validação — lobby, árvores, gruta e radar

Data: 2026-11-13. Place: 106412085364108. Origem desta alteração: commit 95ed5aa, branch ai/forest-economy. Salvamento confirmado pela ferramenta: Team Create versão **126**. Não publicado.

## Alterações reais

- Corrigido raycast sem filtro que podia usar a própria copa como solo. Base do tronco considera a orientação dos eixos, inclusive cilindros cujo comprimento está no eixo X. Novas árvores também passam pela correção.
- Corrigida acumulação da gruta antiga: a altura vinha de uma consulta que atingia o teto anterior. Base agora usa altura autoral estável. Recuperação limitada ao volume local, com Terrain original no backup.
- Removidas grandes lâminas de pedra da entrada; encosta baixa de Terrain integra a abertura e as laterais. Capim decorativo não nasce no corredor da entrada; aproximação cortável e barreira de raízes foram preservadas.
- LobbyVillageLife: recanto de vasos, carroça de colheita, ateliê de ferramentas, fonte, canteiros cercados, bancos, pátios e dois pomares. 1.917 descendentes adicionais na inspeção final. Sem serviços ou interações falsas.
- Cartão pequeno de objetivo recebeu papel creme e tipografia legível. Bolha do jardineiro ficou menor e limitada a 30 studs. Menus aprovados nas imagens 5–8 não foram editados por este patch.
- Radar circular e atlas usam terreno real amostrado, curvas de nível, caminhos e pontos públicos. Quatro lotes aparecem nas posições e dimensões reais. Nenhum segredo é marcado.

## Testes executados no Studio

- Play normal em uma janela; nenhum servidor multiplayer iniciado nesta etapa.
- Primeira auditoria ampla: 505 árvores; passes posteriores sem deslocamentos repetidos. Após adicionar 12 árvores de pomar: **517 verificadas, zero ajustes adicionais** em Edit e Play.
- Gruta: piso em Y=0,699999988 em Edit e Play repetidos, sem acumular altura. Prévia restaura estado Ready após Stop; removida durante Play.
- LobbyVillageLife Ready em Edit e Play. Uma raiz idempotente, sem reconstruir lotes.
- Atlas abriu e fechou pela API local do mesmo controlador. Em Play: 4.096 células e indicador visível no centro quando acompanha o personagem real em (48, 3,6075, -27).
- Rotação do personagem em 90 graus alterou orientação do indicador para aproximadamente -90 graus.
- Atributo MenuJogadorAberto ocultou o radar; restauração devolveu o radar. Prêmios aberto também bloqueou abertura em teste anterior. Aviso offline foi acrescentado à detecção após identificar sobreposição em uma captura. Teste final com OfflineAviso.Enabled=true recusou a abertura; ao desativar, abriu. Estado anterior restaurado sem resgatar recompensa.
- Radar compacto registrou área de sobreposição **0** com o HUD no viewport desktop observado. Não equivale a todos os formatos de tela.
- Console: fazenda com 330 células, protótipo com 256 clusters e floresta com 19.674 tufos cortáveis / 18 segredos; nenhum erro dos scripts desta alteração observado. A redução de capim fica no acesso da gruta.
- Dez arquivos Luau compilados sem erros. Validação estática do BRAIN passou; diff check passou após remover linhas vazias extras. Repetir somente arquivos afetados por ajustes posteriores.
- Nenhuma prévia temporária de radar em StarterGui no salvamento 124.

## Evidência visual e limites

Imagens são capturas nativas do Studio. Capturas de atlas no editor são identificadas como prévia; elas demonstram o renderer instalado, não uma sessão jogada. Uma captura de Play mostrou o aviso offline sobre o atlas, motivando a correção de detecção. Captura de Play posterior expirou; não usar essa falha como prova de defeito do jogo nem apresentar a imagem intermediária como final.

A revisão visual inicial deste escopo marcou 6/10. A versão seguinte removeu lâminas da gruta, liberou o telhado do recanto, conectou pátios, adicionou pomares e melhorou mapa/caminhos. A nota atual deve ser atualizada depois da revisão final.

**Pendentes:** multiplayer (usuário testará), aparelho móvel, FPS em hardware móvel, persistência/reconexão, controle físico e acionamento real por teclado/toque. N e cliques estão conectados no código; abertura por API não comprova acionamento físico. Economia e compras não foram novamente exercitadas nesta alteração visual; nenhuma lógica de preço, capacidade ou recompensa foi modificada.

## Checkpoint posterior — versão 126

A segunda revisão das capturas v3 marcou **5,8/10**. Essas capturas antecedem os seguintes ajustes já instalados e salvos:

- Casa do Jardim: galpão de cultivo de 27 × 23 studs, fachada aberta, bancada, vasos, caixotes, base apoiada e caminho até o passeio. Não cria serviço ou vendedor.
- A gruta usa agora um campo de altura local, largo e baixo, em vez de esferas empilhadas. Barreira continua colidindo e conserva a mesma referência de descoberta; aparência agora tem 20 segmentos de raízes curvas. Backup adicional CaveBeforeLowHillside.
- Atlas abre na visão do mundo, com acesso à posição local; dataset inclui passeio, ramais públicos e Casa do Jardim.
- Último Play aguardou GrassCount antes das asserções: floresta com 19.674 tufos, 18 segredos, Casa do Jardim presente e 517 árvores verificadas / zero mudanças. Um teste anterior consultou a floresta antes de terminar a construção e falhou por precondição; o teste foi corrigido para aguardar o marcador real de conclusão.
- Captura final continua pendente: ferramenta expirou após Play e controle do computador retornou Could not list computer-use targets. Não substituir por imagens geradas nem declarar meta visual atingida.

Implementação anterior registrada em **18c4cf4**; esta continuação fica no commit seguinte do mesmo branch.
