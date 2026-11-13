# Backlog compartilhado — prioridades e status

**Snapshot:** 2026-11-09. Status sem evidência de Play permanece não validado. Cada issue técnica deve referenciar `.rbxl`/commit base.



## Mapa e radar — checkpoint 2026-11-13

- [x] Base aérea real do cenário, zoom, centralização, atalhos e arraste.
- [x] Radar dentro da tela, sem sobrepor os controles desktop observados.
- [ ] Polir nitidez, indicação do modo do atlas e marcadores até meta8/10. Última7,3; iteração encerrou por tempo.
- [ ] Validar touch e desempenho em aparelho móvel.

Versão138 salva; evidência em evidence/map-ui-v2/VALIDACAO.md.

## Checkpoint 2026-11-13 — lobby e radar

- [x] Corrigir grounding das árvores e acumulação de altura da gruta antiga; validar Edit/Play.
- [x] Adicionar pátios, canteiros, recanto, ateliê, carroça, fonte e pomares sem novos serviços.
- [x] Radar topográfico e atlas com posição/direção; preservar menus aprovados.
- [ ] Capturar arte final e concluir revisão independente até meta 8/10. Primeira nota 6/10 antecede os últimos ajustes.
- [ ] Teste físico de N/clique/toque, multiplayer pelo usuário, celular e persistência entre sessões.

Evidências: evidence/world-navigation/VALIDACAO.md; salvamento confirmado versão 126, sem publicação.

## Painel rastreável no GitHub

