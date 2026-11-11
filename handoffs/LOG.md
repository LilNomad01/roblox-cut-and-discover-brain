# Handoffs — histórico compartilhado entre agentes

> Registrar **no topo** a cada tarefa concluída ou parcialmente entregue. Nunca dizer 'testado' sem evidência reproduzível.

## 2026-11-11 — Claude — golpe da enxada reto à frente

- **Pedido do usuário** (depois de testar): "o movimento de ação da enxada está de lado".
- **Base:** commit `561564e`. Backup em `ServerStorage.HoeStraightBackup_20261111`.
- **Diagnóstico:** desde a versão original, a lâmina batia ~2,3 studs à esquerda (o −45° do ombro em `A.pose` inclina o cabo). Com a postura de ombro, ela ainda abria para a direita na saída.
- **Mudança:** só o clipe `Enxada` do `AnimFerramentas`.
  - Braço achado por busca numérica: centrado, rente ao chão, sem colisão.
  - Chaves novas em 0,10, 0,58 e 0,70.
  - **O ponto de contato mudou:** agora fica ~4,8 studs reto à frente.
- **Testes reais (Play PC):** desvio lateral máximo de 0,92 stud; nenhum toque no corpo durante o golpe; +2 por golpe em 2 golpes; capturas de lado e de frente; console limpo.
- **Pendências:** avaliação do usuário; celular.

## 2026-11-11 — Claude — foice e enxada no ombro, golpe sem atravessar o corpo, toggle de equipar

- **Pedido do usuário:** veio com uma foto de um homem carregando a enxada no ombro.
  - "as animações da foice e da enxada estão péssimas";
  - segurar como na foto, sem bugs e sem atravessar o corpo;
  - apertar o número de novo tira o item da mão.
- **Base:** a mesma place, depois do commit `b72dc17`. Backups em `ServerStorage.ShoulderCarryBackup_20261111` e `ServerStorage.SwingClipBackup_20261111`.
- **Mudanças no jogo:**
  - `AnimFerramentas`: postura de ombro, mais o ajuste de ombro e pulso no golpe. **Isto muda o trajeto da lâmina** em ~0,87 stud. Servidor e cliente usam o mesmo módulo.
  - `Animador`:
    - mão esquerda livre na postura parada;
    - **bug anterior corrigido:** o personagem parava de animar depois do respawn (cache de juntas montada antes dos membros chegarem).
  - `FerramentasServer`: toggle para `"Nenhuma"`.
  - `GameServer`: texto do objetivo com a mão vazia.
  - Trechos exatos em `game/animations/PATCHES.md`.
- **Testes reais (Play PC):**
  - colisões medidas por cinemática:
    - enxada: 8 quadros → 0;
    - foice: golpe sem contato, folga mínima de 0,37 → 0,72 stud;
  - corte por golpe igual ao de antes: foice +4, enxada +2;
  - toggle nas teclas 1 a 4;
  - postura e golpe depois do respawn;
  - capturas da postura;
  - console sem erros.
  - Ver `evidence/animations-2026-11-11/VALIDACAO.md`.
- **Erro meu, já corrigido:** a 1ª edição do `Animador` não compilou (um `local` solto). Corrigido e revalidado.
- **Não explicado:** um salto isolado do saco (4 → 40) e uma tecla 4 que equipou a foice. Nenhum dos dois se repetiu.
- **Pendências:**
  - avaliação do usuário;
  - vídeo do golpe;
  - celular e multiplayer;
  - outros corpos de avatar.
- **Próximo:** NPCs (auditoria começada: todos usam o mesmo modelo `VendorAvatar`; balão do jardineiro `AlwaysOnTop`; a interação é só um aviso).

## 2026-11-11 — Claude — animações: postura de segurar foice e enxada

