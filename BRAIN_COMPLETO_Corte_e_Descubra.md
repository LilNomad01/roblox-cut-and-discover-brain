# 🧠 BRAIN COMPLETO — CORTE & DESCUBRA / CUT & DISCOVER

> **Data base:** 2026-11-09. **LEIA PRIMEIRO:** fatos extraídos de arquivo, relato do usuário e propostas são categorias distintas. A V9 foi analisada estaticamente, sem Play. Este arquivo é contexto para outra IA, não relatório de software certificado.

**Como usar:** copie/mande este arquivo para a IA do seu amigo; se tiver acesso ao repositório, prefira ler arquivos individuais atualizados e `handoffs/LOG.md`.


---

## SEÇÃO — Contexto e fontes
**Origem:** `brain/00_START_HERE.md`

# START HERE — Contexto em 90 segundos

**Projeto:** Corte & Descubra / Cut & Discover, simulador de jardinagem com exploração no Roblox.  
**Tom:** leve, satisfatório, estilizado, colorido, com mistério aconchegante; priorizar mobile.  
**Diferencial:** cortar o matagal para revelar trilhas, baús, pistas, casas, ruínas e transformar ambientes.

## Loop

`Cortar no lote → ganhar grama/saco → vender → ganhar moedas e XP → comprar ferramenta → desbloquear habilidades → entrar na floresta → abrir trilhas e revelar objetos → missões e restauração → novas áreas`.

## Conhecido e observado

- Vila com **quatro jardins/lotes**, estradas e ponto de venda; loja amarela externa; menu do jogador com **Perfil, Habilidades, Equipamentos, Exploração, Missões e Configurações**.
- Arquivo local mais recente conhecido: **V9**, com **7.296 instâncias e 103 scripts/módulos** conforme leitura binária; há **backups dentro do `.rbxl`** que não devem ser tratados como scripts ativos.
- Existem assets de 5 máquinas, 3 tipos de ferramenta em 5 raridades, 5 baús e pacote 3D de grama; checar se estão importados/equipados corretamente.
- Barra de ferramentas: `1` unha, `2` enxada, `3` foice, `4` carrinho. `F` para golpe manual nos experimentos recentes.
- **O usuário não gostou da última aparência da floresta:** pinheiros triangulares repetidos, chão muito vazio entre tufos, trilhas pouco orgânicas, cabana distante. Reformulação artística é prioridade.
- **Persistência marcada desativada** em um `GameConfig` da V9. Não prometer salvamento.

## Não confundir

- **Decisão de design** ≠ feature existente.
- **Asset Blender/FBX/GLB existente** ≠ asset corretamente importado e montado no Studio.
- **Código inserido no `.rbxl`** ≠ funcionando no Play.
- **Screenshot do usuário** prova visual daquela sessão, não garante ausência de bugs após mudança.
- **V9 local** ≠ versão oficial publicada, a menos que o usuário confirme.

## Focos de trabalho mais urgentes

1. Confirmar baseline/código ativo, corrigir regressões: carrinho, foice, prompts dos baús, NPC.
2. Refazer a floresta **por design de nível e arte**, com árvores orgânicas, camadas de vegetação, trilhas sinuosas e segredos intencionais.
3. Unificar corte por lâmina (grana/recompensa) e mato TALL/SHORT/STUBBLE.
4. Refinar UI mantendo estilo do jogo; corrigir abas e sobreposições.
5. Colocar habilidades de verdade em produção apenas se testadas; auditar persistência e anti-exploit.

Leia `brain/02_ESTADO_REAL_E_VERSOES.md` para detalhes técnicos reais, `brain/06_MUNDO_FLORESTA_ESQUECIDA.md` para a floresta e `brain/15_SINCRONIZACAO_DAS_IAS.md` para colaborar.


---

## SEÇÃO — Visão do jogo
**Origem:** `brain/01_VISAO_E_DECISOES.md`

# Visão, diferenciação e princípios de design

## Conceito

**Corte & Descubra** é um jogo Roblox que parte da linguagem simples dos simuladores de cortar grama, mas transforma o ato de cortar em ferramenta de **exploração e descoberta**. Um terreno tomado pelo mato pode esconder uma estrada, uma cabana, símbolos, uma passagem, um baú ou uma missão de restauração. O mundo reage visualmente à limpeza.

Pilares:

1. **Satisfação imediata:** animações, som, partículas, trilha aberta e progresso visível a cada sessão.
2. **Progressão sentida:** ferramentas alteram o gesto, a largura, o alcance e o estilo do corte, não só multiplicadores.
3. **Curiosidade:** cada massa de matagal é uma promessa de algo a revelar; sinais discretos para curiosos.
4. **Mundo que melhora:** lugares abandonados podem tornar-se jardins, pontes e oficinas restauradas.
5. **Cooperação respeitosa:** mundo público compartilhado, recompensas e descobertas individuais confiáveis.
6. **Acessibilidade mobile:** legibilidade, FPS, botões tocáveis, controles simples e curtas sessões.

## Loop detalhado

- **Entrada (0–3 min desejados):** jogador aprende a cortar, usa ferramenta inicial divertida, recebe moedas e vê a vantagem da próxima ferramenta.
- **Lote privado:** cortar grama/serviço, saco limitado, vender na caçamba, adquirir equipamento.
- **Exploração:** mata alta dificulta a visão; ferramenta abre trilhas; descobrir marcos dá história/recompensa.
- **Habilidades:** PH ganho em marcos de nível; unlock de mecânicas (Corte Rente, Detector, Drone etc.).
- **Transformação:** reconstruir cabana/ponte com materiais e missões; mostrar antes/depois.
- **Retorno:** diferentes subáreas, objetivos curtos, materiais, segredos e futuras regiões.

## Direção estética

- **Lobby/vila:** verde alegre, ensolarado, simples, legível, cartoon.
- **Floresta:** verde profundo + azuis frios, toques âmbar de lanternas, mistério leve, denso sem virar terror.
- **UI:** cor viva por ação, contorno escuro, UICorner, tipografia arredondada, feedback claro e consistente.
- **Mundo:** low-poly *bem dirigido*, não simplesmente caixas, esferas e pinheiros duplicados em grid.

## Restrições

- Preservar vila e 4 lotes; trabalhar incrementalmente.
- A ferramenta faz o corte, não os pés do personagem.
- O corte deve acompanhar arco/faixa da lâmina, não limpar quadrados grandes visíveis.
- Não esconder recompensas totalmente aleatórias: haver pistas/segredos intencionais.
- Nunca limitar o mistério a porcentagens na loja; incluir ações e descobertas.
- Nunca vender como concluído algo não validado em Play.

## Ideias abandonadas ou apenas discutidas

- Conceito antigo **“Puxe as Ilhas”** foi abandonado — NÃO retomar como gameplay principal.
- Discussões sobre portar outros jogos de PC/Steam para Roblox foram exploratórias e não definem o projeto atual.
- Nas primeiras iterações, o escopo alternou entre Claude/Codex e ChatGPT editar arquivos. Hoje a decisão *prática* é que qualquer IA pode propor/editar sob a mesma governança, **mas o usuário escolhe a baseline e aprova mudanças**.

## Métricas de experiência — metas, NÃO dados medidos

- Primeiro upgrade (enxada): idealmente entre 1 e 3 min.
- Foice: ~8–12 min; carrinho manual ~20–30; motorizado ~45–70; trator ~90–150 min (propostas antigas, ajustar com telemetria).
- Primeira trilha/segredo: objetivo dentro de poucos minutos na floresta.
- Balancear a expectativa de progresso sem grind frustrante e sem subir nível a cada poucos segundos.


---

## SEÇÃO — Estado técnico
**Origem:** `brain/02_ESTADO_REAL_E_VERSOES.md`

# Estado real, evidência e builds

**Snapshot inicial:** 2026-11-09.  
**Artefato inspecionado estaticamente:** `CorteEDescubra_v9_Carrinho_Foice_HUD.rbxl`.  
**Forte ressalva:** o `.rbxl` é uma **cópia experimental gerada ao longo desta conversa**. A versão principal do Claude, o place publicado e o trabalho atual do amigo **não foram verificados**. Antes de programar, confirmar com o usuário qual branch/arquivo é a base.

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


---

## SEÇÃO — Progressão
**Origem:** `brain/03_PROGRESSAO_E_ECONOMIA.md`

# Progressão, moedas, XP, PH e balanceamento

## Economia existente em código (V9, `ReplicatedStorage.ConfigJogo`)

- `PrecoGrama = 2` moedas por unidade vendida.
- `GramaPorPlaca = 1` base por placa cortada, antes de multiplicadores.
- `XPPorPlaca = 5` por placa (validar caminho ativo e anti-dupe).
- `XPParaNivel(n) = floor(60 * n^1.4)`; screenshot exibe nível 1 → 2: `0/60 XP`.
- `RecompensaNivel(n) = 25 * n`.

**Nota:** há também outro módulo `GameConfig` com parâmetros diferentes, como `CellReward=2`, `JobReward=40`, `TutorialReward=15`, `CrateReward=10` e níveis próprios. Isso indica coexistência de sistemas antigos/novos. **Antes de calibrar, identificar qual módulo o gameplay ativo utiliza.** Não misturar tabelas de sistemas paralelos.

## Loja de cortadores na V9 (`ConfigJogo.Itens`)

| ID | Nome | Preço | Corte | Saco |
|---|---|---:|---:|---:|
| `Basico` | Cortador Básico | 0 | 1× | 50 |
| `Eletrico` | Cortador Elétrico | 400 | 2× | 100 |
| `Turbo` | Cortador Turbo | 2.500 | 4× | 250 |
| `Trator` | Mini Trator | 15.000 | 10× | 800 |
| `OffRoad` | Trator Off-Road | 32.000 | 14× | 1.200 |
| `Colheitadeira` | Colheitadeira | 65.000 | 18× | 1.800 |
| `Mega` | Mega Cortador | 100.000 | 30× | 3.000 |
| `Imperial` | Imperial GX | 250.000 | 45× | 5.000 |

