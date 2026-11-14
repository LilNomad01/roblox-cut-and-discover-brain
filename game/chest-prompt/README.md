# Prompt de segredo coletado — por jogador

**Data:** 2026-11-10 · **IA:** Claude · **Place:** `106412085364108`

## Problema

Depois que o jogador abria um baú ou artefato da floresta, o prompt "Abrir baú / Tesouro escondido" continuava aparecendo para ele. A recompensa já era única (`secret.claimed[UserId]` / `Commerce.wasClaimed`), mas o prompt é uma instância compartilhada, então o servidor não podia desligá-lo só para um jogador.

## Solução

| Onde | Mudança |
|---|---|
| `ServerScriptService.CorteEDescubra.GameServer` (cópia em `game/forest-economy/integration/…GameServer.luau`) | Novo `forestMarkClaimed(player,id)`, que acrescenta o id a `Player:GetAttribute("ForestClaimedSecrets")` (CSV). Cada prompt de segredo recebe o atributo `ForestSecretId`. A marcação acontece na coleta e também quando o jogador tenta reabrir um segredo já coletado. **Regras de recompensa inalteradas.** |
| `StarterPlayer.StarterPlayerScripts.ForestSecretPromptClient` (novo, `ForestSecretPromptClient.client.luau`) | Quando um prompt aparece (`PromptShown`) ou a lista muda, desliga localmente (`Enabled=false`) os prompts com `ForestSecretId` já coletado. Sem varrer o Workspace. |

O gnomo Nilo não passa por esse caminho (retorna antes), então o prompt dele continua igual.

## Rollback

Backup do servidor: `ServerStorage.GameServerBeforeChestPromptFix_20261110` (desativado). Para desfazer, copie o `Source` dele de volta para `CorteEDescubra.GameServer` e apague `ForestSecretPromptClient`.

## Teste

Ver `evidence/p0-playtest-2026-11-10/VALIDACAO.md`, seção "Correção do prompt".