- **Base:** Studio reaberto (nova instância MCP, mesma place). Conferido que todas as mudanças anteriores persistiram. Backup em `ServerStorage.AnimationBackup_20261111`.
- **Mudança no jogo:** `AnimFerramentas` com `SEGURA_FOICE` e `SEGURA_CABO` novos (lâmina/cabeça perto do chão, cabo na diagonal). Mudam só a postura parada e o início/fim dos clipes.
- **Testes reais:** poses medidas (foice y −3,0; enxada y −2,9); janela de contato idêntica (diferença 0 em 6.029 amostras); corte em Play igual (enxada +2, foice +4); console limpo. Detalhes em `evidence/animations-2026-11-11/VALIDACAO.md`.
- **Pendências:** IK da mão esquerda a ~1,2 stud da pegada; vídeo do golpe completo; celular.
- **Próximo:** NPCs.

## 2026-11-10 — Claude — transição Vila → Floresta Esquecida

- **Base:** Studio depois do polimento da UI. Backups em `ServerStorage.TransitionBackup_20261110`.
- **Mudanças no jogo:**
  - Novo `RegionTitleCard`, cartão de região ao cruzar o portal.
  - `GameServer`: removido o aviso antigo e decoradas as bordas da trilha de entrada.
  - `ForestScenery`: placa pendurada e lanternas no arco.
  - `Musica`: a floresta passa a usar a trilha Natureza, com troca imediata.
  - `WorldAmbience`: sem o aviso de espera infinita.
  - Detalhes em `game/map-transition/README.md`.
- **Testes reais (Play PC):** cartão de ida e volta; música Natureza tocando; placa legível; 210 pedras/flores nas bordas; console limpo. Detalhes em `evidence/map-transition-2026-11-10/VALIDACAO.md`.
- **Repositório:** `RegionTitleCard` idêntico ao Studio; diffs de `GameServer` e `ForestScenery` aplicados às cópias de `game/forest-economy/integration/` e conferidos por hash. `Musica` e `WorldAmbience` não estão no repositório.
- **Pendências:** celular e 2 jogadores; a prévia do editor não mostra o novo portal.
- **Próximo:** animações.

## 2026-11-10 — Claude — polimento da UI (HUD da missão, menu, árvore)

- **Pedido:** usuário listou 5 frentes (UI, transição do mapa, animações, NPCs, cabana/segredos). Ordem escolhida: UI primeiro, mantendo o estilo atual. O usuário disse que o Claude assume todas, inclusive a floresta, com o Codex pausado.
- **Base:** Studio após a fase 3 do corte fluido. Backups em `ServerStorage.UIPolishBackup_20261110`.
- **Mudanças no jogo:**
  - `QuestPanel` reescrito com o mesmo visual.
  - `PlayerMenuController`: abertura sem espera de 5 s e indicador de aba.
  - `PlayerProfilePanel`: segredos da floresta.
  - `SkillsPanel`, `SkillsTreeNodeComponent` e `SkillsTreeRenderer`: legibilidade e sobreposições.
  - Detalhes em `game/ui-polish/README.md`.
- **Testes reais (Play PC, 1274×461):** menu abre em < 0,6 s; indicador alinhado; card oculto com menu; folga de 11 px; árvore a 0,36× com 0 sobreposições e 0 rótulos truncados; console sem erros. Detalhes em `evidence/ui-polish-2026-11-10/VALIDACAO.md`.
- **Pendências:** layout largo, celular e controle. A captura de tela do Studio deu timeout no fim.
- **Próximo:** transição do mapa (Vila → Floresta).

## 2026-11-10 — Claude — corte fluido, fase 3 (Floresta Esquecida)

- **Base:** Studio depois da fase 2. `ForestGrassClient` do Studio conferido como idêntico ao `game/grass-feel/ForestGrassClient.client.luau` do Codex antes de editar. Backups: `GameServerBeforeForestCutFeel_20261110`, `ForestGrassClientBeforeCutFeel_20261110`, `LotCutPreviewBeforeForest_20261110`.
- **Mudanças no jogo:**
  - `GameServer`: `forestMowerCut` (orçamento + fechamento ao parar) e `FOREST.cutTrace` na ordem do toque.
  - `ForestGrassClient` (do Codex): 1 linha no handler + bloco de previsão no fim, usando o `render(g,true)` existente.
  - `LotCutPreview.swing` repassa os golpes na floresta.
