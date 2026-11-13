# Estado real, evidência e builds

**Snapshot inicial:** 2026-11-09.  
**Artefato inspecionado estaticamente:** `CorteEDescubra_v9_Carrinho_Foice_HUD.rbxl`.  
**Forte ressalva:** o `.rbxl` é uma **cópia experimental gerada ao longo desta conversa**. A versão principal do Claude, o place publicado e o trabalho atual do amigo **não foram verificados**. Antes de programar, confirmar com o usuário qual branch/arquivo é a base.


## 2026-11-13 — Codex — mapa aéreo real e radar reposicionado, versão 138

- **Pedido:** melhorar UI do mapa e posição do radar; substituir aparência abstrata por mapa reconhecível do próprio cenário.
- **Base:** f464cf9, branch ai/forest-economy, place 106412085364108. Cópia reaberta como versão 135; save final confirmado **138**, sem publicação.
- **Aplicado:** capturas nativas de mundo/vila/floresta, vila em mosaico HD, atlas com arraste e regiões, radar completo em área livre. Apenas TopographicRadarController e novo WorldMapImages foram instalados nesta etapa. Menus aprovados e sistemas de jogo preservados.
- **Testes:** N, cliques de zoom/mundo/centralizar/Vila/X, arraste, indicador, carregamento de imagens, limites e bloqueio por Prêmios/offline. Radar em (96,216), tamanho 164×196, viewport986×430, margem18 e sobreposição0. Evidências reais de Play em evidence/map-ui-v2/VALIDACAO.md.
- **Revisão:** 7,5 na primeira rodada, **7,3/10** na última; meta8 não atingida. Ferramenta encerrou por tempo. Restam nitidez, indicação explícita do modo visto e hierarquia dos marcadores. Não declarar acabamento aprovado.
- **Recursos:** assets/world-map-v2 e game/world-navigation/WorldMapImages.luau. A base é uma imagem estática; posição/direção são dinâmicas. Recapturar após alterações permanentes no mundo. Backup do controlador anterior em ServerStorage.WorldMapUIBackup_20261113.
- **Cuidados:** estado temporário de captura restaurado, sem MapCaptureBackup pendente nem radar temporário em StarterGui no save. Mobile, multiplayer e persistência não validados nesta tarefa. Não abrir outros Studios.

## 2026-11-13 — Codex — árvores, gruta baixa, lobby adicional e radar; revisão visual em andamento

- **Continuação:** implementação anterior 18c4cf4. Versão **126** inclui Casa do Jardim (galpão de cultivo), gruta em campo de altura largo e baixo, raízes curvas e atlas com passeio/ramais públicos. Último Play aguardou GrassCount: 19.674 tufos, 18 segredos, galpão presente e 517 árvores / zero novos ajustes. Última nota **5,8/10** refere-se às capturas v3 anteriores a esses ajustes. Não declarar revisão visual final concluída.

- **Base:** 95ed5aa, branch ai/forest-economy, place 106412085364108. Save Team Create confirmado: versão **126**, sem publicação.
- **Causas corrigidas:** árvore podia atingir a própria copa por raycast sem filtro; gruta amostrava o teto anterior e acumulava altura. Grounding considera eixo real do tronco e só Terrain. Gruta usa altura autoral estável, encosta baixa e abertura sem lâminas flutuantes.
- **Arte aplicada:** LobbyVillageLife com recanto de vasos, ateliê, carroça, fonte, canteiros, bancos, pátios e dois pomares conectados. Árvore que atravessava o recanto foi deslocada e reassentada.
- **Navegação:** radar circular e atlas nativos; 13.192 amostras de Terrain, curvas de nível, posição/direção reais, quatro lotes e caminhos públicos. N/clique abrem; zoom, mundo e centralização. Sem destinos secretos ou teleporte.
- **UI preservada:** sem edição nos menus aprovados das imagens 5–8. Somente QuestPanel pequeno e bolha do jardineiro foram redesenhados; radar respeita menus, incluindo OfflineAviso.
- **Prova local:** Play com 517 árvores / zero deslocamentos adicionais; piso da gruta Y=0,7; uma floresta; prévia ausente em Play e Ready após Stop; radar 4.096 células, indicador real e rotação -90°; menu e aviso offline bloqueiam abertura. Nenhum multiplayer iniciado. Dez fontes compiladas, BRAIN e diff check passam.
- **Limites:** revisão inicial 6/10 antecede os últimos ajustes. Capturas nativas v3 mostram gruta baixa e recanto livre; captura final voltou a expirar após Play. Usuário já foi solicitado a manter Studio visível. Não declarar acabamento final aprovado nem usar prévia de editor como screenshot jogado. Mobile, multiplayer e persistência continuam pendentes.
- **Retomada:** não reinstalar tudo. Conferir a janela atual; capturar novas áreas e radar final, apresentar e executar goal_review até meta 8/10. Fontes em game/world-navigation; testes em evidence/world-navigation/VALIDACAO.md. Remover StarterGui.TopographicRadar temporário antes de salvar/Play. Não abrir outros Studios.


