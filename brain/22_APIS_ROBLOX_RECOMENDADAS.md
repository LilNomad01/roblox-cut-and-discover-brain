# APIs da Roblox que podem melhorar o jogo (pesquisa de 2026-11-13)

**Pedido do usuário:** "busque por API's que podemos usar para melhorar o jogo".
**Como foi feita:** pesquisa em fontes oficiais (create.roblox.com e anúncios no DevForum), feita por um subagente do Claude. O que não deu para confirmar está marcado como **não verificado**.
**Situação:** é só pesquisa. Nada aqui foi implementado nem testado no jogo.

## Top 15, por impacto no Corte & Descubra

| # | API | O que faz | Status | Ideia no nosso jogo | Esforço | Requisitos / cuidados |
|---|---|---|---|---|---|---|
| 1 | **AnalyticsService** (`LogEconomyEvent`, `LogFunnelStepEvent`, `LogProgressionEvent`, `LogCustomEvent`) | Telemetria nativa no Creator Dashboard | estável | Moedas que entram (venda do saco) e saem (cortadores, Oficina). Funil: 1º corte → 1ª venda → 1ª compra → Fazenda liberada | baixo | Só no servidor. Limite de tipos de transação e de combinações de campos |
| 2 | **ConfigService / Experience configs** | Valores ao vivo, com segmentação e A/B | estável | Preço de venda, multiplicador do "Hora do Dobro" e frequência dos eventos sem publicar de novo. A/B do preço dos cortadores | baixo/médio | Só no servidor. A mudança leva ~5 min |
| 3 | **Input Action System** (`InputAction`, `InputBinding`, `InputContext`) | Entrada única para PC, celular e controle | lançado em 11/06/2026 | Ações "Cortar", "Trocar ferramenta", "Dirigir" com um mapeamento só. Um contexto separado para o veículo | médio | `InputAction:Fire` está deprecado |
| 4 | **CaptureService** | Screenshot e vídeo curto, salvar na galeria, compartilhar com convite | estável (usar `UserCaptureSaved`) | **Álbum:** foto automática ao achar um segredo da Floresta e botão "compartilhar" que leva o amigo ao segredo | médio | Só no cliente. Upload pede o questionário de maturidade |
| 5 | **SocialService:PromptGameInvite** + `ExperienceInviteOptions` | Convite com dados de entrada (LaunchData) | estável | Reforça o bônus de amigos: o convite leva o lote, e quem convida ganha um bônus | baixo | Checar `CanSendGameInviteAsync`. Validar o LaunchData no servidor |
| 6 | **ExperienceNotificationService** | Notificação para quem aceitou receber | estável | "Sua grama cresceu!", "Chuva Dourada começou!" | médio | Notificações personalizadas só para 13+. Mínimo de 100 visitas. 1 por dia. **O dono cria os modelos de texto no Dashboard** |
| 7 | **BadgeService** | Badges | estável | Ligar as 15 conquistas que já existem (`BadgeId=nil` hoje) | baixo | **O dono precisa criar os badges e passar os IDs** (5 grátis por dia) |
| 8 | **MemoryStoreService** + **MessagingService** | Dados globais rápidos e mensagens entre servidores | estável | Ranking semanal/do evento. Anúncio "evento em todos os servidores" | médio | Cotas por número de jogadores |
| 9 | **Streaming de modelos** (`ModelStreamingMode`, `ModelLevelOfDetail`) | Carrega e descarrega por distância, com versão leve de longe | estável | Lote do jogador `PersistentPerPlayer`; Fazenda e Floresta com LOD leve | médio | Os scripts do cliente precisam aceitar partes ausentes (o `GramaPackCliente` já aceita) |
| 10 | **EditableMesh + Batch APIs** | Malha editável em tempo de execução, com escrita em lote | Batch publicável desde 15/09/2026; EditableMesh em full release **não verificado** | Grama por pedaço: um mesh por chunk, cortar = baixar os vértices | alto | Ligar "Allow Mesh/Image APIs". Orçamento de memória do cliente. Possível exigência de verificação (não verificado) |
| 11 | **Global Wind** + grama decorativa do Terrain | Vento global move a grama do terreno, as nuvens e as partículas | estável | O evento "Vento" mexe em `workspace.GlobalWind`. Grama de fundo sem custo | baixo | O vento é global. A grama do terreno não é cortável |
| 12 | **Nova Audio API** (`AudioPlayer`, `AudioEmitter`, `AudioListener`, `AudioFader`, efeitos) | Áudio moderno com EQ, reverb e compressor | estável | Motor de cada cortador com pitch pela velocidade. Som abafado na chuva. Eco na gruta | médio | Precisa de um `AudioListener` |
| 13 | **HapticService / HapticEffect** | Vibração no celular e no controle | publicável (nomes finais **não verificados**) | Vibração leve a cada corte e forte ao encher o saco | baixo | Testar em aparelho real |
| 14 | **Subscriptions** + **MarketplaceService** | Assinatura mensal, passes e produtos | estável | "Clube do Jardineiro": bônus mensal e cosmético | baixo/médio | Mínimo 49 Robux. **O dono cria e passa os IDs**. Checar `IsEligibleToPurchaseSubscription` |
| 15 | **UI moderna** (`UIListLayout` com `UIFlexItem`, `UIDragDetector`) | Layout flexível e arrastar na interface | estável | HUD que se ajusta ao celular. Arrastar no crafting e no Álbum | baixo | Não existe "UIFlexLayout": o flex fica no `UIListLayout` |