- **Testes reais (Play PC):** antes, lotes a cada ~385 ms. Depois, carrinho com 29 cortes, 20 previstos, 0 recusas (antecipação de ~447 ms); foice/enxada com 15 cortes, 13 previstos, 0 recusas na versão final. Detalhes, incluindo a rodada anômala e o artefato `WalkSpeed=48`, em `evidence/cut-feel-2026-11-10/VALIDACAO.md`.
- **Aviso ao Codex:** o `ForestGrassClient` e o `FOREST.cutTrace` são seus. As mudanças estão marcadas com `[Claude 2026-11-10]`, e o arquivo `game/grass-feel/ForestGrassClient.client.luau` deste PR já as contém. Ao reaplicar algo seu, parta destas versões.
- **Balanceamento:** o carrinho na floresta volta ao ritmo de projeto (0,19 s), ~2× o efetivo anterior. Usuário deve avaliar.
- **Próximos passos:** som real de corte, mobile, ping real, avaliação do balanceamento.

## 2026-11-10 — Claude — corte fluido, fase 2 (ferramentas manuais)

- **Base:** Studio depois da fase 1. Backups: `GameServerBeforeToolCutFeel_20261110`, `FerramentasClienteBeforeToolCutFeel_20261110`, `LotCutFeelBeforeModule_20261110`.
- **Mudanças no jogo:** novo `ReplicatedStorage.Shared.LotCutPreview` (previsão compartilhada + `swing`); `FerramentasCliente` prevê no contato da lâmina e não duplica o feedback do `Contato`; `LotCutFeel` usa o módulo; `CortarPorLamina` aplica `maxTiles` na ordem do toque.
- **Testes reais (Play PC):** 8 golpes, 16 previstos, 0 recusas; corte visível 256 ms após o F contra 532 ms do servidor; economia igual; carrinho sem regressão. Detalhes em `evidence/cut-feel-2026-11-10/VALIDACAO.md`.
- **Repositório:** `game/cut-feel/LotCutPreview.luau`, `game/cut-feel/integration/…FerramentasCliente.client.luau` (idênticos ao Studio), diff do GameServer espelhado.
- **Observação:** outra sessão parou o Play no meio do primeiro teste. Mais de um agente está operando o mesmo Studio; combinar turnos.
- **Próximos passos:** fase 3 (floresta) combinada com o Codex; som real de corte; mobile e ping real.

## 2026-11-10 — Claude — corte fluido, fase 1 (carrinho no lote)

- **Base:** `GameServer` no Studio com a reforma do mundo do Codex já aplicada (backup do Codex `GameServerBeforeEditorPreview_Reform20`; hash `71184/869191729`). Meu backup: `ServerStorage.GameServerBeforeLotCutFeel_20261110`.
- **Pedido:** corte pouco fluido em todas as áreas (blocos, atraso, pouco feedback, ritmo irregular). Diagnóstico e plano em `game/cut-feel/README.md`.
- **Mudanças no jogo:** `GameServer` ganhou `lotMowerCut` (corte pelo trajeto da lâmina com orçamento, `LOT_CUT_REACH=0`) e fecha o último trecho quando o jogador para. Novo LocalScript `LotCutFeel` com previsão, transição, aparas e som `Corte`. Economia inalterada.
- **Testes reais:** 4 iterações em Play PC com monitor por quadrado. Versão final: 17 previstos, 0 recusas, confirmação do servidor em ~266 ms, faixas contínuas, XP 5 por quadrado, saco cheio sem previsão. Detalhes em `evidence/cut-feel-2026-11-10/VALIDACAO.md`.
- **Repositório:** `game/cut-feel/` (cliente idêntico ao Studio). A cópia do `GameServer` em `game/forest-economy/integration/` recebeu só o meu diff (idêntico ao do Studio por hash), **sem** a reforma do Codex, que ainda não foi publicada.
- **Aviso ao Codex:** o `GameServer` do Studio agora tem a sua reforma + as minhas três mudanças (prompt de baú, área das ferramentas, corte do carrinho). Ao publicar a reforma, parta do `Source` atual do Studio. O aviso `Infinite yield … FlorestaEsquecida` em `WorldAmbience` apareceu no console.
- **Próximos passos:** fase 2 (ferramentas manuais), fase 3 (floresta, combinada com o Codex), som real de corte, mobile e ping real.

