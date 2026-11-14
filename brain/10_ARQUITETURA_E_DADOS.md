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

`GameConfig.PersistenceEnabled=false` **foi encontrado no arquivo V9** e **confirmado na place de trabalho em 2026-11-10**. Isso significa que **não se pode prometer salvamento permanente**.

**Auditoria estática 2026-11-10 (place de trabalho):** `DadosJogador` **não** é um segundo save; ele só atende a compra da loja. O save real é `CorteEDescubra.Profiles` (`UpdateAsync`, lease de sessão de 180 s, retry, `DataStoreName="CorteEDescubra_v1"`), com `ProfileData` migrando `schemaVersion` 1→2 e validando `Economy`, `SkillData` e `ForestEconomy`. Segredos da floresta usam `claimed[UserId]` em memória: migrá-los para o perfil antes de ligar o save. Detalhes em [18 — Mapa técnico](18_MAPA_TECNICO_BASELINE.md).

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