**Atenção:** os três extras `OffRoad`, `Colheitadeira`, `Imperial` foram adicionados à configuração em V8. Sua lógica/compra foi escrita, mas **os modelos 3D exclusivos não foram comprovados**; uso de visual fallback possível. Economia não foi balanceada em Play.

## Ferramentas manuais e raridades

- `CortadorUnha`, `Enxada`, `Foice` × `Comum`, `Incomum`, `Raro`, `Lendario`, `Mitologico`.
- Na V9, `FerramentasConfig.KitInicial` dá as versões **Comuns** das três manuais.
- Multiplicadores de raridade previstos: 1,00 / 1,15 / 1,30 / 1,50 / 1,75.
- Compra/evolução de raridade **não concluída**; modelos não implicam que o sistema de progressão funcione.
- Os carrinhos/máquinas não podem virar irrelevantes em relação à foice; largura, modo contínuo, mobilidade e resistência da grama precisam diferenciar.

## PH — pontos de habilidade

- São **separados de moedas, XP e Robux**.
- `SkillDefinitions` da V9 documenta marcos sugeridos de concessão de PH: níveis `2,4,6,8,10,12,15,18,22,26`.
- Cada fonte de PH deve ser creditada **uma única vez**, com ledger/idempotência. PH gasto pelo servidor, verificado contra requisitos e saldo.
- Não permitir compra de habilidade com `status=Planned`, mesmo que o botão exista.
- Evitar reset total em uma migração de perfil.

## Balanceamento ainda necessário

Problema relatado desde fases anteriores: **níveis sobem rápido demais**, sons e feedback pouco satisfatórios. Fazer teste de 30–60 min com métricas: `xp/min`, `moedas/min`, `cortes válidos/min`, `tempo por upgrade`, `tempo por área`, abandono de tutorial e FPS mobile.

Metas históricas **NÃO medidas**: enxada em 1–3 min, foice em 8–12 min, carrinho em 20–30, motorizado em 45–70, trator em 90–150. Outra fórmula proposta anteriormente `100 + 35(L-1) + 6(L-1)^2` era **alternativa de design, não a fórmula em uso**. Não adotar sem comparar à `ConfigJogo` real.

## Anti-exploit

- XP/grama/saco somente quando a unidade muda de estado por corte legítimo.
- Segunda passada `SHORT→STUBBLE` não deve duplicar XP/grama automaticamente; qualquer bônus de habilidade exige regra específica.
- Recompensas de baú/quest/nível idempotentes e server-side.
- Limite de capacidade do saco antes de conceder item.
- Não confiar em RemoteEvent informando quantidade cortada ou moedas.


---

## SEÇÃO — Equipamentos e animações
**Origem:** `brain/04_EQUIPAMENTOS_E_ANIMACOES.md`

# Equipamentos, montagem, animações e game feel

## Filosofia

**Quem corta a grama é a lâmina da ferramenta.** O corpo, o `HumanoidRootPart`, os pés ou a posição do jogador não devem, por si só, limpar vegetação. Ferramentas manuais usam golpe/janela de contato; máquinas cortam continuamente ao avançar.

## Slots e kit na V9

1. **UNHA** — cortador de unha comum, curto alcance, ato absurdo/divertido.
2. **ENXADA** — golpe frontal descendente com duas mãos.
3. **FOICE** — varredura lateral ampla com mãos na haste.
4. **CARRINHO** — modelo real na frente, empurrado com as mãos no guidão; máquina acompanha compras.

`F`/clique para manuais, números 1–4 para troca, toque para mobile; checar conflito com atalhos de outras ferramentas e habilidades. Não duplicar equipamento ao atacar.

## Configuração observada em `FerramentasConfig`

| Ferramenta | Duração | Janela de contato | Cooldown | Alcance | Largura | MaxTiles por ataque |
|---|---:|---:|---:|---:|---:|---:|
| Cortador de unha | 0,80 s | 0,34–0,45 | 0,85 s | 4,5 studs | 0,9 | 1 |
| Enxada | 0,82 s | 0,32–0,43 | 0,86 s | 7,5 studs | 2,2 | 2 |
| Foice | 0,72 s | 0,22–0,48 | 0,76 s | 8,5 studs | 1,6 | 4 |

Atributos são da **cópia V9** e não foram balanceados em Play. Confirmar se os servidores realmente usam essas configurações e não rotas antigas.

## Animações-alvo por timeline (60 FPS conceitual)

### UNHA — 0,80 s

- `0,00–0,20`: inclinação/agachamento (Ease In Out; influência ~35–40%).
- `0,20–0,34`: preparar mão junto à grama (Cubic In).
- `0,34–0,45`: pequeno clique/corte e VFX no contato.
- `0,45–0,80`: recuperar postura (Cubic Out; influência ~70%).
- Idle: postura relaxada/engraçada; não segurar objeto do tamanho de enxada.

### ENXADA — 0,82 s

- `0,00–0,20`: erguer haste, girar ombro e inclinar tronco (Ease InOut ~40%).
- `0,20–0,39`: golpe descendente acelerado (Cubic In).
- `0,32–0,43`: lâmina encontra vegetação, validar área varrida.
- `0,43–0,82`: follow-through curto e retorno (Cubic Out ~70%).
- A segunda mão deve permanecer na haste, sem IK em conflito com AnimationTracks.

### FOICE — 0,72 s

- `0,00–0,14`: antecipação; peso na perna contrária, ombros giram (Ease InOut ~40%).
- `0,14–0,30`: início da varredura lateral, acelerando (Cubic In).
- `0,30–0,46`: arco principal com rastro curtíssimo da lâmina; desaceleração orgânica.
- `0,46–0,72`: follow-through, leve recoil e retorno (Cubic Out 65–75%).
- Não usar um círculo 360º para golpe frontal comum; somente `CUT_SPIN` habilita giro próprio.

### CARRINHO — contínuo

- Pose de entrada `0,25 s`, Ease In Out; mãos no `Guidao`/`Grip`, braços estendidos.
- Idle parado: mãos apoiadas, respiração discreta, rodas paradas.
- Walk empurrando: passos sincronizados à velocidade, rodas girando, corpo 5–10° inclinado, microbalanço da máquina.
- Saída `0,20 s`, Cubic Out. Não usar animação de arma manual com carrinho equipado.
- Validar `PrimaryPart`, `Pivot`, `Motor6D`/`WeldConstraint`, collision groups, peças `Anchored`, replicação e respawn.

## Visual/audio feedback

- Curto `whoosh` de foice, impacto ao contato real, um pouco de aparas verdes, animação da grama `TALL→SHORT` em ~0,10–0,22 s e `SHORT→STUBBLE` ~0,08–0,16 s.
- Evitar um som a cada folha; agregar por golpe/faixa.
- Sem `SoundId`/`AnimationId` inventados. Solicitar importação/publicação quando preciso.

## Problemas conhecidos

- Foice apareceu segurada de modo rígido/horizontal em screenshot.
- Carrinho sumiu na V8; seleção de slot mostrava saco `0/1`; V9 reporta correção de inicialização, fallback e IK, **sem Play validado**.
- Protótipo antigo `FoicePlaceholder` duplicava ferramenta ao pressionar `F`; deve permanecer desativado/removido após auditar o código atual.
- Se o avatar for R6, animações R15 procedurais precisam fallback apropriado.
- Todos os slots e animações precisam persistir coerentemente durante troca, respawn, lag e mobile.

## Critérios de aceite

- A enxada segura em duas mãos e realmente desce ao contato.
- Foice percorre arco frente/lateral, sem cortar atrás ou ao caminhar sem comando.
- Carrinho aparece sempre que equipado, avança à frente do jogador, mãos no guidão, corta pela lâmina.
- Só um modelo visual equipado; sem ataque fantasma ou resets bruscos.
- PC, celular e outro jogador veem a pose correta.


---

## SEÇÃO — Grama e corte
**Origem:** `brain/05_GRAMA_E_CORTE.md`

# Vegetação e sistema de corte

## Duas necessidades diferentes, um sistema de regras

1. **Lote/jardim da vila:** 64 unidades visuais ou células lógicas por serviço nas screenshots; gameplay econômico confiável e repetível.
2. **Floresta pública:** massas volumosas de matagal alto que ocultam trilhas, baús e pistas; pode usar outros visuais/densidades, mas **reutiliza a mesma validação de corte e recompensa**.
3. **Área de Teste:** o usuário **gostou muito** daquele mato alto, com folhas compridas e espigas. É a referência visual preferida da floresta, não uma graminha curta genérica.

## Estados visualmente indispensáveis

- `TALL` / `ALTO`: 5–8 studs, ocasionais 9–10 para esconder descoberta. Folhas altas, densas, coloridas, com sementes. Não usar colisão folha a folha.
- `SHORT` / `BAIXO`: 0,9–1,8 studs; primeira passada, cenário revelado.
- `STUBBLE` / `RASTEIRO`: 0,15–0,45 studs; acabamento da limpeza.

Variações: `Grass_A01...A06`, `Grass_B01...B04`, LODs e debris. Nomear e mapear coerentemente os três estágios de cada família, sem troca de modelo de outro tamanho.

## Geometria orgânica do corte

**Problema a evitar:** remover um tile quadrado inteiro ao encostar na grama. A área cortada deve ser o **volume varrido pela lâmina**.