## 2026-11-10 — Claude — corte das ferramentas manuais pela área do quadrado

- **Base:** `GameServer` com hash `70952/613054764` (depois da correção do prompt), place `106412085364108`.
- **Decisão do usuário:** aplicar o teste por área e manter os `maxTiles` atuais (foice 4, enxada 2, unha 1).
- **Mudança no jogo:** `CortarPorLamina` usa `distQuadrado` (traço da lâmina × área 4×4 do quadrado) em vez da distância ao centro. Backup em `ServerStorage.GameServerBeforeHitAreaFix_20261110`. Cópia em `game/forest-economy/integration/…GameServer.luau` com hash igual ao Studio (`71734/624928825`).
- **Testes reais (Play PC):** foice +4/+4/+4 na posição que antes dava 0; enxada +2; unha 1 quadrado em 3 golpes; carrinho inalterado (+7); XP 5 por quadrado; sem erros. Detalhes em `evidence/tool-hit-rate-2026-11-10/ANALISE.md`.
- **Risco:** o rendimento das ferramentas manuais subiu (foice ~1,6 → 4 por golpe). Observar o balanceamento em relação ao carrinho. Mobile e floresta não medidos.
- **Aviso ao Codex:** o `GameServer` do manifesto mudou de novo; parta da cópia atualizada.

## 2026-11-10 — Claude — investigação da taxa de acerto das ferramentas manuais

- **Base:** place `106412085364108`, Play solo PC. **Nenhuma mudança no jogo.**
- **Causa:** `CortarPorLamina` (GameServer) aceita o quadrado do lote só se o traço da lâmina passar a `largura/2` do **centro** (grade de 4 studs). O acerto depende do alinhamento do jogador com a grade.
- **Medição:** 2.888 golpes simulados por ferramenta com o código do servidor, mais golpes reais gravados. Acerto atual: unha 10%, enxada 53%, foice 86%. Com teste pela área do quadrado, as três chegam a 100%, limitadas por `maxTiles`.
- **Arquivos:** `evidence/tool-hit-rate-2026-11-10/ANALISE.md`, backlog (P0-04).
- **Próxima ação:** usuário decidir se aplica o teste por área mantendo ou reduzindo `maxTiles`.

## 2026-11-10 — Claude — prompt de baú coletado escondido por jogador

- **Base:** place `106412085364108`; `GameServer` igual a `game/forest-economy/integration/…GameServer.luau` em `bd17159`.
- **Mudanças no jogo:** `CorteEDescubra.GameServer` ganhou `forestMarkClaimed`, o atributo `ForestSecretId` nos prompts e o atributo `ForestClaimedSecrets` no jogador. Novo LocalScript `StarterPlayerScripts.ForestSecretPromptClient`. Regras de recompensa inalteradas. Backup em `ServerStorage.GameServerBeforeChestPromptFix_20261110`.
- **Arquivos do repo:** `game/chest-prompt/` (cliente + README com rollback), cópia do GameServer em `game/forest-economy/integration/` atualizada (hash igual ao do Studio), evidência, backlog e status.
- **Testes reais:** Play PC. 16/16 prompts marcados; depois da coleta o prompt fica `Enabled=false` no cliente e `true` no servidor; pagou 14 moedas uma vez; sem erros no console.
- **Pendências:** Team Test com 2 jogadores e mobile.
- **Aviso ao Codex:** editei o `GameServer` que está no seu manifesto `ai/forest-economy`. Ao reaplicar a integração, parta da cópia atualizada para não desfazer a correção.

## 2026-11-10 — Claude — playtest P0-02 a P0-05 (PC)