| Issue | Prioridade | Escopo |
|---|---|---|
| [#1 — Baseline](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/1) | P0 | Confirmar build oficial e scripts ativos |
| [#2 — Equipamentos](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/2) | P0 | Carrinho, foice, enxada, corte pela lâmina |
| [#3 — Baús e saves](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/3) | P0 | Coleta, recompensa única, persistência |
| [#4 — Interface](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/4) | P0 | Menus sem sobreposição, mobile |
| [#5 — Floresta 2.0](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/5) | P1 | Level art, matagal, segredos e cabana |
| [#6 — Comércio e mochilas](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/6) | P1 | Vendedores, caçambas, mochilas, gnomo secreto |

As listas abaixo são o backlog detalhado; a discussão de execução, responsáveis, commits e evidências devem aparecer nas Issues e nos Handoffs.

## P0 — Estabilização

- [ ] **P0-01** Confirmar baseline oficial atual (comparar cópia Claude/Studio com V9), backup e branch.
  - **2026-11-10 (Claude):** usuário confirmou a place `106412085364108` como **baseline de trabalho**. Mapa estático em [18 — Mapa técnico](../brain/18_MAPA_TECNICO_BASELINE.md). Salvamento: o usuário relatou que o Studio salva automaticamente. Falta confirmar: é a versão publicada?
- [ ] **P0-08** Decidir `MaxPlayers` (hoje 60) × 4 lotes: o 5º jogador é expulso. Ajustar Game Settings ou permitir jogador sem lote. **2026-11-12 (Claude):** não dá para mudar por script (propriedade só leitura). **O usuário precisa pôr Server Size = 4 em Game Settings → Places** ([evidência](../evidence/cleanup-2026-11-12/VALIDACAO.md)).
- [x] **P0-09** Remover duplicata de `Workspace."Sprint on shift"`. **2026-11-12 (Claude):** duplicata movida para `ServerStorage.LimpezaBackup_20261112`; personagem com 1 `SprintScript` em Play ([evidência](../evidence/cleanup-2026-11-12/VALIDACAO.md)).
- [x] **P0-10** Limpeza de restos de depuração. **2026-11-12 (Claude, autorizado pelo usuário: "Faça após o 3"):** `Workspace.Script`, `_VerFerramentas` e os 3 remotes legados movidos para `ServerStorage.LimpezaBackup_20261112`; console sem "Hello world" ([evidência](../evidence/cleanup-2026-11-12/VALIDACAO.md)).
- [x] **P0-02** Testar inicialização e saco normal em Play; investigar `0/1` e regressão V8. **2026-11-10 (Claude):** Play PC OK, `SacoMax=50`, `0/1` não reproduzido, sem erros de script. [Evidência](../evidence/p0-playtest-2026-11-10/VALIDACAO.md).
- [ ] **P0-03** Testar slot 4/carrinho, rodas, guidão, corte físico e respawn em PC/mobile. **PC validado em Play** (montagem, corte por input real, respawn). Falta mobile.
- [ ] **P0-04** Testar foice/enxada/unha R15, ferramentas reais e hitbox; gravar vídeo. **PC:** as 3 equipam e cortam pelo servidor. Falta vídeo/avaliação da animação. **Taxa de acerto investigada** ([análise](../evidence/tool-hit-rate-2026-11-10/ANALISE.md)): no lote, o servidor só conta o quadrado se a lâmina passar perto do **centro** (raio 0,45–1,1 numa grade de 4 studs). Acerto hoje: unha 10%, enxada 53%, foice 86%. **Corrigido** (teste pela área do quadrado, `maxTiles` mantidos por decisão do usuário) e validado em Play no PC: foice 4/golpe, enxada 2, unha 1 a cada 3 golpes.
- [ ] **P0-05** Baús: prompt E/touch, orientação e idempotência de recompensa. **PC:** baú da entrada da floresta pagou uma única vez e está em pé. Faltam toque, baú do lote e baús revelados. Prompt visível depois da coleta **corrigido** (Claude, `game/chest-prompt/`), validado em Play no PC; falta Team Test com 2 jogadores.
- [ ] **P0-12** Corte fluido (pedido do usuário 2026-11-10). **Fase 1 — carrinho no lote: feita e validada em Play PC** (corte pelo trajeto da lâmina, orçamento, fechamento ao parar, previsão no cliente; 0 recusas no teste final). Ver `game/cut-feel/` e `evidence/cut-feel-2026-11-10/`. **Fase 2 — ferramentas manuais: feita e validada em Play PC** (corte previsto no contato, ~277 ms antes do servidor, 0 recusas). **Fase 3 — floresta: feita e validada em Play PC** (cadência corrigida, fechamento ao parar, previsão do carrinho e de foice/enxada; 0 recusas nas rodadas finais). Pendentes: avaliar o balanceamento do carrinho na floresta (~2× o ritmo efetivo anterior), som real de corte, mobile e ping real.
- [x] **P0-11** Verificar posse/permissão dos `TextureID`s. **2026-11-12 (Claude):** os 4 são da conta criadora do jogo (LilNomad00) e carregam com Success em Play ([evidência](../evidence/cleanup-2026-11-12/VALIDACAO.md)).
- [ ] **P0-06** UI: uma única aba/modal, hotbar oculta ao abrir Loja, responsividade.
  - **2026-11-10 (Claude):** polimento da UI validado em Play PC, layout compacto (menu abre na hora, indicador de aba, card da missão, árvore legível e sem sobreposições). Ver `game/ui-polish/` e `evidence/ui-polish-2026-11-10/`. Faltam layout largo, celular e controle.
    - **2026-11-12 (Claude):** HUD alinhado com o **HudKit**: os botões novos no mesmo estilo e na mesma escala da HUD original; ÁLBUM na coluna da esquerda; grade 2×2 à direita; margem de 18 e espaço de 8 em toda a pilha da direita. Ver `game/hud/`.
- [ ] **P1-13** Pedidos do usuário de 2026-11-10, em sequência: ~~UI~~ (feito) → ~~transição do mapa~~ (feito: `game/map-transition/`) → ~~animações~~ (2026-11-11, rodada 2 a pedido do usuário: foice e enxada apoiadas no ombro, golpe sem atravessar o corpo, apertar o número de novo guarda o item, corrigido o personagem que parava de animar após respawn; ver `game/animations/`; aguarda avaliação do usuário) → ~~NPCs~~ (2026-11-11: comerciantes de frente para o balcão, visual próprio, animação, placa de nome, balão de fala com dicas reais; ver `game/npcs/`; multiplayer e celular pendentes) → ~~cabana e segredos da floresta~~ (2026-11-11: cabana decorada por fora e por dentro, relíquias únicas, pistas de vaga-lumes, revelação/feixe/coleta com contador; ver `game/cabin-secrets/`). **As 5 frentes do pedido de 2026-11-10 foram entregues; aguardam avaliação do usuário.** O usuário autorizou o Claude a assumir também a área da floresta (Codex pausado).
- [ ] **P0-07** Auditar saves e `PersistenceEnabled=false`; planejar migração e testes de reconexão.
  - **2026-11-11 (Claude):** persistência **ligada** e validada no Studio (store `_Studio`).
    - Saco e segredos coletados passam a ser salvos e restaurados.
    - Espera pela trava de sessão ao trocar de servidor.
    - **Bug corrigido:** o servidor fechava antes do salvamento final.
    - Ver `game/persistence/` e `evidence/persistence-2026-11-11/`.
    - Falta testar no servidor publicado e com troca entre servidores.

## P1 — Floresta Esquecida (principal foco de arte e gameplay)

- [ ] **P1-01** Redesenhar *blockout* por setores, caminho sinuoso + visão revelada gradualmente.
- [ ] **P1-02** Criar/importar kit de 8–12 árvores irregulares, samambaias, raízes, troncos e moitas.
- [ ] **P1-03** Substituir pinheiros clonados/arranjados em linhas; melhorar densidade e sombras.
- [ ] **P1-04** Espalhar **grama alta da Área de Teste** com três estados e corte server-authoritative.
- [ ] **P1-05** Integrar cabana abandonada/restaurada do Blender como hero asset.
- [ ] **P1-06** Riacho/ponte quebrada + clareira secreta + 3 segredos com recompensa testada.
- [ ] **P1-07** Transição orgânica Vila→Floresta com áudio/luz locais, sem escurecer outros jogadores.
- [ ] **P1-08** Teste visual com screenshot/vídeo e FPS mobile; colher aprovação do usuário.

## Proposta — Pets, gamepasses e progressão (2026-11-11, PLANEJADO)

Pesquisa e proposta em [19 — Pets, gamepasses e progressão](../brain/19_PETS_GAMEPASS_PROGRESSAO.md). Nada implementado. **Depende do P0-07 (persistência)**: sem salvar dados não dá para vender itens nem dar pets.

- [x] **MON-00** Balancear a progressão atual. **2026-11-11 (Claude):** curva de XP `110·n^1,4` e preços novos dos cortadores; modelo em `game/balance/`. Validado em Play no Studio. Falta uma sessão real cronometrada.
- [ ] **MON-01** Missões diárias/semanais e álbum de coleções (depois do P0-07). **Álbum feito** (2026-11-12, `game/album/`, [evidência](../evidence/album-2026-11-12/VALIDACAO.md)): 4 páginas, +5% de grama por página completa. Missões: ver PAD-05.
- **Pesquisa de jogos similares (2026-11-11):** [brain 20](../brain/20_PADROES_JOGOS_SIMILARES.md). Itens que faltam, por prioridade:
  - [x] **PAD-01** recompensa diária com sequência e por tempo jogado (2026-11-11, `game/rewards/`);
  - [x] **PAD-02** grama dourada (2026-11-11; floresta 1% não testada);
  - [x] **PAD-03** códigos (2026-11-11); bônus de grupo pronto, mas **desligado até o usuário informar o GrupoId**;
  - [x] **PAD-04** grama do lote volta a crescer e progresso offline com teto (2026-11-12, `game/rewards/`, [evidência](../evidence/regrow-offline-2026-11-12/VALIDACAO.md));
  - [x] **PAD-05** quadro de missões variadas com recompensas permanentes (2026-11-12, `game/missions/`, [evidência](../evidence/missions-2026-11-12/VALIDACAO.md); trilha Floresta, celular e multiplayer não testados);
  - [x] **PAD-06** clima e eventos do servidor (2026-11-12, `game/events/`, [evidência](../evidence/events-2026-11-12/VALIDACAO.md); ciclo automático, visual 3D, celular e multiplayer não testados);
  - [x] **PAD-07** rankings globais e conquistas (2026-11-12, `game/rankings/`, [evidência](../evidence/rankings-2026-11-12/VALIDACAO.md)); **badges desligados até o dono criar os badges e informar os ids**;
  - [ ] **PAD-08** jogo com amigos. **Bônus de amigo feito** (2026-11-12, `game/friends/`, [evidência](../evidence/friends-2026-11-12/VALIDACAO.md): +10% por amigo no servidor, até 3, e botão de convite). **Falta:** "ajudar no jardim do amigo" (mexe no núcleo do lote; precisa de Team Test) e o teste de amizade real com 2 contas.
- [ ] **MON-02** Pets "Ajudantes do Jardim" versão 1: obtidos só jogando, sem troca, chances visíveis, efeitos no servidor com teto.
  - **2026-11-11 (Claude):** versão 1 com **multiplicador de grama**, a pedido do usuário.
    - 10 ajudantes e 3 ninhos com chances visíveis; 3 equipados, até 30 no inventário.
    - Salvos no perfil; seguem o jogador.
    - Validado em Play no Studio. Ver `game/pets/`.
    - Faltam: clique real no painel, celular, multiplayer e incluir os pets no modelo de balanceamento.
- [ ] **MON-03** Gamepasses de conveniência/visual e boosts (developer products com `ProcessReceipt` gravado antes de `PurchaseGranted`; preço lido com `GetProductInfo`).
- [ ] **MON-04** Serviços de jardim em níveis de dificuldade; evolução de raridade das ferramentas. **Raridade feita** (2026-11-12, `game/tool-rarity/`, [evidência](../evidence/tool-rarity-2026-11-12/VALIDACAO.md)): Oficina no lobby, 3 materiais, Comum → Mitológico com grama e quadrados extras. **Serviços em níveis:** rascunho em `game/jobs/`, não instalado.
- [ ] **MON-05** "Fama de Jardineiro" (renascimento) e regiões novas. **Fama feita** (2026-11-12, `game/fame/`, [evidência](../evidence/fame-2026-11-12/VALIDACAO.md)): Imperial GX + 200 mil moedas (×1,6 por estrela), +25% de grama por estrela, título, estrela na cabeça e coluna no placar. **Falta:** PH por estrela (depende do `SkillRules`) e desbloqueios por estrela. **Região nova feita:** Fazenda Abandonada (2026-11-12, `game/farm/`, [evidência](../evidence/farm-2026-11-12/VALIDACAO.md)), aberta no nível 10 ou com Fama 1; faltam segredos e ajudante exclusivo da região.
- [ ] **MON-06** (Opcional, decisão do usuário) Ovos pagos: só com chances, `PolicyService` e compra direta alternativa.

## P2 — Profundidade do jogo

- [ ] **P2-01** NPC Zeca + missão Trilha Esquecida + 3 itens antigos.
- [ ] **P2-02** Restauração da cabana / ponte e recompensas consistentes por jogador.
- [ ] **P2-03** Mapa de Exploração por regiões e visão do jogador; vínculo com habilidades.
- [ ] **P2-04** Auditar cada um dos oito nós Ready, registrar teste e liberar somente os funcionais.
- [ ] **P2-05** Implementar Cartógrafo / Construtor de Pontes quando mapa/cenário e dados prontos.
- [ ] **P2-06** Inventário e evolução reais de raridades das três ferramentas manuais.
- [ ] **P2-07** Baús por raridade: loot tables, posicionamento intencional, drop controlado.

## P3 — Polimento e novas áreas

- [ ] Balanceamento XP/moedas/PH com métricas; áudio/vibração/feedback.
- [x] Tratores como veículos e modelos exclusivos OffRoad/Colheitadeira/Imperial. **2026-11-12/13 (Claude):** v1 em peças e v2 com mais detalhe (`game/mowers/`); validado em Play no Studio.
- [x] **MOD-01** Trator preso no degrau de 0,2 entre a `Base` e o `Lawn` na beirada do lote. **Causa:** as rodas não giram (deslizam) e o atrito da borracha (1,0) segurava o veículo na quina. **Correção (2026-11-13):** `MowerMount.vehicle` dá atrito 0,05 às peças `Roda*`. Validado em Play: o Trator saiu do ponto onde nasce, subiu o degrau e cortou (550 → 611); a Colheitadeira andou 22,5 e cortou (611 → 655). Ver `evidence/mowers-2026-11-13`.
- [x] **GRAMA-PACK** Toda a grama dos lotes e da Fazenda como a da área de teste (Grass Pack). **2026-11-13 (Claude):** só o visual, no cliente (`game/grass/GramaPackCliente.client.luau`). Validado em Play no Studio: 5.274 tufos, corte, saco e tufo dourado funcionando. Falta: medir FPS no celular; avaliar escala menor nos lotes, se a faixa cortada precisar aparecer mais.
- [ ] **API-01** Pesquisa de APIs da Roblox feita (`brain/22_APIS_ROBLOX_RECOMENDADAS.md`). Escolher quais implementar: AnalyticsService, ConfigService, CaptureService no Álbum e convites são de baixo esforço. Badges, notificações e assinaturas dependem de IDs criados pelo dono.
- [ ] **MOD-02** Melhorias de modelagem. **2026-11-13 (Claude), validado em Play no Studio:**
  - aura no Lendário e no Mitológico;
  - plantação de milho e abóbora na Fazenda (o trator parado já existia);
  - telhado de duas águas nos quadros de Missões e Ranking.
  - Ver `evidence/modelagem-2026-11-13`.

  **Falta:** variação de tufos (precisa combinar com o Codex, porque mexe na jogabilidade e na floresta). O pinheiro torto da floresta fica com o Codex.
- [ ] Fazenda, Parque do Lago, Ruínas e segredos maiores.
- [ ] Otimização multiplayer/mobile com perfil de performance.

**Como atualizar:** marcar `[x]` só após terminar, com link de issue/PR + evidência; ao contrário, anotar `IMPLEMENTADO_NAO_PLAYTESTADO` em texto.

## P1 — Comércio e autonomia de exploração (adicionado 2026-11-10)

- [ ] **P1-09** Comerciantes: Guto na entrada, Lia no acampamento, Teca na cabana e Nilo secreto.
- [ ] **P1-10** Caçambas na entrada, acampamento e cabana (terceira reparável); reutilizar venda do lobby.
- [ ] **P1-11** Mochilas com upgrade de capacidade adicional, sem duplicar bônus; auditar `SacoMax` e saves.
- [ ] **P1-12** Gnomo colecionador com loja especial, contratos e pista da caverna; validar descobertas.

Ver [17 — Especificação](../brain/17_COMERCIANTES_CACAMBAS_MOCHILAS.md) e [Issue #6](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/6). **Todos PLANEJADOS, sem Play.**

### Execução de comércio — 2026-11-10

Aplicado ao place `106412085364108`, branch `ai/forest-economy`, código em `game/forest-economy/`. As mecânicas de P1-09 a P1-12 passaram em 48 verificações de Play, mais 50 asserções das regras. O checklist geral permanece aberto até validar toque, controle real, multiplayer, desempenho móvel e persistência autorizada. Os testes de código não equivalem a navegação completa da região em cada plataforma.

Evidências: [validação e limitações](../evidence/forest-economy/VALIDACAO.md). Persistência continua desativada; o usuário precisa salvar o place no Studio. A corrida foi delegada ao Claude em conversa separada, atualmente pausada, e não faz parte desta atualização.

### Densidade e corte — 2026-11-10

Visual da floresta e feedback local atualizados. Play e idempotência de recompensa verificados; avaliação do usuário e desempenho móvel pendentes. Ver [evidência](../evidence/grass-feel/VALIDACAO.md).

- [x] **Editor — 2026-11-10:** prévia estática da floresta instalada; Edit/Play/Edit sem duplicação validado. Place salvo na versão 19. Ver `evidence/editor-preview/VALIDACAO.md`.

- [x] **2026-11-12 — Terreno (editor):** eliminar cortes retangulares, corrigir cota do lobby e frestas de LOD; evidência em `evidence/world-reform/CHECKPOINT_TERRAIN.md`.
- [ ] **2026-11-12 — Lobby:** praça temática, horta/estufa, marcos, props e integração dos quatro lotes. Multiplayer será testado pelo usuário.

### Checkpoint do lobby — 2026-11-12

Praça, horta/moinho/estufa, props e caminhos aplicados. Play confirmou inicialização sem duplicação e coordenadas preservadas. Studio desconectou antes da revisão final e do save; tarefa permanece aberta. Ver [checkpoint](../evidence/lobby-garden/CHECKPOINT.md).

### Retomada do lobby — versão 112

Arte ampliada e salva; inicialização, posições dos lotes/spawns, letreiros e dez pontos de circulação verificados. Tarefa visual permanece aberta até capturar e avaliar a última revisão paisagística. Não confundir a nota 6,8/10 das imagens v4 com avaliação das sebes/painéis atuais. Multiplayer a cargo do usuário; mobile e persistência pendentes.