- Unha: região pequena e baixa; requer vários movimentos.
- Enxada: faixa frontal descendente, recorte curto.
- Foice: varredura lateral de arco, com pontos de amostragem ao longo da animação.
- Carrinho motorizado/manual: tira contínua no solo, calculada entre posições anteriores e atuais da lâmina e largura física real.
- Trator: cobertura maior, controle como veículo se for ride-on.

Implementação pode usar células invisíveis/índice espacial, mas sem borda visual retangular: clumps sobrepostos, variantes, bordas irregulares, estágios por microclump; minimizar instâncias por lote e região.

## Segurança de gameplay

- Cliente pede **ação**; servidor valida ferramenta, propriedade, área atingida, cooldown, velocidade plausível, terreno elegível e estado da grama.
- `TALL→SHORT` é corte primário; `SHORT→STUBBLE` é acabamento. Crédito de XP/grama segue `Rewards` e habilidades ativas, com idempotência por célula/serviço/owner.
- Não conceder XP por frame, por folha, por tentativa sem mudança nem pelo mesmo tufo já cortado.
- Respeitar saco, XP, combos e evolução sem duplicidade.
- Forest multiplayer: decidir se matagal compartilhado entre todos ou progresso individual/instanciado. Documentar regra por setor.

## Distribuição

**Vila:** bordas livres dos lotes, manchas entre áreas verdes; sem cobrir ruas, spawn, caçambas, entrada da loja ou controles. **Floresta:** manchas densas com vazios intencionais, trilhas curvas, microclareiras e curvas de visão. Nunca espalhar exatamente igual no chão inteiro.

## Performance

- Preferir MeshParts baixos poly e poucos materiais, instanciados por região; colisão simplificada apenas para troncos/obstáculos.
- **Streaming/LOD por proximidade**, distância de render e pooling para efeitos; limitar duplicação de clones.
- Medir FPS, draw calls e instâncias no mobile. Evitar loop Heartbeat individual para cada tufo.
- Cliente visual pode interpolar transição, mas servidor controla corte e recompensa.

## Estado conhecido

- ZIP GrassPack contém modelos `.glb`, `.blend`, LODs e documentação; usuário reportou antes **54 de 70 GLBs importados**, dado histórico a verificar na versão principal.
- V9 inspecionada tem pasta `GrassPack` e muitos objetos `Grass_*`; isso **não prova** uso correto no mapa atual.
- O usuário aprovou visual da grama da Área de Teste; a qualidade/distribuição na floresta ainda não foi aprovada.


---

## SEÇÃO — Floresta Esquecida
**Origem:** `brain/06_MUNDO_FLORESTA_ESQUECIDA.md`

# Mundo e reformulação da Floresta Esquecida

## Mundo compartilhado — visão planejada

**Centro:** vila ensolarada com **quatro terrenos particulares**, estradas, caçamba de venda, loja, testes e menus.  
**Região inicial:** **Floresta Esquecida**, acessível caminhando da vila, centro do primeiro ciclo de descoberta/restauração.  
**Futuro:** Fazenda Abandonada (off-road e materiais), Parque do Lago (exploração livre), Ruínas Antigas (puzzles e segredos); ainda não presumir construídos.

## Avaliação artística da última screenshot — 2026-11-09

**O usuário desaprovou** o cenário atual. Visual visto: pinheiros triangulares/planos em fileiras uniformes, troncos semelhantes, chão aberto, grama alta em manchas mas pouco sub-bosque, cabana distante, céu enorme, contraste de piso escuro artificial. Lembra plantação de árvores/procedural genérico. Precisa refazer o **level art e o fluxo de exploração**, não apenas aumentar quantidade de objetos.

### Nova direção de arte aceita como proposta prioritária

- **Floresta encantada abandonada, levemente misteriosa, NÃO terror.** Visual cartoon/low-poly bem modelado com luz azul-petróleo, verdes profundos, dourado nas lanternas e pontos focais.
- Árvores orgânicas de silhuetas variadas: troncos curvados, bifurcações, raízes suaves, copas irregulares em 2–6 volumes, algumas coníferas boas, árvores secas quebradas e jovens.
- Sub-bosque: samambaias, moitas, arbustos, rochas com musgo, troncos caídos, tocos, fungos, raízes, flores pontuais e folhas no solo.
- **Ocultação intencional:** limitar linhas de visão com curva de trilha, árvores densas, elevação suave, muros de vegetação; sugerir pontos de interesse sem revelar tudo.
- **Contraste espacial:** túnel de árvores → clareira iluminada → matagal escuro → cabana com luz âmbar → riacho → segredo.
- Densidade não significa colidir com tudo ou sobrecarregar mobile. Massas decorativas e manchas cortáveis devem ser separadas.

## Organização de mapa proposta (não coordenadas verificadas)

### 0. Passagem desde a vila — 30–60 studs de transição

Saída física do lobby, sem teleporte seco. Relva comum vai ficando alta, árvores aproximam, cerca/placa antiga, luz muda sutilmente. O jogador enxerga uma pista de cabana e escuta novos sons. Sem bloquear acesso básico a iniciantes.

### 1. Mata Baixa — primeira descoberta (tutorial)

Mato alto da Área de Teste em manchas; trilha antiga parcialmente visível; primeiro baú/objeto simples. Câmera mobile deve manter o personagem legível. Introduzir pista que aponta para a cabana.

### 2. Corredor dos Galhos — primeiro corte de caminho

Trilha sinuosa com curva, samambaias, árvores altas. Matagal impede ver o próximo ponto, mas a direção é dada por sinais ambientais (placa caída, trilho de terra, flores únicas). Nada de corredor perfeitamente reto com árvores equidistantes.

### 3. Cabana Esquecida — primeiro grande ponto de interesse

Cabana abandonada do kit Blender, parcialmente escondida entre árvores. Varanda, telhado assimétrico, musgo, trepadeiras, cercas velhas, ferramentas, lanterna quente. Ao revelar: VFX de descoberta e missão de restauração. Versão restaurada em modelos separados, controle por jogador/servidor definido antes.

### 4. Riacho + Ponte Quebrada — objetivo de médio prazo

Água natural em leito curvo, pedras nas margens, ponte quebrada com madeiras corretas, sem formas flutuantes. A ponte mostra claramente uma área além do riacho. A habilidade `REST_BRIDGE` é planejada; não bloquear progressão por feature ainda indisponível sem rota alternativa.

### 5. Clareira Secreta — recompensa do curioso

Pequena área distinta com pedestal/artefato ou um baú raro, acessível por uma pista no entorno e corte do matagal. Não anunciar no mapa antes de descoberta.

### 6. Núcleo da Floresta Antiga — progressão futura

Mais denso/escuro, árvores antigas, sons profundos, segredos ligados a habilidades; manter acessível a quem chega. Trilhas secundárias e atalhos após limpeza.

## Escala

O usuário quer área significativamente maior do que a pequena ilha de Blender. Nas iterações foram propostos ~330×330 e ~470×478 studs, mas são **dimensões de experimentos**, não “tamanho final aprovado”. Nova escala deve ser baseada no tempo de percurso, densidade, FPS e conteúdo. Sugerir **400–600 studs** como espaço de planejamento, com possibilidade de expandir por setores, mas *não* gerar campo plano vazio só para crescer números.

## Layout navegável

- Caminho principal entendível mesmo sob matagal, 3–5 pontos de interesse espaçados.
- 2–4 subrotas opcionais; cada rota com **pista visual + resultado**.
- 6–10 segredos iniciais criados com intenção; não confundir com roll de baú aleatório.
- Distância/ocultação de vistas controlada; mostrar fragmentos da cabana, ponte e ruína para criar curiosidade.
- Testar tempo de caminhada do spawn ao primeiro segredo sem equipamento caro.

## NPC e missões — projeto

**Zeca, o Jardineiro** na entrada/ligado à cabana. Missão inicial **“A Trilha Esquecida”**: conversar, limpar caminho, encontrar **3 itens antigos**, descobrir cabana, retornar. Missão seguinte **“Um Novo Começo”**: reunir materiais, limpar entorno e restaurar cabana. Recompensas em moedas/XP/PH precisam balanceamento e idempotência. **NÃO confundir Zeca com o NPC “Novo Serviço” do lote privado**.

## Blender ↔ Roblox Studio

- Não exportar uma floresta inteira como um MeshPart gigante. Usar **kit modular**: árvores, vegetação, pedras, raízes, cabana/variações, ponte/variações, placas/cercas, esconderijos.
- Roblox monta setores, lógica, colisões, cut cells, checkpoints, reveal e iluminação local.
- Asset não deve aparecer “flutuando”: pivô na base, orientação consistente, teste de escala (1 stud) e Snap-to-Ground por raycast.

## Iluminação e áudio

- Evitar editar `Lighting` global de forma irreversível ao entrar (afeta todos jogadores em server). Usar efeitos locais com Tween no cliente, zona de Atmosphere/ColorCorrection quando tecnicamente compatível, sons 3D regionais e sombras de geometria.
- Transição desejada: ~1,8 s com `Sine InOut`/`Cubic InOut`, leve redução de saturação/brilho, sem deixar legibilidade ruim.
- Ambient: vento, aves distantes, folhas/insetos. Usar IDs licenciados/autorizados, não placeholders de áudio fictícios.

## Critérios de aprovação visual

1. 8–12 silhuetas reais de árvore e distribuição **não regular**.
2. Sub-bosque em camadas e artefatos que contam história.
3. Trilhas sinuosas com revelação gradual e clareiras.
4. Cabana marcante e ligada à mecânica de cortar/descobrir.
5. Mato da Área de Teste denso, com corte e recompensas válidos.
6. 2–3 segredos funcionais no primeiro setor antes de expandir.
7. Sem asset flutuante, sem chão artificial vazio, sem queda significativa de FPS mobile.