## Auditoria estrutural estática da V9

Leitura direta do formato binário do `.rbxl` (instâncias/classes/propriedades `Name`/`Source`), sem iniciar Roblox Studio:

| Item | Observado |
|---|---|
| Instâncias | **7.296** |
| Scripts, LocalScripts e ModuleScripts com `Source` | **103** (inclui cópias e backups!) |
| Parts | ~5.749 |
| MeshParts | ~917 |
| Models | ~182 |
| `GameConfig.PersistenceEnabled` | **false** |
| Asset group `GameAssets` | Presente |
| Grupo `GrassPack` | Presente |
| Modelos de baú | `Bau_Comum`, `Bau_Incomum`, `Bau_Raro`, `Bau_Lendario`, `Bau_Mitologico` |
| Cortadores 3D | `Cortador_Basico`, `_Eletrico`, `_Turbo`, `_Trator`, `_Mega` |
| Ferramentas manuais | `CortadorUnha`, `Enxada`, `Foice` × 5 raridades |
| Cabana estática como instância nomeada | **Não localizada** na V9; floresta descrita como gerada durante `Play` |
| Fontes importantes | `GameServer`, `FerramentasServer`, `FerramentasConfig`, `SkillDefinitions`, `SkillService`, `SkillMechanics`, `SkillsPanel`, `PlayerMenuController`, `InterfaceHUD`, `ConfigJogo`, `DadosJogador`, `Profiles` |

### Cuidado com backups

O arquivo carrega scripts com nomes como `*_backup_antes_*` e cópias de caminho da árvore do Roblox serializadas. Não contar todos como código em execução. Determinar `Enabled`/`Disabled` e ancestralidade real antes de editar; buscar conflito de remotes e interfaces antigas.

## Avaliação por sistema

| Sistema | Estado e evidência | O que falta comprovar |
|---|---|---|
| Vila + quatro lotes | **RELATADO_PELO_USUARIO / CONFIRMADO_EM_ARQUIVO**; screenshots mostram terrenos e estrada | Tráfego multi-jogador e respawn |
| Grama do lobby | **RELATADO_PELO_USUARIO**: 64 tufos por serviço e corte gerando progressão | Corte por lâmina em cada ferramenta; evitar XP duplicado |
| Grama alta de teste | **RELATADO_PELO_USUARIO**; matagal denso e visualmente aprovado | Integrar em todas as zonas sem degradar desempenho |
| Loja externa | **RELATADO_PELO_USUARIO**; loja amarela, cards coloridos; conflito de duplicidade corrigido em experimento | Comportamento em todos os layouts/mobile |
| Barra 1–4 | **CONFIRMADO_EM_ARQUIVO / screenshot**; quatro ferramentas | V9 redução e persistência visual em mobile precisam Play |
| Modelos de equipamentos | **CONFIRMADO_EM_ARQUIVO** | Pivô, mão, animação, hitbox e variáveis por raridade |
| Carrinho ao equipar | **IMPLEMENTADO_NAO_PLAYTESTADO** na V9 (fallback de modelo + IK) | Visual e gameplay real; sumia na versão anterior |
| Foice, enxada, unha | **IMPLEMENTADO_NAO_PLAYTESTADO** parcialmente; configs e animação procedural | Ergonomia, golpe natural, varredura/hit server, R15/R6 |
| Árvore de habilidades | **CONFIRMADO_EM_ARQUIVO**; 19 nós configurados, alguns `Ready` | Desbloqueio real por nó, PH, efeitos, UI, persistência |
| Menu Perfil/Equipamentos/Exploração/Missões/Config | **CONFIRMADO_EM_ARQUIVO / screenshots** | Layout/scroll responsivo; regressões de sobreposição |
| Floresta Esquecida | **IMPLEMENTADO_NAO_PLAYTESTADO** no `.rbxl` e **RELATADO_PELO_USUARIO** nas imagens posteriores | Usuário rejeitou direção visual atual: exige reformulação de nível/arte |
| Baús | **CONFIRMADO_EM_ARQUIVO** modelos + lógica experimental | Interação falhou em screenshot anterior; testar prompt E/toque e premiação |
| NPC “Novo Serviço” | **IMPLEMENTADO_NAO_PLAYTESTADO** experimental V8/V9 | Localização, diálogo, estado do serviço e repetição |
| Persistência | **BLOQUEADO / não comprovado**; config V9 false | Auditoria de perfil, DataStore, migração e testes reconexão |
| Áudio e economia balanceada | **PLANEJADO / parcial não auditado** | Assets autorizados, mix, telemetria, XP/min e curva real |