- **Base:** place `106412085364108` em Play solo no Studio do usuário; documentação na branch `claude/baseline-studio-2026-11-10` (mesclada com `bd17159`).
- **Mudanças no jogo:** nenhuma. Os dados do teste foram descartados ao parar o Play.
- **Testes reais (PC, teclado):** P0-02 inicialização OK (`SacoMax=50`, bug `0/1` não reproduzido, sem erros de script). P0-03 carrinho montado, corte com W/A/S (`Saco 0→7`, `XP 35`) e respawn com carrinho e saco preservados. P0-04 foice, enxada e unha equipam uma de cada vez e cortam pelo servidor. P0-05 baú da entrada da floresta pagou uma única vez em 3 tentativas. Detalhes e capturas em `evidence/p0-playtest-2026-11-10/`.
- **Achados:** `TextureID`s que não carregam no `Cortador_Basico` e no `GrassPack`; prompt "Abrir baú" continua visível depois da coleta; taxa de acerto da enxada e da foice parece baixa; a navegação automática não corta (exige `MoveDirection`), o que é esperado.
- **Pendências:** mobile, controle, multiplayer, avaliação de animação em vídeo, baú do lote e baús revelados por corte.
- **Observação:** o Codex instalou `Workspace.ForestEditorPreview` na mesma place em paralelo. As contagens estáticas do `18_MAPA_TECNICO_BASELINE.md` são anteriores a essa prévia.

## 2026-11-10 — Claude — baseline de trabalho confirmada e mapa técnico

- **Base:** place `106412085364108` / universe `10775723165` aberta no Studio do usuário; documentação sobre `8a6f71c` (`ai/forest-economy`), branch `claude/baseline-studio-2026-11-10`.
- **Decisão do usuário:** essa place é a versão em que estamos trabalhando, e o Studio salva automaticamente (relato do usuário). Ainda não confirmado: se é a versão publicada.
- **Arquivos:** novo `brain/18_MAPA_TECNICO_BASELINE.md`; `brain/02_ESTADO_REAL_E_VERSOES.md`, `brain/10_ARQUITETURA_E_DADOS.md`, `brain/17_COMERCIANTES_CACAMBAS_MOCHILAS.md`, `brain/00_START_HERE.md`, `README.md`, `brain/status.json`, `tasks/BACKLOG.md`.
- **Testes reais:** somente leitura do DataModel em **Edit** via MCP do Roblox Studio (contagens, hierarquia, fontes, busca textual). **Nenhum Play, nenhuma edição no jogo.** `status.json` validado como JSON e varredura de tokens feita via PowerShell. `scripts/validate_brain.py` (Python 3.12.10) passou: 27 arquivos obrigatórios; validação documental, não é Play.
- **Achados:** `DadosJogador` não é um segundo save (só a rota de compra); `Profiles` tem lease e migração, mas `PersistenceEnabled=false`; floresta construída em runtime dentro do `GameServer`; `MaxPlayers=60` com 4 lotes; duas cópias ativas de "Sprint on shift"; remotes legados aparentemente sem uso; restos de depuração.
- **Próximos passos:** usuário confirmar publicação/salvamento (P0-01) e decidir `MaxPlayers` (P0-08); depois, Play para P0-02 a P0-05. A tarefa de corrida/sprint (P0-09) segue com o Claude, pausada.

## 2026-11-10 — Codex — floresta visível no editor