---

## SEÇÃO — Árvore de habilidades
**Origem:** `brain/07_ARVORE_E_HABILIDADES.md`

# Árvore de habilidades — 19 nós, PH e implementação real

## Visual

O usuário enviou referência de árvore de habilidades **hexagonal**, vários ramos com cores próprias e painel lateral. Nosso design precisa casar com o jogo, não ser um overlay preto/genericão. Nó central **Jardineiro Iniciante**, pan/zoom PC e touch, categoria com cor, cadeados, requisitos, custo, rank, efeito real e interação com mapa.

Ramos: **CORTE verde**, **EXPLORAÇÃO azul**, **TECNOLOGIA laranja**, **RESTAURAÇÃO roxo**, **MISTÉRIOS dourado/segredos ocultos**.

## Fatos da V9 — `SkillDefinitions`

**19 nós**. O arquivo classifica oito como `Ready` e outros onze como `Planned`, mas *Ready em código ≠ testado em Roblox Studio*. Existem `SkillService` e `SkillMechanics`; validar gatilhos reais e conexões UI antes de permitir compra no jogo publicado.

### Nós `Ready` no arquivo, com comportamento descrito nos módulos

| ID | Nome | Status arquivo | Ação/evidência textual |
|---|---|---|---|
| `CUT_CLOSE` | Corte Rente | Ready | após jardim completo, passar novamente para acabamento (`STUBBLE`) |
| `CUT_SPIN` | Corte Giratório | Ready | corte em raio/até 10 tiles no lote, cooldown ~20 s |
| `CUT_TURBO` | Modo Turbo | Ready | aumenta faixa de máquina por ~8 s, cooldown ~45 s |
| `EXP_VISION` | Visão do Explorador | Ready | torna grama do lote translúcida por ~5 s, mostra pista do baú |
| `EXP_DETECTOR` | Detector de Tesouros | Ready | `G` detecta baú já revelado no lote por ~8 s |
| `TECH_CLIPPINGS` | Coletor de Aparas | Ready | recurso/passivo a cada cortes legítimos, respeita capacidade |
| `TECH_QUICKSWAP` | Troca Rápida | Ready | alternar entre últimos dois cortadores adquiridos (`V`) |
| `TECH_DRONE` | Drone Jardineiro | Ready | `H`, drone temporário no próprio lote com cap de cortes, cooldown ~60 s |

Observação de escopo: algumas ações citadas como “para floresta” em prompts antigos funcionam *somente no lote* na configuração atual. Extensões para floresta são **PLANEJADAS**, não existentes só por nome.

### Nós `Planned` / NÃO compráveis até mecânica real

- `CUT_PRECISION` — Corte de Precisão; linhas, padrões e bordas.
- `EXP_MAP` — Cartógrafo; mapa detalhado com descobertas reais, não revelar segredos desconhecidos.
- `EXP_BOTANIST` — Botânico Especialista; interação com plantas especiais.
- `TECH_OFFROAD` — Rodas Off-Road; lama/rampas em Fazenda.
- `REST_BRIDGE` — Construtor de Pontes; reparar ponte e liberar trajeto.
- `REST_GARDEN` — Jardineiro Criativo; decoração limitada ao lote próprio.
- `REST_WORKSHOP` — Oficina Restaurada; recuperação de instalação e novas funções.
- `REST_COOP` — Mutirão de Limpeza; contratos cooperativos.
- `SECRET_ROOTS` — Segredo das Raízes; descoberta por pista do mundo.
- `SECRET_LEGENDARY_CUT` — Corte Lendário; domínio de ferramentas/realizações.
- `SECRET_GREEN_ARCH` — Arqueologia Verde; padrões/ruínas/puzzles.

## Integração com mapa de exploração

Mapa no menu **Exploração** deve mostrar somente regiões descobertas, marcador do jogador, NPCs conhecidos, ponte e cabana descobertas, pistas de tesouro autorizadas. Habilidades `EXP_MAP`, `EXP_DETECTOR`, `EXP_VISION`, `REST_BRIDGE` devem produzir **mudanças visíveis** no mapa quando implementadas.

## Pontos de habilidade

- Marcos propostos no arquivo: `[2,4,6,8,10,12,15,18,22,26]`.
- Servidor verifica saldo, nível, propriedade da ferramenta, requisito, rank e `status=Ready` com mecânica real.
- UI precisa mostrar motivo de bloqueio e nunca gastar PH para função inexistente.
- Salvar progressão, ranks e fontes de PH sem duplicar; hoje persistência não comprovada.

## Bugs já vistos

- Duas árvores/interfaces sobrepostas em versões anteriores.
- Componentes de **Perfil/Equipamentos/Habilidades** visíveis simultaneamente em screenshot de UI.
- `0 PH` com vários nós bloqueados; se houver teste, não interpretar isso como sistema quebrado por si só.
- Painel lateral lotado e textos cortados em alguns formatos de tela; precisa safe areas, hierarquia e scroll próprios.

## Critérios de qualidade

Nenhuma árvore fake. Visual, dado e servidor sincronizados. Pan/zoom suaves; código não renderiza conexões a cada frame sem necessidade; botões de unlock mostram feedback; segredo oculto não vaza descrição. Validar multi-jogador, mobile e reconexão antes de `VALIDADO_EM_PLAY`.


---

## SEÇÃO — UI/UX
**Origem:** `brain/08_UI_UX.md`

# UI/UX e identidade visual

## Identidade aprovada

A UI pública da vila tem botões grandes coloridos, fundo com gradiente, contorno quase preto, sombra offset, cantos arredondados e fonte lúdica legível. Principais botões externos: **MENU verde/mint, LOJA amarelo, UPGRADES azul, PETS rosa, CONFIG cinza**. HUD de nível/XP, moedas, saco e meta do jardim.

A loja externa amarela é o **único fluxo principal de compra**. A aba **Equipamentos** do menu existe como inventário / consulta / equipar, não como segunda Loja concorrente. Upgrades não deve abrir falsamente a mesma Loja sem função distinta.

## Menu do Jogador — abas

1. **Perfil**: avatar, display, nível, XP, moedas, equipado, região, PH, segredos, tempo, grama.
2. **Habilidades**: árvore hexagonal funcional, seleção de nó, painel lateral, PH; integração com mapa.
3. **Equipamentos**: subcategorias Manuais, Cortadores, Especiais; lista owned + ação equipar, detalhes.
4. **Exploração**: mapa e progresso por região; cabana, ponte, floresta e futuros biomas.
5. **Missões**: ativas, disponíveis, concluídas, progresso individual.
6. **Configurações**: intensidade de câmera, vibração, som, qualidade simplificada, etc.

## Problemas visuais relatados

- No passado a barra de 4 ferramentas aparecia por cima da Loja e menu (corrigido em cópias, preservar).
- Menu/Config chegaram a mostrar abas vazias ou árvore inesperada; dependência entre controladores concorrentes.
- Perfil e Equipamentos/Habilidades ficaram visíveis simultaneamente: `Visible` e hierarquia de páginas conflitantes.
- Alguns modais cobriam HUD no topo com textos grandes.
- Barra de 4 ferramentas era **alta e invasiva**, principal pedido recente foi redução de ~20–30%; V9 tem ajuste de ~25% ainda não confirmado visualmente.
- Botão flutuante **NOVO SERVIÇO** era retângulo simples verde cobrindo personagem; pedido: **NPC jardineiro perto do lote**, diálogo/ProximityPrompt, balão mais bonito.
- Layout da árvore pode ficar excessivamente escuro/diminuto em telas grandes, e textos cortados no painel de detalhes.

## Componentes de qualidade

- `ScreenGui` separado para HUD, menus, lojas; **controlador de visibilidade único** e prioridade ZIndex planejada, sem 2 modais ativos ao mesmo tempo.
- Borda/contorno, cores e tipografia consistentes; estado *hover*, *pressed*, *disabled* e *selected* claros.
- Loja: grade responsiva com cards que não cortam texto/preço, scroll vertical independente, modal responsivo e `Close` sempre no safe area.
- Barra: slots 1–4, pequena, ícones bem centralizados e numeral com selo preto. Dimensões via `UIScale`/breakpoints; safe area mobile respeitada.
- Árvores: zoom e pan ancorados no centro, painel lateral fixo (PC) / inferior (mobile), texto com hierarquia/scroll; status bloqueado por requisito claro.
- Perfil: sem cartões vazios enormes; dados relevantes agrupados e botões que levam ao fluxo certo.
- Menus entram com 0,18–0,25 s `Quad/Cubic Out`; close com ~0,15 s; animações interrompíveis.

## Safe areas e acessibilidade

- Não cobrir controles de joystick/chat/CoreGui no mobile; usar `GuiService` safe insets/containers responsivos conforme APIs aplicáveis.
- Botões tocáveis >= ~44–48 px se viável, texto legível ao escalar; evitar elementos fixos em `Offset` gigantes em telefone.
- Contraste branco e contorno, label + ícone (não só cor), navegação por controle.
- Evitar desfoque global pesado, pós-processamento e transparências excessivas que reduzem FPS mobile.

## Princípio de compra

O modelo real da máquina exibida deve corresponder ao item comprado/equipado. Cards não devem anunciar modelos 3D exclusivos que não existem; pode haver fallback explícito **apenas para teste**, sinalizado no manifesto.


---

## SEÇÃO — Baús e itens
**Origem:** `brain/09_BAUS_ITENS_E_DESCOBERTAS.md`

# Baús, raridades, segredos, itens e coleta

## Assets existentes

ZIP `Entrega4_Itens.zip` inclui:

- **5 baús**: Comum, Incomum, Raro, Lendário, Mitológico (`.fbx` e cenas renderizadas).
- **5 máquinas**: Básico, Elétrico, Turbo, Trator, Mega (`.fbx`).
- **15 ferramentas manuais** (unha/enxada/foice × 5 raridades).

A V9 contém os cinco nomes de baú em modelos dentro do `.rbxl`; isso confirma presença, não funcionamento do prompt/loot.

## Raridade do baú — proposta aprovada

- **Comum: 60%**
- **Incomum: 25%**
- **Raro: 10%**
- **Lendário: 4%**
- **Mitológico: 1%**

**Essa é a distribuição CONDICIONAL ao sortear a raridade de um baú já gerado.** **Não** significa 60% de chance de baú comum em cada tufo cortado. Probabilidade de spawn e seleção de raridade são processos independentes. Combinar descobertas posicionadas à mão com drops ocasionais bem limitados.

## Fluxo alvo de baú

1. Mundo/servidor cria baú em local válido ou objeto secreto pré-posicionado está oculto.
2. O jogador corta os tufos que realmente o encobrem, ou acha pista.
3. Servidor registra descoberta individual (sem vazar outros secrets).
4. Baú emerge/revela com VFX curto, **em pé, apoiado no chão**.
5. ProximityPrompt deve ser perceptível no PC e touch/mobile; colocar âncora acima do baú, com linha de visão apropriada.
6. Servidor valida distância, jogador, direito, estado, loot e frequência; marca coletado de modo idempotente.
7. Animação de tampa, luz de raridade, som, feedback do item/moedas.
8. Atualizar inventário/PH/XP conforme tabela autorizada; persistir quando save ativo.

**Falha relatada:** baú visível que jogador não conseguia pegar. V8/V9 tentaram mover prompts, aumentar raio e corrigir `Style=Custom` sem UI custom; **testar in-game**. Modelos importados já tiveram problema de spawn deitado; verificar pivô e orientation `CFrame`.

## Segredos intencionais, não só sorte

- Caminho camuflado que revela uma placa, depois uma clareira.
- Tronco oco com moeda/item raro.
- Riacho que conduz a ponte quebrada.
- Pedra com símbolo vista após limpar matagal.
- Baú semioculto nas raízes de árvore antiga.
- Objetos antigos da missão de Zeca (3 itens), com ids únicos por jogador.
- Pedestal/artefato na clareira secreta.

Mínimo MVP útil: 3 segredos diferentes, um baú interativo por raridade básica, uma trilha revelável e uma cena de descoberta da cabana. Não espalhar tesouros flutuantes ao acaso.

## Regras de loot a definir

- Chance de spawn de baú por corte (baixa, calibrada por tempo de sessão).
- Tabelas de recompensas por raridade, com limites de recursos.
- Respawn por jogador/servidor e persistência.
- Se recompensas de grupo serão por participação ou individualmente.
- Como valores raros influenciam economia e PH (evitar power creep).

Até definição, usar defaults conservadores em ambiente de teste, não fabricar chance/probabilidade como regra aprovada.


---

## SEÇÃO — Arquitetura e dados
**Origem:** `brain/10_ARQUITETURA_E_DADOS.md`

# Arquitetura Roblox/Luau, dados e segurança

## Situação técnica observada

A V9 tem `ReplicatedStorage` com módulos `ConfigJogo`, `Shared/FerramentasConfig`, `Shared/SkillDefinitions`, `Shared/GrassConfig` e outros; no servidor aparecem `GameServer`, `FerramentasServer`, `SkillService`, `SkillMechanics`, `DadosJogador`, `Profiles`, `Economia`. No cliente: `InterfaceHUD`, `PlayerMenuController`, `SkillActionBar`, etc. Há versões `*_backup_*` e fontes antigas conservadas dentro do mesmo arquivo.

**Risco arquitetural:** duas famílias de sistemas de economia (`GameConfig` vs `ConfigJogo`) e controllers de árvore diferentes podem coexistir; auditar referências, scripts ativos, remotes e condições de uso. Evitar nova reescrita monolítica.

## Modelo desejado (adaptar ao que já existe)

```text
ReplicatedStorage/
  Shared/ConfigJogo | FerramentasConfig | SkillDefinitions | GrassConfig
  Remotes/ ... (um conjunto estável e documentado)
ServerScriptService/
  CorteEDescubra/
    GameServer (orquestração fina)
    Services/Inventory, Cutting, Forest, Skill, Chest, Quest, Save, Equipment
StarterPlayer/StarterPlayerScripts/
  EquipmentController, AnimationController, MenuController, SkillUI
ServerStorage/
  GameAssets/
    Mowers, Ferramentas, Baus, GrassPack, ForestModular
Workspace/
  GameWorld/ (vila e lotes já existentes)
  Regions/Forest/ (quando construir a região persistente)
```

A hierarquia é **uma meta de organização**, não substituir pastas atuais sem migração.

## Autoridade do servidor

- Cliente envia `UseTool(toolId, action)` ou amostras não confiáveis; servidor usa estado validado, posição física legítima e regras de alcance/cooldown.
- Loja pede compra de `itemId`; servidor busca preço na definição, valida moeda, posse e transação atômica.
- PH e habilidades: `SkillService` controla ponto/rank/estado e se é comprável; ativação com cooldown.
- Baús: o servidor define a raridade e loot, valida interação, marca fonte de recompensa consumida.
- Progressão: evitar 2 scripts creditarem XP pelo mesmo corte. Uma única rota de recompensa com chave idempotente.
- Área compartilhada: não permitir jogador farmar ou destruir o terreno privado de outro.

## Persistência

`GameConfig.PersistenceEnabled=false` **foi encontrado no arquivo V9**. Isso significa que **não se pode prometer salvamento permanente**. Também existe `DadosJogador`/`Profiles`: auditá-los antes de qualquer toggle.

Dados-alvo do perfil:

- `schemaVersion`, moeda, XP/nível, saco.
- Ferramentas compradas, raridade, slot equipado.
- PH concedidos/gastos, ranks, fontes de recompensa já pagas.
- Baús/segredos descobertos, missões, itens coletados.
- Marcos de restauração e regiões conhecidas.
- Preferências UI/câmera/som se aprovadas.

Migrar com versão de schema e defaults; não sobrescrever perfil em falha de DataStore; usar `UpdateAsync`/controle de sessão apropriado e testes com perfis seguros; respeitar limites de requisição Roblox.

## Multiplayer / escolha pendente

- **Vila e estradas:** compartilhadas.
- **Quatro terrenos privados:** ação e recompensas por dono.
- **Floresta:** aparência do mato, revelações e construções podem ser compartilhadas ou por jogador; decidir antes de publicar. Uma abordagem híbrida permite cenário compartilhado + estados de progresso/recompensa individuais.
- **Reparo de ponte:** o direito/recompensa pode ser individual e a geometria compartilhada por sessão; evitar griefing.

## Performance

- Não usar `Touched` em cada folha nem `Heartbeat` independente em cada clump.
- Spatial hash / região / hit sweep para corte, pooling de efeitos e carregamento por distância.
- Validação de raycasts/overlaps e colliders simples para obstáculos.
- Revisar NetworkOwnership e física da máquina; o visual pode ser client-driven enquanto corte/recompensa ficam no servidor.
- Benchmarks PC, mobile intermediário, mobile de entrada, 2+ jogadores; medidas de FPS e memória.

## Testes mínimos

- Compra idempotente e sem saldo negativo.
- Saco não fica `0/1` após inicialização.
- XP não duplica por ataque ou por respawn.
- Carrinho não some na troca/respawn, hitbox usa lâmina.
- Baú abre no PC e celular; coleta exatamente uma vez.
- Uma habilidade `Ready` altera gameplay; uma `Planned` não pode ser adquirida.
- Fechar menu restaura HUD/controles; não gera overlays.
- Reconexão preserva dados **somente após habilitar/migrar corretamente**.


---

## SEÇÃO — Assets e Blender
**Origem:** `brain/11_ASSETS_E_BLENDER.md`

# Assets, Blender e pipeline de importação

## Arquivos locais conhecidos (2026-11-09)

- `Entrega4_Itens.zip`: 5 baús FBX + 5 cortadores FBX + 15 ferramentas FBX + `.blend` fonte, script Python, renders/README.
- `CorteDescubra_GrassPack.zip`: `.blend`, `generate_grass.py` ou scripts correlatos, GLBs de 3 estados/LODs, renders, manifesto e README.
- `FlorestaEsquecida.blend`: diorama/asset scene de floresta.
- `FlorestaEsquecida_Refinada_v2.blend`: refinamento incremental; script anterior criou coleção `CD_REFINO_V2`, podendo gerar erro em reexecução.
- Múltiplas cópias `.rbxl` v1–v9, com V9 última local, **não automaticamente baseline oficial**.

**Esses arquivos NÃO estão automaticamente incluídos neste repositório BRAIN.** Se forem subir ao GitHub, considerar Git LFS e licença/permissão; usar manifesto com nome/hash. Nunca inventar asset IDs.

## Inventário de modelos

| Kit | Quantidade conhecida | Principal pendência |
|---|---:|---|
| Máquinas | 5 FBX | Pivô, guidão, lâmina, cada motor/veículo funcional |
| Ferramentas manuais | 15 FBX | Montagem 2 mãos, animações, raridade real |
| Baús | 5 FBX | orientação, base/tampa, prompt, abrir/loot |
| Grama | GLB de TALL/SHORT/STUBBLE + LODs | importação real e instanciamento no lobby/floresta |
| Floresta | Blender com árvore/cabana/ponte/props | converter diorama em **kit modular**, não exportar ilha gigante |

## Regra do kit modular

Cada item precisa de:

- Prefixo estável: `TREE_*`, `Grass_*`, `Cabana_Abandonada`, `Cabana_Restaurada`, `Bridge_Broken`, `Bridge_Restored`, etc.
- Pivô na base, orientação frontal documentada e escala consistente.
- `Collision` simplificada; vegetação geralmente `CanCollide=false`.
- LOD ou variações leves e poucos materiais; estética stylized low-poly.
- Originais `.blend` e `.py`, exports `.glb`/`.fbx`, preview, manifesto.
- Checagem no Studio com modelo humano comparando escala.

## Árvores — novo kit necessário

Anteriormente as árvores ficaram como troncos retos e bolas/cones; a última floresta mostra pinheiros triangulares repetidos. Novo kit recomendado: `TREE_SMALL_01/02`, `TREE_MED_01/02`, `TREE_TALL_01/02`, `TREE_CROOKED_01`, `TREE_DEAD_01`, mais 2–4 variações grandes orgânicas, tocos e troncos caídos. Distribuir por grupos e alternar cor, tamanho e orientação sem parecer clone.

## Cabana e ponte

A cabana Blender possui conceito de **abandonada/restaurada**; houve tentativas de exportação, não comprovação de integração final. Deve substituir uma cabana provisória somente quando importada e testada. Ponte quebrada/restaurada com colliders adequados, sem tábuas flutuantes.

## Fluxo recomendado

`Blender (fonte + pivôs) → export FBX/GLB → Studio Import 3D → checar hierarquia MeshParts → ajustar PrimaryPart/attachments → prefab sob ServerStorage → montar região modular → teste de escala/performance → conectar lógica/recompensas`.

**Não modelar uma floresta gigante como malha única.** Montagem ambiental, iluminação, pathing e células de corte são do Roblox Studio.


---

## SEÇÃO — Bugs e testes
**Origem:** `brain/12_BUGS_RISCOS_TESTES.md`

# Bugs, riscos, diagnóstico e aceitação

**Regra:** cada bug deve ter `ID`, `build`, `passos para reproduzir`, `resultado observado`, `esperado`, `Output`, `evidência`, `status` e `responsável`. Não marcar resolvido sem Play validado.

## Quadro de regressões

| ID | Severidade | Evidência / problema | Status inicial |
|---|---|---|---|
| `BUG-001` | P0 | Carrinho sumia ao selecionar slot 4; screenshot saco `0/1` | V9 tem correção escrita, **Play pendente** |
| `BUG-002` | P0 | Script V8 do NPC tinha texto Lua quebrado por newline e escopo inadequado; inicialização afetada | V9 relata correção estrutural; **regressão precisa Play** |
| `BUG-003` | P1 | Foice com pegada rígida; animação pouco convincente e ataque anterior duplicava objeto | V9 procedural melhorada, **aprovação visual pendente** |
| `BUG-004` | P1 | Baú visível, não coletável; prompts possivelmente custom invisíveis | Correção escrita; testar E/toque/distância/loot |
| `BUG-005` | P1 | Baú spawnando deitado, pivô mal orientado | Ajustes prévios experimentais; testar todos os 5 modelos |
| `BUG-006` | P1 | Árvore de habilidade, Perfil e Equipamentos sobrepostos | Correções de visibilidade nas cópias, **mobile/Play pendente** |
| `BUG-007` | P1 | Loja e hotbar sobrepostas; menus duplicados abrindo UI errada | Corrigido visualmente segundo o usuário em uma versão, manter em regressão |
| `BUG-008` | P1 | HUD Jardim 0/64 permanecia na floresta | Código contextual inserido em build experimental; validar |
| `BUG-009` | P1 | Floresta parece plantação de pinheiros, vazia e sem atmosfera; usuário não aprovou | **ABERTO — prioridade artística** |
| `BUG-010` | P1 | Persistência `false` no arquivo de referência; progressão perde estado entre sessões | **ABERTO / não ativar sem auditoria** |
| `BUG-011` | P2 | Botão Novo Serviço como overlay simples e invasivo; pedido NPC próximo ao jardim | NPC experimental na V8/V9, validar local e fluxo |
| `BUG-012` | P2 | Barra de ferramentas ocupa tela demais | V9 reduziu ~25%, validar mobile |
| `BUG-013` | P2 | Evolução de ferramentas por raridade modelada, mas sem sistema de compras/save totalmente testado | **PARCIAL/PLANEJADO** |
| `BUG-014` | P2 | Grama em quadrados/muito baixa em alguns protótipos | Cortes orgânicos e visual de Área de Teste ainda precisam unificação |

## Testes de corte e animação

- `1` unha: agachar/cortar somente dentro da janela; XP atribuído no servidor.
- `2` enxada: ferramenta real segue duas mãos e golpe frontal; sem foice fantasma.
- `3` foice: arco lateral real, sem atingir atrás, som/partículas no momento correto.
- `4` carrinho: visível, rodas apoiadas, mãos no guidão, grama cortada pela lâmina ao movimentar.
- Trocar `3→4→2→4`, respawn, lag, caminhar sem atacar, apertar F repetidamente.
- Trator e Mega: verificar se comportamento não é um carrinho soldado ao corpo sem direção própria.

## Testes de UI

- Menu, Config, Habilidades, Equipamentos, Exploração, Missões, Loja, Pets em PC e emulador smartphone.
- No máximo **um** modal principal visível; hotbar oculta durante modal; `Close/Esc` limpa overlay e devolve controle.
- Selecionar habilidade e voltar ao Perfil; nenhum elemento anterior visível por trás.
- Loja amarela compra; aba Equipamentos apenas consulta/equipa, sem cobrança duplicada.
- Texto e botões dentro de safe areas; botão NPC Novo Serviço não tapa personagem.

## Testes de baú/segredos

- Baú fica em pé sobre chão irregular e não flutua.
- Prompt aparece em PC e mobile; `E`/toque abre uma vez.
- Baú previamente revelado não cria recompensa duplicada após reconexão/respawn/corte repetido.
- 5 raridades com prefabs corretos; chance de baú ≠ chance de raridade.

## Testes da floresta

- Entrada contínua sem teleporte abrupto; não interrompe a vila.
- Mato alto usado da Área de Teste; densidades variadas; caminho revela pistas e cabana.
- Segredos funcionam e não são todos visíveis de uma só vez.
- Riacho, ponte e cabana estão conectados ao chão, sem peças soltas.
- FPS estável em dispositivo móvel e 2–4 jogadores.
- Iluminação da floresta não escurece lobby para outros jogadores.

## Critério de fechamento

`VALIDADO_EM_PLAY` somente após verificação no Roblox Studio com pelo menos **vídeo/screenshot/log** e build identificada. `INTEGRADO_NO_RBXL` não significa que está pronto. Registrar data do teste e IDs de commit/asset.


---

## SEÇÃO — Roadmap
**Origem:** `brain/13_ROADMAP.md`

# Roadmap — fatias pequenas, entregas verificáveis

Esta sequência incorpora prioridades do usuário até 2026-11-09. Ajustar ao estado da baseline escolhida.

## P0 — Estabilizar a baseline (obrigatório antes de expandir)

- Identificar versão principal do Claude/Studio e comparar V9; backup e branch.
- Conferir game init e `PersistenceEnabled`; separar scripts ativos de backups.
- Testar carrinho presente, saco normal, hitbox de lâmina, foice/enxada/unha, troca, respawn.
- Testar baús e prompts em PC/touch e lucro não duplicado.
- Testar UI sem sobreposições com hotbar menor.

**Entrega P0:** baseline testada 15–20 min com checklist + logs e ao menos um vídeo de foice/carrinho.

## P1 — Floresta Esquecida (maior desejo atual)

1. Criar blocagem por setores e trilhas sinuosas (não mover vila).
2. Kit modular de árvores orgânicas: ~8–12 variações e sub-bosque.
3. Substituir distribuição regular de pinheiros e corrigir terreno/visibilidade.
4. Usar mato alto da Área de Teste com sistema de corte/recompensa existente.
5. Cabana real do Blender como hero asset e primeiro segredo revelável.
6. Riacho/ponte com geometria correta e rota visível.
7. 3 segredos **funcionais**, mais 3–7 como extensão posterior; teste de baú no matagal.
8. Transição local suave de luz/áudio da vila para floresta; testes mobile.

**Entrega P1:** uma área jogável de floresta de 5–10 min com início, meio e recompensa, aprovada por screenshot/vídeo do usuário. Só então expandir.

## P2 — Progressão de descoberta

- NPC Zeca e primeira missão; 3 itens escondidos, descoberta da cabana.
- Feedback de restauração antes/depois com itens de inventário.
- Mapa de exploração na aba, descobertas persistentes, marcadores sem spoilers.
- Conectar Cartógrafo/Detector à floresta após implementação real e testes.

## P3 — Economia / loja / habilidades em produção

- Telemetria de XP/min, moeda/min, recompensas e ritmo por ferramenta.
- Ativar save com migração e rollback/teste com múltiplas sessões.
- Garantir compra apenas de habilidades com mecânica real. Implementar previstos por ciclos.
- Loja: catálogo e visuais 3D coerentes, raridades das ferramentas manuais, não multiplicadores vazios.
- Baús: loot tables, rarity/roll e proteções anti-farm.

## P4 — Mundo futuro

- Fazenda Abandonada e Rodas Off-Road.
- Parque do Lago.
- Ruínas Antigas / padrões cortados / Mistérios.
- Contratos cooperativos / decoração e oficina.

## Risco de cronograma

É melhor concluir **uma floresta pequena porém densa e com 3 descobertas reais** do que uma floresta enorme com centenas de árvores iguais, sem narrativa nem performance. Trabalhar em fatias verticais: arte + gameplay + UI + reward + teste.