## Versões — histórico e risco

| Versão | Proveniência e contexto | Status |
|---|---|---|
| Original de Claude/Codex | Projeto Roblox que existia antes da intervenção direta do ChatGPT; baseline preferida expressamente em um momento | **NÃO anexada/validada como última versão** |
| V1–V5 | Experimentos de edição do `.rbxl` pelo ChatGPT para floresta, modelos, mecânica de corte e ferramentas; erros de geometria, animação e interface | **DESCONTINUADO por solicitação do usuário**; NÃO reutilizar cegamente |
| “cópia 2” | Arquivo de backup do usuário, base dos trabalhos posteriores | **CONFIRMADO_EM_ARQUIVO**, mas não necessariamente publicado |
| V6 | Loja, baús, habilidades; corrigidos scripts e adições, sem Play | **IMPLEMENTADO_NAO_PLAYTESTADO** |
| V7 | Floresta gerada em runtime, matagal/segredos, HUD; usuário enviou screenshots | **RELATADO_PELO_USUARIO**: aparência insuficiente |
| V8 | NPC Novo Serviço, baús, 3 itens adicionais, correção de aba; introduziu falhas de inicialização | **HISTÓRICO/REGRESSÃO** |
| V9 | Corrigiu falhas V8, montou carrinho com fallback/IK, foice procedural, HUD ~25% menor | **ÚLTIMO ARQUIVO LOCAL INSPECIONADO, NÃO VALIDADO EM PLAY** |
| Floresta redesenhada por Claude após prompt | Usuário pediu refazer; screenshot posterior mostra pinheiros repetidos e muito espaço aberto | **VISUAL REPROVADO**; arquivo correspondente não identificado |

## Evidência da aparência atual, fornecida pelo usuário

- Screenshot da floresta com muitos pinheiros triangulares alinhados, matagal alto e cabana ao fundo; **não gostou do resultado**. Quer floresta maior, fechada, com árvores irregulares, sub-bosque, caminhos curvos e segredos escondidos.
- Screenshot dos menus com **padrão colorido** e contornos. Houve sobreposição Loja/Habilidades/Perfil; corrigida parcialmente em algumas cópias.
- Screenshot de carrinho ausente e saco `0/1`; V9 reporta correção de script quebrado do NPC, **ainda requer Play**.
- Screenshot foice segurada horizontalmente e pouco natural; precisa melhorias reais de animação.
- Screenshot de baú visível sem possibilidade de pegar; correção de prompts foi escrita, **ainda requer teste**.

## Próximo passo obrigatório de engenharia

**Confirmar baseline**, comparar V9 com arquivo atualizado do amigo/Claude, listar diffs e preservar dados. Nunca sobrescrever o progresso verdadeiro com V9 só porque é a versão local mais recente disponível.

## Checkpoint atual — lobby, 2026-11-12

Arte do lobby aplicada na cópia atual do place `106412085364108`; validação parcial de inicialização. Studio desconectou durante Play. Novo save, acabamento final e teste do cliente não confirmados. A referência V19 continua sendo o último save comprovado, sem nova publicação. Ver [evidência e pendências](../evidence/lobby-garden/CHECKPOINT.md).

## Atualização da retomada — lobby salvo na versão 112

A cópia atual do place `106412085364108` foi reaberta com as alterações do checkpoint preservadas. A ferramenta de save confirmou versão **112**, Team Create, sem publicação. Inicialização, circulação, letreiros e ambiente local foram verificados em Play; a prévia voltou após Stop. A revisão visual mais recente ainda depende de captura da viewport. Ver [resultados atuais](../evidence/lobby-garden/CHECKPOINT.md).
