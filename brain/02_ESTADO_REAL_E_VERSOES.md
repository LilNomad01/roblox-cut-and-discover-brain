# Estado real, evidência e builds

> **Atualização 2026-11-10 — baseline de trabalho confirmada pelo usuário:** place `106412085364108` (universe `10775723165`) aberta no Studio. Ela é da mesma linhagem da V9, mas **não é idêntica** (contém comércio da floresta, `ForestTreeKit`, `ForestGrassClient` e backups de 2026-11-10). Mapa completo em [18 — Mapa técnico da baseline](18_MAPA_TECNICO_BASELINE.md). Publicação e salvamento do estado atual **não confirmados**. O restante deste capítulo descreve a V9 como **histórico**.

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
