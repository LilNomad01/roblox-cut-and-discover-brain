# Persistência — dados do jogador salvos (P0-07)

**Data:** 2026-11-11 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** começar pela persistência, primeiro passo da proposta em `brain/19`.

**Backup:** `ServerStorage.PersistenciaBackup_20261111` (Profiles, ProfileData, GameServer, Economia, GameConfig, ForestCommerceService, SkillService).

## O que já existia (Codex)

Um sistema completo, mas **desligado** (`GameConfig.PersistenceEnabled=false`):

- `Profiles`: DataStore `CorteEDescubra_v1` com trava de sessão de 180 s, renovada a cada salvamento; 3 tentativas com espera crescente; recusa sobrescrever dados inválidos; expulsa o jogador se um salvamento intermediário falhar.
- `ProfileData`/`Rules`: esquema versão 2 com migração da versão 1, validação de cada campo, `Economy` (moedas, nível, XP, cortadores), `SkillData` (PH e habilidades) e `ForestEconomy` (mochila, equipamentos, kits, flores, cogumelos, mapas, segredos coletados, gnomo, contrato).
- `GameServer`: carrega ao entrar; salva a cada 45 s, ao sair e no `BindToClose`.

## O que mudou

| Arquivo | Mudança |
|---|---|
| `Shared.GameConfig` | `PersistenceEnabled = true`. |
| `CorteEDescubra.Profiles` (cópia completa: `Profiles.luau`) | Detalhes abaixo. |
| `CorteEDescubra.ProfileData` | `Saco` entra no salvamento (opcional e validado). |
| `ServerScriptService.Economia` | `Iniciar` restaura o saco em vez de zerar. |
| `CorteEDescubra.GameServer` | Depois do `Commerce.attach`: limita o saco à capacidade e restaura `ForestClaimedSecrets` e `ForestSecrets` a partir do perfil. O `BindToClose` espera os salvamentos finais. |
| `ForestCommerceService`, `SkillService` | O aviso "temporário" das telas também liga quando o perfil está em modo temporário. |

Mudanças em `Profiles`:

- **No Studio**, usa o DataStore `CorteEDescubra_v1_Studio`, para os testes não tocarem os dados dos jogadores.
- **No Studio sem acesso às APIs**, cria um perfil temporário com aviso no console, em vez de expulsar o jogador.
- **Espera pela trava:** até ~24 s quando outro servidor ainda segura a sessão (troca rápida de servidor).
- **Studio assume sessão antiga:** só no store `_Studio`, para um teste interrompido não travar o próximo.
- **Conta os salvamentos finais em andamento** (`Profiles.pendentes()`), para o servidor esperar antes de fechar.

### Bug corrigido: perda de dados ao fechar o servidor

**Antes:** quando o servidor fecha, o jogador sai primeiro (`PlayerRemoving`) e o salvamento final dele começa. O `BindToClose` só esperava os jogadores que ainda estavam na lista de lotes, então o servidor fechava antes de a gravação terminar. **Efeito:** perder o progresso desde o último salvamento automático (até 45 s), com o perfil travado por até 3 minutos.

**Agora:** o `BindToClose` espera `Profiles.pendentes()` chegar a 0, por até 25 s.

### Trechos (fora do `Profiles`)

`ProfileData`:

```lua
        or type(d.Comprados)~="string" or #d.Comprados>128 or type(d.Cortador)~="string"
        or (d.Saco~=nil and not integer(d.Saco,1000000000)) then return false end -- [Claude 2026-11-11] saco opcional
...
        for _,key in ipairs({"Moedas","Nivel","XP","Comprados","Cortador","Saco"}) do -- [Claude 2026-11-11] + conteúdo do saco
```

`Economia.Iniciar`:

```lua
	-- [Claude 2026-11-11] o conteúdo do saco volta do perfil (o GameServer limita à capacidade depois das mochilas)
	local saco = tonumber(d.Saco) or 0
	p:SetAttribute("Saco", math.max(0, math.floor(saco)))
```

`GameServer`, ao entrar, depois do `Commerce.attach(player)`:

```lua
    player:SetAttribute("Saco",math.min(player:GetAttribute("Saco") or 0,player:GetAttribute("SacoMax") or 0))
    do
        local fe=profile.ForestEconomy
        if fe and type(fe.claimed)=="table" then
            local ids={} for id in pairs(fe.claimed) do table.insert(ids,id) end
            table.sort(ids)
            player:SetAttribute("ForestClaimedSecrets",table.concat(ids,","))
            player:SetAttribute("ForestSecrets",#ids)
        end
    end
```

`GameServer`, no `BindToClose`, depois da espera existente:

```lua
    -- [Claude 2026-11-11] espera também os salvamentos finais disparados pelo PlayerRemoving
    while Profiles.pendentes()>0 and os.clock()<deadline do task.wait(.1) end
```

## O que é salvo / o que não é

**Salvo:**
- moedas, nível, XP, cortadores comprados e equipado;
- **conteúdo do saco**;
- PH e habilidades;
- mochila e equipamentos da floresta (lanterna, bússola, marcador), kits, flores, cogumelos e mapas;
- segredos coletados;
- gnomo, contrato e caçamba restaurada.

**Não salvo, de propósito:**
- o progresso do jardim em andamento (o serviço recomeça ao entrar);
- a posição no mapa;
- a ferramenta equipada.

## Requisito no Studio

Para testar o salvamento no Studio, a opção **Game Settings → Security → Enable Studio Access to API Services** precisa estar ligada. O usuário ligou em 2026-11-11.
