# APIs extras (fase 2 do pedido "implemente todas as APIs")

**Data:** 2026-11-14 · **IA:** Claude · **Place:** `106412085364108` · Pesquisa: [brain/22](../../brain/22_APIS_ROBLOX_RECOMENDADAS.md)

## Situação de cada API da pesquisa

| # | API | Situação | Onde |
|---|---|---|---|
| 1 | AnalyticsService | ✅ economia, funil de onboarding, nível, compras | `game/shop/Analytics.luau` + Economia + LojaServidor |
| 2 | ConfigService | ✅ `preco_grama_mult` e `loja_boost_minutos` ao vivo (sem a chave, vale o padrão) | `game/shop/LiveConfig.luau` |
| 3 | Input Action System | ✅ atalhos **L** (abre/fecha a loja Premium) e **B** (vender de qualquer lugar, com o passe) | `LojaCliente` (InputContext "AtalhosLoja") |
| 4 | CaptureService | ✅ foto automática ao achar um segredo, com "Salvar na galeria" e "Compartilhar" (o convite leva ao jogo) | `ApisExtrasCliente` |
| 5 | SocialService + ExperienceInviteOptions | ✅ o convite leva `LaunchData = "convite:<id>"`; quem entra e quem convidou recebem aviso | `AmigosCliente` (patch) + `ApisExtrasServidor` |
| 6 | ExperienceNotificationService | ✅ pede permissão (opt-in) **uma vez**, depois de 5 min e de uma venda. **O envio** dos avisos é configurado pelo dono no Creator Dashboard (modelos de texto) | `ApisExtrasCliente` |
| 7 | BadgeService | ⏳ já existia (15 conquistas). Faltam **os IDs dos badges**, criados pelo dono | `EstatisticasServidor` |
| 8 | MemoryStoreService + MessagingService | ✅ contador global "tufos cortados hoje no mundo" (placa no Quadro de Ranking) e anúncios para **todos os servidores** (ex.: alguém chocou um ajudante Celestial ou Divino) | `ApisExtrasServidor` |
| 9 | Streaming | ✅ já estava ligado (`StreamingEnabled=true`). A grama nova (`GramaPackCliente`) aceita quadrados que entram e saem | — |
| 10 | EditableMesh + Batch | ❌ **não feito.** Exige protótipo, a opção "Allow Mesh/Image APIs" e talvez verificação. Fica como próximo passo de desempenho da grama | — |
| 11 | GlobalWind | ✅ brisa leve sempre; vento forte no evento "Vento" e médio na "Chuva" | `ApisExtrasServidor` |
| 12 | Nova Audio API | ❌ **não feito.** Precisa de IDs de áudio, que o projeto não tem (`Sons` está sem IDs). Não inventei assets | — |
| 13 | HapticService / HapticEffect | ✅ vibração leve ao encher o saco e forte quando lota; respeita a opção "Vibração" | `ApisExtrasCliente` |
| 14 | Subscriptions + MarketplaceService | ✅ loja Premium completa + assinatura "Clube do Jardineiro" (+25% de grama). **Os IDs são criados pelo dono** | `game/shop/` |
| 15 | UI moderna (flex) | ➖ o HUD já é responsivo (HudKit, com escala). Não precisou | — |
| — | PolicyService | ✅ ovo pago some para jogadores restritos | `LojaServidor` |
| — | TextChatService | ✅ etiqueta [VIP] no chat | `LojaCliente` |

## Arquivos

- `ApisExtrasServidor.server.luau` → `ServerScriptService.CorteEDescubra.ApisExtrasServidor`. Outros scripts podem anunciar para todos os servidores com `ApisExtrasServidor.Anunciar:Fire("texto")`.
- `ApisExtrasCliente.client.luau` → `StarterPlayerScripts.ApisExtrasCliente`.
- **Patch** em `AmigosCliente` (convite com `ExperienceInviteOptions`). Backup em `ServerStorage.LojaBackup_20261114`.