- **Base:** `8a6f71c`, place `106412085364108`, branch `ai/forest-economy`.
- **Arquivos:** instalador `game/editor-preview/install.luau`, integrações `GameServer`/`ForestScenery`, README, ADR-0004 e validação específica.
- **Mudanças:** prévia estática `Workspace.ForestEditorPreview`, com cenário existente e cobertura de grama simplificada. Backup de TerrainRegion e pivôs originais antes da preparação do terreno. GameServer remove somente a prévia identificada antes dos builders reais.
- **Correção:** exploração usava caminho fixo `workspace.GameWorld.FlorestaEsquecida`; agora recebe as árvores do `root` informado. Primeira tentativa incompleta foi restaurada antes de reconstruir.
- **Testes:** Edit com 12.065 descendentes e 6.075 meshes de grama, zero prompts ativos e zero peças soltas; build idempotente. Play com prévia ausente, uma floresta, 25.197 registros de grama, 16 segredos e um stream. Stop restaurou a prévia. Fontes de GameServer e ForestScenery conferidas por tamanho/checksum. Console do Play sem erros do jogo. Compilação do instalador, módulo derivado e integrações.
- **Salvamento:** ferramenta de save disponível nesta sessão; place salvo no Roblox, versão 19, sem publicar. Substitui a limitação de ferramenta descrita nos handoffs anteriores para esta entrega.
- **Risco/pendências:** prévia para visualização; editar suas peças não altera o gerador. Desempenho do editor em outra máquina e retorno após reabrir o Studio ainda não executados. TerrainRegion preservado para rollback; sem mudança de dados de jogadores.
- **Próxima ação:** usuário avaliar floresta no editor; mudanças permanentes de layout continuam nos builders.

## 2026-11-10 — Codex — matagal mais denso e feedback de corte

- **Base:** `441fa2a`, place `106412085364108`, branch `ai/forest-economy`.
- **Arquivos:** `game/grass-feel/ForestGrassClient.client.luau`, evidência em `evidence/grass-feel/`, status e backlog.
- **Mudanças:** sobreposição e altura visual da vegetação normal, cores verdes, folhas maiores, transição Cubic Out e som de corte existente com limite. Sem novas instâncias de grama, alteração econômica ou mudanças na corrida.
- **Testes:** compilação Luau; Play e inspeção visual; rota de lâmina com `Cuts=1`, `SackGain=1`, `NoExtraReward=true`; 1.501 peças locais sem colisão/toque/consulta. Console consultado sem erro do jogo.
- **Risco/pendências:** desempenho em aparelho móvel e avaliação auditiva não comprovados; salvar place no Studio. Backup em `ServerStorage.GrassFeelBackup_20261110`.
- **Próxima ação:** usuário avaliar densidade e sensação de corte; detalhes e rollback em `evidence/grass-feel/VALIDACAO.md`.

## 2026-11-10 — Codex — comércio integrado e validado em Play

- **Base:** `997d839`, branch `ai/forest-economy`, place `106412085364108` / universe `10775723165`; sem carregar builds experimentais sobre o jogo aberto.
- **Arquivos modificados:** `game/forest-economy/` e integrações do manifesto, `brain/status.json`, `tasks/BACKLOG.md`, esta entrada e `evidence/forest-economy/`.
- **Resultado:** comerciantes, cinco mochilas aditivas, três vendas pela mesma economia, contrato de Teca, coleta por jogador e equipamentos reais. Nilo reutiliza o gnomo e a revelação pelo corte existentes. Área comercial protegida também nas árvores criadas pelo módulo de cenário; placas voltadas para a entrada das bancas.
- **Testes executados:** 15 fontes compiladas no Luau 0.746; 50 asserções de regras; 48 verificações de servidor/cliente em Play. Mochila e equipamentos após respawn, E/X/Esc e transições de modais verificadas separadamente. As 11 fontes aplicadas foram comparadas com os arquivos locais em Edit.
- **Correção encontrada em QA:** o fechamento assíncrono do comércio florestal limpava `LojaAberta` após abrir a Loja principal. O evento de fechamento agora preserva o estado quando a Loja principal assume o modal; regressão executada e aprovada.
- **Limitações/riscos:** save segue desativado; mobile, controle real, multiplayer e desempenho móvel não validados. O arquivo `.rbxl` precisa ser salvo pelo usuário, pois o MCP não oferece essa operação. Nenhuma publicação ou migração de banco executada.
- **Backup:** seis scripts originais em `ServerStorage.ForestCommerceBackup_20261110`; instruções de rollback no README do módulo.
- **Próxima ação:** usuário salvar o place; executar critérios pendentes em aparelhos e servidor de teste. A tarefa de corrida do Claude está pausada e não foi editada nesta atualização.

## 2026-11-10 — Codex — comércio da floresta preparado para integração