**Também vale olhar:**
- **AdService** (vídeo recompensado): hoje está fora de alcance, porque exige 100 mil+ jogadores diários e só aparece para 13+.
- **Experience Events** (próximo evento com RSVP).
- **TextGenerator** (IA em tempo de execução, beta): só para falas curtas de NPC, por causa das regras de maturidade.
- **LocalizationService** (tradução automática) e **TextChatService**.

## Grama: o caminho de desempenho

1. **O servidor guarda só dados; o cliente desenha.** Já é assim nos lotes e na Fazenda com o `GramaPackCliente` (2026-11-13) e na Floresta com o `ForestGrassClient`.
2. **Tufos baratos:** mesma malha e textura, e `CanCollide`/`CanQuery`/`CanTouch`/`CastShadow` desligados. O `GramaPackCliente` já faz isso.
3. **Esconder em vez de destruir:** reaproveitar tufos e mover em lote com `workspace:BulkMoveTo`, sem criar e destruir a cada corte. **Melhoria futura** para o `GramaPackCliente`, que hoje troca o tufo por clone.
4. **Streaming + LOD** nos lotes e na Fazenda.
5. **Avançado:** EditableMesh por pedaço. Fazer um protótipo antes de migrar.
6. **Parallel Luau** (Actors) para o cálculo; as escritas voltam ao modo serial.

## Cuidados

- **Itens aleatórios pagos:** consultar `PolicyService:GetPolicyInfoForPlayerAsync().ArePaidRandomItemsRestricted` e mostrar as chances. No Brasil, o **ECA Digital (Lei 15.211/2025)** proíbe loot box paga acessível a menores (segundo análises jurídicas; não verifiquei como a Roblox aplica isso). **Recomendação:** ovos de pet e Oficina só com moeda ganha jogando, nunca com Robux direto ou indireto.
- **APIs deprecadas, evitar:** `CaptureService.CaptureSaved`, `InputAction:Fire`, `BodyVelocity`/`BodyGyro` (o jogo já usa `LinearVelocity` e `AlignOrientation`).
- **IDs:** badges, modelos de notificação, assinaturas, passes e produtos são criados **pelo dono** no Creator Dashboard. Não inventar.
- **Idade:** notificações personalizadas e anúncios só alcançam 13+. O jogo deve funcionar sem eles.

## Links oficiais

- AnalyticsService: https://create.roblox.com/docs/reference/engine/classes/AnalyticsService
- Configs: https://create.roblox.com/docs/production/configs
- Input Action System: https://create.roblox.com/docs/input/input-action-system
- CaptureService: https://create.roblox.com/docs/reference/engine/classes/CaptureService
- Convites: https://create.roblox.com/docs/production/promotion/invite-prompts
- Notificações: https://create.roblox.com/docs/production/promotion/experience-notifications
- Badges: https://create.roblox.com/docs/production/publishing/badges
- MemoryStore: https://create.roblox.com/docs/cloud-services/memory-stores
- Streaming: https://create.roblox.com/docs/workspace/streaming
- EditableMesh e Batch: https://devforum.roblox.com/t/full-release-editablemesh-batching-apis-parallel-queries/4779401
- Global Wind: https://create.roblox.com/docs/environment/global-wind
- Audio API: https://devforum.roblox.com/t/roblox-audio-api-exits-beta-enhanced-sound-controls-now-available/3153454
- Haptics: https://devforum.roblox.com/t/full-release-you-can-now-publish-haptic-effects-in-your-experience/3660577
- Subscriptions: https://create.roblox.com/docs/production/monetization/subscriptions
- Flex na UI: https://create.roblox.com/docs/ui/list-flex-layouts
- AdService: https://create.roblox.com/docs/reference/engine/classes/AdService
- Experience Events: https://create.roblox.com/docs/production/promotion/experience-events
- TextGenerator: https://create.roblox.com/docs/reference/engine/classes/TextGenerator