---

## SEÇÃO — Histórico de decisões
**Origem:** `brain/14_HISTORICO_DECISOES.md`

# Histórico de decisões e experiências

Este registro resume a conversa em vez de afirmar que cada passo foi publicado.

## 2026-11-03 a 2026-11-04 — Assets e sistemas iniciais

- Desenvolvimento de `Entrega4_Itens.zip`: modelos FBX de 5 baús, 5 cortadores e 15 ferramentas manuais.
- Desenvolvimento do `CorteDescubra_GrassPack.zip`: grama TALL/SHORT/STUBBLE, LODs e Blender.
- Ideias de progressão por raridade e sistema de baús foram definidas.

## 2026-11-08 / 09 — Interface e progressão

- Evolução visual de menu do jogador, Perfil, Habilidades, Equipamentos, Exploração, Missões e Config.
- Referência de árvore hexagonal; 19 nós com cinco ramos. Alguns nós ganharam comportamento em código; outros continuam Planned.
- Usuário identificou sobreposição de UI, Loja duplicada, bugs de Config e selecionou a **Loja amarela externa** como única loja principal.
- Propostas de prompts para Claude/Codex, ajustes diretos em `.rbxl` de teste.

## Experimentos `.rbxl`

- V1: primeira montagem de floresta separada; muito provisória.
- V2: corte pela lâmina/carrinho e export cabana; Play não executado aqui.
- V3: correção de formas erradas de Parts que apareciam como esferas; matagal precisava refinamento.
- V4: ferramentas manuais/novas árvores.
- V5: HUD e tentativa de correção de animação duplicada.
- **Usuário pediu para desconsiderar V1–V5 e voltar à origem com Claude.** Esta decisão continua importante: não reutilizar esses scripts como base sem autorização.
- Depois, usuário enviou `backup - cópia 2.rbxl`; a partir dela vieram correções UI e builds V6–V9, todas experimentais.
- V6: loja, baús, árvore.
- V7: floresta gerada no Play, baús/segredos, integração no corte.
- V8: NPC do serviço, novos cortadores e prompts; bug de inicialização/sintaxe detectado depois.
- V9: correções de sintaxe do NPC, carrinho, IK, foice procedural e hotbar ~25% menor. **Apenas integridade/arquivo; Play não comprovado**.

## Feedback artístico mais recente

- Usuário mostrou floresta com **pinheiros geométricos idênticos em espaçamento regular e cabana distante**.
- Avaliação acordada: cenário ainda sem direção artística; precisa layout por setores, árvores de silhuetas diferentes, sub-bosque e caminhos curvos.
- Novo prompt de reformulação visual enviado ao Claude, mas o arquivo/resultado posterior ainda não foi analisado como código.

## Decisões que NÃO devemos perder

1. Nome/conceito principal é **Corte & Descubra**, não “Puxe as Ilhas”.
2. O diferencial é exploração e restauração escondida sob o mato, não grama por grama apenas para moedas.
3. **Aparência do matagal da Área de Teste** agrada ao usuário; usar como guia visual da floresta.
4. **Blender para assets modulares; Roblox Studio para montagem e gameplay**.
5. Loja amarela externa prevalece; Equipamentos é inventário.
6. Nunca deixar ferramentas cortar só pelos pés/corpo.
7. Foice deve ter animação real de ceifar, carrinho empurrado pelo guidão.
8. Árvore tem de liberar mecânicas funcionais, com PH reais, e se conectar ao mapa de descoberta.
9. Versões descartadas não devem ser reintroduzidas sem comparação e autorização.
10. Não alegar save ou testes concluídos sem prova.


---

## SEÇÃO — Sincronização IA
**Origem:** `brain/15_SINCRONIZACAO_DAS_IAS.md`

# Como duas ou mais IAs usam o MESMO BRAIN pelo GitHub

## O que funciona de verdade

O GitHub funciona como **base documental versionada**; cada IA autorizada pode consultar e atualizar os mesmos arquivos. O histórico fica auditável e mudanças são propagadas assim que a outra IA faz `pull`/`fetch`.

**Não é memória automática nem chat entre IAs.** As IAs não acompanham commits continuamente sem uma integração/agendamento próprio, e não compartilham instantaneamente estados internos. Para sincronização confiável, **cada IA deve ler no começo e escrever ao fim** de sua sessão, ou o agente deve ser configurado para acionar o GitHub nesses gatilhos.

## Acesso necessário

1. Criar repositório privado `roblox-cut-and-discover-brain` no GitHub (separado do código do jogo, opcionalmente com links para ele).
2. Convidar colaborador/amigo com permissão adequada (idealmente `Write`, sem Admin por padrão).
3. Cada IA precisa de sua própria ferramenta/conector GitHub autenticado na conta autorizada ou de trabalhar localmente via Git.
4. Nunca compartilhar tokens/chaves em chat ou no BRAIN. Concessão explícita de acesso por conta.

## Protocolo obrigatório: início

1. Identificar `repository`, `branch` e último commit no GitHub.
2. Ler `AGENTS.md`, `brain/00_START_HERE.md`, `brain/02_ESTADO_REAL_E_VERSOES.md`, `brain/status.json` e últimas entradas de `handoffs/LOG.md`.
3. Ler docs específicos da tarefa e qualquer issue/PR relacionada.
4. Confirmar baseline `.rbxl`/commit **real do Roblox** e diferença entre estado anterior e atual.
5. Não adotar fatos “Ready” como testados em Play sem evidência.

## Protocolo obrigatório: fim

1. Registrar arquivos mudados e commit de código/asset do jogo, build, screenshots ou logs de teste.
2. Atualizar documentação afetada, `tasks/BACKLOG.md`, `brain/status.json` e `handoffs/LOG.md`.
3. Abrir PR e pedir revisão para mudanças de arquitetura/estado; alterações pequenas podem ir direto ao `main` se combinadas.
4. Nunca sobrescrever mudanças da outra IA sem `fetch`/merge; usar `sha` ao atualizar arquivos por API.
5. Marcar o trabalho `IMPLEMENTADO_NAO_PLAYTESTADO` quando só se inspecionou ou alterou código.

## Como usar com ChatGPT

No chat conectado ao GitHub, pedir: **“Leia o repositório `owner/roblox-cut-and-discover-brain`, sobretudo AGENTS.md, BRAIN, status e handoffs, antes de continuar. Ao finalizar, atualize os arquivos e registre testes.”** O ChatGPT poderá usar as ações de leitura/escrita que sua conexão permitir. Não assumirá o conteúdo atualizado de outra conversa até consultá-lo.

## Como usar com Claude/Claude Code/Codex

- No diretório de trabalho, `git clone` do BRAIN ou incluir como diretório de documentação/submódulo, sem trocar código original de jogo.
- Arquivos `CLAUDE.md`/`AGENTS.md` instruem leitura/atualização; conferir configurações do seu agente para obedecer a esses arquivos.
- Ao terminar tarefa, abrir commit/PR com handoff. Se a IA não tem acesso ao GitHub, entregar `*.md` com mudanças para um humano publicar; **não afirmar sync automático**.

## Edição simultânea

- Uma task/issue por recurso, branch distinta por IA (`ai/claude-forest-art`, `ai/chatgpt-ui-fix`, etc.).
- Não modificar `brain/status.json` em paralelo sem rebase/merge; revisão humana quando duas evidências se contradizem.
- Resolver conflito por **arquivo do projeto atual + teste + decisão do usuário**, não pela IA que escreveu por último.

## No futuro: automação real de sincronização

Integração OPCIONAL via GitHub Actions pode validar Markdown/JSON/links e avisar sobre PRs. Ações **não** fazem a IA aprender automaticamente novas mudanças; para isso é necessário conectá-la ao repositório e disparar leitura em sessões/gatilhos. Não inventar “cérebro com memória instantânea” sem infraestrutura.


---

## SEÇÃO — Perguntas abertas
**Origem:** `brain/16_QUESTOES_ABERTAS.md`

# Questões abertas — validar antes de afirmar

- **Qual é a baseline oficial atual?** Projeto Claude original, `backup - cópia 2`, V9 ou outro `.rbxl` posterior? O usuário precisa escolher/fornecer.
- O jogo publicado atualmente usa **qual** módulo de economia (`ConfigJogo` ou `GameConfig`) em cada fluxo?
- `PersistenceEnabled=false` ainda está ativo no place que o usuário joga? Quando/como será habilitado com migração?
- As três ferramentas manuais comuns são livres para sempre ou desbloqueadas por missões/loja? A V9 dá kit inicial, mas progressão de design original previa desbloqueio gradual.
- Foice, enxada e carrinho de fato cortam por hitbox real e ficam animados corretamente nos avatares usados?
- Qual o modelo e assets da cabana Blender corretos, e foram importados no place principal?
- Status real de 54/70 modelos de grama importados. Quais são os assets IDs válidos no place atual?
- Visibilidade do mato da floresta: individual por jogador ou compartilhada? Como evitar competição/griefing?
- Regras de restauração de cabana e ponte em mundo multiplayer?
- Distribuição efetiva de drop de baú, loot table por raridade e limite de recompensa?
- Quais das oito habilidades `Ready` já foram **validadas em Play**? Quais continuam protótipos?
- `Drone Jardineiro` precisa novo modelo? `Rodas Off-Road` depende da Fazenda, ainda planejada.
- NPC “Novo Serviço” pertence a cada lote? Zeca da floresta é NPC diferente.
- Ajustes mobile/safe areas foram verificados em iOS/Android reais?
- A prioridade de agora é apenas reformular a floresta ou também polir animações, economia e UI antes?