- **Base:** `0878755`, branch `ai/forest-economy`; scripts ativos do place `106412085364108` comparados com a auditoria anterior, sem alterações funcionais nesses seis pontos de integração.
- **Arquivos:** `game/forest-economy/`, catálogo, regras de perfil, serviço, cenário, cliente e seis integrações explícitas em `manifest.json`.
- **Escopo:** Guto/Lia/Teca, Nilo existente, mochilas com bônus aditivo, três vendas pela `Economia.Vender`, coleta individual, contrato e equipamentos reais. Acesso aos equipamentos por UI própria porque o jogo oculta o Backpack padrão.
- **Validação:** 11 arquivos compilados no Luau 0.746; 50 asserções das regras de compra, materiais, limites e isolamento passaram. Não é evidência de Play.
- **Estado:** código preparado em disco; ainda não aplicado ao Studio neste checkpoint. Persistência permanece desativada; sem gravação de DataStore ou publicação.
- **Risco:** integração visual, inicialização e entradas ainda precisam de execução real; compras/descobertas duram somente a sessão com a configuração atual.
- **Próxima ação:** aplicar com verificação de origem e backup, executar Play e documentar resultados. A tarefa de corrida do Claude é separada e está pausada.

## 2026-11-10 — ChatGPT — ideia futura e orientação multiplayer

- **Ideia anotada, NÃO implementada:** jardineiro mencionar Floresta Esquecida no nível 5.
- **Arquivos de documentação:** `ideas/IDEIAS_FUTURAS_NAO_IMPLEMENTAR.md`, capítulo da floresta, README.
- **Orientação técnica dada:** em Roblox Studio, Play solo não compartilha servidor entre colaboradores; utilizar Team Test. Em jogo publicado, usar Join Experience e conferir MaxPlayers/privacidade.
- **Código do jogo:** sem modificações; nenhum Play executado.

## 2026-11-10 — ChatGPT — expansão de comércio na Floresta Esquecida

- **Escopo:** documentar comerciantes Guto/Lia/Teca/Nilo, caçambas, mochilas, interação de NPCs e economia de exploração.
- **Fonte:** decisão de design do usuário em chat; **tudo PLANEJADO, nada editado no Roblox**.
- **Arquivos:** `brain/17_COMERCIANTES_CACAMBAS_MOCHILAS.md`, capítulos de floresta/economia, `tasks/BACKLOG.md`, `brain/status.json` e índice.
- **GitHub Issue:** [#6 — Comércio e mochilas](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/6).
- **Validação:** consistência dos documentos; nenhum teste em Roblox Studio.
- **Próxima ação:** confirmar baseline real e implementar de modo incremental, começando pela venda reusada e capacidade de saco sem duplicação.

## 2026-11-09 — ChatGPT — organização do BRAIN no GitHub

- **Escopo:** estruturação da documentação preexistente em capítulos, regras para Claude/Codex/IA do amigo, backlog, status e GitHub Actions.
- **Fonte:** documento monolítico previamente enviado ao repositório pelo usuário. O conteúdo original permanece em `archive/`.
- **Mudanças no jogo Roblox:** nenhuma.
- **Validação:** auditoria documental / integridade de arquivos no repositório (não é Play).
- **Pendências:** confirmar baseline real e validar gameplay; exigir acesso ao mesmo GitHub para cada IA.
- **Issues de execução criadas:** [#1 baseline](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/1), [#2 equipamentos](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/2), [#3 baús e saves](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/3), [#4 UI](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/4), [#5 floresta 2.0](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/5).
- **Próxima ação:** selecionar uma tarefa P0 ou P1 e registrar o commit do jogo correspondente.

## 2026-11-09 — Snapshot inicial (conversa)

- Histórico de brainstorm, assets de grama/equipamentos/baús, interface, árvore de habilidades e várias versões experimentais `.rbxl`.
- V9 auditada estaticamente com 7.296 instâncias / 103 scripts e módulos incluindo backups; **sem playtest**.
- Usuário reprovou o visual repetitivo da última floresta e definiu reformulação artística como prioridade.
- **Versões v1–v5 explicitamente descartadas** como baseline.