**Agentes:** não bloquear um trabalho simples por causa de todas essas perguntas; apenas registrar dúvidas pertinentes à sua tarefa e fazer a melhor auditoria possível.


---

## SEÇÃO — Backlog
**Origem:** `tasks/BACKLOG.md`

# Backlog compartilhado — prioridades e status

**Snapshot:** 2026-11-09. Status sem evidência de Play permanece não validado. Cada issue técnica deve referenciar `.rbxl`/commit base.

## P0 — Estabilização

- [ ] **P0-01** Confirmar baseline oficial atual (comparar cópia Claude/Studio com V9), backup e branch.
- [ ] **P0-02** Testar inicialização e saco normal em Play; investigar `0/1` e regressão V8.
- [ ] **P0-03** Testar slot 4/carrinho, rodas, guidão, corte físico e respawn em PC/mobile.
- [ ] **P0-04** Testar foice/enxada/unha R15, ferramentas reais e hitbox; gravar vídeo.
- [ ] **P0-05** Baús: prompt E/touch, orientação e idempotência de recompensa.
- [ ] **P0-06** UI: uma única aba/modal, hotbar oculta ao abrir Loja, responsividade.
- [ ] **P0-07** Auditar saves e `PersistenceEnabled=false`; planejar migração e testes de reconexão.

## P1 — Floresta Esquecida (principal foco de arte e gameplay)

- [ ] **P1-01** Redesenhar *blockout* por setores, caminho sinuoso + visão revelada gradualmente.
- [ ] **P1-02** Criar/importar kit de 8–12 árvores irregulares, samambaias, raízes, troncos e moitas.
- [ ] **P1-03** Substituir pinheiros clonados/arranjados em linhas; melhorar densidade e sombras.
- [ ] **P1-04** Espalhar **grama alta da Área de Teste** com três estados e corte server-authoritative.
- [ ] **P1-05** Integrar cabana abandonada/restaurada do Blender como hero asset.
- [ ] **P1-06** Riacho/ponte quebrada + clareira secreta + 3 segredos com recompensa testada.
- [ ] **P1-07** Transição orgânica Vila→Floresta com áudio/luz locais, sem escurecer outros jogadores.
- [ ] **P1-08** Teste visual com screenshot/vídeo e FPS mobile; colher aprovação do usuário.

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
- [ ] Tratores como veículos e modelos exclusivos OffRoad/Colheitadeira/Imperial.
- [ ] Fazenda, Parque do Lago, Ruínas e segredos maiores.
- [ ] Otimização multiplayer/mobile com perfil de performance.

**Como atualizar:** marcar `[x]` só após terminar, com link de issue/PR + evidência; ao contrário, anotar `IMPLEMENTADO_NAO_PLAYTESTADO` em texto.


---

## SEÇÃO — Manifesto de artefatos
**Origem:** `assets/MANIFESTO.md`

# Manifesto de artefatos locais conhecidos

> Evidência da sessão 2026-11-09. Os binários **não são automaticamente incluídos no repositório BRAIN**. SHA-256 serve para reconhecer cópias; não prova que o arquivo é production.

| Arquivo local | Tamanho | SHA-256 |
|---|---:|---|
| `CorteEDescubra_v9_Carrinho_Foice_HUD.rbxl` | 1,142,000 bytes | `2cf07fd6e54215ffcfe0ac3d6dd301a7367f5d410ea485e4686bc0dc41d015fb` |
| `CorteEDescubra-backup - cópia 2.rbxl` | 1,108,289 bytes | `f6458a84c006c6c7bb6f629e5caed21271b555d0d90e92f29d387451256139a8` |
| `Entrega4_Itens.zip` | 11,356,683 bytes | `8d1cab0b81d48c677c9d5d9f81ba3112a05e8c97d5219ed59074326d7a1719c1` |
| `CorteDescubra_GrassPack.zip` | 10,792,309 bytes | `354cca0003e79e5e4928d543f9852a456438929d86390ec8ecb71bd150a5541a` |
| `FlorestaEsquecida.blend` | 1,074,723 bytes | `1e80907ac1cc274266bcf65903b112fc737e9844e982abb94a22f2d0036f3224` |
| `FlorestaEsquecida_Refinada_v2.blend` | 1,129,455 bytes | `4b9308ef474d7299d920f0007bba98413825c858b2ff5c9dd6033d8787be380b` |

## Política de armazenamento

Não fazer commit de `.rbxl`, `.blend`, `.fbx`, `.glb`, vídeos e ZIPs no repositório textual sem aprovação. Usar Git LFS ou um repositório de assets privado quando necessário. `assets/MANIFESTO.md` deve rastrear nomes/hashes/versões e localização autorizada.

Importante: arquivos `.rbxl` editados pelo ChatGPT em V1–V9 são **builds experimentais**, não uma cadeia de produção certificada.


---

## SEÇÃO — Regras compartilhadas
**Origem:** `AGENTS.md`

# AGENTS.md — Contrato para ChatGPT, Claude, Codex e outras IAs

## Você está no projeto Corte & Descubra

Jogo Roblox de **cortar vegetação para revelar um mundo esquecido**, com jardim pessoal, ferramentas e máquinas progressivas, árvore de habilidades, baús, exploração, restauração e segredos. Leia `README.md`, `brain/00_START_HERE.md`, `brain/02_ESTADO_REAL_E_VERSOES.md` e `handoffs/LOG.md` **antes de alterar qualquer coisa**.

### Fonte de verdade e confiança

- **1º** arquivo `.rbxl`/`.rbxlx` real selecionado como baseline pelo usuário, assets e código do projeto atual.
- **2º** testes dentro do Roblox Studio com logs, screenshots/vídeos e relato do usuário.
- **3º** decisões em `decisions/` e estado documentado neste repositório.
- **4º** propostas antigas, prompts e código experimental **não** aceito.
- Nunca converta **PLANEJADO** em **IMPLEMENTADO/TESTADO** por inferência.
- Sempre registre `data`, `arquivo/commit base`, `arquivos modificados`, `testes feitos`, `testes pendentes`, `risco` e `próxima ação`.

### Regras inegociáveis

1. **Não recriar o jogo do zero.** Preservar vila, quatro terrenos, grama, moeda, XP, PH, loja, equipamento, árvore, menus, dados e missões funcionais.
2. **Nunca misturar builds experimentais v1–v5** com a baseline escolhida; a V6–V9 também exige confirmação do usuário para servir de baseline.
3. Auditar hierarquia do Roblox Explorer, scripts ativos (versus backups), dependências, RemoteEvents e modelo real antes de editar.
4. **Servidor autoritativo** em compras, desbloqueio de habilidades, recompensas, corte, baús, posicionamento válido e estado de missões.
5. Não duplicar tool visual ou cortar grama pelos pés. Cortador empurrável usa posição da lâmina; foice/enxada/unha precisam de golpes próprios.
6. Não criar `AnimationId`, `SoundId`, `MeshId` fictício. Se faltar importação/publicação, documentar pendência real.
7. Sempre preservar/exigir plano de migração de save; `PersistenceEnabled=false` foi observado na V9 — não afirmar persistência ativa sem confirmação.
8. Otimizar mobile/controle. Evitar um script por tufo, partículas excessivas e colisão em folhas.
9. Respeitar o **design system** colorido, cartoon, de contornos escuros; não trazer overlay genérico escuro que conflite com a Loja.
10. Trabalhar em **etapas pequenas**, testáveis, com backup/branch. Não afirmar Play se apenas verificou integridade estática.
11. Propostas de lore/segredos devem preservar surpresa do jogador; não expor coordenadas escondidas ao cliente.
12. Não salvar tokens, senhas, URLs de webhooks privados ou informações pessoais neste repositório.

### Como iniciar uma sessão

- `git pull --ff-only` se trabalhando localmente; caso contrário, `fetch` dos arquivos atuais pelo conector GitHub.
- Ler `brain/status.json` e `handoffs/LOG.md` para mudanças recentes.
- Conferir versão base contra o projeto Roblox realmente aberto.
- Abrir tarefa/issue se não existir, anotar escopo e hipótese.
- Trabalhar somente no escopo autorizado; fazer commit/PR com evidências.

### Como encerrar a sessão

1. Atualizar `brain/status.json` **somente com fatos verificados**, sem inventar resultado.
2. Atualizar `tasks/BACKLOG.md` e documentos afetados.
3. Adicionar entrada com data/IA/artefato/testes no topo de `handoffs/LOG.md`.
4. Se mudou arquitetura/regra de design, criar novo ADR em `decisions/`.
5. Fazer commit ou PR. Outra IA deve poder reproduzir os passos sem conversar com quem fez.

### Convenção de estados

- `CONFIRMADO_EM_ARQUIVO`: existe no `.rbxl`/asset inspecionado.
- `RELATADO_PELO_USUARIO`: screenshot ou teste relatado.
- `IMPLEMENTADO_NAO_PLAYTESTADO`: código presente, comportamento não validado em Play.
- `VALIDADO_EM_PLAY`: execução real reproduzida em Studio com evidência.
- `PLANEJADO`: intenção/feature solicitada.
- `BLOQUEADO`: dependência ausente ou bug impeditivo.
- `DESCONTINUADO`: experimento explicitamente abandonado.

### Guia para ferramentas de IA

- **Claude:** `CLAUDE.md` redireciona para este arquivo. Não duplicar regras divergentes.
- **Codex:** seguir `AGENTS.md` e registrar alterações no BRAIN.
- **ChatGPT:** usar conexão GitHub para ler/atualizar os arquivos a cada sessão relevante; **não** assumir leitura em tempo real sem chamada ao GitHub.
- **IA do amigo:** acesso GitHub explícito, ler e atualizar no mesmo repositório. Em caso de edição simultânea, usar PRs e reconciliar conflitos.
